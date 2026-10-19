#import "SpringboardHooks.h"
#import <objc/runtime.h>
#import <objc/message.h>

// Forward declarations for the tweak manager (defined in Atria.m)
@class ARITweakManager;

@interface ARIAtriaHooks ()
@end

@implementation ARIAtriaHooks

+ (void)installAll {
    [self installSpringboardHooks];
}

+ (void)installSpringboardHooks {
    [self installIconListViewHook];
    [self installFlowLayoutHook];
    [self installDockViewHook];
    [self installPageDotsHook];
    [self installBadgeViewHook];
    [self installIconViewHook];
}

+ (void)installIconListViewHook {
    Class iconListView = NSClassFromString(@"SBIconListView");
    if (!iconListView) {
        return;
    }
    [self addMethodIfMissing:iconListView
                     selector:sel_registerName(@"atria_updateLayout")
                       object:nil
                    impBlock:^void(id self, SEL _cmd) {
        [self applyLayoutToIconListView:(UIView *)self];
    }];
}

+ (void)installFlowLayoutHook {
    Class flowLayout = NSClassFromString(@"SBIconListFlowExtendedLayout");
    if (!flowLayout) {
        return;
    }
    [self addMethodIfMissing:flowLayout
                     selector:sel_registerName(@"atria_applyCustomMetrics")
                       object:nil
                    impBlock:^void(id self, SEL _cmd) {
        [self applyLayoutToIconListView:nil];
    }];
}

+ (void)installDockViewHook {
    Class dockView = NSClassFromString(@"SBDockView");
    if (!dockView) {
        return;
    }
    [self addMethodIfMissing:dockView
                     selector:sel_registerName(@"atria_applyDockLayout")
                       object:nil
                    impBlock:^void(id self, SEL _cmd) {
        [self applyDockLayoutToDockView:(UIView *)self];
    }];
}

+ (void)installPageDotsHook {
    Class pageControl = NSClassFromString(@"SBIconListPageControl");
    if (!pageControl) {
        return;
    }
    [self addMethodIfMissing:pageControl
                     selector:sel_registerName(@"atria_applyPageDotsState")
                       object:nil
                    impBlock:^void(id self, SEL _cmd) {
        [self applyPageDotsToPageControl:(UIView *)self];
    }];
}

+ (void)installBadgeViewHook {
    Class badgeView = NSClassFromString(@"SBIconBadgeView");
    if (!badgeView) {
        return;
    }
    [self addMethodIfMissing:badgeView
                     selector:sel_registerName(@"atria_applyBadgeState")
                       object:nil
                    impBlock:^void(id self, SEL _cmd) {
        [self applyBadgeStateToBadgeView:(UIView *)self];
    }];
}

+ (void)installIconViewHook {
    Class iconView = NSClassFromString(@"SBIconView");
    if (!iconView) {
        return;
    }
    [self addMethodIfMissing:iconView
                     selector:sel_registerName(@"atria_applyIconScale")
                       object:nil
                    impBlock:^void(id self, SEL _cmd) {
        [self applyIconScaleToIconView:(UIView *)self];
    }];
}

+ (void)addMethodIfMissing:(Class)target
                    selector:(SEL)sel
                      object:(id)obj
                  impBlock:(void (^)(id, SEL))block {
    if (!target || !sel || !block) {
        return;
    }

    IMP imp = imp_implementationWithBlock(block, NULL);
    if (class_getInstanceMethod(target, sel)) {
        method_setImplementation(class_getInstanceMethod(target, sel), imp);
    } else {
        class_addMethod(target, sel, imp, "v@:");
    }
}

+ (void)applyLayoutToIconListView:(UIView *)iconListView {
    // The tweak manager is owned by Atria.m, so we use objc_getClass to fetch it.
    Class managerClass = objc_getClass("ARITweakManager");
    if (!managerClass) {
        return;
    }
    id shared = objc_msgSend(managerClass, sel_registerName("sharedManager"));
    id state = objc_msgSend(shared, sel_registerName("state"));
    BOOL enabled = (BOOL)objc_msgSend(state, sel_registerName("enabled"));
    if (!enabled) {
        return;
    }

    UIView *rootView = iconListView ? iconListView : [self currentSpringboardRootView];
    if (!rootView) {
        return;
    }

    CGFloat dropShadow = [objc_msgSend(state, sel_registerName("dropShadow")) boolValue];
    BOOL showBackground = [objc_msgSend(state, sel_registerName("showBackground")) boolValue];

    rootView.layer.cornerRadius = 0.0;
    rootView.layer.masksToBounds = NO;

    if (dropShadow) {
        rootView.layer.shadowColor = [UIColor blackColor].CGColor;
        rootView.layer.shadowOpacity = 0.24;
        rootView.layer.shadowRadius = 12.0;
        rootView.layer.shadowOffset = CGSizeMake(0.0, 6.0);
    } else {
        rootView.layer.shadowOpacity = 0.0;
    }

    if (showBackground) {
        rootView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.18];
    } else {
        rootView.backgroundColor = [UIColor clearColor];
    }
}

