#import "Tweak.h"
#import <objc/runtime.h>
#import <objc/message.h>

static NSString *const kAtriaDomain = @"me.lau.Atria";
static NSString *const kAtriaPrefsDomain = @"me.lau.AtriaPrefs";

@implementation ARILayoutState
- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = YES;
        _columns = 4;
        _rows = 4;
        _iconScale = 1.0;
        _spacingX = 12.0;
        _spacingY = 12.0;
        _insets = UIEdgeInsetsMake(20, 20, 20, 20);
        _hidePageDots = NO;
        _hideLabels = NO;
        _hideBadges = NO;
        _dropShadow = YES;
        _showBackground = NO;
        _blurTintEnabled = NO;
        _disableTapGesture = NO;
        _disableDock = NO;
        _hideFolderIconBG = NO;
        _scaleInsideFolders = NO;
        _saveIconState = YES;
        _enableAppLibrary = NO;
        _hide3DTouchActions = NO;
        _showTooltips = NO;
    }
    return self;
}
@end

@implementation ARITweakManager
+ (instancetype)sharedManager {
    static ARITweakManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [self new]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = [ARILayoutState new];
    }
    return self;
}

- (void)applicationDidFinishLaunching {
    [self reloadAllFromSettings];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(reloadAllFromSettings)
                                                   name:NSUserDefaultsDidChangeNotification
                                                 object:nil];
    [self queueLayoutRefresh];
}

- (void)reloadAllFromSettings {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kAtriaDomain];
    if (!defaults) {
        return;
    }

    NSDictionary *options = [ARIAtriaOptions options];

    self.state.enabled = [[options[@"layoutEnabled"] value] boolValue];
    self.state.columns = [[options[@"columns"] value] integerValue];
    self.state.rows = [[options[@"rows"] value] integerValue];
    self.state.iconScale = [[options[@"iconScale"] value] floatValue];
    self.state.spacingX = [[options[@"spacing_x"] value] floatValue];
    self.state.spacingY = [[options[@"spacing_y"] value] floatValue];
    self.state.hidePageDots = [[options[@"hidePageDots"] value] boolValue];
    self.state.hideLabels = [[options[@"hideLabels"] value] boolValue];
    self.state.hideBadges = [[options[@"hideBadges"] value] boolValue];
    self.state.dropShadow = [[options[@"dropShadow"] value] boolValue];
    self.state.showBackground = [[options[@"showBackground"] value] boolValue];
    self.state.blurTintEnabled = [[options[@"blurTintEnabled"] value] boolValue];
    self.state.disableTapGesture = [[options[@"disableTapGesture"] value] boolValue];
    self.state.disableDock = [[options[@"disableDock"] value] boolValue];
    self.state.hideFolderIconBG = [[options[@"hideFolderIconBG"] value] boolValue];
    self.state.scaleInsideFolders = [[options[@"scaleInsideFolders"] value] boolValue];
    self.state.saveIconState = [[options[@"saveIconState"] value] boolValue];
    self.state.enableAppLibrary = [[options[@"enableAppLibrary"] value] boolValue];
    self.state.hide3DTouchActions = [[options[@"hide3DTouchActions"] value] boolValue];
    self.state.showTooltips = [[options[@"showTooltips"] value] boolValue];

    NSString *welcomeText = [defaults stringForKey:@"welcomeText"];
    self.state.welcomeText = [welcomeText length] ? welcomeText : @"%GREETING%, user";

    NSString *welcomeColor = [defaults stringForKey:@"welcomeTextColor"];
    self.state.welcomeTextColor = [ARIAtriaHooks colorFromHexString:welcomeColor];
}

- (void)queueLayoutRefresh {
    dispatch_async(dispatch_get_main_queue(), ^{
        ARITweakManager *manager = [ARITweakManager sharedManager];
        if (!manager.state.enabled) {
            return;
        }

        [ARIAtriaHooks applyLayoutToIconListView:nil];
        [ARIAtriaHooks applyDockLayoutToDockView:nil];
        [ARIAtriaHooks applyPageDotsToPageControl:nil];
    });
}
@end

@implementation Tweak
+ (void)load {
    NSLog(@"Atria second-development skeleton loaded");

    [ARITweakManager sharedManager];
    [ARIAtriaHooks installAll];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NANOSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ARITweakManager sharedManager] applicationDidFinishLaunching];
    });
}

+ (void)unload {
    // Leave for future cleanup if you introduce more persistent objects.
}
@end
