#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <CoreLocation/CoreLocation.h>
#import "DYYYUtils.h"

#define DYYYBottomAlertView_DEFINED
#define DYYYToast_DEFINED
#define DYYYFilterSettingsView_DEFINED
#define DYYYUtils_DEFINED
#define DYYYConfirmCloseView_DEFINED
#define DYYYKeywordListView_DEFINED
#define DYYYCustomInputView_DEFINED

#import "AwemeHeaders.h"
#import "DYYYCityManager.h"
#import "DYYYManager.h"
#import "DYYYSettingViewController.h"

#import "DYYYToast.h"
#import "DYYYBottomAlertView.h"
#import "DYYYConfirmCloseView.h"
#import "DYYYFloatSpeedButton.h"
// ============================================================
//  DYYYSpeedHUDHelper — 倍速 HUD 视图工具
//  用于长按滑动手势过程中显示当前选中的倍速档位
// ============================================================

// ── 倍速 HUD（底部文字提示） ──────────────────────────────────
// 手势滑动期间在屏幕底部中央显示 "下滑松手锁定 X.Xx 倍速"
extern NSArray *findViewControllersInHierarchy(UIViewController *rootViewController);

static UIView *dyyySpeedHUDView  = nil;
static UILabel* dyyySpeedHUDLabel = nil;

// 仅隐藏 AWEPlayInteractionViewController.view 下的 overlay UI，不触碰视频播放视图。
// 通过 findViewControllersInHierarchy 定位当前播放界面控制器，再遍历其 view 的子视图。
// 跳过的类：播放器相关（Video/Metal/Player）、DYYY 自建视图、AWEPlayInteractionViewController 自身。
static BOOL dyyyIsProtectedClass(NSString *cls) {
    if ([cls containsString:@"DYYY"]) return YES;
    if ([cls containsString:@"Video"] || [cls containsString:@"video"]) return YES;
    if ([cls containsString:@"Metal"] || [cls containsString:@"TTMetal"]) return YES;
    if ([cls containsString:@"Player"] || [cls containsString:@"player"]) return YES;
    if ([cls containsString:@"Media"] || [cls containsString:@"media"]) return YES;
    if ([cls isEqualToString:@"AWEPlayInteractionViewController"]) return YES;
    return NO;
}

static void dyyyHidePlayInterfaceUI(void) {
    UIWindow *window = [DYYYManager getActiveWindow];
    if (!window) return;
    UIViewController *rootVC = window.rootViewController;
    while (rootVC.presentedViewController) rootVC = rootVC.presentedViewController;
    NSArray *vcs = findViewControllersInHierarchy(rootVC);
    for (UIViewController *vc in vcs) {
        if (![vc isKindOfClass:NSClassFromString(@"AWEPlayInteractionViewController")]) continue;
        UIView *view = vc.view;
        if (!view) continue;
        for (UIView *sub in view.subviews) {
            NSString *cls = NSStringFromClass([sub class]);
            if (dyyyIsProtectedClass(cls)) continue;
            sub.hidden = YES;
        }
    }
}

static void dyyyShowPlayInterfaceUI(void) {
    UIWindow *window = [DYYYManager getActiveWindow];
    if (!window) return;
    UIViewController *rootVC = window.rootViewController;
    while (rootVC.presentedViewController) rootVC = rootVC.presentedViewController;
    NSArray *vcs = findViewControllersInHierarchy(rootVC);
    for (UIViewController *vc in vcs) {
        if (![vc isKindOfClass:NSClassFromString(@"AWEPlayInteractionViewController")]) continue;
        UIView *view = vc.view;
        if (!view) continue;
        for (UIView *sub in view.subviews) {
            sub.hidden = NO;
        }
    }
}

