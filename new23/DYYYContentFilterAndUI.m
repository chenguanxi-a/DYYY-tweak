#import "DYYYNew23.h"
#import "DYYYManager.h
#import "AwemeHeaders.h
#define DYYYMediaTypeVideo MediaTypeVideo
#define DYYYMediaTypeAudio MediaTypeAudio
#define DYYYMediaTypeImage MediaTypeImage
#define DYYYMediaTypeHeic MediaTypeHeic
#import <Photos/Photos.h>

@implementation DYYYContentFilter
+ (BOOL)containsHDRMetadataInObject:(id)obj depth:(NSInteger)depth {
    if (!obj || depth > 6) return NO;
    @try {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in ((NSDictionary *)obj).allKeys) {
                if ([key containsString:@"hdr"] || [key containsString:@"HDR"]) return YES;
                if ([self containsHDRMetadataInObject:obj[key] depth:depth + 1]) return YES;
            }
        } else if ([obj isKindOfClass:[NSArray class]]) {
            for (id item in (NSArray *)obj) {
                if ([self containsHDRMetadataInObject:item depth:depth + 1]) return YES;
            }
        }
    } @catch (__unused NSException *e) {}
    return NO;
}

+ (BOOL)shouldExcludeFromGlobalHDRFilter:(id)obj {
    if (!obj) return NO;
    if (D23Bool(@"DYYYDisableAllHDR", NO)) return NO;
    return [self containsHDRMetadataInObject:obj depth:0];
}

+ (BOOL)objectContainsMeaningfulAdPayload:(id)obj {
    if (!obj) return NO;
    @try {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)obj;
            for (NSString *key in @[@"ad", @"adId", @"ad_info", @"isAd", @"promotion"]) {
                id v = dict[key];
                if (v && v != [NSNull null]) {
                    if ([v isKindOfClass:[NSNumber class]] && [v boolValue]) return YES;
                    if ([v isKindOfClass:[NSDictionary class]] && [v count] > 0) return YES;
                }
            }
        }
    } @catch (__unused NSException *e) {}
    return NO;
}

+ (NSNumber *)numberValueForLowLikesFilter:(id)model {
    if (!model) return nil;
    @try {
        id stats = [model valueForKey:@"statistics"];
        if (!stats) return nil;
        id digg = [stats valueForKey:@"digg_count"];
        if ([digg isKindOfClass:[NSString class]]) return @([((NSString *)digg) intValue]);
        if ([digg isKindOfClass:[NSNumber class]]) return digg;
    } @catch (__unused NSException *e) {}
    return nil;
}

+ (NSNumber *)resolvedDiggCountForAweme:(id)aweme {
    NSNumber *n = [self numberValueForLowLikesFilter:aweme];
    if (n) return n;
    @try {
        id stats = [aweme valueForKey:@"statistics"];
        id custom = [stats valueForKey:@"digg_count"];
        if (custom && ![custom isKindOfClass:[NSNull class]]) {
            if ([custom isKindOfClass:[NSString class]]) return @([((NSString *)custom) intValue]);
            if ([custom isKindOfClass:[NSNumber class]]) return custom;
        }
    } @catch (__unused NSException *e) {}
    return @(0);
}
@end

