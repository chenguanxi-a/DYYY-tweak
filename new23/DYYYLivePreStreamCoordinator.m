#import "DYYYNew23.h"
#import <QuartzCore/QuartzCore.h>

@implementation DYYYLivePreStreamTransformState
+ (instancetype)transformStateForView:(UIView *)view createIfNeeded:(BOOL)createIfNeeded {
    static NSMutableDictionary<NSNumber *, DYYYLivePreStreamTransformState *> *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSMutableDictionary dictionary];
    });
    @synchronized(cache) {
        if (!view) return nil;
        NSNumber *key = @((uint64_t)view);
        DYYYLivePreStreamTransformState *state = cache[key];
        if (!state && createIfNeeded) {
            state = [[DYYYLivePreStreamTransformState alloc] init];
            state->transform = CGAffineTransformIdentity;
            state->alpha = 1.0;
            state->contentOffsetY = 0;
            cache[key] = state;
        }
        if (!state) return nil;
        return state;
    }
}
@end

@implementation DYYYLivePreStreamControllerState
- (instancetype)init {
    self = [super init];
    if (self) {
        _transformState = [[DYYYLivePreStreamTransformState alloc] init];
        _lastLayoutTime = 0;
        _layoutValid = NO;
    }
    return self;
}
@end

@implementation DYYYLivePreStreamLayoutCoordinator {
    DYYYLivePreStreamControllerState *_state;
    dispatch_source_t _updateTimer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = [[DYYYLivePreStreamControllerState alloc] init];
    }
    return self;
}

- (void)scheduleUpdateForController:(UIViewController *)controller {
    self.controller = controller;
    [self scheduleUpdateForView:controller.view];
}

- (void)scheduleUpdateForView:(UIView *)view {
    if (!view) return;
    DYYYLivePreStreamTransformState *state = [DYYYLivePreStreamTransformState transformStateForView:view createIfNeeded:YES];
    if (!state) return;
    _state.transformState = state;
    _state.layoutValid = NO;
    _state.lastLayoutTime = CACurrentMediaTime();

    if (!_updateTimer) {
        _updateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_updateTimer, dispatch_time(NULL, 0), (uint64_t)(1.0 * NSEC_PER_SEC), (uint64_t)(0.1 * NSEC_PER_SEC));
        __weak DYYYLivePreStreamLayoutCoordinator *weakSelf = self;
        dispatch_source_set_event_handler(_updateTimer, ^{
            DYYYLivePreStreamLayoutCoordinator *strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf updateScheduled:YES];
        });
        dispatch_resume(_updateTimer);
    }
}

- (void)updateScheduled:(BOOL)scheduled {
    _state.layoutValid = !scheduled;
}

- (void)setUpdateScheduled:(BOOL)scheduled {
    [self updateScheduled:scheduled];
}

- (void)dealloc {
    if (_updateTimer) {
        dispatch_source_cancel(_updateTimer);
        _updateTimer = nil;
    }
}

- (DYYYLivePreStreamTransformState *)currentTransformState {
    return _state.transformState;
}
@end

@implementation DYYYLiveQuality {
    NSArray<NSNumber *> *_qualityLevels;
}

+ (instancetype)shared {
    static DYYYLiveQuality *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[DYYYLiveQuality alloc] init];
        shared->_qualityLevels = @[ @0, @1, @2, @3, @4 ];
    });
    return shared;
}

- (NSArray<NSNumber *> *)availableLevels {
    return _qualityLevels ?: @[];
}

- (NSInteger)currentLevel {
    return D23Int(@"DYYYLiveQuality", 0);
}

- (void)setCurrentLevel:(NSInteger)level {
    [[NSUserDefaults standardUserDefaults] setInteger:level forKey:@"DYYYLiveQuality"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)displayNameForLevel:(NSInteger)level {
    NSArray *names = @[@"\u81ea\u52a8", @"\u4f4e\u6e05", @"\u6807\u6e05", @"\u9ad8\u6e05", @"\u539f\u753b"];
    if (level < 0 || level >= (NSInteger)names.count) return @"?";
    return names[level];
}
@end