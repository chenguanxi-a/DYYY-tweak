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

// ===== Profile 域 (76 个 hook) =====

%hook AWENormalModeTabBarGeneralPlusButton

- (void)didMoveToWindow {
    %orig;
    if (self.window && DYYYGetBool(@"DYYYisHiddenJia")) {
        self.userInteractionEnabled = NO;
        self.hidden = YES;
    }
}

- (void)layoutSubviews {
    %orig;
    if (DYYYGetBool(@"DYYYisHiddenJia")) {
        self.userInteractionEnabled = NO;
        self.hidden = YES;
    }
}

%end

%hook AWEHPTopTabItemTextContentView

- (void)layoutSubviews {
	%orig;

	NSString *topTitleConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYModifyTopTabText"];
	if (topTitleConfig.length == 0)
		return;

	NSArray *titlePairs = [topTitleConfig componentsSeparatedByString:@"#"];

	NSString *accessibilityLabel = nil;
	if ([self.superview respondsToSelector:@selector(accessibilityLabel)]) {
		accessibilityLabel = self.superview.accessibilityLabel;
	}
	if (accessibilityLabel.length == 0)
		return;

	for (NSString *pair in titlePairs) {
		NSArray *components = [pair componentsSeparatedByString:@"="];
		if (components.count != 2)
			continue;

		NSString *originalTitle = components[0];
		NSString *newTitle = components[1];

		if ([accessibilityLabel isEqualToString:originalTitle]) {
			if ([self respondsToSelector:@selector(setContentText:)]) {
				[self setContentText:newTitle];
			} else {
				[self setValue:newTitle forKey:@"contentText"];
			}
			break;
		}
	}
}

%end

%hook AWEFeedTableView
- (void)layoutSubviews {
    %orig;

    if (self.superview == nil) {
        return;
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
        CGRect frame = self.frame;
        frame.size.height = self.superview.frame.size.height;
        self.frame = frame;
    } else if (tabHeight > 0) {
        UIWindow *keyWindow = [DYYYManager getActiveWindow];
        if (keyWindow && keyWindow.safeAreaInsets.bottom == 0) {
            return;
        }
        CGRect frame = self.frame;
        frame.size.height = self.superview.frame.size.height - tabHeight;
        self.frame = frame;
    }
}
%end

%hook AWEConcernCellLastView
- (void)layoutSubviews {
    %orig;

    if (DYYYGetBool(@"DYYYEnableFullScreen") && tabHeight > 0) {
        for (UIView *subview in self.subviews) {
            CGRect frame = subview.frame;
            frame.origin.y -= tabHeight;
            subview.frame = frame;
        }
    }
}
%end

%hook AWESearchAnchorListModel

- (BOOL)hideWords {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"];
}

- (void)setHideWords:(BOOL)arg1 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		%orig(YES);
	} else {
		%orig(arg1);
	}
}

- (void)setScene:(id)arg1 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentViews"]) {
		NSDictionary *customScene = @{@"hideComments" : @YES};
		%orig(customScene);
	} else {
		%orig(arg1);
	}
}
%end

%hook AWEDiscoverFeedEntranceView
- (id)init {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideInteractionSearch"]) {
		return nil;
	}
	return %orig;
}
%end

%hook AWETemplateTagsCommonView

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTemplateTags"]) {
		UIView *parentView = self.superview;
		if (parentView) {
			parentView.hidden = YES;
		} else {
			self.hidden = YES;
		}
	}
}

%end

%hook AWEFeedStickerContainerView

- (BOOL)isHidden {
	BOOL origHidden = %orig;
	BOOL hideRecommend = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChallengeStickers"];
	return origHidden || hideRecommend;
}

- (void)setHidden:(BOOL)hidden {
	BOOL forceHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChallengeStickers"];
	%orig(forceHide ? YES : hidden);
}

%end

%hook AWEPostWorkViewController
- (BOOL)isDouGuideTipViewShow {
	BOOL r = %orig;
	NSLog(@"Original value: %@", @(r));
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideChallengeStickers"]) {
		NSLog(@"Force return YES");
		return YES;
	}
	return r;
}
%end

%hook AFDSkylightCellBubble
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideAvatarBubble"]) {
		[self removeFromSuperview];
		return;
	}
}
%end

%hook AWEFeedAnchorContainerView

- (BOOL)isHidden {
	BOOL origHidden = %orig;
	BOOL hideSamestyle = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFeedAnchorContainer"];
	return origHidden || hideSamestyle;
}

- (void)setHidden:(BOOL)hidden {
	BOOL forceHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFeedAnchorContainer"];
	%orig(forceHide ? YES : hidden);
}

%end

%hook AWEProfileNavigationButton
- (void)setupUI {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideButton"]) {
		return;
	}
	%orig;
}
%end

%hook AWEFeedUnfollowFamiliarFollowAndDislikeView
- (void)showUnfollowFamiliarView {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFamiliar"]) {
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AWEFamiliarNavView
- (void)layoutSubviews {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFamiliar"]) {
		self.hidden = YES;
	}

	%orig;
}
%end

%hook AWEFeedRelatedSearchTipView
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

%hook AWEAwemeModel