+ (void)applyDockLayoutToDockView:(UIView *)dockView {
    Class managerClass = objc_getClass("ARITweakManager");
    if (!managerClass || !dockView) {
        return;
    }
    id shared = objc_msgSend(managerClass, sel_registerName("sharedManager"));
    id state = objc_msgSend(shared, sel_registerName("state"));
    BOOL enabled = (BOOL)objc_msgSend(state, sel_registerName("enabled"));
    if (!enabled) {
        return;
    }

    BOOL disableDock = [objc_msgSend(state, sel_registerName("disableDock")) boolValue];
    CGFloat scale = [objc_msgSend(state, sel_registerName("iconScale")) floatValue];

    if (disableDock) {
        dockView.hidden = YES;
        dockView.alpha = 0.0;
    } else {
        dockView.hidden = NO;
    }

    if (scale > 0.01) {
        dockView.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

+ (void)applyPageDotsToPageControl:(UIView *)pageControl {
    Class managerClass = objc_getClass("ARITweakManager");
    if (!managerClass) {
        return;
    }
    id shared = objc_msgSend(managerClass, sel_registerName("sharedManager"));
    id state = objc_msgSend(shared, sel_registerName("state"));
    BOOL enabled = (BOOL)objc_msgSend(state, sel_registerName("enabled"));
    if (!enabled || !pageControl) {
        return;
    }
    BOOL hidePageDots = [objc_msgSend(state, sel_registerName("hidePageDots")) boolValue];
    pageControl.hidden = hidePageDots;
}

+ (void)applyBadgeStateToBadgeView:(UIView *)badgeView {
    Class managerClass = objc_getClass("ARITweakManager");
    if (!managerClass || !badgeView) {
        return;
    }
    id shared = objc_msgSend(managerClass, sel_registerName("sharedManager"));
    id state = objc_msgSend(shared, sel_registerName("state"));
    BOOL enabled = (BOOL)objc_msgSend(state, sel_registerName("enabled"));
    if (!enabled) {
        return;
    }
    BOOL hideBadges = [objc_msgSend(state, sel_registerName("hideBadges")) boolValue];
    badgeView.hidden = hideBadges;
}

+ (void)applyIconScaleToIconView:(UIView *)iconView {
    Class managerClass = objc_getClass("ARITweakManager");
    if (!managerClass || !iconView) {
        return;
    }
    id shared = objc_msgSend(managerClass, sel_registerName("sharedManager"));
    id state = objc_msgSend(shared, sel_registerName("state"));
    BOOL enabled = (BOOL)objc_msgSend(state, sel_registerName("enabled"));
    if (!enabled) {
        return;
    }
    CGFloat scale = [objc_msgSend(state, sel_registerName("iconScale")) floatValue];
    if (scale > 0.01) {
        iconView.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

+ (UIView *)currentSpringboardRootView {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        for (UIView *subview in window.subviews) {
            if ([NSStringFromClass([subview class]) containsString:@"SpringBoard"] ||
                [NSStringFromClass([subview class]) containsString:@"SBMain"]) {
                return subview;
            }
        }
    }
    return nil;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    if (![hexString length]) {
        return [UIColor whiteColor];
    }
    NSString *cleaned = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet];
    unsigned int value = 0;
    if (cleaned.length < 6) {
        return [UIColor whiteColor];
    }
    if ([[NSScanner scannerWithString:cleaned] scanHexInt:&value]) {
        CGFloat red = ((CGFloat)(value & 0xFF0000)) / 255.0;
        CGFloat green = ((CGFloat)(value & 0x00FF00)) / 255.0;
        CGFloat blue = ((CGFloat)(value & 0x0000FF)) / 255.0;
        return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    }
    return [UIColor whiteColor];
}

@end
