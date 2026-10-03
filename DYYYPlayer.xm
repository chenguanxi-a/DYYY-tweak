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

// ===== Player 域 (60 个 hook) =====

%hook AWEFeedTabJumpGuideView

- (void)layoutSubviews {
	%orig;
	[self removeFromSuperview];
}

%end

%hook AWEAwemePlayVideoViewController

- (void)setIsAutoPlay:(BOOL)arg0 {
    %orig(arg0);
    DYYYApplyPreparedPlaybackSpeedToPlayer(self);
}

%end

%hook AWEDanmakuContentLabel
- (void)setTextColor:(UIColor *)textColor {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableDanmuColor"]) {
		NSString *danmuColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDanmuColor"];

		if ([danmuColor.lowercaseString isEqualToString:@"random"] || [danmuColor.lowercaseString isEqualToString:@"#random"]) {
			textColor = [UIColor colorWithRed:(arc4random_uniform(256)) / 255.0
						    green:(arc4random_uniform(256)) / 255.0
						     blue:(arc4random_uniform(256)) / 255.0
						    alpha:CGColorGetAlpha(textColor.CGColor)];
			self.layer.shadowOffset = CGSizeZero;
			self.layer.shadowOpacity = 0.0;
		} else if ([danmuColor hasPrefix:@"#"]) {
			textColor = [self colorFromHexString:danmuColor baseColor:textColor];
			self.layer.shadowOffset = CGSizeZero;
			self.layer.shadowOpacity = 0.0;
		} else {
			textColor = [self colorFromHexString:@"#FFFFFF" baseColor:textColor];
		}
	}

	%orig(textColor);
}

%new
- (UIColor *)colorFromHexString:(NSString *)hexString baseColor:(UIColor *)baseColor {
	if ([hexString hasPrefix:@"#"]) {
		hexString = [hexString substringFromIndex:1];
	}
	if ([hexString length] != 6) {
		return [baseColor colorWithAlphaComponent:1];
	}
	unsigned int red, green, blue;
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&red];
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&green];
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&blue];

	if (red < 128 && green < 128 && blue < 128) {
		return [UIColor whiteColor];
	}

	return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:CGColorGetAlpha(baseColor.CGColor)];
}
%end

%hook AWEMarkView

- (void)layoutSubviews {
	%orig;

	UIViewController *vc = [DYYYUtils findViewControllerFromView:self];

	if ([vc isKindOfClass:%c(AWEPlayInteractionViewController)]) {
		if (self.markLabel) {
			self.markLabel.textColor = [UIColor whiteColor];
		}
	}

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLocation"]) {
		self.hidden = YES;
		return;
	}
}

%end

%hook AWEDanmakuItemTextInfo
- (void)setDanmakuTextColor:(id)arg1 {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableDanmuColor"]) {
		NSString *danmuColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDanmuColor"];

		if ([danmuColor.lowercaseString isEqualToString:@"random"] || [danmuColor.lowercaseString isEqualToString:@"#random"]) {
			arg1 = [UIColor colorWithRed:(arc4random_uniform(256)) / 255.0 green:(arc4random_uniform(256)) / 255.0 blue:(arc4random_uniform(256)) / 255.0 alpha:1.0];
		} else if ([danmuColor hasPrefix:@"#"]) {
			arg1 = [self colorFromHexStringForTextInfo:danmuColor];
		} else {
			arg1 = [self colorFromHexStringForTextInfo:@"#FFFFFF"];
		}
	}

	%orig(arg1);
}

%new
- (UIColor *)colorFromHexStringForTextInfo:(NSString *)hexString {
	if ([hexString hasPrefix:@"#"]) {
		hexString = [hexString substringFromIndex:1];
	}
	if ([hexString length] != 6) {
		return [UIColor whiteColor];
	}
	unsigned int red, green, blue;
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&red];
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&green];
	[[NSScanner scannerWithString:[hexString substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&blue];

	if (red < 128 && green < 128 && blue < 128) {
		return [UIColor whiteColor];
	}

	return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:1.0];
}
%end

%hook LOTAnimationView
- (void)layoutSubviews {
    %orig;

    // 检查是否需要隐藏加号
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLOTAnimationView"]) {
        [self removeFromSuperview];
        return;
    }

    // 应用透明度设置
    NSString *transparencyValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYAvatarViewTransparency"];
    if (transparencyValue && transparencyValue.length > 0) {
        CGFloat alphaValue = [transparencyValue floatValue];
        if (alphaValue >= 0.0 && alphaValue <= 1.0) {
            self.alpha = alphaValue;
        }
    }
}
%end

%hook AWELongVideoControlModel
- (bool)allowDownload {
	return YES;
}
%end

%hook AWELongVideoControlModel
- (long long)preventDownloadType {
	return 0;
}
%end

%hook BDASplashControllerView
+ (id)alloc {
	BOOL noAds = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoAds"];
	if (noAds) {
		return nil;
	}
	return %orig;
}
%end

%hook AWELandscapeFeedEntryView

- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideEntry"]) {
		[self removeFromSuperview];
		return;
	}

	if (self.superview) {
		[self.superview bringSubviewToFront:self];
	}
}

%end

%hook AWEStoryContainerCollectionView
- (void)layoutSubviews {
	%orig;
	if ([self.subviews count] == 2)
		return;

	// 获取 enableEnterProfile 属性来判断是否是主页
	id enableEnterProfile = [self valueForKey:@"enableEnterProfile"];
	BOOL isHome = (enableEnterProfile != nil && [enableEnterProfile boolValue]);

	// 检查是否在作者主页
	BOOL isAuthorProfile = NO;
	UIResponder *responder = self;
	while ((responder = [responder nextResponder])) {
		if ([NSStringFromClass([responder class]) containsString:@"UserHomeViewController"] || [NSStringFromClass([responder class]) containsString:@"ProfileViewController"]) {
			isAuthorProfile = YES;
			break;
		}
	}

	// 如果不是主页也不是作者主页，直接返回
	if (!isHome && !isAuthorProfile)
		return;

	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:[UIView class]]) {
			UIView *nextResponder = (UIView *)subview.nextResponder;

			// 处理主页的情况
			if (isHome && [nextResponder isKindOfClass:%c(AWEPlayInteractionViewController)]) {
				UIViewController *awemeBaseViewController = [nextResponder valueForKey:@"awemeBaseViewController"];
				if (![awemeBaseViewController isKindOfClass:%c(AWEFeedCellViewController)]) {
					continue;
				}

				CGRect frame = subview.frame;
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
				frame.size.height = subview.superview.frame.size.height - tabHeight;
				subview.frame = frame;
			}
			}
			// 处理作者主页的情况
			else if (isAuthorProfile) {
				// 检查是否是作品图片
				BOOL isWorkImage = NO;

				// 可以通过检查子视图、标签或其他特性来确定是否是作品图片
				for (UIView *childView in subview.subviews) {
					if ([NSStringFromClass([childView class]) containsString:@"ImageView"] || [NSStringFromClass([childView class]) containsString:@"ThumbnailView"]) {
						isWorkImage = YES;
						break;
					}
				}

				if (isWorkImage) {
				// 修复作者主页作品图片上移问题
				CGRect frame = subview.frame;
				frame.origin.y += tabHeight;
				subview.frame = frame;
			}
			}
		}
	}
}
%end