static void dyyyUpdateSpeedHUD(CGFloat currentSpeed) {
    UIWindow *window = [DYYYManager getActiveWindow];
    if (!window) return;

    CGFloat screenWidth  = window.bounds.size.width;
    CGFloat screenHeight = window.bounds.size.height;
    CGFloat hudHeight    = 48.0;
    CGFloat hudWidth     = 200.0;
    CGFloat hudY         = screenHeight - hudHeight - 100.0;

    if (!dyyySpeedHUDView) {
        dyyySpeedHUDView  = [[UIView alloc] init];
        dyyySpeedHUDView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.72];
        dyyySpeedHUDView.layer.cornerRadius = hudHeight / 2.0;
        dyyySpeedHUDView.clipsToBounds = YES;
        dyyySpeedHUDView.alpha = 0.0;
        dyyySpeedHUDView.hidden = YES;
        [window addSubview:dyyySpeedHUDView];
    }

    if (!dyyySpeedHUDLabel) {
        dyyySpeedHUDLabel = [[UILabel alloc] init];
        dyyySpeedHUDLabel.textColor = [UIColor whiteColor];
        dyyySpeedHUDLabel.backgroundColor = [UIColor clearColor];
        dyyySpeedHUDLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        dyyySpeedHUDLabel.textAlignment = NSTextAlignmentCenter;
        dyyySpeedHUDLabel.adjustsFontSizeToFitWidth = YES;
        dyyySpeedHUDLabel.minimumScaleFactor = 0.6;
        // 必须显式设置 frame，否则默认 (0,0,0,0) 导致文字不可见
        dyyySpeedHUDLabel.frame = CGRectMake(0, 0, hudWidth, hudHeight);
        [dyyySpeedHUDView addSubview:dyyySpeedHUDLabel];
    }

    // 格式："下滑松手锁定 X.Xx 倍速"
    NSString *speedText = [NSString stringWithFormat:@"下滑松手锁定 %.1fx 倍速", currentSpeed];
    dyyySpeedHUDLabel.text = speedText;

    CGSize textSize = [speedText sizeWithAttributes:@{NSFontAttributeName: dyyySpeedHUDLabel.font}];
    hudWidth = MAX(hudWidth, textSize.width + 40.0);
    CGFloat hudX = (screenWidth - hudWidth) / 2.0;
    dyyySpeedHUDView.frame = CGRectMake(hudX, hudY, hudWidth, hudHeight);

    // 更新 label frame 填满 HUD，保证文字居中可见
    dyyySpeedHUDLabel.frame = CGRectMake(0, 0, hudWidth, hudHeight);

    dyyySpeedHUDView.hidden = NO;
    dyyySpeedHUDView.alpha  = 1.0;
    dyyySpeedHUDLabel.alpha = 1.0;
    // 强制布局刷新，确保文字立即渲染
    [dyyySpeedHUDLabel setNeedsLayout];
    [dyyySpeedHUDLabel layoutIfNeeded];
}

static void dyyyHideSpeedHUD(void) {
    if (!dyyySpeedHUDView) return;
    [UIView animateWithDuration:0.2 animations:^{
        dyyySpeedHUDView.alpha  = 0.0;
        dyyySpeedHUDLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        dyyySpeedHUDView.hidden = YES;
    }];
}



// 函数声明（DYYYFloatSpeedButton.h 未导出）

// tabHeight 变量声明
static CGFloat tabHeight = 0;
static CGFloat originalTabHeight = 0;

// 评论视图可见性变量
extern BOOL dyyyCommentViewVisible;

// 函数声明
extern void updateSpeedButtonVisibility(void);
extern void updateClearButtonVisibility(void);
extern void reloadClearButtonConfiguration(void);

// 获取标签栏高度的函数
static CGFloat getTabBarHeight(void) {
    static CGFloat cachedHeight = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWindow *keyWindow = nil;
        if (@available(iOS 13.0, *)) {
            NSSet *connectedScenes = [UIApplication sharedApplication].connectedScenes;
            for (UIScene *scene in connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
                    for (UIWindow *window in windowScene.windows) {
                        if (window.isKeyWindow) {
                            keyWindow = window;
                            break;
                        }
                    }
                    if (keyWindow) break;
                }
            }
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            keyWindow = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
        }
        
        if (@available(iOS 11.0, *)) {
            cachedHeight = keyWindow.safeAreaInsets.bottom;
        }
        if (cachedHeight == 0) {
            cachedHeight = 49.0; // 默认标签栏高度
        }
        
        tabHeight = cachedHeight;
    });
    return cachedHeight;
}

// 初始化函数
static void initializeTabHeight(void) __attribute__((constructor));
static void initializeTabHeight(void) {
    tabHeight = getTabBarHeight();
}

@interface AWEPlayInteractionElementMaskView : UIView
@end

@interface AWEGradientView : UIView
@end

@interface AWEHotSearchInnerBottomView : UIView
@end

@interface AWEHotSpotBlurView : UIView
@end

@interface AWECodeGenCommonAnchorBasicInfoModel : NSObject
@property (nonatomic, copy) NSString *name;
@end

@interface AWEProfileMixItemCollectionViewCell : UIView
@property (nonatomic, copy) NSString *accessibilityLabel;
@end

@interface AWEFeedPauseRelatedWordComponent : NSObject
@property (nonatomic, strong) UIView *relatedView;
- (id)updateViewWithModel:(id)arg0;
- (id)pauseContentWithModel:(id)arg0;
- (id)recommendsWords;
- (void)showRelatedRecommendPanelControllerWithSelectedText:(id)arg0;
- (void)setupUI;
@end

@interface AWEPlayInteractionUserAvatarView : UIView
@end

@interface AWELiveAutoEnterStyleAView : UIView
@end

@interface DYYYCityManager (DYYYExt)
- (NSString *)generateRandomFourLevelAddressForCityCode:(NSString *)cityCode;
@end

#define DYYYMediaTypeVideo MediaTypeVideo
#define DYYYMediaTypeImage MediaTypeImage
#define DYYYMediaTypeAudio MediaTypeAudio
#define DYYYMediaTypeHeic MediaTypeHeic

@interface AWEIMReusableCommonCell : UIView
@property (nonatomic, strong) id currentContext;
@end

@interface AWEIMMessageComponentContext : NSObject
@property (nonatomic, strong) id message;
@end

@interface AWEIMGiphyMessage : NSObject
@property (nonatomic, strong) AWEURLModel *giphyURL;
@end

