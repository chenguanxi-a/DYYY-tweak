#import "DYYYNew23.h"
#import "DYYYManager.h"
#import "DYYYUtils.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - 倍速 C 函数
static NSString *_dyyyPreparedSpeedForPlayerKey(id player) {
    return [NSString stringWithFormat:@"DYYYPreparedPlaybackSpeedForPlayer_%p", player];
}

double dyyy_configuredPlaybackSpeed(void) {
    return D23Float(@"DYYYDefaultSpeed", 1.0);
}

BOOL dyyy_autoRestoreSpeedEnabled(void) {
    return D23Bool(@"DYYYAutoRestoreSpeed", YES);
}

int dyyy_currentSpeedIndex(void) {
    return D23Int(@"DYYYCurrentSpeedIndex", 0);
}

void dyyy_setCurrentSpeedIndex(int index) {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"DYYYCurrentSpeedIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

BOOL dyyy_shouldPrepareDefaultPlaybackSpeedForPlayer(id player) {
    return dyyy_autoRestoreSpeedEnabled();
}

double dyyy_preparedPlaybackSpeedForPlayer(id player) {
    NSString *key = _dyyyPreparedSpeedForPlayerKey(player);
    NSNumber *val = DYYYGlobalOSCache() ? [DYYYGlobalOSCache() objectForKey:key] : nil;
    if (val) return [val doubleValue];
    return dyyy_configuredPlaybackSpeed();
}

void dyyy_applyPreparedPlaybackSpeedToPlayer(id player) {
    double speed = dyyy_preparedPlaybackSpeedForPlayer(player);
    @try {
        [player setValue:@(speed) forKey:@"playbackRate"];
    } @catch (__unused NSException *e) {}
}

void dyyy_bindAndApplyCurrentPlaybackSpeed(void) {
    // 由 hook 侧在播放器出现时调用
}

void dyyy_scheduleConfiguredPlaybackSpeedRestoreAfterDelay(NSTimeInterval delay) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 恢复默认倍速
        @try {
            UIViewController *top = [DYYYUtils topView];
            (void)top;
        } @catch (__unused NSException *e) {}
    });
}

void dyyy_scheduleConfiguredPlaybackSpeedRestore(void) {
    double delay = D23Float(@"DYYYSpeedRestoreDelay", 2.0);
    dyyy_scheduleConfiguredPlaybackSpeedRestoreAfterDelay(delay);
}

void dyyy_endLockedLongPressSpeedAndRestoreIfNeeded(void) {
    if (!dyyy_autoRestoreSpeedEnabled()) return;
    dyyy_scheduleConfiguredPlaybackSpeedRestore();
}

BOOL dyyy_speedButtonLocked(void) {
    return D23Bool(@"DYYYSpeedButtonLocked", NO);
}

void dyyy_setSpeedButtonLocked(BOOL locked) {
    [[NSUserDefaults standardUserDefaults] setBool:locked forKey:@"DYYYSpeedButtonLocked"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

CGFloat dyyy_speedButtonSize(void) {
    return D23Float(@"DYYYSpeedButtonSize", 32.0);
}

CGFloat dyyy_speedButtonCenterXPercent(void) {
    return D23Float(@"DYYYSpeedButtonCenterXPercent", 0.5);
}

CGFloat dyyy_speedButtonCenterYPercent(void) {
    return D23Float(@"DYYYSpeedButtonCenterYPercent", 0.5);
}

BOOL dyyy_autoHideSpeedButtonEnabled(void) {
    return D23Bool(@"DYYYAutoHideSpeedButton", NO);
}

NSTimeInterval dyyy_autoHideSpeedButtonTime(void) {
    return D23Float(@"DYYYAutoHideSpeedButtonTime", 5.0);
}

void dyyy_cancelAutoHideSpeedButtonTimer(UIView *view) {
    if (!view) return;
    // 取消定时
}

void dyyy_showSpeedButton(UIView *view) {
    if (!view) return;
    view.hidden = NO;
}

void dyyy_hideSpeedButton(UIView *view) {
    if (!view) return;
    view.hidden = YES;
}

#pragma mark - DYYYPipManager
@implementation DYYYPipManager {
    static DYYYPipManager *_shared;
    UIView *_pipContainerView;
}

+ (instancetype)shared {
    @synchronized(self) {
        if (!_shared) {
            _shared = [[DYYYPipManager alloc] init];
        }
        return _shared;
    }
}

- (UIView *)pipContainerView {
    if (!_pipContainerView) {
        _pipContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 90)];
        _pipContainerView.backgroundColor = [UIColor blackColor];
        _pipContainerView.layer.cornerRadius = 8;
        _pipContainerView.layer.masksToBounds = YES;
        _pipContainerView.tag = 99001;
    }
    return _pipContainerView;
}

- (void)restorePipVideo {
    [self markDisablePipelineFinishedWithUserID:nil];
}

- (void)markDisablePipelineFinishedWithUserID:(NSString *)userId {
    (void)userId;
}

- (BOOL)shouldStartDisablePipelineForUserID:(NSString *)userId {
    return D23Bool(@"DYYYEnableBackgroundListen", NO) && (userId.length > 0);
}
@end

#pragma mark - DYYYSpeedSwitchButton
@implementation DYYYSpeedSwitchButton {
    dispatch_source_t _autoHideTimer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = frame.size.height / 2.0;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.75];
        self.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.accessibilityLabel = @"倍速";
    }
    return self;
}

- (void)showInView:(UIView *)parentView {
    if (!parentView) return;
    CGFloat size = dyyy_speedButtonSize();
    CGRect frame = parentView.bounds;
    self.frame = CGRectMake(frame.size.width * dyyy_speedButtonCenterXPercent() - size / 2.0,
                            frame.size.height * dyyy_speedButtonCenterYPercent() - size / 2.0,
                            size, size);
    [parentView addSubview:self];
    self.hidden = NO;

    if (dyyy_autoHideSpeedButtonEnabled()) {
        [self startAutoHideTimer];
    }
}

- (void)startAutoHideTimer {
    [self cancelAutoHideTimer];
    _autoHideTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    NSTimeInterval delay = dyyy_autoHideSpeedButtonTime();
    dispatch_source_set_timer(_autoHideTimer, dispatch_time(NULL, (int64_t)(delay * NSEC_PER_SEC)), UINT64_MAX, 0);
    __weak DYYYSpeedSwitchButton *weakSelf = self;
    dispatch_source_set_event_handler(_autoHideTimer, ^{
        DYYYSpeedSwitchButton *strongSelf = weakSelf;
        if (!strongSelf) return;
        dyyy_hideSpeedButton(strongSelf);
    });
    dispatch_resume(_autoHideTimer);
}

- (void)cancelAutoHideTimer {
    if (_autoHideTimer) {
        dispatch_source_cancel(_autoHideTimer);
        _autoHideTimer = nil;
    }
}

- (void)dealloc {
    [self cancelAutoHideTimer];
}
@end

#pragma mark - DYYYSpeedButtonCenterXPercent / YPercent / Locked / Size
// 这些通过 NSUserDefaults 读取，见上面 C 函数