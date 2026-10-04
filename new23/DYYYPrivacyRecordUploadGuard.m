#import "DYYYNew23.h"

@implementation DYYYPrivacyRecordUploadGuard {
    BOOL _castVPNCheckDisabled;
    BOOL _awemeViewRecordUploadDisabled;
    BOOL _profileVisitRecordUploadDisabled;
}

+ (instancetype)shared {
    static DYYYPrivacyRecordUploadGuard *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[DYYYPrivacyRecordUploadGuard alloc] init];
        shared->_castVPNCheckDisabled = D23Bool(@"DYYYDisableCastVPNCheck", NO);
        shared->_awemeViewRecordUploadDisabled = D23Bool(@"DYYYDisableAwemeViewRecordUpload", NO);
        shared->_profileVisitRecordUploadDisabled = D23Bool(@"DYYYDisableProfileVisitRecordUpload", NO);
    });
    return shared;
}

- (void)install {
    self->_castVPNCheckDisabled = D23Bool(@"DYYYDisableCastVPNCheck", NO);
    self->_awemeViewRecordUploadDisabled = D23Bool(@"DYYYDisableAwemeViewRecordUpload", NO);
    self->_profileVisitRecordUploadDisabled = D23Bool(@"DYYYDisableProfileVisitRecordUpload", NO);
}

- (BOOL)castVPNCheckDisabled {
    return D23Bool(@"DYYYDisableCastVPNCheck", NO);
}

- (BOOL)awemeViewRecordUploadDisabled {
    return D23Bool(@"DYYYDisableAwemeViewRecordUpload", NO);
}

- (BOOL)profileVisitRecordUploadDisabled {
    return D23Bool(@"DYYYDisableProfileVisitRecordUpload", NO);
}

@end