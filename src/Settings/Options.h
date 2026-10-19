#import <Foundation/Foundation.h>

@interface ARIOption : NSObject
@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) NSNumber *defaultValue;
@property (nonatomic, strong) NSNumber *minimumValue;
@property (nonatomic, strong) NSNumber *maximumValue;
@property (nonatomic, assign) BOOL isToggle;
@property (nonatomic, assign) BOOL numeric;
- (id)value;
- (BOOL)boolValue;
- (NSInteger)integerValue;
- (CGFloat)floatValue;
@end

@interface ARIAtriaOptions : NSObject
+ (NSDictionary<NSString *, ARIOption *> *)options;
+ (BOOL)isEnabled;
+ (NSInteger)columns;
+ (NSInteger)rows;
+ (CGFloat)iconScale;
@end
