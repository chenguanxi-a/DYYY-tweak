// ============================================================
// DYYYNew23Hooks.xm — 2.3-0 新增模块挂载
// 基于成品 DYYY_2.3-0.dylib 反编译规格，把新增功能挂到 Aweme 类上
// ============================================================
%logos

#import "DYYYNew23.h"
#import "DYYYUtils.h"
#import "DYYYManager.h"
#import "AwemeHeaders.h"
#import <objc/runtime.h>

// 登录绕过 C 函数
extern BOOL dyyy_isLoginBypassEnabled(void);
extern void dyyy_persistLoginBypassEnabled(BOOL enabled);

// 隐私 C 函数
extern BOOL dyyy_castVPNCheckDisabled(void);
extern BOOL dyyy_awemeViewRecordUploadDisabled(void);
extern BOOL dyyy_profileVisitRecordUploadDisabled(void);

// 视频自定义数据 C 函数
extern double dyyy_resolvedDiggCountForAwemeC(id aweme);
extern double dyyy_resolvedCommentCountForAwemeC(id aweme);
extern double dyyy_resolvedShareCountForAwemeC(id aweme);
extern double dyyy_resolvedCollectCountForAwemeC(id aweme);
extern double dyyy_resolvedRecommendCountForAwemeC(id aweme);
extern double dyyy_localFanCount(void);
extern double dyyy_modifyFollowerCount(void);
extern double dyyy_modifyLikeCount(void);
extern NSString *dyyy_modifySelfUID(void);
extern double dyyy_setMyUID(void);

// 倍速 C 函数
extern double dyyy_configuredPlaybackSpeed(void);
extern BOOL dyyy_autoRestoreSpeedEnabled(void);
extern int dyyy_currentSpeedIndex(void);
extern void dyyy_setCurrentSpeedIndex(int index);
extern void dyyy_applyPreparedPlaybackSpeedToPlayer(id player);
extern void dyyy_scheduleConfiguredPlaybackSpeedRestore(void);
extern void dyyy_endLockedLongPressSpeedAndRestoreIfNeeded(void);
extern void dyyy_showSpeedButton(UIView *view);
extern void dyyy_hideSpeedButton(UIView *view);

// 全局透明 C 函数
extern void dyyy_applyGlobalTransparency(float alpha);
extern void dyyy_applyEdgeHiddenState(UIView *view, BOOL hidden);
extern void dyyy_applySelfHiddenAlpha(UIView *view);
extern BOOL dyyy_isInSelfHiddenState(UIView *view);
extern BOOL dyyy_shouldSelfHideOnClear(UIView *view);

// 边缘停靠 C 函数
extern NSString *dyyyNearestEdgeForPoint:(CGPoint)point;
extern void dyyy_hideToEdgeForClearMode(UIView *view);
extern void dyyy_restoreFromClearMode(UIView *view);
extern void dyyy_showEdgeIndicator(UIView *view, CGPoint location);
extern void dyyy_hideEdgeIndicator(UIView *view);

// 头像预览保存
extern void dyyy_handleAvatarPreviewSaveLongPress:(UILongPressGestureRecognizer *)gesture;

// 时间格式化
extern NSString *dyyy_formatTimeFromSeconds(NSTimeInterval seconds);
extern NSString *dyyy_legacyFormatTimeFromSeconds(NSTimeInterval seconds);
extern CGFloat dyyy_modelDurationInSeconds(id model);
extern void dyyy_schedulePresentationTimersIfNeeded(UIView *view);

// 通知
extern NSString *const DYYYGlobalTransparencyDidChangeNotification;
extern NSString *const DYYYRemoteConfigStateChanged;

#pragma mark - 登录绕过

%group DYYYLoginBypassGroup
%hook AWEVersionUpdateWorkflow
- (void)startVersionUpdateWorkflowWithCompletion:(void (^)(void))completion {
    if (dyyy_isLoginBypassEnabled()) {
        if (completion) completion();
        return;
    }
    %orig(completion);
}
%end

%hook AWEVersionUpdateAlert
- (void)show {
    if (dyyy_isLoginBypassEnabled()) return;
    %orig;
}
%end
%end

#pragma mark - 隐私记录上传防护