@implementation DYYYVideoEditViewController
- (instancetype)init {
    self = [super init];
    if (self) { _customStats = [NSMutableDictionary dictionary]; }
    return self;
}
- (void)commitCustomStats {
    if (!_videoId) return;
    for (NSString *key in _customStats.allKeys) {
        [[NSUserDefaults standardUserDefaults] setObject:_customStats[key] forKey:[@"DYYYVideoCustom_" stringByAppendingString:key]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:_videoId forKey:@"DYYYTempEditingVideoId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation DYYYMessageCustomizer
+ (NSString *)formatVideoDate:(NSDate *)date customFormat:(NSString *)fmt {
    if (!date) return @"";
    NSString *format = fmt;
    if (format.length == 0) format = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYMessageCustomVideoDateFormat"];
    if (format.length == 0) {
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-MM-dd HH:mm";
        return [df stringFromDate:date];
    }
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = format;
    return [df stringFromDate:date];
}

+ (NSString *)customAudioDurationString:(NSTimeInterval)seconds {
    NSInteger total = (NSInteger)seconds;
    if (total < 60) return [NSString stringWithFormat:@"%ld s", (long)total];
    NSInteger m = total / 60, s = total % 60;
    return [NSString stringWithFormat:@"%ld:%02ld", (long)m, (long)s];
}

+ (BOOL)isOneWayReadReceiptEnabled {
    return D23Bool(@"DYYYMessageOneWayReadReceipt", NO);
}

+ (NSArray<NSString *> *)readReceiptTargets {
    NSString *targets = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYMessageReadReceiptTargets"];
    if (targets.length == 0) return @[];
    return [targets componentsSeparatedByString:@","];
}

+ (void)applyReadReceiptStyles {
}
@end

@implementation DYYYGeoNamesCache {
    NSMutableDictionary<NSString *, NSString *> *_cache;
}
+ (instancetype)shared {
    static DYYYGeoNamesCache *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[DYYYGeoNamesCache alloc] init];
        shared->_cache = [NSMutableDictionary dictionary];
    });
    return shared;
}
- (NSString *)cachedNameForGeonameId:(NSString *)geonameId {
    return _cache[geonameId];
}
- (void)storeName:(NSString *)name forGeonameId:(NSString *)geonameId {
    _cache[geonameId] = name;
}
+ (NSString *)geonamesUsername {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYGeonamesUsername"] ?: @"";
}
@end

@implementation DYYYRemoteConfig {
    BOOL _useRemote;
    NSString *_currentFlagKey;
    NSString *_remoteModeString;
}
+ (instancetype)shared {
    static DYYYRemoteConfig *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[DYYYRemoteConfig alloc] init];
        shared->_useRemote = D23Bool(@"DYYYUseRemoteConfig", NO);
        shared->_currentFlagKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYRemoteConfigFlagKey"];
        shared->_remoteModeString = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYRemoteModeString"];
    });
    return shared;
}
- (BOOL)useRemote { return _useRemote; }
- (NSString *)currentFlagKey { return _currentFlagKey; }
- (NSString *)remoteModeString { return _remoteModeString; }
- (void)checkForRemoteConfigUpdate {
    NSString *urlString = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYRemoteConfigURL"];
    if (urlString.length == 0) return;
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) return;
    [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) {
            [self notifyStateChanged:NO];
            return;
        }
        @try {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]) {
                [[NSUserDefaults standardUserDefaults] setObject:json[@"flag"] forKey:@"DYYYRemoteConfigFlagKey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self notifyStateChanged:YES];
            }
        } @catch (__unused NSException *e) {}
    }] resume];
}
- (void)notifyStateChanged:(BOOL)changed {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYRemoteConfigStateChanged"
                                                        object:self
                                                      userInfo:@{@"changed": @(changed)}];
}
@end

@implementation DYYYRecommendationFilterConfig
+ (instancetype)config {
    DYYYRecommendationFilterConfig *c = [[DYYYRecommendationFilterConfig alloc] init];
    c.filterLowLikes = D23Bool(@"DYYYFilterLowLikes", NO);
    c.lowLikesThreshold = D23Float(@"DYYYFilterLowLikesThreshold", 100.0);
    c.filterTimeLimit = D23Bool(@"DYYYFilterTimeLimit", NO);
    c.maxAgeSeconds = D23Float(@"DYYYFilterTimeLimitSeconds", 86400.0);
    NSString *users = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYFilterUsers"];
    c.filteredUserIds = users.length > 0 ? [users componentsSeparatedByString:@","] : nil;
    NSString *props = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYFilterProp"];
    c.filteredProperties = props.length > 0 ? [props componentsSeparatedByString:@","] : nil;
    return c;
}

