#import "EditorViews.h"

@implementation ARIDynamicBackgroundView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.12];
        _gradientColor = [UIColor whiteColor];
        _intensity = 0.35;
        self.backgroundColor = _backgroundColor;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)startAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @0.18;
    animation.toValue = @0.42;
    animation.duration = 1.8;
    animation.autoreverses = YES;
    animation.repeatCount = INFINITY;
    [self.layer addAnimation:animation forKey:@"atria_background_pulse"];
}

- (void)stopAnimation {
    [self.layer removeAllAnimations];
}
@end

@implementation ARIDynamicWelcomeLabel
- (instancetype)init {
    self = [super init];
    if (self) {
        _textColor = [UIColor whiteColor];
        _textSize = 28.0;
        _font = [UIFont systemFontOfSize:28 weight:UIFontWeightSemibold];
        self.textColor = _textColor;
        self.font = _font;
        self.alpha = 0.0;
    }
    return self;
}

- (void)resetAnchors {
    self.topAnchorOffset = 0.0;
    self.leadingAnchorOffset = 0.0;
}
@end

@implementation ARIEditingMainView {
    ARIDynamicBackgroundView *_backgroundView;
    ARIDynamicWelcomeLabel *_welcomeLabel;
    UIScrollView *_contentScrollView;
}

@synthesize backgroundView = _backgroundView;
@synthesize welcomeLabel = _welcomeLabel;
@synthesize contentScrollView = _contentScrollView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundView = [ARIDynamicBackgroundView new];
        _backgroundView.frame = self.bounds;
        [self addSubview:_backgroundView];

        _contentScrollView = [UIScrollView new];
        _contentScrollView.frame = self.bounds;
        _contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_contentScrollView];

        _welcomeLabel = [ARIDynamicWelcomeLabel new];
        _welcomeLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 60.0);
        [_contentScrollView addSubview:_welcomeLabel];

        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)loadOptionsIntoUI {
    [self.welcomeLabel resetAnchors];
}

- (void)presentOnView:(UIView *)parentView {
    if (!parentView) {
        return;
    }
    self.frame = parentView.bounds;
    self.alpha = 0.0;
    [parentView addSubview:self];
    [UIView animateWithDuration:0.28 animations:^{
        self.alpha = 1.0;
    }];
}
@end

@implementation ARIEditingControlsView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.72];
        self.layer.cornerRadius = 12.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)layoutOptionsForTarget:(UIView *)target {
    (void)target;
    [self setNeedsLayout];
}
@end

@implementation ARISettingCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _img = [UIImageView new];
        _currentSettingLabel = [UILabel new];
        _lowerLabel = [UILabel new];
        _upperLabel = [UILabel new];
        _opLabel = [UILabel new];
        _slider = [UISlider new];
        _currentValueTextEntry = [UITextField new];
        _matEffect = [UIVisualEffectView effectViewWithBlurEffect:
                     [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];

        [self.contentView addSubview:_matEffect];
        _matEffect.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        _matEffect.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.contentView addSubview:_img];
        [self.contentView addSubview:_currentSettingLabel];
        [self.contentView addSubview:_lowerLabel];
        [self.contentView addSubview:_upperLabel];
        [self.contentView addSubview:_opLabel];
        [self.contentView addSubview:_slider];
        [self.contentView addSubview:_currentValueTextEntry];

        _currentSettingLabel.textColor = [UIColor whiteColor];
        _lowerLabel.textColor = [UIColor lightGrayColor];
        _upperLabel.textColor = [UIColor lightGrayColor];
        _opLabel.textColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)bindOption:(NSString *)key {
    self.settingKey = key;
    self.settingTranslation = key;
    self.currentSettingLabel.text = key;
}
@end

@implementation ARISettingCollectionViewHost
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)registerOption:(NSString *)key {
    (void)key;
}

- (void)updateForOption:(NSString *)key {
    (void)key;
}
@end

@implementation ARIFadeEffectView
- (instancetype)initWithEffect:(UIBlurEffect *)effect {
    self = [super initWithEffect:effect];
    if (self) {
        _showFade = YES;
    }
    return self;
}

- (void)animateIn {
    self.alpha = 0.0;
    [UIView animateWithDuration:0.22 animations:^{
        self.alpha = self.showFade ? 1.0 : 0.0;
    }];
}

- (void)animateOut {
    [UIView animateWithDuration:0.22 animations:^{
        self.alpha = 0.0;
    }];
}
@end

@implementation ARISplashViewController {
    ARIDynamicWelcomeLabel *_welcomeLabel;
}

@synthesize welcomeLabel = _welcomeLabel;

- (instancetype)init {
    self = [super init];
    if (self) {
        _welcomeLabel = [ARIDynamicWelcomeLabel new];
    }
    return self;
}

- (void)showInView:(UIView *)parentView {
    if (!parentView) {
        return;
    }
    self.view.frame = parentView.bounds;
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.72];
    _welcomeLabel.frame = CGRectMake(0, 80.0, parentView.bounds.size.width, 60.0);
    _welcomeLabel.alpha = 0.0;
    [parentView addSubview:self.view];
    [self.view addSubview:_welcomeLabel];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NANOSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _welcomeLabel.alpha = 1.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NANOSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.view removeFromSuperview];
        });
    });
}
@end
