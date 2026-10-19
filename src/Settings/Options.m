#import "Options.h"

static NSString *const kAtriaDomain = @"me.lau.Atria";

@implementation ARIOption
- (instancetype)init {
    self = [super init];
    if (self) {
        _numeric = NO;
    }
    return self;
}

- (id)value {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kAtriaDomain];
    if (!self.key || !defaults) {
        return self.defaultValue;
    }
    id stored = [defaults objectForKey:self.key];
    if (stored) {
        return stored;
    }
    return self.defaultValue;
}

- (BOOL)boolValue {
    if (self.isToggle || [self.value isKindOfClass:[NSNumber class]]) {
        return [self.value boolValue];
    }
    return NO;
}

- (NSInteger)integerValue {
    if (self.numeric) {
        return [self.value integerValue];
    }
    return 0;
}

- (CGFloat)floatValue {
    if (self.numeric) {
        return [self.value floatValue];
    }
    return 0.0;
}
@end

@implementation ARIAtriaOptions
+ (NSDictionary<NSString *, ARIOption *> *)options {
    NSMutableDictionary *map = [NSMutableDictionary new];

    ARIOption *enabled = [ARIOption new];
    enabled.key = @"layoutEnabled";
    enabled.defaultValue = @YES;
    enabled.isToggle = YES;
    map[@"layoutEnabled"] = enabled;

    ARIOption *columns = [ARIOption new];
    columns.key = @"columns";
    columns.defaultValue = @4;
    columns.numeric = YES;
    columns.minimumValue = @2;
    columns.maximumValue = @7;
    map[@"columns"] = columns;

    ARIOption *rows = [ARIOption new];
    rows.key = @"rows";
    rows.defaultValue = @4;
    rows.numeric = YES;
    rows.minimumValue = @2;
    rows.maximumValue = @8;
    map[@"rows"] = rows;

    ARIOption *iconScale = [ARIOption new];
    iconScale.key = @"iconScale";
    iconScale.defaultValue = @1.0;
    iconScale.numeric = YES;
    iconScale.minimumValue = @0.5;
    iconScale.maximumValue = @1.6;
    map[@"iconScale"] = iconScale;

    ARIOption *spacingX = [ARIOption new];
    spacingX.key = @"spacing_x";
    spacingX.defaultValue = @12.0;
    spacingX.numeric = YES;
    spacingX.minimumValue = @0;
    spacingX.maximumValue = @48;
    map[@"spacing_x"] = spacingX;

    ARIOption *spacingY = [ARIOption new];
    spacingY.key = @"spacing_y";
    spacingY.defaultValue = @12.0;
    spacingY.numeric = YES;
    spacingY.minimumValue = @0;
    spacingY.maximumValue = @48;
    map[@"spacing_y"] = spacingY;

    ARIOption *hidePageDots = [ARIOption new];
    hidePageDots.key = @"hidePageDots";
    hidePageDots.defaultValue = @NO;
    hidePageDots.isToggle = YES;
    map[@"hidePageDots"] = hidePageDots;

    ARIOption *hideLabels = [ARIOption new];
    hideLabels.key = @"hideLabels";
    hideLabels.defaultValue = @NO;
    hideLabels.isToggle = YES;
    map[@"hideLabels"] = hideLabels;

    ARIOption *hideBadges = [ARIOption new];
    hideBadges.key = @"hideBadges";
    hideBadges.defaultValue = @NO;
    hideBadges.isToggle = YES;
    map[@"hideBadges"] = hideBadges;

    ARIOption *dropShadow = [ARIOption new];
    dropShadow.key = @"dropShadow";
    dropShadow.defaultValue = @YES;
    dropShadow.isToggle = YES;
    map[@"dropShadow"] = dropShadow;

    ARIOption *showBackground = [ARIOption new];
    showBackground.key = @"showBackground";
    showBackground.defaultValue = @NO;
    showBackground.isToggle = YES;
    map[@"showBackground"] = showBackground;

    ARIOption *blurTintEnabled = [ARIOption new];
    blurTintEnabled.key = @"blurTintEnabled";
    blurTintEnabled.defaultValue = @NO;
    blurTintEnabled.isToggle = YES;
    map[@"blurTintEnabled"] = blurTintEnabled;

    ARIOption *disableTapGesture = [ARIOption new];
    disableTapGesture.key = @"disableTapGesture";
    disableTapGesture.defaultValue = @NO;
    disableTapGesture.isToggle = YES;
    map[@"disableTapGesture"] = disableTapGesture;

    ARIOption *disableDock = [ARIOption new];
    disableDock.key = @"disableDock";
    disableDock.defaultValue = @NO;
    disableDock.isToggle = YES;
    map[@"disableDock"] = disableDock;

    ARIOption *hideFolderIconBG = [ARIOption new];
    hideFolderIconBG.key = @"hideFolderIconBG";
    hideFolderIconBG.defaultValue = @NO;
    hideFolderIconBG.isToggle = YES;
    map[@"hideFolderIconBG"] = hideFolderIconBG;

    ARIOption *scaleInsideFolders = [ARIOption new];
    scaleInsideFolders.key = @"scaleInsideFolders";
    scaleInsideFolders.defaultValue = @NO;
    scaleInsideFolders.isToggle = YES;
    map[@"scaleInsideFolders"] = scaleInsideFolders;

    ARIOption *saveIconState = [ARIOption new];
    saveIconState.key = @"saveIconState";
    saveIconState.defaultValue = @YES;
    saveIconState.isToggle = YES;
    map[@"saveIconState"] = saveIconState;

    ARIOption *enableAppLibrary = [ARIOption new];
    enableAppLibrary.key = @"enableAppLibrary";
    enableAppLibrary.defaultValue = @NO;
    enableAppLibrary.isToggle = YES;
    map[@"enableAppLibrary"] = enableAppLibrary;

    ARIOption *hide3DTouchActions = [ARIOption new];
    hide3DTouchActions.key = @"hide3DTouchActions";
    hide3DTouchActions.defaultValue = @NO;
    hide3DTouchActions.isToggle = YES;
    map[@"hide3DTouchActions"] = hide3DTouchActions;

    ARIOption *showTooltips = [ARIOption new];
    showTooltips.key = @"showTooltips";
    showTooltips.defaultValue = @NO;
    showTooltips.isToggle = YES;
    map[@"showTooltips"] = showTooltips;

    return [map copy];
}

+ (BOOL)isEnabled {
    return [[self options][@"layoutEnabled"] boolValue];
}

+ (NSInteger)columns {
    return [[self options][@"columns"] integerValue];
}

+ (NSInteger)rows {
    return [[self options][@"rows"] integerValue];
}

+ (CGFloat)iconScale {
    return [[self options][@"iconScale"] floatValue];
}
@end