@interface AWEIMCustomMenuModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *trackerName;
@property (nonatomic, copy) void (^willPerformMenuActionSelectorBlock)(id);
@end

// 前向声明：倍速管理所需类型
@interface AWEPlayInteractionSpeedController : NSObject
- (id)playVideoViewController;
- (void)changeSpeed:(double)speed;
@end

@interface AWEPlayInteractionViewController (DYYYSpeedAccess)
@property(nonatomic, strong) AWEAwemeModel *model;
- (id)awemeModel;
- (void)onPlayer:(id)arg0 didDoubleClick:(id)arg1;
- (id)controllerByProtocol:(Protocol *)protocol;
- (id)videoDelegate;
@end

// ============================================================
// 倍速管理基础设施（移植自 DYYY12345/DYYY.xm:211-620）
// 适配说明：
//   - [DYYYUtils getActiveWindow] → [DYYYManager getActiveWindow]
//   - isFloatSpeedButtonEnabled → DYYYGetBool(@"DYYYEnableFloatSpeedButton")
//   - [DYYYFloatingSpeedButton reloadConfiguration] → 跳过（当前项目无此方法）
//   - [speedButton resetFadeTimer] → 跳过（当前项目无此方法）
//   - setCurrentSpeedValue → 本地定义 DYYYSetCurrentSpeedValue
//   - dyyyInteractionViewVisible → 本地 static 变量
// ============================================================

static BOOL DYYYShouldHandleSpeedFeatures(void) {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFloatSpeedButton"]) {
        return YES;
    }

    float defaultSpeed = [[NSUserDefaults standardUserDefaults] floatForKey:@"DYYYDefaultSpeed"];
    if (defaultSpeed <= 0.0f) {
        return NO;
    }

    return fabsf(defaultSpeed - 1.0f) > FLT_EPSILON;
}

static __weak AWEPlayInteractionViewController *dyyyActiveSpeedInteractionController = nil;
static __weak AWEAwemeModel *dyyyCurrentSpeedAweme = nil;
static NSString *dyyyLastAutoRestoredSpeedAwemeIdentifier = nil;
static BOOL dyyyLongPressFastSpeedActive = NO;
static BOOL dyyyLongPressLockedSpeedActive = NO;
static BOOL dyyyInteractionViewVisible = NO;

static void DYYYClearLongPressSpeedState(void) {
    dyyyLongPressFastSpeedActive = NO;
    dyyyLongPressLockedSpeedActive = NO;
}

static CGFloat DYYYViewControllerVisibilityScore(UIViewController *viewController) {
    if (!viewController || !viewController.isViewLoaded) {
        return -1.0;
    }

    UIView *view = viewController.view;
    UIWindow *window = view.window;
    if (!window || view.hidden || view.alpha <= 0.01 || CGRectIsEmpty(view.bounds)) {
        return -1.0;
    }

    CGRect frameInWindow = [view convertRect:view.bounds toView:window];
    CGRect visibleFrame = CGRectIntersection(frameInWindow, window.bounds);
    if (CGRectIsNull(visibleFrame) || CGRectIsEmpty(visibleFrame)) {
        return -1.0;
    }

    CGFloat visibleArea = CGRectGetWidth(visibleFrame) * CGRectGetHeight(visibleFrame);
    CGFloat totalArea = CGRectGetWidth(frameInWindow) * CGRectGetHeight(frameInWindow);
    CGFloat visibleRatio = totalArea > 0.0 ? visibleArea / totalArea : 0.0;
    CGPoint windowCenter = CGPointMake(CGRectGetMidX(window.bounds), CGRectGetMidY(window.bounds));
    CGFloat centerBonus = CGRectContainsPoint(visibleFrame, windowCenter) ? 1000000000.0 : 0.0;
    return centerBonus + visibleRatio * 1000000.0 + visibleArea;
}

static BOOL DYYYAwemeModelsMatch(AWEAwemeModel *lhs, AWEAwemeModel *rhs) {
    if (!lhs || !rhs) {
        return NO;
    }
    if (lhs == rhs) {
        return YES;
    }

    NSString *lhsItemID = lhs.itemID;
    NSString *rhsItemID = rhs.itemID;
    return lhsItemID.length > 0 && rhsItemID.length > 0 && [lhsItemID isEqualToString:rhsItemID];
}

static NSString *DYYYSpeedAwemeIdentifier(AWEAwemeModel *aweme) {
    if (!aweme) {
        return nil;
    }
    if (aweme.itemID.length > 0) {
        return aweme.itemID;
    }
    return [NSString stringWithFormat:@"%p", aweme];
}

static AWEAwemeModel *DYYYSpeedAwemeFromObject(id object) {
    Class awemeClass = NSClassFromString(@"AWEAwemeModel");
    if (!object || !awemeClass) {
        return nil;
    }
    if ([object isKindOfClass:awemeClass]) {
        return (AWEAwemeModel *)object;
    }

    for (NSString *key in @[ @"model", @"awemeModel", @"currentAweme" ]) {
        @try {
            id value = [object valueForKey:key];
            if ([value isKindOfClass:awemeClass]) {
                return (AWEAwemeModel *)value;
            }
        } @catch (NSException *exception) {
        }
    }
    return nil;
}

