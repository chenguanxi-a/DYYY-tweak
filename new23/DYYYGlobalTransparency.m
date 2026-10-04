#import "DYYYNew23.h"
#import <UIKit/UIKit.h>

#pragma mark - 药丸按钮工厂
UIView *dyyy_makePillButtonWithTitle:(NSString *)title
                               frame:(CGRect)frame
                              darkMode:(BOOL)darkMode
                            emphasized:(BOOL)emphasized
                                action:(void (^)(void))action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    button.layer.cornerRadius = frame.size.height / 2.0;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [button setTitle:title forState:UIControlStateNormal];

    UIColor *bgColor;
    UIColor *textColor;
    if (darkMode) {
        bgColor = emphasized ? [UIColor whiteColor] : [UIColor colorWithWhite:0.1 alpha:0.9];
        textColor = emphasized ? [UIColor blackColor] : [UIColor whiteColor];
    } else {
        bgColor = emphasized ? [UIColor colorWithWhite:0.95 alpha:0.95] : [UIColor colorWithWhite:0.2 alpha:0.7];
        textColor = emphasized ? [UIColor blackColor] : [UIColor whiteColor];
    }
    button.backgroundColor = bgColor;
    [button setTitleColor:textColor forState:UIControlStateNormal];

    if (action) {
        __block UIView *btnRef = button;
        [button addTarget:action ? button : nil action:nil forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

#pragma mark - 触觉反馈
void dyyy_playTapFeedback(void) {
    if (!D23Bool(@"DYYYHapticFeedbackEnabled", YES)) return;
    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [gen prepare];
    [gen impactOccurred];
}

void dyyy_restoreTapTransform(UIView *view) {
    if (!view) return;
    view.transform = CGAffineTransformIdentity;
    view.alpha = 1.0;
}

#pragma mark - 全局透明
void dyyy_applyGlobalTransparency(float alpha) {
    // 广播通知让所有订阅者应用全局透明度
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYGlobalTransparencyDidChangeNotification"
                                                        object:nil
                                                      userInfo:@{@"alpha": @(alpha)}];
}

#pragma mark - 安全取值
id dyyy_safeValueForKey:(NSString *)key fromObject:(id)obj {
    if (!obj || !key) return nil;
    @try {
        return [obj valueForKey:key];
    } @catch (__unused NSException *e) {
        return nil;
    }
}

#pragma mark - 头像预览保存
@implementation DYYYAvatarPreviewSaver
+ (void)handleAvatarPreviewSaveLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    UIView *view = gesture.view;
    if (!view) return;
    [self saveAvatarPreviewFromDouyinSource:view];
}

+ (void)saveAvatarPreviewFromDouyinSource:(UIView *)sourceView {
    if (!sourceView) return;
    // 截取头像区域
    UIGraphicsBeginImageContextWithOptions(sourceView.bounds.size, NO, [UIScreen mainScreen].scale);
    [sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!image) return;

    void (^saveBlock)(void) = ^{
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        [DYYYUtils showToast:@"Avatar saved to Photos"];
    };
    dispatch_async(dispatch_get_main_queue(), saveBlock);
}
@end

#pragma mark - 迷你程序奖励会话
@implementation DYYYMiniProgramRewardSession {
    static DYYYMiniProgramRewardSession *_current;
}
+ (instancetype)currentSession { return _current; }
- (void)markRewardGranted {
    _current = nil;
}
- (void)cancel { _current = nil; }
+ (void)startSession {
    _current = [[DYYYMiniProgramRewardSession alloc] init];
    _current.startedAt = CACurrentMediaTime();
    _current.rewardToken = [NSUUID UUID].UUIDString;
}
@end

#pragma mark - 直播时长相关 C 函数补充
void dyyy_saveButtonTapped(UIView *view) {
    if (!view) return;
    dyyy_playTapFeedback();
    [UIView animateWithDuration:0.2 animations:^{
        view.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            view.transform = CGAffineTransformIdentity;
        }];
    }];
}

#pragma mark - 边缘停靠几何计算
typedef struct {
    CGFloat leftCenterX, rightCenterX, topCenterY, bottomCenterY;
    CGFloat minX, maxX, minY, maxY;
    CGFloat halfWidth, halfHeight;
} DYYYEdgeMetrics;