- (void)live_callInitWithDictyCategoryMethod:(id)arg1 {
    if (self.currentAweme && [self.currentAweme isLive] && [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYSkipLive"]) {
        return;
    }
    %orig;
}

+ (id)liveStreamURLJSONTransformer {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYSkipLive"] ? nil : %orig;
}

+ (id)relatedLiveJSONTransformer {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYSkipLive"] ? nil : %orig;
}

+ (id)rawModelFromLiveRoomModel:(id)arg1 {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYSkipLive"] ? nil : %orig;
}

+ (id)aweLiveRoom_subModelPropertyKey {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYSkipLive"] ? nil : %orig;
}

%new
- (BOOL)contentFilter {
	BOOL noAds = DYYYGetBool(@"DYYYNoAds");
	BOOL skipLive = DYYYGetBool(@"DYYYSkipLive");
	BOOL skipHotSpot = DYYYGetBool(@"DYYYSkipHotSpot");
	BOOL skipPhoto = DYYYGetBool(@"DYYYSkipPhoto");
	BOOL skipPhotoText = DYYYGetBool(@"DYYYSkipPhotoText");
	BOOL skipMusic = DYYYGetBool(@"DYYYSkipMusic");
	BOOL skipAIInteraction = DYYYGetBool(@"DYYYSkipAIInteraction");

	// P2-4：广告检测改用 DYYYUtils 统一判定，覆盖 checkIsAd/isHardAd/isAds 等明确广告标记
	BOOL shouldFilterAds = noAds && [DYYYUtils isAdvertisementAwemeModel:self];

	// P2-5：直播过滤改用 cellRoom != nil 或 videoFeedTag 判定，避免误杀带 liveReason 占位的非直播作品
	BOOL isLive = (self.cellRoom != nil) || [self.videoFeedTag isEqualToString:@"直播中"];
	BOOL shouldFilterRec = skipLive && isLive;

	BOOL shouldFilterHotSpot = skipHotSpot && self.hotSpotLynxCardModel;

	BOOL isRecommendFeed = [self.referString isEqualToString:@"homepage_hot"];
	BOOL shouldFilterPhoto = skipPhoto && (self.awemeType == 68) && isRecommendFeed;
	BOOL shouldFilterPhotoText = skipPhotoText && self.isNewTextMode && isRecommendFeed;
	BOOL shouldFilterMusic = skipMusic && (self.musicCard != nil) && isRecommendFeed;
	BOOL shouldFilterAIInteraction = skipAIInteraction && (self.awemeType == 162) && isRecommendFeed;

	BOOL shouldFilterLowLikes = NO;
	BOOL shouldFilterKeywords = NO;
	BOOL shouldFilterTime = NO;
	BOOL shouldFilterProp = NO;
	BOOL shouldFilterUser = NO;

	// 获取用户设置的需要过滤的关键词
	NSString *filterKeywords = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYFilterKeywords"];
	NSArray *keywordsList = nil;

	if (filterKeywords.length > 0) {
		keywordsList = [filterKeywords componentsSeparatedByString:@","];
	}

	// 过滤包含指定拍同款的视频
	NSString *filterProp = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYFilterProp"];
	NSArray *propKeywordsList = nil;

	if (filterProp.length > 0) {
		propKeywordsList = [filterProp componentsSeparatedByString:@","];
	}

	// 获取需要过滤的用户列表
	NSString *filterUsers = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYFilterUsers"];

	NSInteger filterLowLikesThreshold = [[NSUserDefaults standardUserDefaults] integerForKey:@"DYYYFilterLowLikes"];

	// 只有当shareRecExtra不为空时才过滤点赞量低的视频和关键词
	if (self.shareRecExtra && ![self.shareRecExtra isEqual:@""]) {
		// 过滤低点赞量视频
		if (filterLowLikesThreshold > 0) {
			AWESearchAwemeExtraModel *searchExtraModel = [self searchExtraModel];
			if (!searchExtraModel) {
				AWEAwemeStatisticsModel *statistics = self.statistics;
				if (statistics && statistics.diggCount) {
					shouldFilterLowLikes = statistics.diggCount.integerValue < filterLowLikesThreshold;
				}
			}
		}

		// 过滤包含特定关键词的视频
		if (keywordsList.count > 0) {
			// 检查视频标题
			if (self.itemTitle.length > 0) {
				for (NSString *keyword in keywordsList) {
					NSString *trimmedKeyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					if (trimmedKeyword.length > 0 && [self.itemTitle containsString:trimmedKeyword]) {
						shouldFilterKeywords = YES;
						break;
					}
				}
			}

			// 如果标题中没有关键词，检查标签(textExtras)
			if (!shouldFilterKeywords && self.textExtras.count > 0) {
				for (AWEAwemeTextExtraModel *textExtra in self.textExtras) {
					NSString *hashtagName = textExtra.hashtagName;
					if (hashtagName.length > 0) {
						for (NSString *keyword in keywordsList) {
							NSString *trimmedKeyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
							if (trimmedKeyword.length > 0 && [hashtagName containsString:trimmedKeyword]) {
								shouldFilterKeywords = YES;
								break;
							}
						}
						if (shouldFilterKeywords)
							break;
					}
				}
			}
		}

		// 过滤视频发布时间
		long long currentTimestamp = (long long)[[NSDate date] timeIntervalSince1970];
		NSInteger daysThreshold = [[NSUserDefaults standardUserDefaults] integerForKey:@"DYYYFilterTimeLimit"];
		if (daysThreshold > 0) {
			NSTimeInterval videoTimestamp = [self.createTime doubleValue];
			if (videoTimestamp > 0) {
				NSTimeInterval threshold = daysThreshold * 86400.0;
				NSTimeInterval current = (NSTimeInterval)currentTimestamp;
				NSTimeInterval timeDifference = current - videoTimestamp;
				shouldFilterTime = (timeDifference > threshold);
			}
		}
	}

	// 按用户 ID/昵称过滤（解析"昵称-id"格式）
	if (isRecommendFeed && filterUsers.length > 0 && self.author) {
		NSArray *usersList = [filterUsers componentsSeparatedByString:@","];
		NSString *currentShortID = self.author.shortID;

		if (currentShortID.length > 0) {
			for (NSString *userInfo in usersList) {
				NSArray *components = [userInfo componentsSeparatedByString:@"-"];
				if (components.count >= 2) {
					NSString *userId = [components lastObject];
					if ([userId isEqualToString:currentShortID]) {
						shouldFilterUser = YES;
						break;
					}
				}
			}
		}
	}

	// 仅在推荐页过滤拍同款道具
	if (isRecommendFeed && propKeywordsList.count > 0 && self.propGuideV2) {
		NSString *propName = self.propGuideV2.propName;
		if (propName.length > 0) {
			for (NSString *propKeyword in propKeywordsList) {
				NSString *trimmedKeyword = [propKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if (trimmedKeyword.length > 0 && [propName containsString:trimmedKeyword]) {
					shouldFilterProp = YES;
					break;
				}
			}
		}
	}

	return shouldFilterAds || shouldFilterRec || shouldFilterHotSpot || shouldFilterLowLikes || shouldFilterKeywords || shouldFilterTime ||
	       shouldFilterPhoto || shouldFilterPhotoText || shouldFilterMusic || shouldFilterAIInteraction || shouldFilterProp || shouldFilterUser;
}

- (id)initWithDictionary:(id)arg1 error:(id *)arg2 {
	id orig = %orig;
	return [self contentFilter] ? nil : orig;
}

- (id)init {
	id orig = %orig;
	return [self contentFilter] ? nil : orig;
}

- (bool)preventDownload {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoAds"]) {
		return NO;
	} else {
		return %orig;
	}
}

- (void)setAdLinkType:(long long)arg1 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoAds"]) {
		arg1 = 0;
	} else {
	}

	%orig;
}


%end

%hook AWEListDataController

- (void)setDataSource:(NSMutableArray *)dataSource {
    NSArray *filtered = [DYYYUtils arrayByRemovingAdvertisements:dataSource];
    %orig(filtered);
}

- (NSMutableArray *)dataSource {
    NSMutableArray *dataSource = %orig;
    NSArray *filtered = [DYYYUtils arrayByRemovingAdvertisements:dataSource];
    if (filtered != dataSource && [dataSource isKindOfClass:[NSMutableArray class]]) {
        [dataSource setArray:filtered];
    } else if (filtered != dataSource) {
        return [filtered mutableCopy];
    }
    return dataSource;
}

- (void)setFilteredDataSource:(NSMutableArray *)filteredDataSource {
    NSArray *filtered = [DYYYUtils arrayByRemovingAdvertisements:filteredDataSource];
    %orig(filtered);
}

- (NSMutableArray *)filteredDataSource {
    NSMutableArray *filteredDataSource = %orig;
    NSArray *filtered = [DYYYUtils arrayByRemovingAdvertisements:filteredDataSource];
    if (filtered != filteredDataSource && [filteredDataSource isKindOfClass:[NSMutableArray class]]) {
        [filteredDataSource setArray:filtered];
    } else if (filtered != filteredDataSource) {
        return [filtered mutableCopy];
    }
    return filteredDataSource;
}