- (BOOL)shouldFilterAwemeModel:(id)model {
    if (!model) return NO;
    if (self.filterLowLikes) {
        NSNumber *likes = [DYYYContentFilter numberValueForLowLikesFilter:model];
        if (likes && [likes doubleValue] < self.lowLikesThreshold) return YES;
    }
    if (self.filteredUserIds.count > 0) {
        @try {
            id user = [model valueForKey:@"author"];
            if (user) {
                id uid = [user valueForKey:@"uid"];
                if ([uid isKindOfClass:[NSString class]] && [self.filteredUserIds containsObject:uid]) return YES;
            }
        } @catch (__unused NSException *e) {}
    }
    return NO;
}
@end

@implementation DYYYDoubleClickMenu
+ (BOOL)isEnabled {
    return D23Bool(@"DYYYEnableDoubleTapMenu", YES);
}

+ (void)showMenuForAweme:(id)aweme fromView:(UIView *)view {
    if (![self isEnabled]) return;
    if (!aweme) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *top = [DYYYUtils topView];
        if (!top) return;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"双击菜单"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerActionSheet];
        NSArray *items = @[@"评论", @"复制文案", @"下载视频", @"下载音频", @"创建视频", @"接口下载", @"分享面板", @"不感兴趣"];
        for (NSString *item in items) {
            [alert addAction:[UIAlertAction actionWithTitle:item style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
                [self handleAction:a.action title:item aweme:aweme view:view];
            }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [top presentViewController:alert animated:YES completion:nil];
    });
}

- (void)handleAction:(NSString *)action title:(NSString *)title aweme:(id)aweme view:(UIView *)view {
    if ([title isEqualToString:@"评论"]) { [DYYYDoubleClickMenu openCommentPanelForAweme:aweme]; return; }
    if ([title isEqualToString:@"复制文案"]) { [DYYYDoubleClickMenu copyDescriptionForAweme:aweme]; return; }
    if ([title isEqualToString:@"下载视频"]) { [DYYYDoubleClickMenu downloadVideoForAweme:aweme]; return; }
    if ([title isEqualToString:@"下载音频"]) { [DYYYDoubleClickMenu downloadAudioForAweme:aweme]; return; }
    if ([title isEqualToString:@"创建视频"]) { [DYYYDoubleClickMenu createVideoFromAweme:aweme]; return; }
    if ([title isEqualToString:@"接口下载"]) { [DYYYDoubleClickMenu interfaceDownloadForAweme:aweme]; return; }
    if ([title isEqualToString:@"分享面板"]) { [DYYYDoubleClickMenu showSharePanelForAweme:aweme]; return; }
    if ([title isEqualToString:@"不感兴趣"]) { [DYYYDoubleClickMenu markNotInterestedForAweme:aweme]; return; }
    (void)action; (void)view;
}

