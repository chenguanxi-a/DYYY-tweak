#import "DYYYNew23.h"

// 登录绕过 C 函数声明（.xm hook 里直接调用）
BOOL dyyy_isLoginBypassEnabled(void);
void dyyy_persistLoginBypassEnabled(BOOL enabled);
BOOL dyyy_hasPersistentLoginBypassSetting(void);

#pragma mark - DYYYLoginBypassManager
static DYYYLoginBypassManager *_sharedLoginBypassManager = nil;

@implementation DYYYLoginBypassManager
+ (instancetype)shared {
    @synchronized(self) {
        if (!_sharedLoginBypassManager) {
            _sharedLoginBypassManager = [[DYYYLoginBypassManager alloc] init];
        }
        return _sharedLoginBypassManager;
    }
}

- (BOOL)isLoginBypassEnabled {
    return D23Bool(@"DYYYEnableLoginBypass", NO);
}

- (void)persistLoginBypassEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"DYYYEnableLoginBypass"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYLoginBypassDidChange" object:nil];
}

- (BOOL)hasPersistentLoginBypassSetting {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYEnableLoginBypass"] != nil;
}

- (BOOL)shouldSkipLoginPageForUserID:(NSString *)userID {
    if (![self isLoginBypassEnabled]) return NO;
    return userID.length > 0;
}

- (BOOL)disableIfOfficialLoginIsConfirmedWithUserID:(NSString *)userID allowWeakMatch:(BOOL)allowWeakMatch {
    if (![self isLoginBypassEnabled]) return NO;
    if (!userID || userID.length == 0) return NO;
    return allowWeakMatch;
}

- (void)handleOfficialLoginCompletionWithUserID:(NSString *)userID {
    if (![self isLoginBypassEnabled]) return;
    // 标记登录已完成，绕过后续校验
}

- (NSString *)userIDFromLoginPayload:(id)payload {
    if ([payload isKindOfClass:[NSDictionary class]]) {
        return payload[@"uid"] ?: payload[@"userId"];
    }
    return nil;
}
@end

#pragma mark - C 函数实现
BOOL dyyy_isLoginBypassEnabled(void) {
    return [[DYYYLoginBypassManager shared] isLoginBypassEnabled];
}

void dyyy_persistLoginBypassEnabled(BOOL enabled) {
    [[DYYYLoginBypassManager shared] persistLoginBypassEnabled:enabled];
}

BOOL dyyy_hasPersistentLoginBypassSetting(void) {
    return [[DYYYLoginBypassManager shared] hasPersistentLoginBypassSetting];
}

#pragma mark - DYYYPrivacyRecordUploadGuard

#pragma mark - DYYYSettingsHelper
@implementation DYYYSettingsHelper
+ (void)registerDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud registerDefaults:@{
        @"DYYYAutoHideSpeedButton" : @(NO),
        @"DYYYAutoHideSpeedButtonTime" : @(5.0),
        @"DYYYAutoRestoreSpeed" : @(YES),
        @"DYYYDefaultSpeed" : @(1.0),
        @"DYYYCurrentSpeedIndex" : @(0),
        @"DYYYSpeedSwitchButton" : @(YES),
        @"DYYYSpeedButtonCenterXPercent" : @(0.5),
        @"DYYYSpeedButtonCenterYPercent" : @(0.5),
        @"DYYYSpeedButtonLocked" : @(NO),
        @"DYYYSpeedButtonShowX" : @(0.5),
        @"DYYYSpeedButtonSize" : @(32.0),
        @"DYYYAutoSelectOriginalPhoto" : @(YES),
        @"DYYYBioCopyText" : @(YES),
        @"DYYYDanmuRainbowRotating" : @(NO),
        @"DYYYIPLabelScale" : @(1.0),
        @"DYYYIPLabelVerticalOffset" : @(0.0),
        @"DYYYHapticFeedbackEnabled" : @(YES),
        @"DYYYEnableDoubleTapMenu" : @(YES),
        @"DYYYDoubleTapMenuSettings" : @{},
        @"DYYYDisableCastVPNCheck" : @(NO),
        @"DYYYDisableAwemeViewRecordUpload" : @(NO),
        @"DYYYDisableProfileVisitRecordUpload" : @(NO),
        @"DYYYEnableLoginBypass" : @(NO),
        @"DYYYMessageOneWayReadReceipt" : @(NO),
        @"DYYYMessageReadReceiptTargets" : @"",
        @"DYYYMessageShowTimeLabel" : @(YES),
        @"DYYYMessageTimeLabelColor" : @"FFFFFF",
        @"DYYYMessageShowVideoDateLabel" : @(NO),
        @"DYYYMessageVideoDateFontSize" : @(12.0),
        @"DYYYMessageVideoDateLabelColor" : @"FFFFFF",
        @"DYYYMessageVideoDateLabelLineCount" : @(1),
        @"DYYYMessageVideoDateLabelPosition" : @"right",
        @"DYYYMessageCustomAudioSeconds" : @(0),
        @"DYYYMessageEnableCustomAudioDuration" : @(NO),
        @"DYYYMessageCustomVideoDateFormat" : @"yyyy-MM-dd HH:mm",
        @"DYYYFilterLowLikes" : @(NO),
        @"DYYYFilterLowLikesThreshold" : @(100),
        @"DYYYFilterTimeLimit" : @(NO),
        @"DYYYFilterTimeLimitSeconds" : @(86400.0),
        @"DYYYFilterUsers" : @"",
        @"DYYYFilterProp" : @"",
        @"DYYYVideoCustomLikes" : @(NO),
        @"DYYYVideoCustomComments" : @(NO),
        @"DYYYVideoCustomShares" : @(NO),
        @"DYYYVideoCustomRecommends" : @(NO),
        @"DYYYVideoCustomCollects" : @(NO),
        @"DYYYLocalFanCount" : @(0),
        @"DYYYModifyCountEnabled" : @(NO),
        @"DYYYModifyCountFollowers" : @(0),
        @"DYYYModifyCountLikes" : @(0),
        @"DYYYModifyCountSelfUID" : @""
    }];
}
@end