%end

%hook AWEMixVideoListDataController

- (void)setDataSource:(id)dataSource {
    NSArray *filtered = [DYYYUtils arrayByRemovingAdvertisements:dataSource];
    %orig(filtered);
}

- (id)dataSource {
    id dataSource = %orig;
    NSArray *filtered = [DYYYUtils arrayByRemovingAdvertisements:dataSource];
    if (filtered != dataSource && [dataSource isKindOfClass:[NSMutableArray class]]) {
        [dataSource setArray:filtered];
    } else if (filtered != dataSource) {
        return filtered;
    }
    return dataSource;
}

%end

%hook AWEMixVideoDetailPlayListDataController

- (void)setDataSource:(id)dataSource {
    NSArray *filtered = [DYYYUtils arrayByRemovingAdvertisements:dataSource];
    %orig(filtered);
}

%end

%hook AWEMixVideoRelatedListDataController

- (void)setDataSource:(id)dataSource {
    NSArray *filtered = [DYYYUtils arrayByRemovingAdvertisements:dataSource];
    %orig(filtered);
}

- (id)dataSource {
    id dataSource = %orig;
    NSArray *filtered = [DYYYUtils arrayByRemovingAdvertisements:dataSource];
    if (filtered != dataSource && [dataSource isKindOfClass:[NSMutableArray class]]) {
        [dataSource setArray:filtered];
    } else if (filtered != dataSource) {
        return filtered;
    }
    return dataSource;
}

%end

%hook AWEHotListDataController

- (id)transferAwemeListIfNeededWithArray:(id)arg1 isInitFetch:(BOOL)arg2 {
    NSArray *orig = %orig;
    if (![orig isKindOfClass:[NSArray class]] || orig.count == 0) {
        return orig;
    }

    // --- 配置读取 ---
    NSInteger daysThreshold = DYYYGetInteger(@"DYYYFilterTimeLimit");
    BOOL skipLive = DYYYGetBool(@"DYYYSkipLive");
    NSInteger minLikesThreshold = DYYYGetInteger(@"DYYYFilterLowLikes");
    BOOL skipPhotoText = DYYYGetBool(@"DYYYSkipPhotoText");
    BOOL skipPhoto = DYYYGetBool(@"DYYYSkipPhoto");
    BOOL skipMusic = DYYYGetBool(@"DYYYSkipMusic");
    BOOL noAds = DYYYGetBool(@"DYYYNoAds");

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval thresholdInSeconds = MAX(daysThreshold, 0) * 86400.0;

    NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:orig.count];

    for (id obj in orig) {
        if (![obj isKindOfClass:%c(AWEAwemeModel)]) {
            [filtered addObject:obj];
            continue;
        }

        AWEAwemeModel *m = (AWEAwemeModel *)obj;

        // 1. 广告过滤：合集、搜索内流、分页追加等旁路也会进入此共享转换。
        if (noAds && [DYYYUtils isAdvertisementAwemeModel:m]) {
            continue;
        }

        // 2. 直播过滤逻辑 (仅依赖 cellRoom / videoFeedTag)
        if (skipLive &&
            [m respondsToSelector:@selector(cellRoom)] && m.cellRoom != nil) {
            continue;
        }
        if (skipLive &&
            [m respondsToSelector:@selector(videoFeedTag)] &&
            [m.videoFeedTag isEqualToString:@"直播中"]) {
            continue;
        }

        // 2.1 图文模式过滤逻辑（推荐页）
        if (skipPhotoText &&
            [m respondsToSelector:@selector(isNewTextMode)] &&
            m.isNewTextMode &&
            [m respondsToSelector:@selector(referString)] &&
            [m.referString isEqualToString:@"homepage_hot"]) {
            continue;
        }

        // 2.2 图集过滤逻辑（推荐页）
        if (skipPhoto &&
            [m respondsToSelector:@selector(awemeType)] &&
            m.awemeType == 68 &&
            [m respondsToSelector:@selector(referString)] &&
            [m.referString isEqualToString:@"homepage_hot"]) {
            continue;
        }

        // 2.3 音乐过滤逻辑（推荐页）
        if (skipMusic &&
            [m respondsToSelector:@selector(referString)] &&
            [m.referString isEqualToString:@"homepage_hot"] &&
            [m respondsToSelector:@selector(musicCard)] &&
            m.musicCard) {
            continue;
        }

        // 3. 时间限制过滤
        if (daysThreshold > 0 && [m respondsToSelector:@selector(createTime)]) {
            NSTimeInterval vTs = [m.createTime doubleValue];
            if (vTs > 1e12) {
                vTs /= 1000.0; // 毫秒转秒
            }

            if (vTs > 0 && (now - vTs) > thresholdInSeconds) {
                continue;
            }
        }

        // 4. 低赞过滤：字段缺失时放行；能解析到数值时严格按阈值过滤。
        if (minLikesThreshold > 0) {
            AWEAwemeStatisticsModel *statistics = nil;
            if ([m respondsToSelector:@selector(statistics)]) {
                statistics = m.statistics;
            }
            NSNumber *diggCount = statistics.diggCount;
            if (diggCount && diggCount.integerValue < minLikesThreshold) {
                continue;
            }
        }

        [filtered addObject:obj];
    }

    return [filtered copy];
}

%end

%hook AWEGeneralSearchModel
- (instancetype)initWithDictionary:(id)dict error:(NSError **)error {
	id orig = %orig;

	BOOL noAds = DYYYGetBool(@"DYYYNoAds");
	if (!noAds || !orig) {
		return orig;
	}

	if ([DYYYUtils isAdvertisementContainerModel:orig] || [DYYYUtils isAdvertisementRawData:dict]) {
		return nil;
	}

	return orig;
}
%end

%hook AWENormalModeTabBarBadgeContainerView

- (void)layoutSubviews {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideBottomDot"]) {
        for (UIView *subview in [self subviews]) {
            if ([subview isKindOfClass:NSClassFromString(@"DUXBadge")]) {
                [subview setHidden:YES];
            }
        }
    }
}

%end

%hook ACCStickerContainerView
- (void)layoutSubviews {
	// 类型安全检查 + 隐藏逻辑
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideInteractionSearch"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES; // 隐藏更彻底
		return;
	}
	%orig;
}
%end

%hook AWEVideoTypeTagView

- (void)setupUI {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYHideLiveGIF"])
		%orig;
}
%end

%hook AWELeftSideBarEntranceView

