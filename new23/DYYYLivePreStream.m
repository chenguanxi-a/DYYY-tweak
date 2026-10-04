#import "DYYYNew23.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#pragma mark - 时间格式化
NSString *dyyy_formatTimeFromSeconds(NSTimeInterval seconds) {
    if (seconds < 0) seconds = 0;
    NSInteger total = (NSInteger)llround(seconds);
    NSInteger h = total / 3600, m = (total % 3600) / 60, s = total % 60;
    if (h > 0) return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)h, (long)m, (long)s];
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)m, (long)s];
}

NSString *dyyy_legacyFormatTimeFromSeconds(NSTimeInterval seconds) {
    return dyyy_formatTimeFromSeconds(seconds);
}

#pragma mark - DYYYLiveDurationTicker
@implementation DYYYLiveDurationTicker {
    dispatch_source_t _timer;
}
- (void)start {
    [self stop];
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    if (!_timer) return;
    dispatch_source_set_timer(_timer, dispatch_time(NULL, 0), (uint64_t)(0.5 * NSEC_PER_SEC), (uint64_t)(0.05 * NSEC_PER_SEC));
    __weak DYYYLiveDurationTicker *weakSelf = self;
    dispatch_source_set_event_handler(_timer, ^{
        DYYYLiveDurationTicker *strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf.currentTime += 0.5;
        if (strongSelf.totalDuration > 0 && strongSelf.currentTime > strongSelf.totalDuration) {
            strongSelf.currentTime = strongSelf.totalDuration;
        }
        if (strongSelf.onTick) strongSelf.onTick(strongSelf);
    });
    dispatch_resume(_timer);
}
- (void)stop {
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}
- (void)dealloc { [self stop]; }
+ (NSString *)formatTimeFromSeconds:(NSTimeInterval)seconds {
    return dyyy_formatTimeFromSeconds(seconds);
}
@end

#pragma mark - DYYYLiveDurationWeakViewBox
@implementation DYYYLiveDurationWeakViewBox {
    __weak UIView *_weakView;
}
+ (instancetype)valueWithWeakView:(UIView *)view {
    DYYYLiveDurationWeakViewBox *box = [[DYYYLiveDurationWeakViewBox alloc] init];
    box->_weakView = view;
    return box;
}
- (UIView *)weakView { return _weakView; }
@end

#pragma mark - DYYYLiveDurationView
@implementation DYYYLiveDurationView {
    DYYYLiveDurationTicker *_ticker;
    NSTimer *_labelTimer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _timeLabel.layer.shadowOpacity = 0.6;
        _timeLabel.layer.shadowRadius = 2;
        _timeLabel.layer.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:_timeLabel];
        _locked = D23Bool(@"DYYYLiveDurationPositionLocked", NO);
        _ticker = [[DYYYLiveDurationTicker alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _timeLabel.frame = CGRectMake(8, self.bounds.size.height / 2.0 - 9, self.bounds.size.width - 16, 18);
    if (_bgGradient) _bgGradient.frame = self.bounds;
}

- (void)updateWithCurrentTime:(NSTimeInterval)currentTime totalDuration:(NSTimeInterval)totalDuration {
    _ticker->currentTime = currentTime;
    _ticker->totalDuration = totalDuration;
    _timeLabel.text = [DYYYLiveDurationTicker formatTimeFromSeconds:currentTime];
    if (totalDuration > 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%@ / %@",
                              [DYYYLiveDurationTicker formatTimeFromSeconds:currentTime],
                              [DYYYLiveDurationTicker formatTimeFromSeconds:totalDuration]];
    }
}

- (void)applyCenterXPercent:(CGFloat)x centerYPercent:(CGFloat)y inBounds:(CGRect)bounds {
    if (!_locked) return;
    if (x <= 0 || y <= 0) return;
    self.frame = CGRectMake(bounds.origin.x + bounds.size.width * x - self.bounds.size.width / 2.0,
                            bounds.origin.y + bounds.size.height * y - self.bounds.size.height / 2.0,
                            self.bounds.size.width, self.bounds.size.height);
}

- (void)removeAllLabels {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_timeLabel];
}

- (void)schedulePresentationTimersIfNeeded {
    if (!_ticker) _ticker = [[DYYYLiveDurationTicker alloc] init];
    if (!_labelTimer) {
        __weak DYYYLiveDurationView *weakSelf = self;
        _labelTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer *timer) {
            DYYYLiveDurationView *strongSelf = weakSelf;
            if (!strongSelf) { [timer invalidate]; return; }
            [strongSelf updateWithCurrentTime:strongSelf._ticker->currentTime
                                  totalDuration:strongSelf._ticker->totalDuration];
        }];
        [_labelTimer setTolerance:0.05];
    }
    [_ticker start];
}

- (void)cancelTimers {
    [_labelTimer invalidate];
    _labelTimer = nil;
    [_ticker stop];
}
@end

#pragma mark - 排期标签相关 C 函数
void dyyy_removeScheduleLabels(UIView *container) {
    if (!container) return;
    for (UIView *sub in container.subviews) {
        if ([sub isKindOfClass:[DYYYLiveDurationView class]]) [sub removeFromSuperview];
    }
}

void dyyy_updateScheduleLabelsWithCurrentTime:(NSTimeInterval)currentTime totalDuration:(NSTimeInterval)totalDuration {
}

void dyyy_updateScheduleLabelsLegacyWithCurrentTime:(NSTimeInterval)currentTime totalDuration:(NSTimeInterval)totalDuration model:(id)model {
    dyyy_updateScheduleLabelsWithCurrentTime:currentTime totalDuration:totalDuration;
}

void dyyy_syncScheduleLabelsWithCurrentTime:(NSTimeInterval)currentTime totalDuration:(NSTimeInterval)total {
}

CGFloat dyyy_modelDurationInSeconds(id model) {
    if (!model) return 0;
    @try {
        NSNumber *num = [model valueForKey:@"duration"];
        if (num) return [num doubleValue] / 1000.0;
        num = [model valueForKey:@"playDuration"];
        if (num) return [num doubleValue];
    } @catch (__unused NSException *e) {}
    return 0;
}

CGFloat dyyy_legacyModelDurationInSeconds(id model) {
    return dyyy_modelDurationInSeconds(model);
}

void dyyy_schedulePresentationTimersIfNeeded(UIView *view) {
    if ([view isKindOfClass:[DYYYLiveDurationView class]]) {
        [(DYYYLiveDurationView *)view schedulePresentationTimersIfNeeded];
    }
}

CGFloat dyyy_legacyScheduleVerticalOffset(void) {
    return D23Float(@"DYYYScheduleVerticalOffset", 0.0);
}

void dyyy_scheduleVerticalOffset(CGFloat offsetY) {
    [[NSUserDefaults standardUserDefaults] setFloat:(float)offsetY forKey:@"DYYYScheduleVerticalOffset"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}