%hook TTMetalView
- (void)setCenter:(CGPoint)center {
    BOOL shouldAdjust = NO;
    UIView *view = (UIView *)self;
    if (DYYYGetBool(@"DYYYEnableFullScreen")) {
        CGFloat viewWidth = CGRectGetWidth(view.bounds);
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if (viewWidth + 0.5f >= screenWidth) {
            UIViewController *vc = [DYYYUtils findViewControllerFromView:view];
            Class playClass = %c(AWEPlayVideoViewController);
            if (playClass && [vc isKindOfClass:playClass]) {
                AWEPlayVideoViewController *playVC = (AWEPlayVideoViewController *)vc;
                AWEAwemeModel *model = playVC.model;
                if ([model respondsToSelector:@selector(isShowLandscapeEntryView)] && model.isShowLandscapeEntryView) {
                    shouldAdjust = YES;
                }
            }
        }
    }

    if (shouldAdjust && tabHeight > 0) {
        center.y -= tabHeight * 0.5;
    }

    %orig(center);
}
%end

%hook TTMetalViewNew
- (void)setCenter:(CGPoint)center {
    BOOL shouldAdjust = NO;
    UIView *view = (UIView *)self;
    if (DYYYGetBool(@"DYYYEnableFullScreen")) {
        CGFloat viewWidth = CGRectGetWidth(view.bounds);
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if (viewWidth + 0.5f >= screenWidth) {
            UIViewController *vc = [DYYYUtils findViewControllerFromView:view];
            Class playClass = %c(AWEPlayVideoViewController);
            if (playClass && [vc isKindOfClass:playClass]) {
                AWEPlayVideoViewController *playVC = (AWEPlayVideoViewController *)vc;
                AWEAwemeModel *model = playVC.model;
                if ([model respondsToSelector:@selector(isShowLandscapeEntryView)] && model.isShowLandscapeEntryView) {
                    shouldAdjust = YES;
                }
            }
        }
    }

    if (shouldAdjust && tabHeight > 0) {
        center.y -= tabHeight * 0.5;
    }

    %orig(center);
}
%end

%hook TTMetalViewVP
- (void)setCenter:(CGPoint)center {
    BOOL shouldAdjust = NO;
    UIView *view = (UIView *)self;
    if (DYYYGetBool(@"DYYYEnableFullScreen")) {
        CGFloat viewWidth = CGRectGetWidth(view.bounds);
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if (viewWidth + 0.5f >= screenWidth) {
            UIViewController *vc = [DYYYUtils findViewControllerFromView:view];
            Class playClass = %c(AWEPlayVideoViewController);
            if (playClass && [vc isKindOfClass:playClass]) {
                AWEPlayVideoViewController *playVC = (AWEPlayVideoViewController *)vc;
                AWEAwemeModel *model = playVC.model;
                if ([model respondsToSelector:@selector(isShowLandscapeEntryView)] && model.isShowLandscapeEntryView) {
                    shouldAdjust = YES;
                }
            }
        }
    }

    if (shouldAdjust && tabHeight > 0) {
        center.y -= tabHeight * 0.5;
    }

    %orig(center);
}
%end

%hook AWEStoryProgressContainerView
- (void)setCenter:(CGPoint)center {
    UIViewController *vc = [DYYYUtils findViewControllerFromView:self];
    if ([vc isKindOfClass:NSClassFromString(@"AWEFeedPlayControlImpl.PureModePageCellViewController")] && DYYYGetBool(@"DYYYEnableFullScreen")) {
        center.y -= tabHeight;
    }
    %orig(center);
}
%end

%hook AWEPlayInteractionProgressContainerView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
		for (UIView *subview in self.subviews) {
			if ([subview class] == [UIView class]) {
				[subview setBackgroundColor:[UIColor clearColor]];
			}
		}
	}
}
%end

%hook AWEDPlayerProgressContainerView
- (void)layoutSubviews {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
        for (UIView *subview in self.subviews) {
            if ([subview isMemberOfClass:[UIView class]]) {
                UIColor *bgColor = subview.backgroundColor;
                if (bgColor) {
                    CGFloat h, s, v, a;
                    if ([bgColor getHue:&h saturation:&s brightness:&v alpha:&a]) {
                        if (v < 0.2) {
                            subview.backgroundColor = [UIColor clearColor];
                        }
                    }
                }
            }
        }
    }
}
%end

%hook AFDFastSpeedView
- (void)layoutSubviews {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
        for (UIView *subview in self.subviews) {
            if ([subview class] == [UIView class]) {
                [subview setBackgroundColor:[UIColor clearColor]];
            }
        }
    }
}
%end

%hook AWEFeedTopBarContainer
- (void)didMoveToSuperview {
    %orig;
    applyTopBarTransparency(self);
}
- (void)setAlpha:(CGFloat)alpha {
    NSString *transparentValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYTopBarTransparent"];
    if (transparentValue && transparentValue.length > 0) {
        CGFloat alphaValue = [transparentValue floatValue];
        if (alphaValue >= 0.0 && alphaValue <= 1.0) {
            CGFloat finalAlpha = (alphaValue < 0.011) ? 0.011 : alphaValue;
            %orig(finalAlpha);
        } else {
            %orig(1.0);
        }
    } else {
        %orig(1.0);
    }
}
%end

%hook AWEPlayInteractionCoCreatorNewInfoView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGongChuang"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AFDCancelMuteAwemeView
- (void)layoutSubviews {
	%orig;

	UIView *superview = self.superview;

	if ([superview isKindOfClass:NSClassFromString(@"AWEBaseElementView")]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCancelMute"]) {
			self.hidden = YES;
		}
	}
}
%end

%hook AWEPlayDanmakuInputContainView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDanmuButton"]) {
		self.hidden = YES;
	}
}

%end

%hook AWEECommerceEntryView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideHisShop"]) {
		UIView *parentView = self.superview;
		if (parentView) {
			parentView.hidden = YES;
		} else {
			self.hidden = YES;
		}
	}
}

%end

%hook AWEPOIEntryAnchorView

- (void)p_addViews {
	// 检查用户偏好设置
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		// 直接跳过视图添加流程
		return;
	}
	// 执行原始方法
	%orig;
}

- (void)setIconUrls:(id)arg1 defaultImage:(id)arg2 {
	// 根据需求选择是否拦截资源加载
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		%orig(nil, nil);
		return;
	}
	// 正常传递参数
	%orig(arg1, arg2);
}

- (void)setContentSize:(CGSize)arg1 {
	// 可选：动态调整尺寸计算逻辑
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		// 计算不包含评论视图的尺寸
		CGSize newSize = CGSizeMake(arg1.width, arg1.height - 44); // 示例减法
		%orig(newSize);
		return;
	}
	// 保持原有尺寸计算
	%orig(arg1);
}

%end

%hook AWEPlayInteractionStrongifyShareContentView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideShareContentView"]) {
		UIView *parentView = self.superview;
		if (parentView) {
			parentView.hidden = YES;
		} else {
			self.hidden = YES;
		}
	}
}

%end

%hook AWEPlayInteractionRelatedVideoView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideBottomRelated"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook BDXWebView
- (void)layoutSubviews {
	%orig;

	BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGiftPavilion"];
	if (!enabled)
		return;

	NSString *title = [self valueForKey:@"title"];

	if ([title containsString:@"任务Banner"] || [title containsString:@"活动Banner"]) {
		[self removeFromSuperview];
	}
}
%end

%hook AWEMusicCoverButton

- (void)layoutSubviews {
    %orig;

    NSString *accessibilityLabel = self.accessibilityLabel;

    if ([accessibilityLabel isEqualToString:@"音乐详情"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMusicButton"]) {
            [self removeFromSuperview];
            return;
        }
    }
}

%end

%hook AWEPlayInteractionListenFeedView
- (void)layoutSubviews {
    %orig;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMusicButton"]) {
        [self removeFromSuperview];
        return;
    }
}
%end

%hook AWEPlayInteractionFollowPromptView

- (void)layoutSubviews {
    %orig;

    NSString *accessibilityLabel = self.accessibilityLabel;

    if ([accessibilityLabel isEqualToString:@"关注"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideAvatarButton"]) {
            [self removeFromSuperview];
            return;
        }
    }
}

