#import <UIKit/UIKit.h>
#import <MobileSubstrate/MobileSubstrate.h>

#import "Settings/Options.h"
#import "Hooks/SpringboardHooks.h"
#import "UI/EditorViews.h"

@class ARILayoutState;

@interface ARITweakManager : NSObject
@property (nonatomic, strong) ARILayoutState *state;
+ (instancetype)sharedManager;
- (void)applicationDidFinishLaunching;
- (void)reloadAllFromSettings;
- (void)queueLayoutRefresh;
@end

@interface ARILayoutState : NSObject
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) NSInteger columns;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, assign) CGFloat iconScale;
@property (nonatomic, assign) CGFloat spacingX;
@property (nonatomic, assign) CGFloat spacingY;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, copy) NSString *welcomeText;
@property (nonatomic, strong) UIColor *welcomeTextColor;
@property (nonatomic, assign) BOOL hidePageDots;
@property (nonatomic, assign) BOOL hideLabels;
@property (nonatomic, assign) BOOL hideBadges;
@property (nonatomic, assign) BOOL dropShadow;
@property (nonatomic, assign) BOOL showBackground;
@property (nonatomic, assign) BOOL blurTintEnabled;
@property (nonatomic, assign) BOOL disableTapGesture;
@property (nonatomic, assign) BOOL disableDock;
@property (nonatomic, assign) BOOL hideFolderIconBG;
@property (nonatomic, assign) BOOL scaleInsideFolders;
@property (nonatomic, assign) BOOL saveIconState;
@property (nonatomic, assign) BOOL enableAppLibrary;
@property (nonatomic, assign) BOOL hide3DTouchActions;
@property (nonatomic, assign) BOOL showTooltips;
@end

@interface Tweak : NSObject
+ (void)load;
+ (void)unload;
@end
