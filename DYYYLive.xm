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

// ===== Live 域 (20 个 hook) =====

%hook AWEFeedLiveMarkView
- (void)setHidden:(BOOL)hidden {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideAvatarButton"]) {
        hidden = YES;
    }

    %orig(hidden);
}
%end

%hook IESLiveActivityBannnerView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGiftPavilion"]) {
		self.hidden = YES;
	}
}

%end

%hook IESLiveFeedDrawerEntranceView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLivePlayground"]) {
		self.hidden = YES;
	}
}

%end

%hook IESLiveAudienceViewController
- (BOOL)prefersStatusBarHidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideStatusbar"]) {
		return YES;
	} else {
		if (class_getInstanceMethod([self class], @selector(prefersStatusBarHidden)) !=
		    class_getInstanceMethod([%c(IESLiveAudienceViewController) class], @selector(prefersStatusBarHidden))) {
			return %orig;
		}
		return NO;
	}
}
%end

%hook AWELiveFeedStatusLabel
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideEnterLive"]) {
		UIView *parentView = self.superview;
		UIView *grandparentView = parentView.superview;

		if (grandparentView) {
			grandparentView.hidden = YES;
		} else if (parentView) {
			parentView.hidden = YES;
		} else {
			self.hidden = YES;
		}
	}
}
%end

%hook AWEIMCellLiveStatusContainerView

- (void)p_initUI {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYGroupLiving"])
		%orig;
}
%end

%hook AWELiveStatusIndicatorView

- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYGroupLiving"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AWELiveSkylightCatchView
- (void)layoutSubviews {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidenLiveCapsuleView"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}

%end

%hook IESLiveButton

- (void)layoutSubviews {
	%orig;

	// 处理清屏按钮
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveRoomClear"]) {
		if ([self.accessibilityLabel isEqualToString:@"退出清屏"] && self.superview) {
			[self.superview removeFromSuperview];
		}
	}

	// 投屏按钮
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveRoomMirroring"]) {
		if ([self.accessibilityLabel isEqualToString:@"投屏"] && self.superview) {
			[self.superview removeFromSuperview];
		}
	}

	// 横屏按钮,可点击
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveRoomFullscreen"]) {
		if ([self.accessibilityLabel isEqualToString:@"横屏"] && self.superview) {
			for (UIView *subview in self.subviews) {
			subview.hidden = YES;
			}
		}
	}
}

%end

%hook IESLiveLayoutPlaceholderView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveRoomClose"]) {
		self.hidden = YES;
	}
}
%end

%hook AWELiveFlowAlertView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCellularAlert"]) {
		self.hidden = YES;
	}
}
%end

%hook IESECLivePluginLayoutView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveGoodsMsg"]) {
		[self removeFromSuperview];
	}
}
%end

%hook HTSLiveDiggView
- (void)setIconImageView:(UIImageView *)arg1 {
	if (DYYYGetBool(@"DYYYHideLiveLikeAnimation")) {
		%orig(nil);
	} else {
		%orig(arg1);
	}
}
%end

%hook AWEFeedLiveTabRevisitControlView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveDiscovery"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
}
%end

%hook IESLiveKTVSongIndicatorView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideKTVSongIndicator"]) {
		self.hidden = YES;
		[self removeFromSuperview];
	}
}
%end

%hook AWELiveGuideElement

- (BOOL)enableAutoEnterRoom {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableAutoEnterLive"]) {
		return NO;
	}
	return %orig;
}

- (BOOL)enableNewAutoEnter {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableAutoEnterLive"]) {
		return NO;
	}
	return %orig;
}

%end

%hook AWENewLiveSkylightViewController
// 隐藏顶部直播视图 - 添加条件判断
- (void)showSkylight:(BOOL)arg0 animated:(BOOL)arg1 actionMethod:(unsigned long long)arg2 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidenLiveView"]) {
		return;
	}
	%orig(arg0, arg1, arg2);
}

- (void)updateIsSkylightShowing:(BOOL)arg0 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidenLiveView"]) {
		%orig(NO);
	} else {
		%orig(arg0);
	}
}

%end

%hook AWELiveAutoEnterStyleAView

- (void)layoutSubviews {
	%orig;  // 调用原始方法

	// 检查是否启用隐藏直播视图功能
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidenLiveView"]) {
		// 从父视图中移除此视图，实现隐藏效果
		[self removeFromSuperview];
		return;
	}
}

%end

%hook HTSLiveStreamQualityFragment

- (void)setupStreamQuality:(id)arg1 {
	%orig;

	BOOL enableHighestQuality = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableLiveHighestQuality"];
	if (enableHighestQuality) {
		NSArray *qualities = self.streamQualityArray;
		if (!qualities || qualities.count == 0) {
			qualities = [self getQualities];
		}

		if (!qualities || qualities.count == 0) {
			return;
		}
		// 选择索引0作为最高清晰度
		[self setResolutionWithIndex:0 isManual:YES beginChange:nil completion:nil];
	}
}

%end

%hook HTSLiveStreamPcdnManager

+ (void)start {
	BOOL disablePCDN = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableLivePCDN"];
	if (!disablePCDN) {
		%orig;
	}
}

+ (void)configAndStartLiveIO {
	BOOL disablePCDN = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableLivePCDN"];
	if (!disablePCDN) {
		%orig;
	}
}

%end
