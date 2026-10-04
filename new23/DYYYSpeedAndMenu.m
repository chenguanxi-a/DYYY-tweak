#import "DYYYNew23.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#pragma mark - 菜单模块
@implementation DYYYMenuModule
- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title iconName:(NSString *)iconName {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _title = title;
        _iconName = iconName;
        _children = @[];
    }
    return self;
}
@end

#pragma mark - 菜单样式构建器
@implementation DYYYMenuStyleBuilder
+ (DYYYMenuStyleBuilder *)classicStyle {
    DYYYMenuStyleBuilder *b = [[DYYYMenuStyleBuilder alloc] init];
    b.styleName = @"Classic";
    return b;
}
+ (DYYYMenuStyleBuilder *)neuomorphicStyle {
    DYYYMenuStyleBuilder *b = [[DYYYMenuStyleBuilder alloc] init];
    b.styleName = @"Neuomorphic";
    return b;
}
- (void)setColorStyle:(NSString *)color { (void)color; }
- (void)setLineCapStyle:(NSString *)cap { (void)cap; }
- (void)setLineJoinStyle:(NSString *)join { (void)join; }
- (void)setBorderStyle:(NSString *)border { (void)border; }
- (void)setDecorationStyle:(NSString *)decoration { (void)decoration; }
- (BOOL)applyToView:(UIView *)view {
    if (!view) return NO;
    if ([_styleName isEqualToString:@"Neuomorphic"]) {
        // 新拟态：圆角 + 双层阴影
        view.layer.cornerRadius = 12;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [UIColor systemBackgroundColor];
        CABasicAnimation *a = [CABasicAnimation animationWithKeyPath:@""];
        (void)a;
    }
    return YES;
}
@end

@implementation DYYYNeuomorphicStyleBuilder
@end

@implementation DYYYListStyleBuilder
- (UIListStyle)listStyleValue {
    if ([_listStyle isEqualToString:@"insetGrouped"]) return UIListStyleInsetGrouped;
    if ([_listStyle isEqualToString:@"plain"]) return UIListStylePlain;
    return UIListStyleInsetGrouped;
}
@end

#pragma mark - 玻璃确认弹窗
@implementation DYYYGlassConfirmView {
    UIView *_contentView;
    CAGradientLayer *_glassLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
        _contentView.layer.cornerRadius = 16;
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.borderWidth = 1;
        _contentView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
        [self addSubview:_contentView];

        _glassLayer = [CAGradientLayer layer];
        _glassLayer.colors = @[
            (id)[[UIColor colorWithWhite:1.0 alpha:0.3] CGColor],
            (id)[[UIColor colorWithWhite:0.9 alpha:0.1] CGColor]
        ];
        _glassLayer.startPoint = CGPointMake(0, 0);
        _glassLayer.endPoint = CGPointMake(1, 1);
        [_contentView.layer addSublayer:_glassLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentView.frame = CGRectMake(40, self.bounds.size.height / 2.0 - 80,
                                    self.bounds.size.width - 80, 160);
    _glassLayer.frame = _contentView.bounds;
}

- (void)showInView:(UIView *)parentView {
    if (!parentView) return;
    self.frame = parentView.bounds;
    [parentView addSubview:self];
    self.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{ self.alpha = 1.0; }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:nil completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    UILabel *label = (UILabel *)[_contentView.viewWithTag:1001 isKindOfClass:[UILabel class]] ? [_contentView viewWithTag:1001] : nil;
    if (!label) {
        label = [[UILabel alloc] init];
        label.tag = 1001;
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        label.textColor = [UIColor labelColor];
        [_contentView addSubview:label];
    }
    label.text = title;
}

- (void)setMessage:(NSString *)message {
    _message = message;
}

@end
#pragma mark - 选项选择视图
@implementation DYYYOptionsSelectionView {
    UISegmentedControl *_segment;
    UITextField *_textField;
}

- (instancetype)initWithOptions:(NSArray<NSString *> *)options {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _options = [options copy];
        _segment = [UISegmentedControl new];
        for (NSInteger i = 0; i < (NSInteger)options.count; i++) {
            [_segment insertSegmentWithTitle:options[i] atIndex:i animated:NO];
        }
        _segment.selectedSegmentIndex = 0;
        [_segment addTarget:self action:@selector(dyyyInlineOptionsSegmentChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_segment];

        _textField = [UITextField new];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.font = [UIFont systemFontOfSize:13];
        [_textField addTarget:self action:@selector(dyyyInlineTextEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
        [_textField addTarget:self action:@selector(dyyyInlineTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [self addSubview:_textField];
    }
    return self;
}

- (void)dyyyInlineOptionsSegmentChanged:(UISegmentedControl *)sender {
    self.selectedIndex = sender.selectedSegmentIndex;
    if (self.onSelectionChanged) self.onSelectionChanged(self.selectedIndex);
}

- (void)dyyyInlineTextEditingDidBegin:(UITextField *)sender {
    sender.text = @"";
}

- (void)dyyyInlineTextEditingDidEnd:(UITextField *)sender {
    if (sender.text.length > 0 && self.onSelectionChanged) {
        self.onSelectionChanged(self.selectedIndex);
    }
}

- (void)dyyyInlineTextReturn:(UITextField *)sender {
    [sender resignFirstResponder];
}
@end

#pragma mark - 截图选择视图
@implementation DYYYScreenshotSelectionView
@end

#pragma mark - 设置 Helper