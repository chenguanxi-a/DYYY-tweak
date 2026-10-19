#import <UIKit/UIKit.h>

@interface ARIDynamicBackgroundView : UIView
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *gradientColor;
@property (nonatomic, assign) CGFloat intensity;
- (void)startAnimation;
- (void)stopAnimation;
@end

@interface ARIDynamicWelcomeLabel : UILabel
@property (nonatomic, copy) NSString *welcomeText;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat textSize;
@property (nonatomic, assign) CGFloat topAnchorOffset;
@property (nonatomic, assign) CGFloat leadingAnchorOffset;
- (void)resetAnchors;
@end

@interface ARIEditingMainView : UIView
@property (nonatomic, strong, readonly) ARIDynamicBackgroundView *backgroundView;
@property (nonatomic, strong, readonly) ARIDynamicWelcomeLabel *welcomeLabel;
@property (nonatomic, strong, readonly) UIScrollView *contentScrollView;
- (void)loadOptionsIntoUI;
- (void)presentOnView:(UIView *)parentView;
@end

@interface ARIEditingControlsView : UIView
@property (nonatomic, copy) NSString *settingKey;
@property (nonatomic, copy) NSString *settingTitle;
@property (nonatomic, strong) NSString *settingTranslation;
- (void)layoutOptionsForTarget:(UIView *)target;
@end

@interface ARISettingCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *img;
@property (nonatomic, strong) UILabel *currentSettingLabel;
@property (nonatomic, strong) UILabel *lowerLabel;
@property (nonatomic, strong) UILabel *upperLabel;
@property (nonatomic, strong) UILabel *opLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UITextField *currentValueTextEntry;
@property (nonatomic, strong) UIVisualEffectView *matEffect;
- (void)bindOption:(NSString *)key;
@end

@interface ARISettingCollectionViewHost : UICollectionView
- (void)registerOption:(NSString *)key;
- (void)updateForOption:(NSString *)key;
@end

@interface ARIFadeEffectView : UIVisualEffectView
@property (nonatomic, assign) BOOL showFade;
- (void)animateIn;
- (void)animateOut;
@end

@interface ARISplashViewController : UIViewController
@property (nonatomic, strong, readonly) ARIDynamicWelcomeLabel *welcomeLabel;
- (void)showInView:(UIView *)parentView;
@end