+ (void)openCommentPanelForAweme:(id)aweme {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYDoubleTapComment" object:aweme];
}
+ (void)copyDescriptionForAweme:(id)aweme {
    @try {
        NSString *desc = [aweme valueForKey:@"text"] ?: [aweme valueForKey:@"caption"];
        if (desc) {
            [[UIPasteboard generalPasteboard] setString:desc];
            [DYYYUtils showToast:@"文案已复制"];
        }
    } @catch (__unused NSException *e) {}
}
+ (void)downloadVideoForAweme:(id)aweme {
    @try {
        id video = [aweme valueForKey:@"video"];
        id urlList = [video valueForKey:@"play_addr"];
        NSString *url = [urlList isKindOfClass:[NSString class]] ? urlList : nil;
        if (!url) {
            @try {
                id uriList = [video valueForKey:@"play_addr_list"];
                if ([uriList isKindOfClass:[NSArray class]] && uriList.count > 0) {
                    id first = uriList[0];
                    if ([first isKindOfClass:[NSDictionary class]]) url = first[@"uri"] ?: first[@"url"];
                }
            } @catch (__unused NSException *e) {}
        }
        if (!url) { [DYYYUtils showToast:@"未找到视频 URL"]; return; }
        [DYYYManager downloadMedia:[NSURL URLWithString:url] mediaType:DYYYMediaTypeVideo completion:^(BOOL success) {
            [DYYYUtils showToast:success ? @"视频已保存" : @"下载失败"];
        }];
    } @catch (__unused NSException *e) { [DYYYUtils showToast:@"解析失败"]; }
}
+ (void)downloadAudioForAweme:(id)aweme {
    @try {
        id music = [aweme valueForKey:@"music"];
        NSString *url = [music isKindOfClass:[NSDictionary class]] ? music[@"play_url"] : nil;
        if (url) {
            [DYYYManager downloadMedia:[NSURL URLWithString:url] mediaType:DYYYMediaTypeAudio completion:^(BOOL success) {
                [DYYYUtils showToast:success ? @"音频已保存" : @"下载失败"];
            }];
        } else {
            [DYYYUtils showToast:@"未找到音频 URL"];
        }
    } @catch (__unused NSException *e) {}
}
+ (void)createVideoFromAweme:(id)aweme {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYDoubleCreateVideo" object:aweme];
}
+ (void)interfaceDownloadForAweme:(id)aweme {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYDoubleInterfaceDownload" object:aweme];
}
+ (void)showSharePanelForAweme:(id)aweme {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYDoubleTapshowSharePanel" object:aweme];
}
+ (void)markNotInterestedForAweme:(id)aweme {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYDoubleTapshowDislikeOnVideo" object:aweme];
}

+ (void)longPressSaveCoverForAweme:(id)aweme {
    @try {
        id video = [aweme valueForKey:@"video"];
        NSString *coverUrl = nil;
        @try {
            id cover = [video valueForKey:@"cover"];
            if ([cover isKindOfClass:[NSDictionary class]]) {
                id urlList = cover[@"url_list"];
                if ([urlList isKindOfClass:[NSArray class]] && urlList.count > 0) coverUrl = urlList[0];
            }
        } @catch (__unused NSException *e) {}
        if (coverUrl) {
            [DYYYManager downloadMedia:[NSURL URLWithString:coverUrl] mediaType:DYYYMediaTypeImage completion:^(BOOL s) {
                [DYYYUtils showToast:s ? @"封面已保存" : @"保存失败"];
            }];
        }
    } @catch (__unused NSException *e) {}
}
+ (void)longPressSaveAudioForAweme:(id)aweme {
    [self downloadAudioForAweme:aweme];
}
+ (void)longPressSaveCurrentImageForAweme:(id)aweme {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYLongPressSaveCurrentImage" object:aweme];
}
+ (void)longPressSaveAllImagesForAweme:(id)aweme {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYLongPressSaveAllImages" object:aweme];
}
+ (void)longPressCopyLinkForAweme:(id)aweme {
    @try {
        NSString *share = [aweme valueForKey:@"share_info"];
        NSString *link = [share isKindOfClass:[NSDictionary class]] ? share[@"share_url"] : nil;
        if (link) {
            [[UIPasteboard generalPasteboard] setString:link];
            [DYYYUtils showToast:@"链接已复制"];
        }
    } @catch (__unused NSException *e) {}
}
+ (void)longPressCopyTextForAweme:(id)aweme {
    [self copyDescriptionForAweme:aweme];
}
+ (void)longPressFilterUserForAweme:(id)aweme {
    @try {
        id user = [aweme valueForKey:@"author"];
        NSString *uid = [user isKindOfClass:[NSDictionary class]] ? user[@"uid"] : nil;
        if (uid) {
            NSString *existing = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYFilterUsers"] ?: @"";
            if (![existing containsString:uid]) {
                NSString *updated = [NSString stringWithFormat:@"%@%@%@", existing, existing.length > 0 ? @"," : @"", uid];
                [[NSUserDefaults standardUserDefaults] setObject:updated forKey:@"DYYYFilterUsers"];
                [DYYYUtils showToast:@"已加入用户过滤"];
            }
        }
    } @catch (__unused NSException *e) {}
}
+ (void)longPressFilterTitleForAweme:(id)aweme {
    @try {
        NSString *text = [aweme valueForKey:@"text"] ?: @"";
        if (text.length == 0) return;
        NSString *existing = [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYFilterKeywords"] ?: @"";
        NSArray *words = [text componentsSeparatedByString:@"\n"];
        NSMutableString *updated = [existing mutableCopy];
        for (NSString *w in words) {
            NSString *trimmed = [w stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (trimmed.length > 1 && ![updated containsString:trimmed]) {
                [updated appendFormat:@"\n%@", trimmed];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:updated forKey:@"DYYYFilterKeywords"];
        [DYYYUtils showToast:@"关键词已加入过滤"];
    } @catch (__unused NSException *e) {}
}
+ (void)longPressApiDownloadForAweme:(id)aweme {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYLongPressApiDownload" object:aweme];
}
+ (void)longPressCreateVideoForAweme:(id)aweme {
    [self createVideoFromAweme:aweme];
}
+ (void)longPressTimerCloseForAweme:(id)aweme {
    NSInteger minutes = D23Int(@"DYYYTimerCloseMinutes", 5);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)minutes * 60 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYTimerShutdownTime" object:@(minutes)];
    });
    [DYYYUtils showToast:[NSString stringWithFormat:@"已设置 %ld 分钟关闭", (long)minutes]];
}
@end