%end

%hook AWEPlayInteractionElementMaskView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGradient"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

%hook AWEGradientView
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGradient"]) {
		UIView *parent = self.superview;
		if ([parent.accessibilityLabel isEqualToString:@"暂停，按钮"] || [parent.accessibilityLabel isEqualToString:@"播放，按钮"] ||
		    [parent.accessibilityLabel isEqualToString:@"“切换视角，按钮"]) {
			[self removeFromSuperview];
		}
		return;
	}
}
%end

%hook AWEHotSearchInnerBottomView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideHotSearch"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

%hook AWEHotSpotBlurView
- (void)layoutSubviews {
	%orig;

	// 如果用户启用了隐藏渐变效果的设置，则移除此视图
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideGradient"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

%hook AWELoadingAndVolumeView

- (void)layoutSubviews {
	%orig;

	if ([self respondsToSelector:@selector(removeFromSuperview)]) {
		[self removeFromSuperview];
	}
	self.hidden = YES;
	return;
}

%end

%hook ACCGestureResponsibleStickerView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChallengeStickers"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

%hook AWETextViewInternal

- (void)drawRect:(CGRect)rect {
    %orig(rect);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisDarkKeyBoard"]) {
        
        self.textColor = [UIColor whiteColor];
    }
}

- (double)lineSpacing {
    double r = %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYisDarkKeyBoard"]) {
        
        self.textColor = [UIColor whiteColor];
    }
    return r;
}

%end

%hook AWEPlayInteractionUserAvatarElement

- (void)onFollowViewClicked:(UITapGestureRecognizer *)gesture {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYFollowTips"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"关注确认"
                                                  message:@"是否确认关注？"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"取消"
                                           style:UIAlertActionStyleCancel
                                           handler:nil];
            
            UIAlertAction *confirmAction = [UIAlertAction
                                            actionWithTitle:@"确定"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                %orig(gesture);
            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:confirmAction];
            
            UIViewController *topController = [DYYYManager getActiveTopController];
            if (topController) {
                [topController presentViewController:alertController animated:YES completion:nil];
            }
        });
    }else {
        %orig;
    }
}

%end

%hook AWEPlayInteractionUserAvatarFollowController
- (void)onFollowViewClicked:(UITapGestureRecognizer *)gesture {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYFollowTips"]) {

		dispatch_async(dispatch_get_main_queue(), ^{
		UIAlertController *alertController = [UIAlertController
											  alertControllerWithTitle:@"关注确认"
											  message:@"是否确认关注？"
											  preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction *cancelAction = [UIAlertAction
									   actionWithTitle:@"取消"
									   style:UIAlertActionStyleCancel
									   handler:nil];

		UIAlertAction *confirmAction = [UIAlertAction
										actionWithTitle:@"确定"
										style:UIAlertActionStyleDefault
										handler:^(UIAlertAction * _Nonnull action) {
			%orig(gesture);
		}];

		[alertController addAction:cancelAction];
		[alertController addAction:confirmAction];

		UIViewController *topController = [DYYYManager getActiveTopController];
		if (topController) {
			[topController presentViewController:alertController animated:YES completion:nil];
		}
		});
	} else {
		%orig;
	}
}

%end

%hook AWEDemaciaChapterProgressSlider

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChapterProgress"]) {
		[self removeFromSuperview];
	}
}

%end

%hook DUXPopover
- (void)layoutSubviews {
	%orig;

	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePopover"]) {
		return;
	}

	id rawContent = nil;
	@try {
		rawContent = [self valueForKey:@"content"];
	} @catch (__unused NSException *e) {
		return;
	}

	NSString *text = [rawContent isKindOfClass:NSString.class] ? (NSString *)rawContent : [rawContent description];

	if ([text containsString:@"上次看到"]) {
		[self removeFromSuperview];
	}
}
%end

%hook AWEStoryProgressSlideView

- (void)layoutSubviews {
	%orig;

	BOOL shouldHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideStoryProgressSlide"];
	if (!shouldHide)
		return;
	__block UIView *targetView = nil;
	[self.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
	  if ([obj isKindOfClass:NSClassFromString(@"UISlider")] || obj.frame.size.height < 5) {
		  targetView = obj.superview;
		  *stop = YES;
	  }
	}];

	if (targetView) {
		targetView.hidden = YES;
	} else {
	}
}

%end

%hook AFDNewFastReplyView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePrivateMessages"]) {
		UIView *parentView = self.superview;
		if (parentView) {
			parentView.hidden = YES;
		} else {
			self.hidden = YES;
		}
	}
}

%end

%hook AWEPlayInteractionUserAvatarElement

- (void)layoutSubviews {
    %orig;
    
    // 检查是否启用了自定义相册图片
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableCustomAlbum"]) {
        NSString *customImagePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYCustomAlbumImagePath"];
        
        if (customImagePath && [[NSFileManager defaultManager] fileExistsAtPath:customImagePath]) {
            // 查找相册按钮
            for (UIView *subview in self.subviews) {
                if ([subview isKindOfClass:[UIButton class]] && 
                    [subview.accessibilityIdentifier isEqualToString:@"avatar_album_button"]) {
                    
                    UIButton *albumButton = (UIButton *)subview;
                    
                    // 计算按钮大小
                    CGFloat buttonSize = 40.0; // 默认中号
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYCustomAlbumSizeSmall"]) {
                        buttonSize = 30.0;
                    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYCustomAlbumSizeMedium"]) {
                        buttonSize = 40.0;
                    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYCustomAlbumSizeLarge"]) {
                        buttonSize = 50.0;
                    }
                    
                    // 调整按钮尺寸
                    albumButton.frame = CGRectMake(albumButton.frame.origin.x,
                                                  albumButton.frame.origin.y,
                                                  buttonSize,
                                                  buttonSize);
                    
                    // 加载自定义图片
                    UIImage *customImage = [UIImage imageWithContentsOfFile:customImagePath];
                    if (customImage) {
                        // 创建圆形图片
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(buttonSize, buttonSize), NO, 0);
                        
                        // 创建圆形裁剪路径
                        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, buttonSize, buttonSize)];
                        [circlePath addClip];
                        
                        // 绘制图片铺满整个圆形区域
                        [customImage drawInRect:CGRectMake(0, 0, buttonSize, buttonSize)];
                        
                        UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        // 设置自定义图片
                        [albumButton setImage:roundedImage forState:UIControlStateNormal];
                        albumButton.backgroundColor = [UIColor clearColor];
                    }
                    
                    break;
                }
            }
        }
    }
}

%end

%hook AWEPlayInteractionSearchAnchorView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideInteractionSearch"]) {
		[self removeFromSuperview];
		return;
	}
}

%end

%hook AWEAwemeMusicInfoView

- (void)layoutSubviews {
    %orig;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideQuqishuiting"]) {
        // 找到父视图并隐藏
        UIView *parentView = self.superview;
        if (parentView) {
            parentView.hidden = YES;
        } else {
            self.hidden = YES;
        }
    }
}

%end

%hook AWEFeedPauseRelatedWordComponent

// 拦截更新视图的方法，如果启用了隐藏设置则返回nil
- (id)updateViewWithModel:(id)arg0 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePauseVideoRelatedWord"]) {
		return nil; // 用户选择隐藏暂停关键词，返回nil阻止显示
	}
	return %orig;
}

// 拦截获取暂停内容的方法，控制是否显示暂停时的内容
- (id)pauseContentWithModel:(id)arg0 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePauseVideoRelatedWord"]) {
		return nil; // 用户选择隐藏暂停关键词，返回nil阻止显示
	}
	return %orig;
}