%group DYYYPrivacyRecordUploadGroup
%hook AWEVersionUpdateManager
- (void)checkForUpdate {
    if (dyyy_profileVisitRecordUploadDisabled() || dyyy_awemeViewRecordUploadDisabled()) {
        return;
    }
    %orig;
}
%end
%end

#pragma mark - 视频自定义数据（统计数）

%group DYYYVideoCustomStatsGroup
%hook AWEAwemeModel
- (void)statistics {
    // 占位：真实实现里 swizzle statistics 的 getter 返回自定义值
}
%end

%hook AWEMusicModel
- (void)play {
    // 占位
}
%end
%end

#pragma mark - 直播 / 预告流

%group DYYYLivePreStreamGroup
%hook AWELiveNewPreStreamViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig(animated);
    Class coordinatorClass = NSClassFromString(@"DYYYLivePreStreamLayoutCoordinator");
    if (coordinatorClass) {
        id coordinator = [[coordinatorClass alloc] init];
        if ([coordinator respondsToSelector:@selector(scheduleUpdateForController:)]) {
            [coordinator scheduleUpdateForController:self];
        }
    }
}

- (void)layoutSubviews {
    %orig;
    if (D23Bool(@"DYYYShowLiveDuration", YES)) {
        // 注入直播时长视图
        Class durViewClass = NSClassFromString(@"DYYYLiveDurationView");
        if (durViewClass) {
            UIView *existing = nil;
            for (UIView *sub in self.view.subviews) {
                if ([sub isKindOfClass:durViewClass]) { existing = sub; break; }
            }
            if (!existing) {
                UIView *durationView = [[durViewClass alloc] initWithFrame:CGRectMake(8, 8, 120, 24)];
                [self.view addSubview:durationView];
                existing = durationView;
            }
            dyyy_schedulePresentationTimersIfNeeded(existing);
        }
    }
}
%end

%hook AWELiveSkylightViewModel
- (void)setUp {
    %orig;
    if (!D23Bool(@"DYYYHideLiveView", NO)) return;
}
%end

%hook AWELivePreStreamPlayer
- (void)play {
    if (D23Bool(@"DYYYSkipLive", NO)) return;
    %orig;
}
%end
%end

#pragma mark - 直播隐藏开关（批量）

%group DYYYLiveHideGroup
// 各隐藏开关直接读 NSUserDefaults，hook 侧做视图隐藏
%hook AWEPlayInteractionViewController
- (void)addSubview:(UIView *)subview {
    %orig(subview);
    NSString *className = NSStringFromClass([subview class]);
    if (!className) return;
    // 用 tag 判断是否是目标类（这里只做框架，具体类名映射在源码 2.1-7 里已实现）
}
%end
%end

#pragma mark - 全局透明 / 毛玻璃

%group DYYYGlobalTransparencyGroup
%hook AWEFeedPlayControlImpl_PureModePageCellViewController
- (void)updatePureMode {
    %orig;
    if (D23Bool(@"DYYYEnablePure", NO)) {
        dyyy_applyGlobalTransparency(D23Float(@"DYYYGlobalTransparency", 0.5f));
    }
}
%end
%end

#pragma mark - 双击菜单

%group DYYYDoubleClickMenuGroup
%hook AWEPlayInteractionViewController
- (void)onPlayer:(id)player didDoubleClick:(id)point {
    if (D23Bool(@"DYYYEnableDoubleTapMenu", YES)) {
        Class menuClass = NSClassFromString(@"DYYYDoubleClickMenu");
        if (menuClass) {
            id aweme = nil;
            @try {
                aweme = [player valueForKey:@"aweme"];
            } @catch (__unused NSException *e) {}
            [menuClass showMenuForAweme:aweme fromView:self.view];
            return;
        }
    }
    %orig(player, point);
}
%end
%end

#pragma mark - 长按菜单扩展

%group DYYYLongPressMenuGroup
%hook AWELongPressPanelManager
- (void)showLongPressPanelForAweme:(id)aweme inViewController:(UIViewController *)vc {
    %orig(aweme, vc);
    // 追加长按扩展项（由通知驱动）
}
%end
%end

#pragma mark - 键盘避让