- (void)layoutSubviews {

	__block BOOL isInTargetController = NO;
	UIResponder *currentResponder = self;

	while ((currentResponder = [currentResponder nextResponder])) {
		if ([currentResponder isKindOfClass:NSClassFromString(@"AWEUserHomeViewControllerV2")]) {
			isInTargetController = YES;
			break;
		}
	}

	if (!isInTargetController && [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLeftSideBar"]) {
		for (UIView *subview in self.subviews) {
			subview.hidden = YES;
		}
	}
}

- (void)setRedDot:(id)redDot {
    %orig(nil); 
}

- (void)setNumericalRedDot:(id)numericalRedDot {
    %orig(nil); 
}

%end

%hook AWENearbySkyLightCapsuleView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideNearbyCapsuleView"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AWENormalModeTabBar

static Class barBackgroundClass = nil;
static Class generalButtonClass = nil;
static Class plusContainerButtonClass = nil;
static Class plusButtonClass = nil;
static Class plusInnerButtonClass = nil;
static Class tabBarButtonClass = nil;

+ (void)initialize {
    if (self == [%c(AWENormalModeTabBar) class]) {
        barBackgroundClass = NSClassFromString(@"_UIBarBackground");
        generalButtonClass = %c(AWENormalModeTabBarGeneralButton);
        plusContainerButtonClass = %c(AWENormalModeTabBarPlusButton);
        plusButtonClass = %c(AWENormalModeTabBarGeneralPlusButton);
        plusInnerButtonClass = NSClassFromString(@"AWENormalModeTabBarGeneralPlusInnerButton");
        tabBarButtonClass = %c(UITabBarButton);
    }
}

%new
- (void)dyyy_initializeOriginalTabBarHeight {
    if (originalTabHeight > 0) {
        if (tabHeight <= 0) {
            tabHeight = originalTabHeight;
        }
        return;
    }

    UIWindow *targetWindow = self.window ?: [DYYYManager getActiveWindow];
    if (self.frame.size.height >= 30) {
        originalTabHeight = self.frame.size.height;
    } else if (targetWindow) {
        CGFloat bottomInset = 0;
        if (@available(iOS 11.0, *)) {
            bottomInset = targetWindow.safeAreaInsets.bottom;
        }
        originalTabHeight = 49 + bottomInset;
    }
    if (originalTabHeight > 0 && tabHeight <= 0) {
        tabHeight = originalTabHeight;
    }
}

- (void)didMoveToWindow {
    %orig;
    if (self.window) {
        [self performSelector:@selector(dyyy_initializeOriginalTabBarHeight)];
    }
}

- (void)layoutSubviews {
    %orig;

    if (originalTabHeight <= 0) {
        [self performSelector:@selector(dyyy_initializeOriginalTabBarHeight)];
    }

    if (tabHeight <= 0 && originalTabHeight > 0) {
        tabHeight = originalTabHeight;
    }

    CGFloat customHeight = DYYYGetFloat(@"DYYYTabBarHeight");
    if (customHeight > 0) {
        tabHeight = customHeight;
    } else if (originalTabHeight > 0) {
        tabHeight = originalTabHeight;
    } else {
        tabHeight = self.frame.size.height;
    }

    if (tabHeight <= 0)
        return;

    if ([self respondsToSelector:@selector(setDesiredHeight:)]) {
        ((void (*)(id, SEL, double))objc_msgSend)(self, @selector(setDesiredHeight:), tabHeight);
    }

    if (fabs(self.frame.size.height - tabHeight) > 0.1) {
        CGRect frame = self.frame;
        frame.size.height = tabHeight;
        if (self.superview) {
            frame.origin.y = self.superview.bounds.size.height - tabHeight;
        }
        self.frame = frame;
    }

    BOOL hideShop = DYYYGetBool(@"DYYYHideShopButton");
    BOOL hideMsg = DYYYGetBool(@"DYYYHideMessageButton");
    BOOL hideFri = DYYYGetBool(@"DYYYHideFriendsButton");
    BOOL hideMe = DYYYGetBool(@"DYYYHideMyButton");
    BOOL hidePlus = DYYYGetBool(@"DYYYisHiddenJia");
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

    NSMutableArray *visibleButtons = [NSMutableArray array];
    UIView *ipadContainerView = nil;

    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:generalButtonClass] || [subview isKindOfClass:plusContainerButtonClass] || [subview isKindOfClass:plusButtonClass] ||
            (plusInnerButtonClass && [subview isKindOfClass:plusInnerButtonClass])) {
            NSString *label = subview.accessibilityLabel;
            BOOL isPlusButton = [subview isKindOfClass:plusContainerButtonClass] || [subview isKindOfClass:plusButtonClass] ||
                                (plusInnerButtonClass && [subview isKindOfClass:plusInnerButtonClass]) ||
                                [label isEqualToString:@"拍摄"];
            BOOL shouldHide = (isPlusButton && hidePlus) || ([label containsString:@"商城"] && hideShop) || ([label containsString:@"消息"] && hideMsg) || ([label containsString:@"朋友"] && hideFri) ||
                              ([label isEqualToString:@"我"] && hideMe);

            subview.userInteractionEnabled = !shouldHide;
            subview.hidden = shouldHide;

            if (!shouldHide) {
                [visibleButtons addObject:subview];
            }
        } else if ([subview isKindOfClass:tabBarButtonClass]) {
            subview.userInteractionEnabled = NO;
            subview.hidden = YES;
        } else if (isPad && !ipadContainerView && [subview isMemberOfClass:UIView.class] && fabs(subview.frame.size.width - self.bounds.size.width) > 0.1) {
            ipadContainerView = subview;
        }
    }

    [visibleButtons sortUsingComparator:^NSComparisonResult(UIView *a, UIView *b) {
      return [@(a.frame.origin.x) compare:@(b.frame.origin.x)];
    }];

    CGFloat offsetX, totalWidth;
    if (ipadContainerView) {
        offsetX = ipadContainerView.frame.origin.x;
        totalWidth = ipadContainerView.bounds.size.width;
    } else {
        offsetX = 0;
        totalWidth = self.bounds.size.width;
    }
    CGFloat buttonWidth = (visibleButtons.count > 0) ? (totalWidth / visibleButtons.count) : 0;

    // 均匀布局按钮
    for (NSInteger i = 0; i < visibleButtons.count; i++) {
        UIView *button = visibleButtons[i];
        button.frame = CGRectMake(offsetX + i * buttonWidth, button.frame.origin.y, buttonWidth, button.frame.size.height);
    }

    // 禁用首页刷新功能
    if (DYYYGetBool(@"DYYYDisableHomeRefresh")) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:generalButtonClass]) {
                AWENormalModeTabBarGeneralButton *button = (AWENormalModeTabBarGeneralButton *)subview;
                if ([button.accessibilityLabel isEqualToString:@"首页"]) {
                    // status == 2 表示选中状态
                    button.userInteractionEnabled = (button.status != 2);
                }
            }
        }
    }

    // 背景和分隔线处理
    BOOL hideBottomBg = DYYYGetBool(@"DYYYHideBottomBg");
    BOOL enableFullScreen = DYYYGetBool(@"DYYYEnableFullScreen");

    if (hideBottomBg || enableFullScreen) {
        if (self.skinContainerView) {
            self.skinContainerView.hidden = YES;
        }

        BOOL isHomeSelected = NO;
        BOOL isFriendsSelected = NO;

        if (enableFullScreen && !hideBottomBg) {
            for (UIView *subview in self.subviews) {
                if ([subview isKindOfClass:generalButtonClass]) {
                    AWENormalModeTabBarGeneralButton *button = (AWENormalModeTabBarGeneralButton *)subview;
                    if (button.status == 2) {
                        if ([button.accessibilityLabel isEqualToString:@"首页"])
                            isHomeSelected = YES;
                        else if ([button.accessibilityLabel containsString:@"朋友"])
                            isFriendsSelected = YES;
                    }
                }
            }
        }

        BOOL hideFriendsButton = DYYYGetBool(@"DYYYHideFriendsButton");
        BOOL shouldHideBackgrounds = hideBottomBg || (enableFullScreen && (isHomeSelected || (isFriendsSelected && !hideFriendsButton)));

        // 单次遍历处理所有背景和分割线
        for (UIView *subview in self.subviews) {
            // 跳过底栏按钮
            if ([subview isKindOfClass:generalButtonClass] || [subview isKindOfClass:plusContainerButtonClass] || [subview isKindOfClass:plusButtonClass] ||
                (plusInnerButtonClass && [subview isKindOfClass:plusInnerButtonClass])) {
                continue;
            }
            // 隐藏底栏背景
            if ([subview isKindOfClass:barBackgroundClass] || ([subview isMemberOfClass:[UIView class]] && originalTabHeight > 0 && fabs(subview.frame.size.height - tabHeight) < 0.1)) {
                subview.hidden = shouldHideBackgrounds;
            }
            // 隐藏细分割线
            if (subview.frame.size.height > 0 && subview.frame.size.height < 1 && subview.frame.size.width > 300) {
                subview.hidden = enableFullScreen;
            }
        }
    } else {
        if (self.skinContainerView) {
            self.skinContainerView.hidden = NO;
        }

        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:barBackgroundClass] || [subview isMemberOfClass:[UIView class]]) {
                subview.hidden = NO;
            }
        }
    }
}