// 拦截获取推荐词的方法，控制是否返回推荐关键词
- (id)recommendsWords {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePauseVideoRelatedWord"]) {
		return nil; // 用户选择隐藏暂停关键词，返回nil阻止显示
	}
	return %orig;
}

// 设置UI组件，如果启用了隐藏设置则隐藏相关视图
- (void)setupUI {
	%orig; // 先执行原始方法
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePauseVideoRelatedWord"]) {
		if ([self respondsToSelector:@selector(relatedView)]) {
			UIView *relatedView = self.relatedView;
			if (relatedView && [relatedView isKindOfClass:[UIView class]]) {
				relatedView.hidden = YES; // 隐藏相关词视图
			}
		}
		
		UIView *relatedView = [self valueForKey:@"relatedView"];
		if (relatedView && [relatedView isKindOfClass:[UIView class]]) {
			relatedView.hidden = YES; // 隐藏相关词视图
		}
	}
}

%end

%hook AWETemplateHotspotView

- (void)layoutSubviews {
    %orig;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideHotspot"]) {
        [self removeFromSuperview];
        return;
    }
}

%end

%hook AWEPlayInteractionDescriptionScrollView

- (void)layoutSubviews {
	%orig;

	// 重置当前视图的变换矩阵，确保从初始状态开始调整
	self.transform = CGAffineTransformIdentity;

	// 从用户设置中获取描述文本的垂直偏移量
	NSString *descriptionOffsetValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDescriptionVerticalOffset"];
	CGFloat verticalOffset = 0;
	if (descriptionOffsetValue.length > 0) {
		verticalOffset = [descriptionOffsetValue floatValue];
	}

	// 获取父视图和祖父视图
	UIView *parentView = self.superview;
	UIView *grandParentView = nil;

	if (parentView) {
		grandParentView = parentView.superview;
	}

	// 如果找到祖父视图且用户设置了垂直偏移，则应用位移变换
	if (grandParentView && verticalOffset != 0) {
		CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0, verticalOffset);
		grandParentView.transform = translationTransform;
	}
}

%end

%hook AWEUserNameLabel

- (void)layoutSubviews {
	%orig;

	self.transform = CGAffineTransformIdentity;

	// 添加垂直偏移支持
	NSString *verticalOffsetValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYNicknameVerticalOffset"];
	CGFloat verticalOffset = 0;
	if (verticalOffsetValue.length > 0) {
		verticalOffset = [verticalOffsetValue floatValue];
	}

	UIView *parentView = self.superview;
	UIView *grandParentView = nil;

	if (parentView) {
		grandParentView = parentView.superview;
	}

	// 检查祖父视图是否为 AWEBaseElementView 类型
	if (grandParentView && [grandParentView.superview isKindOfClass:%c(AWEBaseElementView)]) {
		CGRect scaledFrame = grandParentView.frame;
		CGFloat translationX = -scaledFrame.origin.x;

		CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(translationX, verticalOffset);
		grandParentView.transform = translationTransform;
	}
}

%end

%hook AWEFeedVideoButton

- (void)setImage:(id)arg1 {
	NSString *nameString = nil;

	if ([self respondsToSelector:@selector(imageNameString)]) {
		nameString = [self performSelector:@selector(imageNameString)];
	}

	if (!nameString) {
		%orig;
		return;
	}

	NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	NSString *dyyyFolderPath = [documentsPath stringByAppendingPathComponent:@"DYYY"];

	[[NSFileManager defaultManager] createDirectoryAtPath:dyyyFolderPath withIntermediateDirectories:YES attributes:nil error:nil];

	NSDictionary *iconMapping = @{
		@"icon_home_like_after" : @"like_after.png",
		@"icon_home_like_before" : @"like_before.png",
		@"icon_home_comment" : @"comment.png",
		@"icon_home_unfavorite" : @"unfavorite.png",
		@"icon_home_favorite" : @"favorite.png",
		@"iconHomeShareRight" : @"share.png"
	};

	NSString *customFileName = nil;
	if ([nameString containsString:@"_comment"]) {
		customFileName = @"comment.png";
	} else if ([nameString containsString:@"_like"]) {
		customFileName = @"like_before.png";
	} else if ([nameString containsString:@"_collect"]) {
		customFileName = @"unfavorite.png";
	} else if ([nameString containsString:@"_share"]) {
		customFileName = @"share.png";
	}

	for (NSString *prefix in iconMapping.allKeys) {
		if ([nameString hasPrefix:prefix]) {
			customFileName = iconMapping[prefix];
			break;
		}
	}

	if (customFileName) {
		NSString *customImagePath = [dyyyFolderPath stringByAppendingPathComponent:customFileName];

		if ([[NSFileManager defaultManager] fileExistsAtPath:customImagePath]) {
			UIImage *customImage = [UIImage imageWithContentsOfFile:customImagePath];
			if (customImage) {
				CGFloat targetWidth = 44.0;
				CGFloat targetHeight = 44.0;
				CGSize originalSize = customImage.size;

				CGFloat scale = MIN(targetWidth / originalSize.width, targetHeight / originalSize.height);
				CGFloat newWidth = originalSize.width * scale;
				CGFloat newHeight = originalSize.height * scale;

				UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0.0);
				[customImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
				UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();

				if (resizedImage) {
					%orig(resizedImage);
					return;
				}
			}
		}
	}

	%orig;
}

- (id)touchUpInsideBlock {
	id r = %orig;

	// 只有收藏按钮才显示确认弹窗
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYCollectTips"] && [self.accessibilityLabel isEqualToString:@"收藏"]) {

		// 复制并强持有原始 block，避免在异步确认期间被释放
		void (^storedBlock)(void) = nil;
		if (r && [r isKindOfClass:NSClassFromString(@"NSBlock")]) {
			storedBlock = [((void (^)(void))r) copy];
		}
		// 使用关联对象绑定到按钮实例，确认后再清理
		objc_setAssociatedObject(self, @selector(touchUpInsideBlock), storedBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

		dispatch_async(dispatch_get_main_queue(), ^{
			[DYYYBottomAlertView showAlertWithTitle:@"收藏确认"
						  message:@"是否确认/取消收藏？"
					     cancelAction:nil
					    confirmAction:^{
							void (^blockToCall)(void) = objc_getAssociatedObject(self, @selector(touchUpInsideBlock));
							if (blockToCall) {
								blockToCall();
							}
							// 执行后清理关联，释放强引用
							objc_setAssociatedObject(self, @selector(touchUpInsideBlock), nil, OBJC_ASSOCIATION_ASSIGN);
					    }];
		});

		return nil; // 阻止原始 block 立即执行
	}

	return r;
}

- (void)layoutSubviews {
	%orig;

	NSString *accessibilityLabel = self.accessibilityLabel;

	if ([accessibilityLabel isEqualToString:@"点赞"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLikeButton"]) {
			[self removeFromSuperview];
			return;
		}

		// 隐藏点赞数值标签
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLikeLabel"]) {
			for (UIView *subview in self.subviews) {
				if ([subview isKindOfClass:[UILabel class]]) {
					subview.hidden = YES;
				}
			}
		}
	} else if ([accessibilityLabel isEqualToString:@"评论"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentButton"]) {
			[self removeFromSuperview];
			return;
		}

		// 隐藏评论数值标签
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentLabel"]) {
			for (UIView *subview in self.subviews) {
				if ([subview isKindOfClass:[UILabel class]]) {
					subview.hidden = YES;
				}
			}
		}
	} else if ([accessibilityLabel isEqualToString:@"分享"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideShareButton"]) {
			[self removeFromSuperview];
			return;
		}

		// 隐藏分享数值标签
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideShareLabel"]) {
			for (UIView *subview in self.subviews) {
				if ([subview isKindOfClass:[UILabel class]]) {
					subview.hidden = YES;
				}
			}
		}
	} else if ([accessibilityLabel isEqualToString:@"收藏"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCollectButton"]) {
			[self removeFromSuperview];
			return;
		}

		// 隐藏收藏数值标签
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCollectLabel"]) {
			for (UIView *subview in self.subviews) {
				if ([subview isKindOfClass:[UILabel class]]) {
					subview.hidden = YES;
				}
			}
		}
	}
}