static double DYYYDefaultPlaybackSpeed(void) {
    double defaultSpeed = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DYYYDefaultSpeed"];
    if (isfinite(defaultSpeed) && defaultSpeed > 0.0) {
        return defaultSpeed;
    }
    return 1.0;
}

// 本地替代 setCurrentSpeedValue（当前项目 DYYYFloatSpeedButton.xm 未实现此函数）
static BOOL DYYYSetCurrentSpeedValue(float speed) {
    if (!isfinite(speed) || speed <= 0.0f) {
        return NO;
    }

    NSArray *speeds = getSpeedOptions();
    for (NSInteger index = 0; index < speeds.count; index++) {
        if (fabs([speeds[index] floatValue] - speed) < 0.01f) {
            setCurrentSpeedIndex(index);
            return YES;
        }
    }
    return NO;
}

static void DYYYRestoreFloatSpeedButtonForAwemeIfNeeded(AWEAwemeModel *aweme) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL shouldAutoRestore = [defaults boolForKey:@"DYYYEnableFloatSpeedButton"] && [defaults boolForKey:@"DYYYAutoRestoreSpeed"];
    if (!shouldAutoRestore) {
        dyyyLastAutoRestoredSpeedAwemeIdentifier = nil;
        return;
    }

    NSString *awemeIdentifier = DYYYSpeedAwemeIdentifier(aweme);
    if (awemeIdentifier.length == 0 || [awemeIdentifier isEqualToString:dyyyLastAutoRestoredSpeedAwemeIdentifier]) {
        return;
    }

    dyyyLastAutoRestoredSpeedAwemeIdentifier = [awemeIdentifier copy];
    if (!DYYYSetCurrentSpeedValue((float)DYYYDefaultPlaybackSpeed())) {
        setCurrentSpeedIndex(0);
    }
    updateSpeedButtonUI();
}

static NSArray<AWEPlayInteractionViewController *> *DYYYSpeedInteractionControllers(AWEPlayInteractionViewController *preferredController) {
    NSMutableArray<AWEPlayInteractionViewController *> *controllers = [NSMutableArray array];
    Class interactionControllerClass = NSClassFromString(@"AWEPlayInteractionViewController");
    UIWindow *window = [DYYYManager getActiveWindow];
    UIViewController *rootViewController = window.rootViewController;
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }

    for (UIViewController *viewController in rootViewController ? findViewControllersInHierarchy(rootViewController) : @[]) {
        if (interactionControllerClass && [viewController isKindOfClass:interactionControllerClass]) {
            [controllers addObject:(AWEPlayInteractionViewController *)viewController];
        }
    }

    if (preferredController && ![controllers containsObject:preferredController]) {
        [controllers addObject:preferredController];
    }
    return controllers;
}

static AWEPlayInteractionViewController *DYYYResolveSpeedInteractionController(AWEPlayInteractionViewController *preferredController, AWEAwemeModel *targetAweme, BOOL allowVisibleFallback) {
    AWEPlayInteractionViewController *bestModelMatch = nil;
    AWEPlayInteractionViewController *bestVisibleController = nil;
    CGFloat bestModelMatchScore = -1.0;
    CGFloat bestVisibleScore = -1.0;

    for (AWEPlayInteractionViewController *controller in DYYYSpeedInteractionControllers(preferredController)) {
        CGFloat visibilityScore = DYYYViewControllerVisibilityScore(controller);
        if (visibilityScore < 0.0) {
            continue;
        }

        if (visibilityScore > bestVisibleScore) {
            bestVisibleScore = visibilityScore;
            bestVisibleController = controller;
        }
        if (targetAweme && DYYYAwemeModelsMatch(controller.model, targetAweme) && visibilityScore > bestModelMatchScore) {
            bestModelMatchScore = visibilityScore;
            bestModelMatch = controller;
        }
    }

    return bestModelMatch ?: (allowVisibleFallback ? bestVisibleController : nil);
}

static AWEPlayInteractionViewController *DYYYResolveCurrentSpeedInteractionController(AWEPlayInteractionViewController *preferredController) {
    return DYYYResolveSpeedInteractionController(preferredController, dyyyCurrentSpeedAweme, YES);
}

id DYYYCurrentSpeedInteractionController(void) {
    return DYYYResolveCurrentSpeedInteractionController(dyyyActiveSpeedInteractionController);
}