- (void)setHidden:(BOOL)hidden {
    %orig(hidden);

    BOOL disableHomeRefresh = DYYYGetBool(@"DYYYDisableHomeRefresh");
    BOOL enableFullScreen = DYYYGetBool(@"DYYYEnableFullScreen");
    BOOL hideBottomBg = DYYYGetBool(@"DYYYHideBottomBg");
    BOOL hideFriendsButton = DYYYGetBool(@"DYYYHideFriendsButton");

    BOOL isHomeSelected = NO;
    BOOL isFriendsSelected = NO;

    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:generalButtonClass]) {
            AWENormalModeTabBarGeneralButton *button = (AWENormalModeTabBarGeneralButton *)subview;

            // 禁用首页刷新功能
            if (disableHomeRefresh && [button.accessibilityLabel isEqualToString:@"首页"]) {
                button.userInteractionEnabled = (button.status != 2);
            }

            // 检查当前选中的页
            if (enableFullScreen && button.status == 2) {
                if ([button.accessibilityLabel isEqualToString:@"首页"]) {
                    isHomeSelected = YES;
                } else if ([button.accessibilityLabel containsString:@"朋友"]) {
                    isFriendsSelected = YES;
                }
            }
        }
    }

    if (hideBottomBg || enableFullScreen) {
        if (self.skinContainerView) {
            self.skinContainerView.hidden = YES;
        }

        BOOL shouldHideBackgrounds = NO;
        if (hideBottomBg) {
            shouldHideBackgrounds = YES;
        } else if (enableFullScreen) {
            shouldHideBackgrounds = isHomeSelected || (isFriendsSelected && !hideFriendsButton);
        }

        // 处理所有背景和分割线
        for (UIView *subview in self.subviews) {
            CGFloat subviewHeight = subview.frame.size.height;
            // 跳过底栏按钮
            if ([subview isKindOfClass:generalButtonClass] || [subview isKindOfClass:plusContainerButtonClass] || [subview isKindOfClass:plusButtonClass] ||
                (plusInnerButtonClass && [subview isKindOfClass:plusInnerButtonClass])) {
                continue;
            }
            // 隐藏底栏背景
            if ([subview isKindOfClass:barBackgroundClass] || ([subview isMemberOfClass:[UIView class]] && originalTabHeight > 0 && fabs(subviewHeight - tabHeight) < 0.1)) {
                subview.hidden = shouldHideBackgrounds;
            }
            // 隐藏细分割线
            if (subviewHeight > 0 && subviewHeight < 1 && subview.frame.size.width > 300) {
                subview.hidden = enableFullScreen;
            }
        }
    } else {
        if (self.skinContainerView) {
            self.skinContainerView.hidden = NO;
        }
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:barBackgroundClass] || [subview isMemberOfClass:[UIView class]]) {
                subview.hidden = NO;
            }
        }
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    %orig(previousTraitCollection);
}

%end

%hook AWENormalModeTabBarGeneralButton

- (void)layoutSubviews {
    %orig;
}

- (void)setStatus:(NSInteger)status {
    %orig(status);
}

%end

%hook AWEHPSearchBubbleEntranceView
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideSearchBubble"]) {
		[self removeFromSuperview];
		return;
	}
}

%end

%hook AWENormalModeTabBarTextView

- (void)layoutSubviews {
    %orig;
    
    NSString *indexTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYIndexTitle"];
    NSString *friendsTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYFriendsTitle"];
    NSString *msgTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYMsgTitle"];
    NSString *selfTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYSelfTitle"];
    
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if ([label.text isEqualToString:@"首页"]) {
                if (indexTitle.length > 0) {
                    [label setText:indexTitle];
                    [self setNeedsLayout];
                }
            }
            if ([label.text isEqualToString:@"朋友"]) {
                if (friendsTitle.length > 0) {
                    [label setText:friendsTitle];
                    [self setNeedsLayout];
                }
            }
            if ([label.text isEqualToString:@"消息"]) {
                if (msgTitle.length > 0) {
                    [label setText:msgTitle];
                    [self setNeedsLayout];
                }
            }
            if ([label.text isEqualToString:@"我"]) {
                if (selfTitle.length > 0) {
                    [label setText:selfTitle];
                    [self setNeedsLayout];
                }
            }
        }
    }
}
%end

%hook AWEFeedChannelManager