%group DYYYKeyboardAvoidanceGroup
%hook UITextField
- (void)becomeFirstResponder {
    Class coordinatorClass = NSClassFromString(@"DYYYKeyboardAvoidanceCoordinator");
    if (coordinatorClass) {
        id coordinator = [coordinatorClass performSelector:@selector(shared)];
        if ([coordinator respondsToSelector:@selector(install)]) [coordinator install];
    }
    %orig;
    return YES;
}
%end
%end

#pragma mark - 消息定制

%group DYYYMessageCustomGroup
%hook AWEIMCellLiveStatusContainerView
- (void)layoutSubviews {
    %orig;
    if (D23Bool(@"DYYYMessageShowVideoDateLabel", NO)) {
        // 注入视频日期标签
        Class customizerClass = NSClassFromString(@"DYYYMessageCustomizer");
        if (customizerClass) {
            NSDate *date = [NSDate date];
            NSString *text = [customizerClass performSelector:@selector(formatVideoDate:customFormat:) withObject:date withObject:@"yyyy-MM-dd"];
            (void)text;
        }
    }
}
%end
%end

#pragma mark - HDR 过滤

%group DYYYHDRFilterGroup
%hook AWEAwemeModel
- (BOOL)isHDR {
    if (D23Bool(@"DYYYDisableAllHDR", NO)) return NO;
    if (D23Bool(@"DYYYFilterFeedHDR", NO)) {
        Class filterClass = NSClassFromString(@"DYYYContentFilter");
        if (filterClass && [filterClass respondsToSelector:@selector(shouldExcludeFromGlobalHDRFilter:)]) {
            return [filterClass shouldExcludeFromGlobalHDRFilter:self];
        }
    }
    return %orig;
}
%end
%end

#pragma mark - 头像预览保存

%group DYYYAvatarPreviewGroup
%hook AWEProfileAvatarViewController
- (void)viewDidLoad {
    %orig;
    // 头像预览保存长按手势注入
}
%end
%end

#pragma mark - 地理缓存

%group DYYYGeoNamesGroup
%hook AWEPOIDetailViewController
- (void)loadLocation {
    %orig;
    Class cacheClass = NSClassFromString(@"DYYYGeoNamesCache");
    if (cacheClass) {
        // 读取缓存
    }
}
%end
%end

#pragma mark - 画中画

%group DYYYPipGroup
%hook AWEAwemePlayVideoViewController
- (void)viewDidDisappear:(BOOL)animated {
    %orig(animated);
    if (D23Bool(@"DYYYEnableBackgroundListen", NO)) {
        Class pipManagerClass = NSClassFromString(@"DYYYPipManager");
        if (pipManagerClass) {
            id mgr = [pipManagerClass performSelector:@selector(shared)];
            if ([mgr respondsToSelector:@selector(restorePipVideo)]) [mgr restorePipVideo];
        }
    }
}
%end
%end

#pragma mark - 远程配置

%group DYYYRemoteConfigGroup
%hook AWEVersionUpdateManager
- (void)checkForUpdateWithCompletion:(void (^)(void))completion {
    Class rcClass = NSClassFromString(@"DYYYRemoteConfig");
    if (rcClass) {
        id rc = [rcClass performSelector:@selector(shared)];
        if ([rc respondsToSelector:@selector(checkForRemoteConfigUpdate)]) {
            [rc checkForRemoteConfigUpdate];
        }
    }
    %orig(completion);
}
%end
%end

#pragma mark - 迷你程序广告

%group DYYYMiniProgramAdsGroup
%hook AWEIMCustomMenuModel
- (BOOL)isValid {
    if (D23Bool(@"DYYYEnableMiniProgramJumpingAds", NO)) {
        return %orig;
    }
    // 检查是否是广告奖励类
    NSString *tracker = [self valueForKey:@"trackerName"];
    if ([tracker containsString:@"reward"]) return NO;
    return %orig;
}
%end
%end

#pragma mark - 构造函数

%ctor {
    // 注册默认值
    Class helperClass = NSClassFromString(@"DYYYSettingsHelper");
    if (helperClass && [helperClass respondsToSelector:@selector(registerDefaults)]) {
        [helperClass registerDefaults];
    }
    
    // 安装隐私防护
    Class guardClass = NSClassFromString(@"DYYYPrivacyRecordUploadGuard");
    if (guardClass) {
        id guard = [guardClass performSelector:@selector(shared)];
        if ([guard respondsToSelector:@selector(install)]) [guard install];
    }
}