static void DYYYEnsureFloatSpeedButton(AWEPlayInteractionViewController *interactionController) {
    // [DYYYFloatingSpeedButton reloadConfiguration] — 当前项目无此方法，跳过

    AWEAwemeModel *targetAweme = dyyyCurrentSpeedAweme;
    BOOL allowVisibleFallback = !targetAweme || (interactionController && DYYYAwemeModelsMatch(interactionController.model, targetAweme));
    AWEPlayInteractionViewController *currentController = DYYYResolveSpeedInteractionController(interactionController, targetAweme, allowVisibleFallback);
    if (!currentController) {
        updateSpeedButtonVisibility();
        return;
    }

    if ((dyyyLongPressFastSpeedActive || dyyyLongPressLockedSpeedActive) &&
        currentController.model &&
        !DYYYAwemeModelsMatch(dyyyCurrentSpeedAweme, currentController.model)) {
        DYYYClearLongPressSpeedState();
    }

    dyyyActiveSpeedInteractionController = currentController;
    dyyyCurrentSpeedAweme = currentController.model;
    dyyyInteractionViewVisible = YES;

    if (!DYYYGetBool(@"DYYYEnableFloatSpeedButton")) {
        updateSpeedButtonVisibility();
        return;
    }

    UIWindow *keyWindow = [DYYYManager getActiveWindow];
    if (!keyWindow) {
        return;
    }

    DYYYRestoreFloatSpeedButtonForAwemeIfNeeded(currentController.model);

    if (!speedButton) {
        CGFloat btnSize = [[NSUserDefaults standardUserDefaults] floatForKey:@"DYYYSpeedButtonSize"];
        if (btnSize <= 0) {
            btnSize = 32.0;
        }
        CGRect windowBounds = keyWindow.bounds;
        CGRect initialFrame = CGRectMake((windowBounds.size.width - btnSize) / 2.0, (windowBounds.size.height - btnSize) / 2.0, btnSize, btnSize);
        speedButton = [[DYYYFloatingSpeedButton alloc] initWithFrame:initialFrame];
        speedButton.interactionController = currentController;
        updateSpeedButtonUI();
    } else if (speedButton.interactionController != currentController) {
        speedButton.interactionController = currentController;
        [speedButton resetButtonState];
    }

    if (![speedButton isDescendantOfView:keyWindow]) {
        [keyWindow addSubview:speedButton];
        [speedButton loadSavedPosition];
        // [speedButton resetFadeTimer] — 当前项目无此方法，跳过
    }

    [keyWindow bringSubviewToFront:speedButton];
    updateSpeedButtonVisibility();
}

// 提供给跨文件调用的刷新入口
void DYYYRefreshFloatSpeedButton(void) {
    void (^applyBlock)(void) = ^{
        AWEPlayInteractionViewController *currentController = (AWEPlayInteractionViewController *)DYYYCurrentSpeedInteractionController();
        DYYYEnsureFloatSpeedButton(currentController);
    };
    if ([NSThread isMainThread]) {
        applyBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), applyBlock);
    }
}

static BOOL DYYYSetPlaybackRateOnTarget(id target, double speed) {
    if (!target || ![target respondsToSelector:@selector(setVideoControllerPlaybackRate:)]) {
        return NO;
    }

    @try {
        [(AWEAwemePlayVideoViewController *)target setVideoControllerPlaybackRate:speed];
        return YES;
    } @catch (NSException *exception) {
        return NO;
    }
}

static BOOL DYYYApplyPlaybackSpeed(AWEPlayInteractionViewController *interactionController, double speed) {
    interactionController = DYYYResolveCurrentSpeedInteractionController(interactionController);
    if (!interactionController) {
        return NO;
    }

    Protocol *speedControllerProtocol = NSProtocolFromString(@"AWEFastSpeedControllerProtocol");
    if (speedControllerProtocol && [interactionController respondsToSelector:@selector(controllerByProtocol:)]) {
        @try {
            id speedController = [interactionController controllerByProtocol:speedControllerProtocol];
            if ([speedController respondsToSelector:@selector(playVideoViewController)]) {
                id playVideoViewController = [(AWEPlayInteractionSpeedController *)speedController playVideoViewController];
                if (DYYYSetPlaybackRateOnTarget(playVideoViewController, speed)) {
                    return YES;
                }
            }
        } @catch (NSException *exception) {
        }
    }

    if ([interactionController respondsToSelector:@selector(videoDelegate)] && DYYYSetPlaybackRateOnTarget([interactionController videoDelegate], speed)) {
        return YES;
    }

    UIWindow *window = [DYYYManager getActiveWindow];
    UIViewController *rootViewController = window.rootViewController;
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }

    UIViewController *bestPlayerViewController = nil;
    CGFloat bestPlayerVisibilityScore = -1.0;
    for (UIViewController *viewController in rootViewController ? findViewControllersInHierarchy(rootViewController) : @[]) {
        if ([viewController isKindOfClass:NSClassFromString(@"AWEAwemePlayVideoViewController")] ||
            [viewController isKindOfClass:NSClassFromString(@"AWEDPlayerFeedPlayerViewController")] ||
            [viewController isKindOfClass:NSClassFromString(@"AWEDPlayerViewController_Merge")]) {
            CGFloat visibilityScore = DYYYViewControllerVisibilityScore(viewController);
            if (visibilityScore > bestPlayerVisibilityScore) {
                bestPlayerVisibilityScore = visibilityScore;
                bestPlayerViewController = viewController;
            }
        }
    }

    return DYYYSetPlaybackRateOnTarget(bestPlayerViewController, speed);
}

static double DYYYConfiguredPlaybackSpeed(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"DYYYEnableFloatSpeedButton"]) {
        return getCurrentSpeed();
    }

    if ([defaults boolForKey:@"DYYYUserAgreementAccepted"]) {
        return DYYYDefaultPlaybackSpeed();
    }
    return 1.0;
}