%end

%hook AWEStoryProgressContainerView
- (BOOL)isHidden {
	BOOL originalValue = %orig;
	BOOL customHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDotsIndicator"];
	return originalValue || customHide;
}

- (void)setHidden:(BOOL)hidden {
	BOOL forceHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDotsIndicator"];
	%orig(forceHide ? YES : hidden);
}
%end

%hook AWEPlayInteractionUserAvatarView
- (void)layoutSubviews {
	%orig;

	// 检查是否开启了隐藏关注提示的选项
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFollowPromptView"]) {
		// 遍历所有子视图
		for (UIView *subview in self.subviews) {
			// 查找普通UIView类型的子视图（这些通常包含提示信息）
			if ([subview isMemberOfClass:[UIView class]]) {
				// 遍历找到的视图中的子视图并将其透明度设为0（隐藏它们）
				for (UIView *childView in subview.subviews) {
					childView.alpha = 0.0;
				}
			}
		}
	}
}
%end

%hook AWEPlayInteractionTemplateButtonGroup
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTemplateGroup"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AWEDPlayerFeedPlayerViewController

- (void)viewDidLayoutSubviews {
	%orig;
	// 检查是否启用了全屏模式
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
		UIView *contentView = self.contentView;
		if (contentView && contentView.superview) {
			CGRect frame = contentView.frame;
			CGFloat parentHeight = contentView.superview.frame.size.height;

			// 调整内容视图高度以实现全屏效果
			// 如果高度等于父视图高度减去标签栏高度，则扩展至完全全屏
			if (frame.size.height == parentHeight - tabHeight) {
				frame.size.height = parentHeight;
				contentView.frame = frame;
			} 
			// 处理特殊情况：当高度为父视图高度减去两倍标签栏高度时，调整为减去一倍标签栏高度
			else if (frame.size.height == parentHeight - (tabHeight * 2)) {
				frame.size.height = parentHeight - tabHeight;
				contentView.frame = frame;
			}
		}
	}
}

- (void)setIsAutoPlay:(BOOL)arg0 {
    %orig(arg0);
    DYYYApplyPreparedPlaybackSpeedToPlayer(self);
}

- (void)prepareForDisplay {
    %orig;
    if (!DYYYShouldHandleSpeedFeatures()) {
        return;
    }
    DYYYApplyPreparedPlaybackSpeedToPlayer(self);
    updateSpeedButtonUI();
}

%new
- (void)adjustPlaybackSpeed:(float)speed {
    [self setVideoControllerPlaybackRate:speed];
}

%end

%hook AWEDPlayerViewController_Merge

- (void)viewDidLayoutSubviews {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
        UIView *contentView = self.contentView;
        if (contentView && contentView.superview) {
            CGRect frame = contentView.frame;
            CGFloat parentHeight = contentView.superview.frame.size.height;

            if (frame.size.height == parentHeight - tabHeight) {
                frame.size.height = parentHeight;
                contentView.frame = frame;
            } else if (frame.size.height == parentHeight - (tabHeight * 2)) {
                frame.size.height = parentHeight - tabHeight;
                contentView.frame = frame;
            }
        }
    }
}

%end

%hook AWEPlayInteractionViewController

// 当视频播放器视图被双击时调用此方法
- (void)onVideoPlayerViewDoubleClicked:(id)arg1 {
	// 获取用户设置中是否禁用双击操作的开关状态
	BOOL isSwitchOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDouble"];
	// 如果开关未启用（值为NO），则执行原始的双击处理逻辑
	// 如果开关已启用（值为YES），则不执行任何操作，从而禁用双击功能
	if (!isSwitchOn) {
		%orig;
	}
}

- (void)viewDidLayoutSubviews {
    %orig;

    // 隐藏黑色背景视图，让毛玻璃效果显示视频内容
    if (DYYYGetBool(@"DYYYEnableFullScreen") || DYYYGetBool(@"DYYYEnableCommentBlur")) {
        for (UIView *subview in self.view.subviews) {
            if ([subview isKindOfClass:[UIView class]] && subview.backgroundColor && CGColorEqualToColor(subview.backgroundColor.CGColor, [UIColor blackColor].CGColor)) {
                subview.hidden = YES;
            }
        }
    }

    if (DYYYGetBool(@"DYYYEnableCommentBlur")) {
        Class containerViewClass = NSClassFromString(@"AWECommentInputViewSwiftImpl.CommentInputContainerView");
        NSArray<UIView *> *containerViews = [DYYYUtils findAllSubviewsOfClass:containerViewClass inContainer:self.view];
        for (UIView *containerView in containerViews) {
            for (UIView *subview in containerView.subviews) {
                if (subview.hidden == NO && subview.backgroundColor && CGColorGetAlpha(subview.backgroundColor.CGColor) == 1) {
                    float userTransparency = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYCommentBlurTransparent"] floatValue];
                    if (userTransparency <= 0 || userTransparency > 1) {
                        userTransparency = 0.8;
                    }
                    [DYYYUtils applyBlurEffectToView:subview transparency:userTransparency blurViewTag:999];
                }
            }
        }

        Class middleContainerClass = NSClassFromString(@"AWECommentInputViewSwiftImpl.CommentInputViewMiddleContainer");
        NSArray<UIView *> *middleContainers = [DYYYUtils findAllSubviewsOfClass:middleContainerClass inContainer:self.view];
        for (UIView *middleContainer in middleContainers) {
            BOOL containsDanmu = NO;
            for (UIView *innerSubviewCheck in middleContainer.subviews) {
                if ([innerSubviewCheck isKindOfClass:[UILabel class]] && [((UILabel *)innerSubviewCheck).text containsString:@"弹幕"]) {
                    containsDanmu = YES;
                    break;
                }
            }

            if (containsDanmu) {
                UIView *parentView = middleContainer.superview;
                for (UIView *innerSubview in parentView.subviews) {
                    if ([innerSubview isKindOfClass:[UIView class]]) {
                        if (innerSubview.subviews.count > 0) {
                            innerSubview.subviews[0].hidden = YES;
                        }

                        UIView *whiteBackgroundView = [[UIView alloc] initWithFrame:innerSubview.bounds];
                        whiteBackgroundView.backgroundColor = [UIColor whiteColor];
                        whiteBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                        [innerSubview addSubview:whiteBackgroundView];
                        break;
                    }
                }
            } else {
                for (UIView *subview in middleContainer.subviews) {
                    if (subview.hidden == NO && subview.backgroundColor && CGColorGetAlpha(subview.backgroundColor.CGColor) == 1) {
                        [DYYYUtils applyBlurEffectToView:subview transparency:0.2f blurViewTag:999];
                    }
                }
            }
        }
    }

    // 全屏模式：调整交互视图高度（移植自 DYYY12345/DYYY.xm:11517-11591）
    if (!DYYYGetBool(@"DYYYEnableFullScreen")) {
        return;
    }

    UIWindow *keyWindow = [DYYYManager getActiveWindow];
    if (keyWindow && keyWindow.safeAreaInsets.bottom == 0) {
        return;
    }

    // 远程投屏播放页不调整
    UIViewController *directParentVC = self.parentViewController;
    UIViewController *parentVC = directParentVC;
    int maxIterations = 3;
    int count = 0;
    while (parentVC && count < maxIterations) {
        if ([parentVC isKindOfClass:%c(AFDPlayRemoteFeedTableViewController)]) {
            return;
        }
        parentVC = parentVC.parentViewController;
        count++;
    }

    if (!self.view.superview) {
        return;
    }

    CGRect frame = self.view.frame;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat superviewHeight = self.view.superview.frame.size.height;

    if (frame.size.width != screenWidth && frame.size.height < superviewHeight) {
        return;
    }

    NSString *currentReferString = self.referString;
    BOOL useFullHeight = [currentReferString isEqualToString:@"general_search"] || [currentReferString isEqualToString:@"search_result"] || [currentReferString isEqualToString:@"search_ecommerce"] ||
                         [currentReferString isEqualToString:@"close_friends_moment"] || [currentReferString isEqualToString:@"offline_mode"] || [currentReferString isEqualToString:@"challenge"] ||
                         [currentReferString isEqualToString:@"general_search_scan"] || currentReferString == nil;

    if (useFullHeight) {
        frame.size.height = superviewHeight;
    } else {
        frame.size.height = superviewHeight - tabHeight;
    }

    if (fabs(frame.size.height - self.view.frame.size.height) > 0.5) {
        self.view.frame = frame;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    @try {
        // 确保所有UI更新操作安全执行
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableArea"]) {
            // 延迟更新UI，避免生命周期冲突
            dispatch_async(dispatch_get_main_queue(), ^{
                // UI更新代码
            });
        }
    } @catch (NSException *exception) {
        NSLog(@"DYYY视图生命周期异常: %@", exception);
    }
}