DYYYEdgeMetrics dyyy_edgeMetricsFromGeometry(CGRect frame, CGSize superViewSize) {
    DYYYEdgeMetrics m;
    m.halfWidth = frame.size.width / 2.0;
    m.halfHeight = frame.size.height / 2.0;
    m.leftCenterX = frame.origin.x;
    m.rightCenterX = frame.origin.x + frame.size.width;
    m.topCenterY = frame.origin.y;
    m.bottomCenterY = frame.origin.y + frame.size.height;
    m.minX = m.leftCenterX;
    m.maxX = m.rightCenterX;
    m.minY = m.topCenterY;
    m.maxY = m.bottomCenterY;
    return m;
}

CGRect dyyy_edgeGeometryForSuperviewSize:(CGSize)superViewSize
                               halfWidth:(CGFloat)halfWidth
                              halfHeight:(CGFloat)halfHeight
                             leftCenterX:(CGFloat)leftCenterX
                            rightCenterX:(CGFloat)rightCenterX
                               topCenterY:(CGFloat)topCenterY
                            bottomCenterY:(CGFloat)bottomCenterY
                              minAlongEdgeX:(CGFloat)minX
                              maxAlongEdgeX:(CGFloat)maxX
                              minAlongEdgeY:(CGFloat)minY
                              maxAlongEdgeY:(CGFloat)maxY {
    CGFloat centerX = (leftCenterX + rightCenterX) / 2.0;
    CGFloat centerY = (topCenterY + bottomCenterY) / 2.0;
    CGFloat x = MAX(minX + halfWidth, MIN(centerX, maxX - halfWidth));
    CGFloat y = MAX(minY + halfHeight, MIN(centerY, maxY - halfHeight));
    return CGRectMake(x - halfWidth, y - halfHeight, halfWidth * 2, halfHeight * 2);
}

NSString *dyyyNearestEdgeForPoint:(CGPoint)point {
    CGFloat dxLeft = point.x;
    CGFloat dxRight = [UIScreen mainScreen].bounds.size.width - point.x;
    CGFloat dyTop = point.y;
    CGFloat dyBottom = [UIScreen mainScreen].bounds.size.height - point.y;
    CGFloat min = dxLeft;
    NSString *edge = @"left";
    if (dxRight < min) { min = dxRight; edge = @"right"; }
    if (dyTop < min) { min = dyTop; edge = @"top"; }
    if (dyBottom < min) { min = dyBottom; edge = @"bottom"; }
    return edge;
}

NSString *dyyyEdgeForCenter:(CGPoint)center inView:(UIView *)view {
    if (!view) return dyyyNearestEdgeForPoint:center;
    CGRect frame = [view convertRect:view.bounds toView:nil];
    if (center.x < frame.origin.x) return @"left";
    if (center.x > frame.origin.x + frame.size.width) return @"right";
    if (center.y < frame.origin.y) return @"top";
    if (center.y > frame.origin.y + frame.size.height) return @"bottom";
    return @"none";
}

CGPoint dyyySnappedCenterForProposedCenter:(CGPoint)proposed inView:(UIView *)view {
    if (!view) return proposed;
    CGRect bounds = view.bounds;
    CGFloat halfW = view.bounds.size.width / 2.0;
    CGFloat halfH = view.bounds.size.height / 2.0;
    CGFloat x = MAX(halfW, MIN(proposed.x, bounds.size.width - halfW));
    CGFloat y = MAX(halfH, MIN(proposed.y, bounds.size.height - halfH));
    return CGPointMake(x, y);
}

CGPoint dyyyCenterOnEdge:(NSString *)edge forPoint:(CGPoint)point inView:(UIView *)view {
    if (!view) return point;
    CGRect bounds = view.bounds;
    CGPoint center = point;
    if ([edge isEqualToString:@"left"]) {
        center.x = 0;
    } else if ([edge isEqualToString:@"right"]) {
        center.x = bounds.size.width;
    } else if ([edge isEqualToString:@"top"]) {
        center.y = 0;
    } else if ([edge isEqualToString:@"bottom"]) {
        center.y = bounds.size.height;
    }
    return center;
}

CGFloat dyyyDistanceFromPoint:(CGPoint)point toEdge:(NSString *)edge {
    CGRect screen = [UIScreen mainScreen].bounds;
    if ([edge isEqualToString:@"left")]) return point.x - screen.minX;
    if ([edge isEqualToString:@"right"]) return screen.origin.x + screen.size.width - point.x;
    if ([edge isEqualToString:@"top"]) return point.y - screen.minY;
    if ([edge isEqualToString:@"bottom"]) return screen.origin.y + screen.size.height - point.y;
    return 0;
}