static BOOL DYYYShouldPrepareDefaultPlaybackSpeedForPlayer(id playerViewController) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"DYYYEnableFloatSpeedButton"] || ![defaults boolForKey:@"DYYYAutoRestoreSpeed"]) {
        return NO;
    }

    AWEAwemeModel *targetAweme = DYYYSpeedAwemeFromObject(playerViewController) ?: dyyyCurrentSpeedAweme;
    NSString *awemeIdentifier = DYYYSpeedAwemeIdentifier(targetAweme);
    return awemeIdentifier.length > 0 && ![awemeIdentifier isEqualToString:dyyyLastAutoRestoredSpeedAwemeIdentifier];
}

static double DYYYPreparedPlaybackSpeedForPlayer(id playerViewController) {
    if (DYYYShouldPrepareDefaultPlaybackSpeedForPlayer(playerViewController)) {
        return DYYYDefaultPlaybackSpeed();
    }
    return DYYYConfiguredPlaybackSpeed();
}

static void DYYYApplyPreparedPlaybackSpeedToPlayer(id playerViewController) {
    if (!DYYYShouldHandleSpeedFeatures() || !playerViewController || dyyyLongPressFastSpeedActive || dyyyLongPressLockedSpeedActive) {
        return;
    }

    double speed = DYYYPreparedPlaybackSpeedForPlayer(playerViewController);
    void (^applyBlock)(void) = ^{
      DYYYSetPlaybackRateOnTarget(playerViewController, speed);
    };
    if ([NSThread isMainThread]) {
        applyBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), applyBlock);
    }
}

static void DYYYBindAndApplyCurrentPlaybackSpeed(void) {
    if (!DYYYShouldHandleSpeedFeatures() || dyyyLongPressFastSpeedActive || dyyyLongPressLockedSpeedActive) {
        return;
    }

    AWEAwemeModel *targetAweme = dyyyCurrentSpeedAweme;
    AWEPlayInteractionViewController *currentController = DYYYResolveSpeedInteractionController(nil, targetAweme, targetAweme == nil);
    if (!currentController) {
        return;
    }

    DYYYEnsureFloatSpeedButton(currentController);
    DYYYApplyPlaybackSpeed(currentController, DYYYConfiguredPlaybackSpeed());
}

static void DYYYScheduleConfiguredPlaybackSpeedRestoreAfterDelay(NSTimeInterval delay) {
    dispatch_block_t restoreBlock = ^{
      DYYYBindAndApplyCurrentPlaybackSpeed();
    };
    if (delay <= 0.0) {
        dispatch_async(dispatch_get_main_queue(), restoreBlock);
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), restoreBlock);
    }
}

static void DYYYScheduleConfiguredPlaybackSpeedRestore(void) {
    DYYYScheduleConfiguredPlaybackSpeedRestoreAfterDelay(0.0);
    DYYYScheduleConfiguredPlaybackSpeedRestoreAfterDelay(0.2);
}

static void DYYYEndLockedLongPressSpeedAndRestoreIfNeeded(void) {
    if (!dyyyLongPressLockedSpeedActive) {
        return;
    }
    dyyyLongPressLockedSpeedActive = NO;
    DYYYScheduleConfiguredPlaybackSpeedRestore();
}

static void DYYYHandleCurrentSpeedAwemeChanged(id aweme) {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          DYYYHandleCurrentSpeedAwemeChanged(aweme);
        });
        return;
    }

    Class awemeClass = NSClassFromString(@"AWEAwemeModel");
    if (awemeClass && [aweme isKindOfClass:awemeClass]) {
        dyyyCurrentSpeedAweme = (AWEAwemeModel *)aweme;
    }
    if (!DYYYShouldHandleSpeedFeatures()) {
        return;
    }

    DYYYClearLongPressSpeedState();
    DYYYRestoreFloatSpeedButtonForAwemeIfNeeded(dyyyCurrentSpeedAweme);

    DYYYBindAndApplyCurrentPlaybackSpeed();
    DYYYScheduleConfiguredPlaybackSpeedRestore();
}

// 隐藏顶部引导提示

// ===== Base 域 (6 个 hook) =====

%hook UIWindow
- (instancetype)initWithFrame:(CGRect)frame {
	UIWindow *window = %orig(frame);
	if (window) {
		UILongPressGestureRecognizer *doubleFingerLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleFingerLongPressGesture:)];
		doubleFingerLongPressGesture.numberOfTouchesRequired = 2;
		[window addGestureRecognizer:doubleFingerLongPressGesture];
	}
	return window;
}