@implementation DYYYAboutDialogView
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message onConfirm:(void (^)(void))onConfirm {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.85;
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.text = message;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:13];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        [self addSubview:label];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)_handleTap {
    [self removeFromSuperview];
}
+ (void)showAboutDialog:message:(NSString *)message onConfirm:(void (^)(void))onConfirm {
    UIWindow *window = [DYYYManager getActiveWindow];
    DYYYAboutDialogView *view = [[DYYYAboutDialogView alloc] initWithTitle:@"关于" message:message onConfirm:onConfirm];
    view.frame = window.bounds;
    [window addSubview:view];
}
- (void)show {
    UIWindow *window = [DYYYManager getActiveWindow];
    if (!window) return;
    self.frame = window.bounds;
    [window addSubview:self];
    self.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{ self.alpha = 0.85; }];
}

@end

@implementation DYYYAbout
+ (instancetype)shared {
    static DYYYAbout *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [[DYYYAbout alloc] init]; });
    return shared;
}
- (void)show {
    NSString *version = @"2.3-0";
    NSString *msg = [NSString stringWithFormat:@"DYYY++ v%@", version];
    [DYYYAboutDialogView showAboutDialog:message:msg onConfirm:nil];
}
@end

@implementation DYYYCheckUpdate
+ (void)check {
    NSString *url = @"https://api.github.com/repos/chenguanxi-a/DYYY-tweak/releases/latest";
    NSURL *u = [NSURL URLWithString:url];
    if (!u) return;
    [[NSURLSession sharedSession] dataTaskWithURL:u completionHandler:^(NSData *data, NSURLResponse *resp, NSError *err) {
        if (err || !data) {
            [DYYYUtils showToast:@"检查更新失败"];
            return;
        }
        @try {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *tag = json[@"tag_name"] ?: @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYNoUpdates" object:tag];
            [DYYYUtils showToast:[NSString stringWithFormat:@"最新版本 %@", tag]];
        } @catch (__unused NSException *e) {
            [DYYYUtils showToast:@"解析更新信息失败"];
        }
    }] resume];
}
@end

@implementation DYYYCleanCache
+ (void)run {
    NSString *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    if (caches) {
        NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:caches error:nil];
        for (NSString *item in items) {
            [[NSFileManager defaultManager] removeItemAtPath:[caches stringByAppendingPathComponent:item] error:nil];
        }
    }
    [DYYYUtils showToast:@"缓存已清理"];
}
@end

@implementation DYYYCleanSettings
+ (void)run {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    for (NSString *key in [ud dictionaryRepresentation].allKeys) {
        if ([key hasPrefix:@"DYYY"]) [ud removeObjectForKey:key];
    }
    [ud synchronize];
    [DYYYUtils showToast:@"设置已重置"];
}
@end