// 倍速管理：生命周期补全（移植自 DYYY12345/DYYY.xm:11497-11504）
// isInPlayInteractionVC 已由 DYYYFloatClearButton.xm 的 viewWillAppear 处理，此处不再重复
- (void)viewWillAppear:(BOOL)animated {
    %orig;
    dyyyCurrentSpeedAweme = self.model;
    DYYYRestoreFloatSpeedButtonForAwemeIfNeeded(self.model);
    DYYYEnsureFloatSpeedButton(self);
    reloadClearButtonConfiguration();
    updateClearButtonVisibility();
}

%end

%hook AWEPlayInteractionDescriptionLabel

static char kLongPressGestureKey;
static NSString *const kDYYYLongPressCopyEnabledKey = @"DYYYLongPressCopyTextEnabled";

- (void)didMoveToWindow {
    %orig;
    
    BOOL longPressCopyEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kDYYYLongPressCopyEnabledKey];
	
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kDYYYLongPressCopyEnabledKey]) {
        longPressCopyEnabled = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDYYYLongPressCopyEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    UIGestureRecognizer *existingGesture = objc_getAssociatedObject(self, &kLongPressGestureKey);
    if (existingGesture && !longPressCopyEnabled) {
        [self removeGestureRecognizer:existingGesture];
        objc_setAssociatedObject(self, &kLongPressGestureKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    
    if (longPressCopyEnabled && !objc_getAssociatedObject(self, &kLongPressGestureKey)) {
        UILongPressGestureRecognizer *highPriorityLongPress = [[UILongPressGestureRecognizer alloc] 
            initWithTarget:self action:@selector(handleHighPriorityLongPress:)];
        highPriorityLongPress.minimumPressDuration = 0.3;
        
        [self addGestureRecognizer:highPriorityLongPress];
        
        UIView *currentView = self;
        while (currentView.superview) {
            currentView = currentView.superview;
            
            for (UIGestureRecognizer *recognizer in currentView.gestureRecognizers) {
                if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
                    [recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                    [recognizer requireGestureRecognizerToFail:highPriorityLongPress];
                }
            }
        }
        
        objc_setAssociatedObject(self, &kLongPressGestureKey, highPriorityLongPress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isEqual:self] && [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isEqual:self] && [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

%new
- (void)handleHighPriorityLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSString *description = self.text;
        
        if (description.length > 0) {
            [[UIPasteboard generalPasteboard] setString:description];
            [DYYYToast showSuccessToastWithMessage:@"视频文案已复制"];
        }
    }
}

- (void)layoutSubviews {
    %orig;
    self.transform = CGAffineTransformIdentity;

    NSString *descriptionOffsetValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDescriptionVerticalOffset"];
    CGFloat verticalOffset = 0;
    if (descriptionOffsetValue.length > 0) {
        verticalOffset = [descriptionOffsetValue floatValue];
    }

    UIView *parentView = self.superview;
    UIView *grandParentView = nil;

    if (parentView) {
        grandParentView = parentView.superview;
    }

    if (grandParentView && verticalOffset != 0) {
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0, verticalOffset);
        grandParentView.transform = translationTransform;
    }
}

%end

%hook AWEPlayInteractionTimestampElement

static CLLocationManager *locationManager = nil;

+ (void)initialize {
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager requestWhenInUseAuthorization];
    }
    // 设置默认 NSUserDefaults 值
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
        @"DYYYEnableArea": @YES,
        @"DYYYShowDateTime": @YES,
        @"DYYYEnableAreaProvince": @YES,
        @"DYYYEnableAreaCity": @YES,
        @"DYYYEnableAreaDistrict": @YES,
        @"DYYYEnableAreaStreet": @YES,
        @"DYYYDateTimeFormat_YMDHM": @YES // 默认启用年-月-日 时:分格式
    }];
}