- (void)reloadChannelWithChannelModels:(id)arg1 currentChannelIDList:(id)arg2 reloadType:(id)arg3 selectedChannelID:(id)arg4 {
    NSArray *channelModels = arg1;
    NSMutableArray *newChannelModels = [NSMutableArray array];
    NSArray *currentChannelIDList = arg2;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *newCurrentChannelIDList = [NSMutableArray arrayWithArray:currentChannelIDList];
    
    for (AWEHPTopTabItemModel *tabItemModel in channelModels) {
        NSString *channelID = tabItemModel.channelID;
        
        if ([channelID isEqualToString:@"homepage_hot_container"]) {
            [newChannelModels addObject:tabItemModel];
            continue;
        }
        
        BOOL isHideChannel = NO;
        if ([channelID isEqualToString:@"homepage_follow"]) {
            isHideChannel = [defaults boolForKey:@"DYYYHideFollow"];
        } else if ([channelID isEqualToString:@"homepage_mediumvideo"]) {
            isHideChannel = [defaults boolForKey:@"DYYYHideMediumVideo"];
        } else if ([channelID isEqualToString:@"homepage_mall"]) {
            isHideChannel = [defaults boolForKey:@"DYYYHideMall"];
        } else if ([channelID isEqualToString:@"homepage_nearby"]) {
            isHideChannel = [defaults boolForKey:@"DYYYHideNearby"];
        } else if ([channelID isEqualToString:@"homepage_groupon"]) {
            isHideChannel = [defaults boolForKey:@"DYYYHideGroupon"];
        } else if ([channelID isEqualToString:@"homepage_tablive"]) {
            isHideChannel = [defaults boolForKey:@"DYYYHideTabLive"];
        } else if ([channelID isEqualToString:@"homepage_pad_hot"]) {
            isHideChannel = [defaults boolForKey:@"DYYYHidePadHot"];
        } else if ([channelID isEqualToString:@"homepage_hangout"]) {
            isHideChannel = [defaults boolForKey:@"DYYYHideHangout"];
        } else if ([channelID isEqualToString:@"homepage_familiar"]) {
            isHideChannel = [defaults boolForKey:@"DYYYHideFriend"];
        }
        
        if (!isHideChannel) {
            [newChannelModels addObject:tabItemModel];
        } else {
            [newCurrentChannelIDList removeObject:channelID];
        }
    }
    
    %orig(newChannelModels, newCurrentChannelIDList, arg3, arg4);
}

%end

%hook AWEFeedRootViewController
- (BOOL)prefersStatusBarHidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideStatusbar"]) {
		return YES;
	} else {
		if (class_getInstanceMethod([self class], @selector(prefersStatusBarHidden)) !=
		    class_getInstanceMethod([%c(AWEFeedRootViewController) class], @selector(prefersStatusBarHidden))) {
			return %orig;
		}
		return NO;
	}
}
%end

%hook AWEBaseListViewController
- (void)viewDidLayoutSubviews {
    %orig;
    if (DYYYGetBool(@"DYYYEnableCommentBlur") && [self isKindOfClass:NSClassFromString(@"AWECommentPanelContainerSwiftImpl.CommentContainerInnerViewController")]) {
        float userTransparency = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYCommentBlurTransparent"] floatValue];
        if (userTransparency <= 0 || userTransparency > 1) {
            userTransparency = 0.9;
        }
        [DYYYUtils applyBlurEffectToView:self.view transparency:userTransparency blurViewTag:999];
    }
}
%end

%hook AWEListKitMagicCollectionView

- (void)layoutSubviews {
    %orig;

    if (!DYYYGetBool(@"DYYYEnableCommentBlur")) {
        return;
    }

    UICollectionView *collectionView = (UICollectionView *)self;

    UIView *superview = collectionView.superview;
    CGRect targetFrame = superview.bounds;
    if (superview == nil || CGSizeEqualToSize(targetFrame.size, CGSizeZero) || CGRectEqualToRect(collectionView.frame, targetFrame)) {
        return;
    }

    collectionView.frame = targetFrame;

    CGFloat commentOffset = 166.0;

    UIEdgeInsets inset = collectionView.contentInset;
    inset.bottom = commentOffset;
    collectionView.contentInset = inset;
    collectionView.scrollIndicatorInsets = inset;
}

%end

%hook BDMultiContentContainer_ImageContentView

- (void)setTransform:(CGAffineTransform)transform {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableCommentBlur"]) {
        return;
    }
    %orig(transform);
}

%end

%hook AWEAwemeDetailTableView

- (void)setFrame:(CGRect)frame {
	// 检查是否启用了全屏模式（通过用户默认设置）
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
		// 获取设备屏幕的高度
		CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

		// 计算frame高度与屏幕高度的余数
		CGFloat remainder = fmod(frame.size.height, screenHeight);
		// 如果余数不为0，说明高度不是屏幕高度的整数倍
		if (remainder != 0) {
			// 调整frame高度，使其成为屏幕高度的整数倍，确保视图填满整个屏幕
			frame.size.height += (screenHeight - remainder);
		}
	}
	// 调用原始的setFrame:方法来设置调整后的frame
	%orig(frame);
}

%end

%hook AWEMixVideoPanelMoreView

// 调整视频面板的框架位置，实现全屏显示效果
- (void)setFrame:(CGRect)frame {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
		// 计算目标Y坐标，减去底部标签栏的高度
		CGFloat targetY = frame.origin.y - tabHeight;
		CGFloat screenHeightMinusGDiff = [UIScreen mainScreen].bounds.size.height - tabHeight;

		// 设置误差容忍度，防止精度问题
		CGFloat tolerance = 10.0;

		// 只有当接近屏幕底部时才调整位置
		if (fabs(targetY - screenHeightMinusGDiff) <= tolerance) {
			frame.origin.y = targetY;
		}
	}
	%orig(frame);
}

// 使视频面板背景透明，增强全屏体验
- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
		self.backgroundColor = [UIColor clearColor];
	}
}

%end

%hook AWEAwemeDetailTableViewController
- (BOOL)prefersStatusBarHidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideStatusbar"]) {
		return YES;
	} else {
		if (class_getInstanceMethod([self class], @selector(prefersStatusBarHidden)) !=
		    class_getInstanceMethod([%c(AWEAwemeDetailTableViewController) class], @selector(prefersStatusBarHidden))) {
			return %orig;
		}
		return NO;
	}
}
%end

%hook AWEAwemeHotSpotTableViewController
- (BOOL)prefersStatusBarHidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideStatusbar"]) {
		return YES;
	} else {
		return %orig;
	}
}
%end

%hook AWEFullPageFeedNewContainerViewController
- (BOOL)prefersStatusBarHidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideStatusbar"]) {
		return YES;
	} else {
		if (class_getInstanceMethod([self class], @selector(prefersStatusBarHidden)) !=
		    class_getInstanceMethod([%c(AWEFullPageFeedNewContainerViewController) class], @selector(prefersStatusBarHidden))) {
			return %orig;
		}
		return NO;
	}
}
%end

%hook AWEHPTopTabItemBadgeContentView

- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLiveCapsuleView"]) {
		self.frame = CGRectMake(0, 0, 0, 0);
		self.hidden = YES;
	}
}

// 隐藏顶栏红点
- (id)showBadgeWithBadgeStyle:(NSUInteger)style badgeConfig:(id)config count:(NSInteger)count text:(id)text {
	BOOL hideEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTopBarBadge"];

	if (hideEnabled) {
		// 阻断徽章创建
		return nil; // 返回 nil 阻止视图生成
	} else {
		// 未启用隐藏功能时正常显示
		return %orig(style, config, count, text);
	}
}

%end

%hook AWEHPDiscoverFeedEntranceView
- (void)setAlpha:(CGFloat)alpha {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDiscover"]) {
        alpha = 0;
        %orig(alpha);
   }else {
       %orig;
    }
}

// 隐藏右上搜索，但可点击
- (void)layoutSubviews {
    %orig;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDiscover"]) {
        UIView *firstSubview = self.subviews.firstObject;
        if ([firstSubview isKindOfClass:[UIImageView class]]) {
            ((UIImageView *)firstSubview).image = nil;
        }
    }
}