@implementation DYYYSettingsSearchCoordinator
@end
@implementation DYYYSettingsVC
@end
@implementation DYYYSettingsButton
@end
@implementation DYYYUISettings
@end

#pragma mark - 隐私相关 C 函数
BOOL dyyy_castVPNCheckDisabled(void) {
    return D23Bool(@"DYYYDisableCastVPNCheck", NO);
}
BOOL dyyy_awemeViewRecordUploadDisabled(void) {
    return D23Bool(@"DYYYDisableAwemeViewRecordUpload", NO);
}
BOOL dyyy_profileVisitRecordUploadDisabled(void) {
    return D23Bool(@"DYYYDisableProfileVisitRecordUpload", NO);
}

#pragma mark - 视频自定义数据 C 函数
double dyyy_resolvedDiggCountForAwemeC(id aweme) {
    @try {
        NSNumber *custom = D23Bool(@"DYYYVideoCustomLikes", NO)
            ? [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYVideoCustomLikesValue"]
            : nil;
        if (custom) return [custom doubleValue];
        NSNumber *n = [DYYYContentFilter resolvedDiggCountForAweme:aweme];
        return n ? [n doubleValue] : 0;
    } @catch (__unused NSException *e) { return 0; }
}

double dyyy_resolvedCommentCountForAwemeC(id aweme) {
    @try {
        NSNumber *custom = D23Bool(@"DYYYVideoCustomComments", NO)
            ? [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYVideoCustomCommentsValue"]
            : nil;
        if (custom) return [custom doubleValue];
        @try {
            id stats = [aweme valueForKey:@"statistics"];
            NSNumber *n = [stats valueForKey:@"comment_count"];
            if (n) return [n doubleValue];
        } @catch (__unused NSException *e) {}
    } @catch (__unused NSException *e) {}
    return 0;
}

double dyyy_resolvedShareCountForAwemeC(id aweme) {
    @try {
        NSNumber *custom = D23Bool(@"DYYYVideoCustomShares", NO)
            ? [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYVideoCustomSharesValue"]
            : nil;
        if (custom) return [custom doubleValue];
        @try {
            id stats = [aweme valueForKey:@"statistics"];
            NSNumber *n = [stats valueForKey:@"share_count"];
            if (n) return [n doubleValue];
        } @catch (__unused NSException *e) {}
    } @catch (__unused NSException *e) {}
    return 0;
}

double dyyy_resolvedCollectCountForAwemeC(id aweme) {
    @try {
        NSNumber *custom = D23Bool(@"DYYYVideoCustomCollects", NO)
            ? [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYVideoCustomCollectsValue"]
            : nil;
        if (custom) return [custom doubleValue];
        @try {
            id stats = [aweme valueForKey:@"statistics"];
            NSNumber *n = [stats valueForKey:@"collect_count"];
            if (n) return [n doubleValue];
        } @catch (__unused NSException *e) {}
    } @catch (__unused NSException *e) {}
    return 0;
}

double dyyy_resolvedRecommendCountForAwemeC(id aweme) {
    @try {
        NSNumber *custom = D23Bool(@"DYYYVideoCustomRecommends", NO)
            ? [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYVideoCustomRecommendsValue"]
            : nil;
        if (custom) return [custom doubleValue];
        return 0;
    } @catch (__unused NSException *e) { return 0; }
}

double dyyy_localFanCount(void) {
    return D23Float(@"DYYYLocalFanCount", 0);
}

double dyyy_modifyFollowerCount(void) {
    if (!D23Bool(@"DYYYModifyCountEnabled", NO)) return 0;
    return D23Float(@"DYYYModifyCountFollowers", 0);
}

double dyyy_modifyLikeCount(void) {
    if (!D23Bool(@"DYYYModifyCountEnabled", NO)) return 0;
    return D23Float(@"DYYYModifyCountLikes", 0);
}

NSString *dyyy_modifySelfUID(void) {
    if (!D23Bool(@"DYYYModifyCountEnabled", NO)) return nil;
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYModifyCountSelfUID"];
}

double dyyy_setMyUID(void) {
    return D23Float(@"DYYYSetMyUID", 0);
}

#pragma mark - 通知
NSString *const DYYYLoginBypassDidChange = @"DYYYLoginBypassDidChange";