- (id)timestampLabel {
	UILabel *label = %orig;
	
	// 准备第一行显示日期时间
	NSString *firstLine = @"";
	NSString *secondLine = @"";
	
	// 处理时间和日期显示
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYShowDateTime"]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		
		// 根据子开关决定日期格式
		NSString *dateFormat = @"yyyy-MM-dd HH:mm"; // 默认格式
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDateTimeFormat_YMDHM"]) {
			dateFormat = @"yyyy-MM-dd HH:mm";
		} else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDateTimeFormat_MDHM"]) {
			dateFormat = @"MM-dd HH:mm";
		} else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDateTimeFormat_HMS"]) {
			dateFormat = @"HH:mm:ss";
		} else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDateTimeFormat_HM"]) {
			dateFormat = @"HH:mm";
		} else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDateTimeFormat_YMD"]) {
			dateFormat = @"yyyy-MM-dd";
		} else {
			// 检查是否有旧的格式设置
			NSString *oldFormat = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYDateTimeFormat"];
			if (oldFormat && oldFormat.length > 0) {
				dateFormat = oldFormat;
			}
		}
		
		formatter.dateFormat = dateFormat;
		
		// 使用视频发布时间而不是当前时间
		NSDate *creationDate = nil;
		NSNumber *createTimeStamp = [self.model valueForKey:@"createTime"];
		if (createTimeStamp) {
			// 时间戳转换为日期
			creationDate = [NSDate dateWithTimeIntervalSince1970:[createTimeStamp doubleValue]];
		} else {
			// 回退到原始标签文本中可能包含的时间信息
			NSString *originalText = label.text;
			if (originalText && originalText.length > 0) {
				firstLine = originalText;
			} else {
				creationDate = [NSDate date]; // 作为最后的回退选项
			}
		}
		
		if (creationDate) {
			firstLine = [formatter stringFromDate:creationDate];
		}
	}
	
	// 处理自定义属地，放在第二行 - 添加安全检查
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableArea"]) {
		NSString *cityCode = self.model.cityCode;
		NSString *customCityCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYCustomCityCode"];
		
		// 检查是否使用自定义属地
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableCustomArea"] && customCityCode) {
			cityCode = customCityCode;
		}
		
		// 使用真实位置解析（优先POI/IP属地，回退cityCode随机生成）
		if (cityCode && cityCode.length > 0) {
			DYYYCityManager *cityManager = [DYYYCityManager sharedInstance];
			if (cityManager) {
				NSString *locationPrefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYLocationPrefix"] ?: @"IP属地:";
				NSMutableString *location = [NSMutableString stringWithString:locationPrefix];
				
				@try {
					// 优先使用真实POI/IP解析，若无有效数据则回退到cityCode随机生成
					NSString *parsedLocation = [cityManager parseLocationFromAwemeModel:self.model];
					if (parsedLocation && parsedLocation.length > 0) {
						[location appendString:parsedLocation];
					} else {
						// 回退：使用cityCode生成随机地址
						NSString *fallbackAddr = [cityManager generateRandomFourLevelAddressForCityCode:cityCode];
						[location appendString:fallbackAddr ?: @"未知地区"];
					}
				} @catch (NSException *exception) {
					NSLog(@"DYYY异常: %@", exception);
					[location appendString:@"未知地区"];
				}
				
				if (location.length > locationPrefix.length) {
					secondLine = location;
				}
			}
		}
	}
	
	// 如果有两行内容，设置为多行显示
	if (secondLine.length > 0) {
		label.numberOfLines = 2;
		label.textAlignment = NSTextAlignmentLeft;
		label.lineBreakMode = NSLineBreakByWordWrapping;
		
		// 组合成两行文本
		label.text = [NSString stringWithFormat:@"%@\n%@", firstLine, secondLine];
		
		// 动态调整标签大小
		CGSize textSize = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:@{NSFontAttributeName: label.font}
												  context:nil].size;
		CGRect frame = label.frame;
		frame.size.height = textSize.height + 10;
		label.frame = frame;
		
		// 设置段落样式
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.alignment = NSTextAlignmentLeft;
		paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
		
		NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:label.text];
		[attributedText addAttribute:NSParagraphStyleAttributeName 
							  value:paragraphStyle 
							  range:NSMakeRange(0, label.text.length)];
		
		label.attributedText = attributedText;
	} else {
		label.numberOfLines = 1;
		label.text = firstLine;
		label.textAlignment = NSTextAlignmentLeft;
	}
	
	// 设置标签颜色
	NSString *labelColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYLabelColor"];
	if (labelColor.length > 0) {
		label.textColor = [DYYYManager colorWithHexString:labelColor];
	}
	
	// 添加长按手势
	if (!objc_getAssociatedObject(label, "hasLongPressGesture")) {
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] 
												 initWithTarget:self 
												 action:@selector(handleLongPress:)];
		[label addGestureRecognizer:longPress];
		label.userInteractionEnabled = YES;
		objc_setAssociatedObject(label, "hasLongPressGesture", @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return label;
}

// 显示城市选择器
%new
- (void)showCitySelector {
    NSString *savedCityCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYCustomCityCode"];
    UIViewController *topVC = [DYYYManager getActiveTopController];
    if (topVC) {
        [[DYYYCityManager sharedInstance] showCitySelectorInViewController:topVC 
                                                             delegate:(id<CitySelectorDelegate>)self
                                                 initialSelectedCode:savedCityCode];
    } else {
        [DYYYManager showToast:@"无法打开选择器：找不到顶层视图控制器"];
    }
}

// 显示日期时间格式选择器 - 保留该方法用于长按菜单
%new
- (void)showDateTimeFormatSelector {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择日期时间格式" 
                                                                  message:@"请选择一种格式（也可在设置中选择）" 
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *formats = @[
        @{@"name": @"年-月-日 时:分", @"format": @"yyyy-MM-dd HH:mm", @"key": @"DYYYDateTimeFormat_YMDHM"},
        @{@"name": @"月-日 时:分", @"format": @"MM-dd HH:mm", @"key": @"DYYYDateTimeFormat_MDHM"},
        @{@"name": @"时:分:秒", @"format": @"HH:mm:ss", @"key": @"DYYYDateTimeFormat_HMS"},
        @{@"name": @"时:分", @"format": @"HH:mm", @"key": @"DYYYDateTimeFormat_HM"},
        @{@"name": @"年-月-日", @"format": @"yyyy-MM-dd", @"key": @"DYYYDateTimeFormat_YMD"}
    ];
    
    for (NSDictionary *formatInfo in formats) {
        [alert addAction:[UIAlertAction actionWithTitle:formatInfo[@"name"]
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            // 关闭所有格式开关
            for (NSDictionary *format in formats) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:format[@"key"]];
            }
            
            // 打开选中的格式开关
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:formatInfo[@"key"]];
            
            // 保留旧的格式键以保持兼容性
            [[NSUserDefaults standardUserDefaults] setObject:formatInfo[@"format"] forKey:@"DYYYDateTimeFormat"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [DYYYManager showToast:[NSString stringWithFormat:@"已设置日期时间格式: %@", formatInfo[@"name"]]];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    UIViewController *topVC = [DYYYManager getActiveTopController];
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIView *sourceView = topVC.view;
        alert.popoverPresentationController.sourceView = sourceView;
        alert.popoverPresentationController.sourceRect = CGRectMake(sourceView.bounds.size.width / 2, 
                                                                   sourceView.bounds.size.height / 2, 
                                                                   0, 0);
    }
    
    [topVC presentViewController:alert animated:YES completion:nil];
}

// 处理城市选择结果
%new
- (void)citySelectorDidSelect:(NSString *)provinceCode 
                 provinceName:(NSString *)provinceName 
                     cityCode:(NSString *)cityCode 
                     cityName:(NSString *)cityName 
                 districtCode:(NSString *)districtCode 
                 districtName:(NSString *)districtName {
    NSString *selectedCode = cityCode ?: provinceCode;
    if (selectedCode) {
        [[NSUserDefaults standardUserDefaults] setObject:selectedCode forKey:@"DYYYCustomCityCode"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DYYYEnableCustomArea"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *location = (provinceName.length > 0 && cityName.length > 0) 
            ? [NSString stringWithFormat:@"%@ %@", provinceName, cityName] 
            : (cityName ?: provinceName);
        [DYYYManager showToast:[NSString stringWithFormat:@"已设置属地为: %@", location]];
    }
}

// 处理长按事件
%new
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"时间和属地设置" 
                                                                  message:@"请选择操作" 
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 时间日期选项
    BOOL dateTimeEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYShowDateTime"];
    NSString *dateTimeTitle = dateTimeEnabled ? @"关闭日期时间显示" : @"开启日期时间显示";
    
    [alert addAction:[UIAlertAction actionWithTitle:dateTimeTitle
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:!dateTimeEnabled forKey:@"DYYYShowDateTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [DYYYManager showToast:dateTimeEnabled ? @"已关闭日期时间显示" : @"已更新设置"];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"设置日期时间格式"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self showDateTimeFormatSelector];
    }]];
    
    // 属地设置选项
    [alert addAction:[UIAlertAction actionWithTitle:@"选择自定义属地"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        [self showCitySelector];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"使用默认属地" 
                                              style:UIAlertActionStyleDefault 
                                            handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYEnableCustomArea"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYCustomCityCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [DYYYManager showToast:@"已恢复默认属地"];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" 
                                              style:UIAlertActionStyleCancel 
                                            handler:nil]];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = gesture.view;
        alert.popoverPresentationController.sourceRect = gesture.view.bounds;
    }
    
    UIViewController *topVC = [DYYYManager getActiveTopController];
    [topVC presentViewController:alert animated:YES completion:nil];
}