%end

%hook AWEFeedTemplateAnchorView

- (void)layoutSubviews {
	%orig;

	BOOL hideFeedAnchor = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideFeedAnchorContainer"];
	BOOL hideLocation = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideLocation"];

	if (!hideFeedAnchor && !hideLocation)
		return;

	AWECodeGenCommonAnchorBasicInfoModel *anchorInfo = [self valueForKey:@"templateAnchorInfo"];
	if (!anchorInfo || ![anchorInfo respondsToSelector:@selector(name)])
		return;

	NSString *name = [anchorInfo valueForKey:@"name"];
	BOOL isPoi = [name isEqualToString:@"poi_poi"];

	if ((hideFeedAnchor && !isPoi) || (hideLocation && isPoi)) {
		UIView *parentView = self.superview;
		if (parentView) {
			parentView.hidden = YES;
		}
	}
}

%end

%hook AWEUserTabListModel

- (NSInteger)profileLandingTab {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDefaultEnterWorks"]) {
		return 0;
	} else {
		return %orig;
	}
}

%end

%hook AWENormalModeTabBarFeedView
- (void)layoutSubviews {
    %orig;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideDoubleColumnEntry"]) {
        for (UIView *subview in self.subviews) {
            if (![subview isKindOfClass:[UILabel class]]) {
                subview.hidden = YES;
            }
        }
    }
}
%end

%hook AWEHPTopBarCTAItemView

- (void)showRedDot {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYHideSidebarDot"])
		%orig;
}

- (void)hideCountRedDot {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYHideSidebarDot"])
		%orig;
}

- (void)layoutSubviews {
	%orig;
	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:[%c(DUXBadge) class]]) {
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideSidebarDot"]) {
				subview.hidden = YES;
			}
		}
	}
}
%end

%hook AWETemplateCommonView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCameraLocation"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AWETemplatePlayletView

- (void)layoutSubviews {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideTemplatePlaylet"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AWESearchEntranceView

- (void)layoutSubviews {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideSearchEntrance"]) {
		self.hidden = YES;
		return;
	}

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideSearchEntranceIndicator"]) {
		for (UIView *subview in self.subviews) {
			if ([subview isKindOfClass:[UIImageView class]] && [NSStringFromClass([((UIImageView *)subview).image class]) isEqualToString:@"_UIResizableImage"]) {
				((UIImageView *)subview).hidden = YES;
			}
		}
	}

	%orig;
}

%end

%hook AWENewHotSpotBottomBarView
- (void)layoutSubviews {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideHotspot"]) {
		if ([self respondsToSelector:@selector(removeFromSuperview)]) {
			[self removeFromSuperview];
		}
		self.hidden = YES;
		return;
	}
	%orig;
}
%end

%hook AWEAwesomeSplashFeedCellOldAccessoryView

// 在方法入口处添加控制逻辑
- (id)ddExtraView {
	// 检查用户是否启用了无广告模式
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoAds"]) {
		return NULL; // 返回空视图
	}

	// 正常模式调用原始方法
	return %orig;
}

%end

%hook AWEConcernSkylightCapsuleView
- (void)setHidden:(BOOL)hidden {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideConcernCapsuleView"]) {
		[self removeFromSuperview];
		return;
	}

	%orig(hidden);
}
%end

%hook AWEFeedMultiTabSelectedContainerView

- (void)setHidden:(BOOL)hidden {
	BOOL forceHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidentopbarprompt"];

	if (forceHide) {
		%orig(YES);
	} else {
		%orig(hidden);
	}
}

%end

%hook AFDRecommendToFriendEntranceLabel
- (void)layoutSubviews {
	%orig;  // 调用原始方法
	
	// 检查是否启用了"隐藏推荐提示"的设置
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideRecommendTips"]) {
		// 确认视图有可访问性标签后移除此视图
		if (self.accessibilityLabel) {
			[self removeFromSuperview];  // 从父视图中移除该推荐入口标签
		}
	}
}

%end

%hook AWEProfileMixItemCollectionViewCell
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePostView"]) {
		if ([self.accessibilityLabel isEqualToString:@"私密作品"]) {
			[self removeFromSuperview];
		}
	}
}
%end

%hook AWEProfileMixCollectionViewCell
- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePostView"]) {
		self.hidden = YES;
	}
}
%end

%hook AWENearbyFullScreenViewModel

- (void)setShowSkyLight:(id)arg1 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMenuView"]) {
		arg1 = nil;
	}
	%orig(arg1);
}

- (void)setHaveSkyLight:(id)arg1 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideMenuView"]) {
		arg1 = nil;
	}
	%orig(arg1);
}

%end

%hook AWEProfileTaskCardStyleListCollectionViewCell
- (BOOL)shouldShowPublishGuide {
	// 检查是否启用了隐藏作品视图的设置
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePostView"]) {
		return NO;  // 返回NO以隐藏发布引导提示
	}
	return %orig;  // 返回原始实现结果
}
%end

%hook AWEProfileRichEmptyView

- (void)setTitle:(id)title {
	// 如果启用了隐藏作品视图的设置，则跳过设置标题
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePostView"]) {
		return;  // 直接返回，不设置标题
	}
	%orig(title);  // 调用原始实现设置标题
}

- (void)setDetail:(id)detail {
	// 如果启用了隐藏作品视图的设置，则跳过设置详情文本
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePostView"]) {
		return;  // 直接返回，不设置详情文本
	}
	%orig(detail);  // 调用原始实现设置详情文本
}
%end

%hook AWECorrelationItemTag

- (void)layoutSubviews {
	%orig;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideItemTag"]) {
		self.frame = CGRectMake(0, 0, 0, 0);
		self.hidden = YES;
	}
}

%end

%hook AWENormalModeTabBarGeneralButton

- (BOOL)enableRefresh {
	if ([self.accessibilityLabel isEqualToString:@"首页"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYDisableHomeRefresh"]) {
			return NO;
		}
	}
	return %orig;
}

%end

%hook AWEVersionUpdateManager

- (void)startVersionUpdateWorkflow:(id)arg1 completion:(id)arg2 {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoUpdates"]) {
		if (arg2) {
			void (^completionBlock)(void) = arg2;
			completionBlock();
		}
	} else {
		%orig;
	}
}

- (id)workflow {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoUpdates"] ? nil : %orig;
}

- (id)badgeModule {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYNoUpdates"] ? nil : %orig;
}

%end

%hook AFDProfileAvatarFunctionManager
- (BOOL)shouldShowSaveAvatarItem {
	BOOL shouldEnable = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableSaveAvatar"];
	if (shouldEnable) {
		return YES;
	}
	return %orig;
}
%end

%hook AWESettingsViewModel

