#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ARIAtriaHooks : NSObject
+ (void)installAll;
+ (void)installSpringboardHooks;
+ (void)installIconListViewHook;
+ (void)installFlowLayoutHook;
+ (void)installDockViewHook;
+ (void)installPageDotsHook;
+ (void)installBadgeViewHook;
+ (void)installIconViewHook;
+ (void)applyLayoutToIconListView:(UIView *)iconListView;
+ (void)applyDockLayoutToDockView:(UIView *)dockView;
+ (void)applyPageDotsToPageControl:(UIView *)pageControl;
+ (void)applyBadgeStateToBadgeView:(UIView *)badgeView;
+ (void)applyIconScaleToIconView:(UIView *)iconView;
+ (UIView *)currentSpringboardRootView;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (void)addMethodIfMissing:(Class)target
                    selector:(SEL)sel
                      object:(id)obj
                  impBlock:(void (^)(id, SEL))block;
@end