%new
- (void)handleDoubleFingerLongPressGesture:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		UIViewController *rootViewController = self.rootViewController;
		if (rootViewController) {
			UIViewController *settingVC = [[DYYYSettingViewController alloc] init];

			if (settingVC) {
				BOOL isIPad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad;
				if (@available(iOS 15.0, *)) {
					if (!isIPad) {
						settingVC.modalPresentationStyle = UIModalPresentationPageSheet;
					} else {
						settingVC.modalPresentationStyle = UIModalPresentationFullScreen;
					}
				} else {
					settingVC.modalPresentationStyle = UIModalPresentationFullScreen;
				}

				if (settingVC.modalPresentationStyle == UIModalPresentationFullScreen) {
					UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
					[closeButton setTitle:@"关闭" forState:UIControlStateNormal];
					closeButton.translatesAutoresizingMaskIntoConstraints = NO;

					[settingVC.view addSubview:closeButton];

					[NSLayoutConstraint activateConstraints:@[
						[closeButton.trailingAnchor constraintEqualToAnchor:settingVC.view.trailingAnchor constant:-10],
						[closeButton.topAnchor constraintEqualToAnchor:settingVC.view.topAnchor constant:40], [closeButton.widthAnchor constraintEqualToConstant:80],
						[closeButton.heightAnchor constraintEqualToConstant:40]
					]];

					[closeButton addTarget:self action:@selector(closeSettings:) forControlEvents:UIControlEventTouchUpInside];
				}

				UIView *handleBar = [[UIView alloc] init];
				handleBar.backgroundColor = [UIColor whiteColor];
				handleBar.layer.cornerRadius = 2.5;
				handleBar.translatesAutoresizingMaskIntoConstraints = NO;
				[settingVC.view addSubview:handleBar];

				[NSLayoutConstraint activateConstraints:@[
					[handleBar.centerXAnchor constraintEqualToAnchor:settingVC.view.centerXAnchor],
					[handleBar.topAnchor constraintEqualToAnchor:settingVC.view.topAnchor constant:8], [handleBar.widthAnchor constraintEqualToConstant:40],
					[handleBar.heightAnchor constraintEqualToConstant:5]
				]];

				[rootViewController presentViewController:settingVC animated:YES completion:nil];
			}
		}
	}
}

%new
- (void)closeSettings:(UIButton *)button {
	[button.superview.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


%end

%hook UIView

- (void)setFrame:(CGRect)frame {

    if ([self isKindOfClass:%c(AWEIMSkylightListView)] && [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideAvatarList"]) {
        frame = CGRectZero;
    }

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableCommentBlur"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
        %orig;
        return;
    }

    UIViewController *vc = [DYYYUtils findViewControllerFromView:self];
    Class PlayVCClass1 = %c(AWEAwemePlayVideoViewController);
    Class PlayVCClass2 = NSClassFromString(@"AWEDPlayerFeedPlayerViewController");
    Class PlayVCClass3 = NSClassFromString(@"AWEDPlayerViewController_Merge");
    
    BOOL isPlayVC = ((PlayVCClass1 && [vc isKindOfClass:PlayVCClass1]) ||
                     (PlayVCClass2 && [vc isKindOfClass:PlayVCClass2]) ||
                     (PlayVCClass3 && [vc isKindOfClass:PlayVCClass3]));
    
    if (isPlayVC) {

        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableCommentBlur"] && frame.origin.x != 0) {
            return;
        } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"] && frame.origin.x != 0 && frame.origin.y != 0) {
            %orig;
            return;
        } else {
            CGRect superviewFrame = self.superview.frame;

            if (superviewFrame.size.height > 0 && frame.size.height > 0 && frame.size.height < superviewFrame.size.height && frame.origin.x == 0 && frame.origin.y == 0) {

                CGFloat heightDifference = superviewFrame.size.height - frame.size.height;
                if (fabs(heightDifference - tabHeight) < 1.0) {
                    frame.size.height = superviewFrame.size.height;
                    %orig(frame);
                    return;
                }
            }
        }
    }
    %orig;
}

- (void)setAlpha:(CGFloat)alpha {
    UIViewController *vc = [DYYYUtils findViewControllerFromView:self];
    
    if ([vc isKindOfClass:%c(AWEPlayInteractionViewController)] && alpha > 0) {
        NSString *transparentValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYGlobalTransparency"];
        if (transparentValue.length > 0) {
            CGFloat alphaValue = transparentValue.floatValue;
            if (alphaValue >= 0.0 && alphaValue <= 1.0) {
                %orig(alphaValue);
                return;
            }
        }
    }
    %orig;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self setBackgroundColor:backgroundColor];
        });
        return;
    }

    if (DYYYGetBool(@"DYYYEnableFullScreen")) {
        UIViewController *vc = [DYYYUtils findViewControllerFromView:self];
        if ([vc isKindOfClass:%c(AWEAwemeDetailTableViewController)] ||
            [vc isKindOfClass:%c(AWEAwemeDetailCellViewController)]) {
            %orig([UIColor clearColor]);
            return;
        }
    }

    %orig(backgroundColor);
}