- (NSArray *)sectionDataArray {
    NSArray *originalSections = %orig;
    
    BOOL sectionExists = NO;
    for (AWESettingSectionModel *section in originalSections) {
        if ([section.sectionHeaderTitle isEqualToString:@"DYYY"]) {
            sectionExists = YES;
            break;
        }
    }
    
    if (!sectionExists) {
        AWESettingItemModel *dyyyItem = [[%c(AWESettingItemModel) alloc] init];
        dyyyItem.identifier = @"DYYY";
        dyyyItem.title = @"DYYY";
        dyyyItem.detail = @"v2.1-7++";
        dyyyItem.type = 0;
        dyyyItem.iconImageName = @"noticesettting_like";
        dyyyItem.cellType = 26;
        dyyyItem.colorStyle = 2;
        dyyyItem.isEnable = YES;
        
        dyyyItem.cellTappedBlock = ^{
            UIViewController *rootViewController = self.controllerDelegate;
            if (!rootViewController) {
                return;
            }
            
            DYYYSettingViewController *settingVC = [[DYYYSettingViewController alloc] init];
            if (rootViewController.navigationController) {
                [rootViewController.navigationController pushViewController:settingVC animated:YES];
            } else {
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingVC];
                navController.modalPresentationStyle = UIModalPresentationFullScreen;
                [rootViewController presentViewController:navController animated:YES completion:nil];
            }
        };
        
        AWESettingSectionModel *dyyySection = [[%c(AWESettingSectionModel) alloc] init];
        dyyySection.sectionHeaderTitle = @"DYYY";
        dyyySection.sectionHeaderHeight = 40;
        dyyySection.type = 0;
        dyyySection.itemArray = @[dyyyItem];
        
        NSMutableArray<AWESettingSectionModel *> *newSections = [NSMutableArray arrayWithArray:originalSections];
        [newSections insertObject:dyyySection atIndex:0];
        
        return newSections;
    }
    
    return originalSections;
}

%end

%hook AWETabViewController

%property (nonatomic, assign) BOOL isIncognitoModeActive;

- (void)viewDidLoad {
    %orig;
    
    // 初始化无痕模式状态
    ensureIncognitoStateDictInitialized();
    
    // 检查是否启用无痕模式
    BOOL enableIncognito = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableIncognitoMode"];
    
    // 同步设置无痕模式状态
    self.isIncognitoModeActive = enableIncognito;
    @synchronized(incognitoStateDict) {
        [incognitoStateDict setObject:@(enableIncognito) forKey:@"isIncognitoActive"];
    }
    
    // 如果启用了无痕模式，显示提示
    if (enableIncognito) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [DYYYManager showToast:@"无痕浏览模式已启用，浏览记录不会被保存"];
        });
    }
}

%end

%hook AWEHistoryService

- (void)addAwemeToHistory:(id)arg1 {
    if (isIncognitoModeActive()) {
        // 无痕模式下不记录历史
        return;
    }
    %orig;
}

%end

%hook AWESearchHistoryStorage

- (void)saveSearchKeyword:(id)arg1 {
    if (isIncognitoModeActive()) {
        // 无痕模式下不记录搜索历史
        return;
    }
    %orig;
}

%end

%hook AWELikeServiceManager

- (void)likeAweme:(id)arg1 completion:(id)arg2 {
    if (isIncognitoModeActive()) {
        // 无痕模式下显示提示，不执行点赞
        [DYYYManager showToast:@"无痕模式下，点赞操作不会被记录"];
        
        // 调用回调避免UI卡住
        if (arg2 && [arg2 isKindOfClass:NSClassFromString(@"NSBlock")]) {
            void (^completionBlock)(BOOL, NSError *) = arg2;
            completionBlock(YES, nil);
        }
        return;
    }
    %orig;
}

%end

%hook AWEFavoriteServiceManager

- (void)favoriteAweme:(id)arg1 completion:(id)arg2 {
    if (isIncognitoModeActive()) {
        // 无痕模式下显示提示，不执行收藏
        [DYYYManager showToast:@"无痕模式下，收藏操作不会被记录"];
        
        // 调用回调避免UI卡住
        if (arg2 && [arg2 isKindOfClass:NSClassFromString(@"NSBlock")]) {
            void (^completionBlock)(BOOL, NSError *) = arg2;
            completionBlock(YES, nil);
        }
        return;
    }
    %orig;
}

%end

%hook AWEUserServiceManager

- (void)followUser:(id)arg1 completion:(id)arg2 {
    if (isIncognitoModeActive()) {
        // 无痕模式下显示提示，不执行关注
        [DYYYManager showToast:@"无痕模式下，关注操作不会被记录"];
        
        // 调用回调避免UI卡住
        if (arg2 && [arg2 isKindOfClass:NSClassFromString(@"NSBlock")]) {
            void (^completionBlock)(id, NSError *) = arg2;
            NSError *error = [NSError errorWithDomain:@"com.dyyy.incognito" code:999 userInfo:@{NSLocalizedDescriptionKey: @"无痕模式已阻止此操作"}];
            completionBlock(nil, error);
        }
        return;
    }
    %orig;
}

%end

%hook AWEAwemeDetailTableViewController
- (BOOL)hasIphoneAutoPlaySwitch {
    // 检查是否启用自动播放功能
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableAutoPlay"];
    if (!enabled) {
        return %orig; // 未启用时保持原来的行为
    }
    return YES; // 启用时强制返回YES
}
%end

%hook AWEAwemeDetailContainerPlayControlConfig
- (BOOL)enableUserProfilePostAutoPlay {
    // 检查是否启用自动播放功能
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableAutoPlay"];
    if (!enabled) {
        return %orig; // 未启用时保持原来的行为
    }
    return YES; // 启用时强制返回YES
}
%end

%hook AWEFeedIPhoneAutoPlayManager
- (BOOL)isAutoPlayOpen {
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableAutoPlay"];
    if (enabled) {
        return YES;
    }
    return %orig;
}

- (BOOL)getFeedIphoneAutoPlayState {
    // 检查是否启用自动播放功能
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableAutoPlay"];
    if (!enabled) {
        return %orig; // 未启用时保持原来的行为
    }
    return YES; // 启用时强制返回YES
}

%end

%hook AWEFeedModuleService
- (BOOL)getFeedIphoneAutoPlayState {
    // 检查是否启用自动播放功能
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableAutoPlay"];
    if (!enabled) {
        return %orig; // 未启用时保持原来的行为
    }
    return YES; // 启用时强制返回YES
}
%end

%hook AFDViewedBottomView
- (void)layoutSubviews {
    %orig;

    // 启用全屏模式时将底部视图设为透明
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableFullScreen"]) {
        // 将 self 强制转换为 UIView 来访问 backgroundColor 属性
        ((UIView *)self).backgroundColor = [UIColor clearColor];
        
        // 通过 KVC 安全地访问 effectView 属性，转换为 NSObject
        @try {
            UIView *effectView = [(NSObject *)self valueForKey:@"effectView"];
            if (effectView && [effectView isKindOfClass:[UIView class]]) {
                effectView.hidden = YES;
            }
        } @catch (NSException *exception) {
            // 如果没有 effectView 属性，忽略错误
            NSLog(@"AFDViewedBottomView 没有 effectView 属性或访问失败: %@", exception.reason);
        }
    }
}
%end
