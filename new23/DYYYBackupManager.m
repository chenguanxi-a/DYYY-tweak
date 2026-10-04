#import "DYYYNew23.h"
#import <QuartzCore/QuartzCore.h>

@implementation DYYYBackupManager
+ (instancetype)shared {
    static DYYYBackupManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [[DYYYBackupManager alloc] init]; });
    return shared;
}

+ (NSString *)backupFileFormatVersion {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"DYYYBackupFormatVersion"] ?: @"1";
}
+ (NSString *)backupFileExtension { return @"dyyybackup"; }

static NSArray<NSString *> *dyyyAllKeysOfInterest(void) {
    NSMutableArray *keys = [NSMutableArray array];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    for (NSString *k in [ud dictionaryRepresentation].allKeys) {
        if ([k hasPrefix:@"DYYY"]) [keys addObject:k];
    }
    return keys;
}

static BOOL dyyyValueIsSensitive(NSString *key, id value) {
    return ([key containsString:@"Token"] || [key containsString:@"Key"] || [key containsString:@"Secret"]) ? YES : NO;
}

- (BOOL)createBackupAtURL:(NSURL *)url
          includeSensitive:(BOOL)includeSensitive
                   summary:(NSString **)summary
                     error:(NSError **)error {
    NSMutableDictionary *root = [NSMutableDictionary dictionary];
    root[@"version"] = [DYYYBackupManager backupFileFormatVersion];
    root[@"created"] = @((long)[[NSDate date] timeIntervalSince1970]);
    root[@"includeSensitive"] = @(includeSensitive);

    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    for (NSString *k in dyyyAllKeysOfInterest()) {
        id v = [[NSUserDefaults standardUserDefaults] objectForKey:k];
        if (!v) continue;
        if (!includeSensitive && dyyyValueIsSensitive(k, v)) continue;
        settings[k] = v;
    }
    root[@"settings"] = settings;

    NSError *plistError = nil;
    NSData *data = [NSPropertyListSerialization dataWithPlist:root
                                                       format:NSPropertyListXMLFormat_v1_0
                                                        error:&plistError];
    if (!data) {
        if (error) *error = plistError;
        return NO;
    }
    BOOL written = [data writeToURL:url options:NSDataWritingAtomic error:error];
    if (written) {
        [[NSUserDefaults standardUserDefaults] setObject:url.absoluteString forKey:@"DYYYBackupLastPath"];
        if (summary) {
            *summary = [NSString stringWithFormat:@"DYYY_Backup_%@.dyyybackup 已保存，共 %lu 项",
                                      [[NSDate date] descriptionWithDateFormat:@"yyyyMMdd_HHmmss"],
                                      (unsigned long)settings.count];
        }
    }
    return written;
}

- (BOOL)restoreBackupAtURL:(NSURL *)url
                     mode:(NSUInteger)mode
                  summary:(NSString **)summary
                    error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:error];
    if (!data) {
        if (error) *error = [NSError errorWithDomain:@"DYYYBackup" code:2 userInfo:@{NSLocalizedDescriptionKey:@"无法读取备份文件"}];
        return NO;
    }
    NSError *parseError = nil;
    id plist = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:&parseError];
    if (![plist isKindOfClass:[NSDictionary class]]) {
        if (error) *error = parseError ?: [NSError errorWithDomain:@"DYYYBackup" code:3 userInfo:@{NSLocalizedDescriptionKey:@"备份格式无效"}];
        return NO;
    }
    NSDictionary *settings = plist[@"settings"];
    if (![settings isKindOfClass:[NSDictionary class]]) {
        if (error) *error = [NSError errorWithDomain:@"DYYYBackup" code:4 userInfo:@{NSLocalizedDescriptionKey:@"备份缺少设置数据"}];
        return NO;
    }

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (mode == 1) { // DYYY_MODE_REPLACE
        for (NSString *k in dyyyAllKeysOfInterest()) {
            if (![settings objectForKey:k]) { [ud removeObjectForKey:k]; }
        }
    }
    for (NSString *k in settings.allKeys) {
        if (![k hasPrefix:@"DYYY"]) continue;
        [ud setObject:settings[k] forKey:k];
    }
    [ud synchronize];
    if (summary) *summary = [NSString stringWithFormat:@"已恢复 %lu 项设置", (unsigned long)settings.count];
    return YES;
}

- (BOOL)inspectBackupAtURL:(NSURL *)url
                   summary:(NSString **)summary
                     error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:error];
    if (!data) return NO;
    NSError *parseError = nil;
    id plist = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:&parseError];
    if (![plist isKindOfClass:[NSDictionary class]]) return NO;
    NSDictionary *settings = plist[@"settings"];
    if (summary) {
        *summary = [NSString stringWithFormat:@"备份版本 %@，包含 %lu 项设置",
                          plist[@"version"] ?: @"?",
                          (unsigned long)([settings isKindOfClass:[NSDictionary class]] ? settings.count : 0)];
    }
    return YES;
}
@end

@implementation DYYYBackupSettings
+ (void)savePendingBackupSettings:(DYYYBackupSettings *)settings {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"path"] = settings.backupPath ?: @"";
    dict[@"includeSensitive"] = @(settings.includeSensitive);
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"DYYYBackupPending"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (DYYYBackupSettings *)pendingBackupSettings {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"DYYYBackupPending"];
    if (!dict) return nil;
    DYYYBackupSettings *s = [[DYYYBackupSettings alloc] init];
    s.backupPath = dict[@"path"];
    s.includeSensitive = [dict[@"includeSensitive"] boolValue];
    return s;
}
@end

@implementation DYYYBackupPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (self.completionBlock) self.completionBlock(url);
}
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    if (self.completionBlock) self.completionBlock(nil);
}
@end