- (void)layoutSubviews {
    %orig;

    if (DYYYGetBool(@"DYYYEnableFullScreen")) {
        if (self.frame.size.height == tabHeight && tabHeight > 0) {
            UIViewController *vc = [DYYYUtils findViewControllerFromView:self];
            if ([vc isKindOfClass:NSClassFromString(@"AWEMixVideoPanelDetailTableViewController")] || [vc isKindOfClass:NSClassFromString(@"AWECommentInputViewController")] ||
                [vc isKindOfClass:NSClassFromString(@"AWEAwemeDetailTableViewController")]) {
                self.backgroundColor = [UIColor clearColor];
            }
        }
    }

    if (DYYYGetBool(@"DYYYEnableFullScreen") || DYYYGetBool(@"DYYYEnableCommentBlur")) {
        UIViewController *vc = [DYYYUtils findViewControllerFromView:self];
        if ([vc isKindOfClass:%c(AWEPlayInteractionViewController)]) {
            for (UIView *subview in self.subviews) {
                if ([subview isKindOfClass:[UIView class]] && subview.backgroundColor && CGColorEqualToColor(subview.backgroundColor.CGColor, [UIColor blackColor].CGColor)) {
                    subview.hidden = YES;
                }
            }
        }
    }
}

%end

%hook UITextInputTraits
- (void)setKeyboardAppearance:(UIKeyboardAppearance)appearance {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisDarkKeyBoard"]) {
        %orig(UIKeyboardAppearanceDark);
    }else {
        %orig;
    }
}
%end

%hook UILabel

- (void)setText:(NSString *)text {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisDarkKeyBoard"]) {
        if ([text hasPrefix:@"善语"] || [text hasPrefix:@"友爱评论"] || [text hasPrefix:@"回复"]) {
            self.textColor = [UIColor colorWithRed:125/255.0 green:125/255.0 blue:125/255.0 alpha:0.6];
        }
    }
    %orig;
}

- (void)layoutSubviews {
	%orig;

	BOOL hideRightLabel = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideRightLabel"];
	if (!hideRightLabel)
		return;

	NSString *accessibilityLabel = self.accessibilityLabel;
	if (!accessibilityLabel || accessibilityLabel.length == 0)
		return;

	NSString *trimmedLabel = [accessibilityLabel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	BOOL shouldHide = NO;

	if ([trimmedLabel hasSuffix:@"人共创"]) {
		NSString *prefix = [trimmedLabel substringToIndex:trimmedLabel.length - 3];
		NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
		shouldHide = ([prefix rangeOfCharacterFromSet:nonDigits].location == NSNotFound);
	}

	if (!shouldHide) {
		shouldHide = [trimmedLabel isEqualToString:@"章节要点"] || [trimmedLabel isEqualToString:@"图集"];
	}

	if (shouldHide) {
		self.hidden = YES;

		// 找到父视图是否为 UIStackView
		UIView *superview = self.superview;
		if ([superview isKindOfClass:[UIStackView class]]) {
			UIStackView *stackView = (UIStackView *)superview;
			// 刷新 UIStackView 的布局
			[stackView layoutIfNeeded];
		}
	}
}

%end

%hook UIButton

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    NSString *label = self.accessibilityLabel;
    if ([label isEqualToString:@"表情"] || [label isEqualToString:@"at"] || [label isEqualToString:@"图片"] || [label isEqualToString:@"键盘"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisDarkKeyBoard"]) {
            
            UIImage *whiteImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
            self.tintColor = [UIColor whiteColor];
            
            %orig(whiteImage, state);
        }else {
            %orig(image, state);
        }
    } else {
        %orig(image, state);
    }
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    %orig;
    
    if ([title isEqualToString:@"加入挑战"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChallengeStickers"]) {
                UIResponder *responder = self;
                BOOL isInPlayInteractionViewController = NO;

                while ((responder = [responder nextResponder])) {
                    if ([responder isKindOfClass:%c(AWEPlayInteractionViewController)]) {
                        isInPlayInteractionViewController = YES;
                        break;
                    }
                }

                if (isInPlayInteractionViewController) {
                    UIView *parentView = self.superview;
                    if (parentView) {
                        UIView *grandParentView = parentView.superview;
                        if (grandParentView) {
                            grandParentView.hidden = YES;
                        } else {
                            parentView.hidden = YES;
                        }
                    } else {
                        self.hidden = YES;
                    }
                }
            }
        });
    }
}

- (void)layoutSubviews {
	%orig;

	NSString *accessibilityLabel = self.accessibilityLabel;

	if ([accessibilityLabel isEqualToString:@"拍照搜同款"] || [accessibilityLabel isEqualToString:@"扫一扫"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideScancode"]) {
			[self removeFromSuperview];
			return;
		}
	}
	
	if ([accessibilityLabel isEqualToString:@"返回"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideBack"]) {
			UIView *parent = self.superview;
			if ([parent isKindOfClass:%c(AWEBaseElementView)]) {
				[self removeFromSuperview];
			}
			return;
		}
	}
}

%end

%hook UIImageView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentDiscover"]) {
		if (!self.accessibilityLabel) {
			UIView *parentView = self.superview;

			if (parentView && [parentView class] == [UIView class] && [parentView.accessibilityLabel isEqualToString:@"搜索"]) {
				self.hidden = YES;
			}

			else if (parentView && [NSStringFromClass([parentView class]) isEqualToString:@"AWESearchEntryHalfScreenElement"] && [parentView.accessibilityLabel isEqualToString:@"搜索"]) {
				self.hidden = YES;
			}
		}
	}
}
%end