void dyyy_hideToEdgeForClearMode(UIView *view) {
    if (!view) return;
    // 清屏时把悬浮按钮推向最近的边缘
    static NSMutableDictionary<NSNumber *, NSString *> *edgeMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ edgeMap = [NSMutableDictionary dictionary]; });
    NSNumber *key = @((uint64_t)view);
    NSString *edge = edgeMap[key];
    if (!edge) {
        CGPoint center = view.center;
        edge = dyyyNearestEdgeForPoint:center;
        edgeMap[key] = edge;
    }
    CGPoint newCenter = dyyyCenterOnEdge:edge forPoint:view.center inView:view.superview;
    view.center = newCenter;
    view.alpha = 0.35;
}

void dyyy_restoreFromClearMode(UIView *view) {
    if (!view) return;
    view.alpha = 1.0;
    static NSMutableDictionary<NSNumber *, NSString *> *edgeMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ edgeMap = [NSMutableDictionary dictionary]; });
    [edgeMap removeObjectForKey:@((uint64_t)view)];
}

BOOL dyyyEdgeHiddenByClearMode(UIView *view) {
    if (!view) return NO;
    static NSMutableDictionary<NSNumber *, NSNumber *> *hiddenMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ hiddenMap = [NSMutableDictionary dictionary]; });
    return [hiddenMap[@((uint64_t)view)] boolValue];
}

BOOL dyyyJustRestoredFromEdgeHidden(UIView *view) {
    return NO;
}

BOOL dyyyHasSavedPosition(UIView *view) {
    if (!view) return NO;
    static NSMutableDictionary<NSNumber *, NSValue *> *posMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ posMap = [NSMutableDictionary dictionary]; });
    return posMap[@((uint64_t)view)] != nil;
}

void dyyy_applyEdgeHiddenState(UIView *view, BOOL hidden) {
    if (!view) return;
    static NSMutableDictionary<NSNumber *, NSNumber *> *hiddenMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ hiddenMap = [NSMutableDictionary dictionary]; });
    hiddenMap[@((uint64_t)view)] = @(hidden);
    view.alpha = hidden ? 0.35 : 1.0;
}

void dyyy_restoreFromEdgeHidden(UIView *view) {
    dyyy_applyEdgeHiddenState(view, NO);
}

void dyyy_applySelfHiddenAlpha(UIView *view) {
    if (!view) return;
    view.alpha = D23Float(@"DYYYAvatarViewTransparency", 1.0);
}

BOOL dyyy_isInSelfHiddenState(UIView *view) {
    if (!view) return NO;
    return view.alpha < 0.8;
}

BOOL dyyy_shouldSelfHideOnClear(UIView *view) {
    if (!view) return NO;
    return view.tag == 0 && view.alpha > 0.8;
}

void dyyy_showEdgeIndicator(UIView *view, CGPoint location) {
    // 指示器显示占位
}

void dyyy_hideEdgeIndicator(UIView *view) {
    // 指示器隐藏占位
}

void dyyy_cancelAutoHideTimer(UIView *view) {
    if (!view) return;
    // 取消自动隐藏计时
}

#pragma mark - 键盘避让
@implementation DYYYKeyboardAvoidanceCoordinator {
    id _keyboardChangeObserver;
}

+ (instancetype)shared {
    static DYYYKeyboardAvoidanceCoordinator *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [[DYYYKeyboardAvoidanceCoordinator alloc] init]; });
    return shared;
}

- (void)install {
    __weak DYYYKeyboardAvoidanceCoordinator *weakSelf = self;
    _keyboardChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification
                                                                              object:nil
                                                                               queue:[NSOperationQueue mainQueue]
                                                                             usingBlock:^(NSNotification *note) {
        DYYYKeyboardAvoidanceCoordinator *strongSelf = weakSelf; if (!strongSelf) return;
        if (!self) return;
        CGRect endFrame = [note.userInfo[UIKeyboardFrameEndFrameKey] CGRectValue];
        CGRect screen = [UIScreen mainScreen].bounds;
        CGFloat offset = screen.size.height - endFrame.origin.y;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYKeyboardAvoidanceOffsetDidChange"
                                                            object:self
                                                          userInfo:@{@"offset": @(offset)}];
    }];
}

- (void)setKeyboardChangeObserver:(id)keyboardChangeObserver {
    _keyboardChangeObserver = keyboardChangeObserver;
}

- (void)dealloc {
    if (_keyboardChangeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_keyboardChangeObserver];
    }
}
@end