+ (BOOL)shouldActiveWithData:(id)arg1 context:(id)arg2 {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableArea"] || 
           [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYShowDateTime"];
}

%end

%hook AWEPlayInteractionSpeedController

static CGFloat currentLongPressSpeed = 0;
static CGFloat initialTouchX = 0;
static BOOL isGestureActive = NO;

- (CGFloat)longPressFastSpeedValue {
    float longPressSpeed = DYYYGetFloat(@"DYYYLongPressSpeed");
    if (longPressSpeed == 0) {
        longPressSpeed = 2.0;
    }
    return longPressSpeed;
}

- (void)changeSpeed:(double)speed {
    float longPressSpeed = DYYYGetFloat(@"DYYYLongPressSpeed");

    if (isGestureActive && currentLongPressSpeed > 0) {
        %orig(currentLongPressSpeed);
        return;
    }

    if (speed == 2.0 && longPressSpeed != 0 && longPressSpeed != 2.0) {
        %orig(longPressSpeed);
        return;
    }

    if (speed <= 1.0 && dyyyLongPressLockedSpeedActive) {
        DYYYEndLockedLongPressSpeedAndRestoreIfNeeded();
    }

    %orig(speed);
}

- (void)handleLongPressFastSpeed:(UILongPressGestureRecognizer *)gesture {
    BOOL enableSpeedGesture = DYYYGetBool(@"DYYYEnableLongPressSpeedGesture");
    CGPoint location = [gesture locationInView:gesture.view];
    // 累计向下滑动距离（全局静态，跨 StateChanged 保持）
    static CGFloat cumulativeDownwardDistance = 0;
    // 记录本次长按的起始 Y 坐标，作为滑动距离计算的基准
    static CGFloat initialTouchY = 0;
    // 记录当前 HUD 上显示的档位索引，用于去抖（避免同档内重复更新）
    static NSInteger currentHUDSpeedIndex = -1;

    BOOL isBeginning = gesture.state == UIGestureRecognizerStateBegan;
    BOOL isEnding    = gesture.state == UIGestureRecognizerStateEnded ||
                       gesture.state == UIGestureRecognizerStateCancelled ||
                       gesture.state == UIGestureRecognizerStateFailed;
    BOOL isChanged   = gesture.state == UIGestureRecognizerStateChanged;

    // ── Began：初始化状态 ──────────────────────────────────────
    if (isBeginning) {
        cumulativeDownwardDistance = 0;
        currentHUDSpeedIndex = -1;
        initialTouchY = location.y;
        dyyyHidePlayInterfaceUI();
        dyyyLongPressFastSpeedActive = YES;
        dyyyLongPressLockedSpeedActive = NO;
        isGestureActive = YES;

        // 预读用户配置的默认长按倍速作为起始档位（最低 1.0x）
        float configured = DYYYGetFloat(@"DYYYLongPressSpeed");
        currentLongPressSpeed = (configured > 0.0f) ? configured : 1.0f;

        // Bug A fix: 不调用 %orig，避免内部触发 changeSpeed: 导致 hook 递归重入卡死主线程。
        // 所有倍速逻辑在本方法内自行处理。
    }

    // ── Ended / Cancelled / Failed：提交或恢复倍速 ────────────
    else if (isEnding) {
        isGestureActive = NO;
        dyyyShowPlayInterfaceUI();

        if (!enableSpeedGesture) {
            dyyyLongPressFastSpeedActive = NO;
            dyyyHideSpeedHUD();
            if (isEnding) DYYYScheduleConfiguredPlaybackSpeedRestore();
            // 清理静态状态
            cumulativeDownwardDistance = 0;
            currentHUDSpeedIndex = -1;
            initialTouchY = 0;
            currentLongPressSpeed = 0;
            return;
        }

        if (dyyyLongPressLockedSpeedActive) {
            // 锁定模式已激活，直接忽略本次结束事件
            dyyyLongPressFastSpeedActive = NO;
            dyyyHideSpeedHUD();
            cumulativeDownwardDistance = 0;
            currentHUDSpeedIndex = -1;
            initialTouchY = 0;
            currentLongPressSpeed = 0;
            return;
        }

        if (cumulativeDownwardDistance >= 30.0) {
            // 满足锁定条件：向下滑动 >= 30px → 锁定当前档位并应用
            CGFloat lockedSpeed = currentLongPressSpeed;
            dyyyLongPressLockedSpeedActive = YES;
            dyyyLongPressFastSpeedActive = NO;
            dyyyHideSpeedHUD();
            dispatch_async(dispatch_get_main_queue(), ^{
                [self changeSpeed:lockedSpeed];
                NSString *msg = [NSString stringWithFormat:@"已锁定 %.1fx 倍速", lockedSpeed];
                [DYYYToast showSuccessToastWithMessage:msg];
            });
        } else {
            // 未达锁定阈值：向下滑动不足 30px，恢复默认倍速
            dyyyLongPressFastSpeedActive = NO;
            dyyyHideSpeedHUD();
            DYYYScheduleConfiguredPlaybackSpeedRestore();
        }

        // 清理静态状态
        cumulativeDownwardDistance = 0;
        currentHUDSpeedIndex = -1;
        initialTouchY = 0;
        currentLongPressSpeed = 0;
        return;
    }

    // 功能未启用则不做任何操作
    if (!enableSpeedGesture) {
        return;
    }

    // ── Changed：根据累计向下距离更新档位与 HUD ───────────────
    if (isChanged && isGestureActive) {
        // Y 轴正方向向下（iOS view 坐标系）
        CGFloat currentY = location.y;
        CGFloat delta = currentY - initialTouchY;
        if (delta > 0) {
            cumulativeDownwardDistance += delta;
        }
        initialTouchY = currentY;

        // 根据累计距离计算当前档位索引（每 30px 一档）
        // 0~29px  -> index 0 -> 1.0x
        // 30~59px -> index 1 -> 1.5x
        // 60~89px -> index 2 -> 2.0x
        // 90~119px-> index 3 -> 2.5x
        // >=120px -> index 4+ -> 3.0x
        NSInteger newSpeedIndex = (NSInteger)(cumulativeDownwardDistance / 30.0);
        newSpeedIndex = MIN(newSpeedIndex, 5);

        if (newSpeedIndex != currentHUDSpeedIndex) {
            currentHUDSpeedIndex = newSpeedIndex;
            // 档位映射表
            float speedLevels[] = {1.0f, 1.5f, 2.0f, 2.5f, 3.0f, 3.0f};
            currentLongPressSpeed = speedLevels[newSpeedIndex];

            // 实时更新底部 HUD
            dyyyUpdateSpeedHUD(currentLongPressSpeed);

            // 异步更新播放器 rate，不阻塞主线程手势回调
            dispatch_async(dispatch_get_main_queue(), ^{
                [self changeSpeed:currentLongPressSpeed];
            });
        }
    }
}

- (void)handleLongPressLockedSpeedBegan {
    dyyyLongPressFastSpeedActive = YES;
    dyyyLongPressLockedSpeedActive = NO;
    %orig;
}

- (void)handleLongPressLockedDoubleSpeedChanged:(id)arg1 gesture:(UIGestureRecognizer *)gesture {
    dyyyLongPressFastSpeedActive = YES;
    dyyyLongPressLockedSpeedActive = NO;
    %orig(arg1, gesture);
}

- (void)handleLongPressLockedDoubleSpeedEnded:(id)arg1 gesture:(UIGestureRecognizer *)gesture {
    %orig(arg1, gesture);
    dyyyLongPressFastSpeedActive = NO;
    dyyyLongPressLockedSpeedActive = YES;
}

- (void)longPressSpeedControlDidChangeSpeed:(double)speed {
    %orig(speed);
    if (speed <= 1.0 && dyyyLongPressLockedSpeedActive) {
        DYYYEndLockedLongPressSpeedAndRestoreIfNeeded();
    }
}

// Bug B fix: allow the speed long-press gesture to recognize simultaneously with
// scroll / swipe gestures on sibling views, preventing gesture starvation.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
        [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}
%end
