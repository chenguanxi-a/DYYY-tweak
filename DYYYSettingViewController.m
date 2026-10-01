#define DYYYFilterSettingsView_DEFINED
#define DYYYBottomAlertView_DEFINED
#define DYYYUtils_DEFINED

#import "DYYYSettingViewController.h"
#import "DYYYManager.h"
#import "DYYYFilterSettingsView.h"
#import "DYYYFloatSpeedButton.h"
#import <Photos/Photos.h>
#import <objc/runtime.h>
#import "DYYYBottomAlertView.h"
#import "DYYYUtils.h"
#import "DYYYSwitchManager.h"
#import "DYYYABTestHook.h"

@interface UISwitch (DYYY_FuturisticEffects)
- (void)applyFuturisticEffects;
- (void)updateFuturisticEffectsWithState:(BOOL)isOn animated:(BOOL)animated;
@end

extern NSDictionary *dyyySettings;

// 娣诲姞鍥剧墖閫夋嫨鍣ㄤ唬鐞?
@interface DYYYImagePickerDelegate : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, copy) void (^completionBlock)(NSDictionary *info);
@end

// 娣诲姞澶囦唤閫夋嫨鍣ㄤ唬鐞?
@interface DYYYBackupPickerDelegate : NSObject <UIDocumentPickerDelegate>
@property (nonatomic, strong) NSString *tempFilePath;
@property (nonatomic, copy) void (^completionBlock)(NSURL *url);
@end

#ifndef AWESettingBaseViewController_DEFINED
#define AWESettingBaseViewController_DEFINED
@interface AWESettingBaseViewController (DYYY_Addition)
@end
#endif

@class AWESettingItemModel;

@implementation DYYYIconOptionsDialogView

- (instancetype)initWithTitle:(NSString *)title previewImage:(UIImage *)previewImage {
    self = [super init];
    if (self) {
        // 鍩烘湰璁剧疆
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        // 鍒涘缓鍐呭瑙嗗浘
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(50, 200, self.bounds.size.width - 100, 300)];
        contentView.backgroundColor = [UIColor systemBackgroundColor];
        contentView.layer.cornerRadius = 15;
        contentView.clipsToBounds = YES;
        
        // 鏍囬鏍囩
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, contentView.bounds.size.width - 40, 30)];
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [contentView addSubview:titleLabel];
        
        // 棰勮鍥剧墖瑙嗗浘
        if (previewImage) {
            UIImageView *previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake((contentView.bounds.size.width - 100) / 2, 60, 100, 100)];
            previewImageView.image = previewImage;
            previewImageView.contentMode = UIViewContentModeScaleAspectFit;
            previewImageView.layer.cornerRadius = 10;
            previewImageView.clipsToBounds = YES;
            [contentView addSubview:previewImageView];
        }
        
        // 鎸夐挳瀹瑰櫒
        UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(20, 180, contentView.bounds.size.width - 40, 80)];
        
        // 娓呴櫎鎸夐挳
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
        clearButton.frame = CGRectMake(0, 0, (buttonContainer.bounds.size.width - 10) / 2, 35);
        [clearButton setTitle:@"娓呴櫎" forState:UIControlStateNormal];
        clearButton.backgroundColor = [UIColor systemRedColor];
        [clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        clearButton.layer.cornerRadius = 8;
        [clearButton addTarget:self action:@selector(clearButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [buttonContainer addSubview:clearButton];
        
        // 閫夋嫨鎸夐挳
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeSystem];
        selectButton.frame = CGRectMake((buttonContainer.bounds.size.width + 10) / 2, 0, (buttonContainer.bounds.size.width - 10) / 2, 35);
        [selectButton setTitle:@"閫夋嫨" forState:UIControlStateNormal];
        selectButton.backgroundColor = [UIColor systemBlueColor];
        [selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectButton.layer.cornerRadius = 8;
        [selectButton addTarget:self action:@selector(selectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [buttonContainer addSubview:selectButton];
        
        // 鍙栨秷鎸夐挳
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelButton.frame = CGRectMake(0, 45, buttonContainer.bounds.size.width, 35);
        [cancelButton setTitle:@"鍙栨秷" forState:UIControlStateNormal];
        cancelButton.backgroundColor = [UIColor systemGrayColor];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.layer.cornerRadius = 8;
        [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [buttonContainer addSubview:cancelButton];
        
        [contentView addSubview:buttonContainer];
        [self addSubview:contentView];
    }
    return self;
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)clearButtonTapped {
    [self dismiss];
    if (self.onClear) {
        self.onClear();
    }
}

- (void)selectButtonTapped {
    [self dismiss];
    if (self.onSelect) {
        self.onSelect();
    }
}

- (void)cancelButtonTapped {
    [self dismiss];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end

// 瀹炵幇澶囦唤閫夋嫨鍣ㄤ唬鐞?
@implementation DYYYBackupPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        if (self.completionBlock) {
            self.completionBlock(urls.firstObject);
        }
        
        // 娓呯悊涓存椂鏂囦欢
        if (self.tempFilePath) {
            [[NSFileManager defaultManager] removeItemAtPath:self.tempFilePath error:nil];
        }
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // 娓呯悊涓存椂鏂囦欢
    if (self.tempFilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:self.tempFilePath error:nil];
    }
}

@end

@implementation UISwitch (DYYY_FuturisticEffects)

- (void)applyFuturisticEffects {
    // 纭繚鍙簲鐢ㄤ竴娆℃晥鏋?
    if ([objc_getAssociatedObject(self, "DYYY_hasAppliedEffects") boolValue]) {
        return;
    }
    
    objc_setAssociatedObject(self, "DYYY_hasAppliedEffects", @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 閰嶇疆涓诲鍣ㄨ鍥惧拰鏁堟灉
    self.clipsToBounds = NO;
    
    // 1. 鍒涘缓楂樺厜鎻忚竟灞?- 澧炲ぇ杈规瀹藉害鍜岄槾褰?
    CALayer *glowBorderLayer = [CALayer layer];
    glowBorderLayer.frame = CGRectInset(self.bounds, -4, -4); // 澧炲ぇ杈规瀹藉害
    glowBorderLayer.cornerRadius = self.bounds.size.height / 2 + 4;
    glowBorderLayer.shadowColor = self.isOn ? [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0].CGColor : [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
    glowBorderLayer.shadowOffset = CGSizeMake(0, 0);
    glowBorderLayer.shadowOpacity = self.isOn ? 0.8 : 0.3; // 榛樿绔嬪嵆鏄剧ず闃村奖
    glowBorderLayer.shadowRadius = 5.0; // 澧炲ぇ闃村奖鍗婂緞
    glowBorderLayer.masksToBounds = NO;
    
    // 2. 鍒涘缓鐜荤拑鏁堟灉瑕嗙洊灞?- 澧炲姞閫忔槑搴︿娇鏁堟灉鏇存槑鏄?
    UIVisualEffectView *glassEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    glassEffectView.frame = self.bounds;
    glassEffectView.clipsToBounds = YES;
    glassEffectView.layer.cornerRadius = self.bounds.size.height / 2;
    glassEffectView.alpha = 0.18; // 澧炲姞閫忔槑搴?
    glassEffectView.userInteractionEnabled = NO;
    
    // 3. 鍒涘缓娑蹭綋鍔ㄧ敾灞?
    CALayer *liquidLayer = [CALayer layer];
    liquidLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    liquidLayer.masksToBounds = YES;
    liquidLayer.cornerRadius = self.bounds.size.height / 2;
    liquidLayer.opacity = 0.0;
    
    // 鍒涘缓娑蹭綋娓愬彉
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = liquidLayer.bounds;
    gradientLayer.cornerRadius = liquidLayer.cornerRadius;
    
    // 璁剧疆娓愬彉棰滆壊鍩轰簬寮€鍏崇姸鎬?- 浣跨敤鏇存槑浜殑棰滆壊
    UIColor *liquidColor = self.isOn ? 
        [UIColor colorWithRed:20/255.0 green:142/255.0 blue:255/255.0 alpha:0.8] : // 鏇翠寒鐨勮摑鑹?
        [UIColor colorWithWhite:0.85 alpha:0.8]; // 鏇翠寒鐨勭伆鑹?
    UIColor *transparentColor = [liquidColor colorWithAlphaComponent:0.0];
    
    gradientLayer.colors = @[(id)liquidColor.CGColor, (id)transparentColor.CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    
    [liquidLayer addSublayer:gradientLayer];
    
    // 瀛樺偍杩欎簺灞備互渚垮悗缁洿鏂?
    objc_setAssociatedObject(self, "DYYY_glowBorderLayer", glowBorderLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, "DYYY_glassEffectView", glassEffectView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, "DYYY_liquidLayer", liquidLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, "DYYY_gradientLayer", gradientLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 灞傜骇椤哄簭寰堥噸瑕侊細楂樺厜灞傚湪搴曢儴锛岀幓鐠冩晥鏋滃湪鏈€涓婂眰
    [self.layer insertSublayer:glowBorderLayer atIndex:0]; // 楂樺厜灞傛斁鍦ㄥ簳閮?
    [self.layer addSublayer:liquidLayer]; // 娑蹭綋灞傚湪涓棿
    [self addSubview:glassEffectView]; // 鐜荤拑鏁堟灉鍦ㄦ渶涓婂眰
    
    // 鍒濆鏇存柊鏁堟灉
    [self updateFuturisticEffectsWithState:self.isOn animated:NO];
    
    // 纭繚鐩戝惉鐘舵€佸彉鍖?
    [self removeTarget:self action:@selector(futuristicSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    [self addTarget:self action:@selector(futuristicSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)futuristicSwitchValueChanged {
    [self updateFuturisticEffectsWithState:self.isOn animated:YES];
}

- (void)updateFuturisticEffectsWithState:(BOOL)isOn animated:(BOOL)animated {
    CALayer *glowBorderLayer = objc_getAssociatedObject(self, "DYYY_glowBorderLayer");
    CALayer *liquidLayer = objc_getAssociatedObject(self, "DYYY_liquidLayer");
    CAGradientLayer *gradientLayer = objc_getAssociatedObject(self, "DYYY_gradientLayer");
    
    // 鍑嗗鍔ㄧ敾
    NSTimeInterval animDuration = animated ? 0.35 : 0.0;
    
    // 1. 鏇存柊楂樺厜杈规棰滆壊鍜屼笉閫忔槑搴?
    UIColor *glowColor = isOn ? [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] : [UIColor colorWithWhite:0.8 alpha:1.0];
    CGFloat glowOpacity = isOn ? 0.8 : 0.3;
    
    if (animated) {
        // 楂樺厜杈规鍔ㄧ敾
        CABasicAnimation *shadowColorAnimation = [CABasicAnimation animationWithKeyPath:@"shadowColor"];
        shadowColorAnimation.toValue = (__bridge id)glowColor.CGColor;
        shadowColorAnimation.duration = animDuration;
        [glowBorderLayer addAnimation:shadowColorAnimation forKey:@"shadowColor"];
        
        CABasicAnimation *shadowOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        shadowOpacityAnimation.toValue = @(glowOpacity);
        shadowOpacityAnimation.duration = animDuration;
        [glowBorderLayer addAnimation:shadowOpacityAnimation forKey:@"shadowOpacity"];
    }
    
    glowBorderLayer.shadowColor = glowColor.CGColor;
    glowBorderLayer.shadowOpacity = glowOpacity;
    
    // 2. 瑙﹀彂娑蹭綋鍔ㄧ敾鏁堟灉
    if (animated) {
        // 璁剧疆娑蹭綋棰滆壊
        UIColor *liquidColor = isOn ? [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:0.7] : [UIColor colorWithWhite:0.8 alpha:0.7];
        UIColor *transparentColor = [liquidColor colorWithAlphaComponent:0.0];
        
        // 鏇存柊娓愬彉棰滆壊
        gradientLayer.colors = @[(id)liquidColor.CGColor, (id)transparentColor.CGColor];
        
        // 娑蹭綋娉㈠姩鍔ㄧ敾
        [CATransaction begin];
        [CATransaction setAnimationDuration:animDuration];
        
        // 鏄剧ず娑蹭綋灞?
        liquidLayer.opacity = 1.0;
        
        // 娑蹭綋娴佸姩鍔ㄧ敾
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
        positionAnimation.fromValue = @(isOn ? -self.bounds.size.width : self.bounds.size.width * 2);
        positionAnimation.toValue = @(isOn ? self.bounds.size.width * 2 : -self.bounds.size.width);
        positionAnimation.duration = animDuration * 1.5;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        [CATransaction setCompletionBlock:^{
            // 瀹屾垚鍚庨殣钘忔恫浣撳眰
            [UIView animateWithDuration:0.2 animations:^{
                liquidLayer.opacity = 0.0;
            }];
        }];
        
        [liquidLayer addAnimation:positionAnimation forKey:@"liquidFlow"];
        [CATransaction commit];
        
        // 娣诲姞鑴夊啿鏁堟灉
        CAKeyframeAnimation *pulseAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        pulseAnimation.values = @[@1.0, @1.03, @1.0];
        pulseAnimation.keyTimes = @[@0, @0.5, @1.0];
        pulseAnimation.duration = animDuration;
        pulseAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                          [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.layer addAnimation:pulseAnimation forKey:@"pulse"];
    }
}

@end

@implementation DYYYImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    if (self.completionBlock) {
        self.completionBlock(info);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end

// DYYYSettingItem绫?
@interface DYYYSettingItem : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *placeholder;

+ (instancetype)itemWithTitle:(NSString *)title key:(NSString *)key type:(NSInteger)type;
+ (instancetype)itemWithTitle:(NSString *)title key:(NSString *)key type:(NSInteger)type placeholder:(NSString *)placeholder;

@end

@implementation DYYYSettingItem
+ (instancetype)itemWithTitle:(NSString *)title key:(NSString *)key type:(NSInteger)type {
    return [self itemWithTitle:title key:key type:type placeholder:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title key:(NSString *)key type:(NSInteger)type placeholder:(NSString *)placeholder {
    DYYYSettingItem *item = [[DYYYSettingItem alloc] init];
    item.title = title;
    item.key = key;
    item.type = type;
    item.placeholder = placeholder;
    return item;
}

@end

// 鑾峰彇椤跺眰瑙嗗浘鎺у埗鍣?
UIViewController *topView(void) {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                window = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
        window = [UIApplication sharedApplication].keyWindow;
    }
    
    UIViewController *rootViewController = window.rootViewController;
    UIViewController *topVC = rootViewController;
    
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    if ([topVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)topVC;
        topVC = nav.topViewController;
    }
    
    return topVC;
}

// 鏄剧ず鍥炬爣閫夐」寮圭獥
static void showIconOptionsDialog(NSString *title, UIImage *previewImage, NSString *saveFilename, void (^onClear)(void), void (^onSelect)(void)) {
    DYYYIconOptionsDialogView *optionsDialog = [[DYYYIconOptionsDialogView alloc] initWithTitle:title previewImage:previewImage];
    optionsDialog.onClear = onClear;
    optionsDialog.onSelect = onSelect;
    [optionsDialog show];
}

// 鍔犺浇鍥哄畾ABTest鏁版嵁锛堜娇鐢?DYYYABTestHook 鐨勭粺涓€瀹炵幇锛屼笉鍐嶉噸澶嶅畾涔夛級
// ensureABTestDataLoaded() / loadFixedABTestData() 宸插湪 DYYYABTestHook.xm 涓疄鐜?

// 鑾峰彇褰撳墠ABTest鏁版嵁
NSDictionary *getCurrentABTestData(void) {
    Class AWEABTestManagerClass = NSClassFromString(@"AWEABTestManager");
    if (!AWEABTestManagerClass) {
        return nil;
    }
    
    id manager = [AWEABTestManagerClass performSelector:@selector(sharedManager)];
    if (!manager) {
        return nil;
    }
    
    SEL abTestDataSelector = NSSelectorFromString(@"abTestData");
    if (![manager respondsToSelector:abTestDataSelector]) {
        return nil;
    }
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSDictionary *currentData = [manager performSelector:abTestDataSelector];
    #pragma clang diagnostic pop
    
    return currentData;
}



@interface DYYYSettingViewController ()
@end

@implementation DYYYSettingViewController
- (void)setupCleanupOptions {
    Class AWESettingItemModelClass = NSClassFromString(@"AWESettingItemModel");
    AWESettingItemModel *cleanCacheItem = [[AWESettingItemModelClass alloc] init];
    cleanCacheItem.identifier = @"DYYYCleanCache";
    cleanCacheItem.title = @"娓呯悊缂撳瓨";
    cleanCacheItem.detail = @"";
    cleanCacheItem.type = 0;
    cleanCacheItem.svgIconImageName = @"ic_broom_outlined";
    cleanCacheItem.cellType = 26;
    cleanCacheItem.colorStyle = 0;
    cleanCacheItem.isEnable = YES;
    
    // 缁戝畾鐐瑰嚮浜嬩欢
    cleanCacheItem.cellTappedBlock = ^{
        // 澶勭悊娓呯悊缂撳瓨閫昏緫
        [self handleCleanCache];
    };
}

- (void)handleCleanCache {
    // DYYYBottomAlertView 璋冪敤锛屼娇鐢ㄦ纭殑鏂规硶鍚嶅拰鍙傛暟椤哄簭
    [DYYYBottomAlertView showAlertWithTitle:@"娓呯悊缂撳瓨"
                               message:@"纭畾瑕佹竻鐞嗙紦瀛樺悧锛焅n杩欏皢鍒犻櫎涓存椂鏂囦欢鍜岀紦瀛?
                         cancelButtonText:@"鍙栨秷"
                         confirmButtonText:@"纭畾"
                         cancelAction:nil
                         confirmAction:^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSUInteger totalSize = 0;

        // 涓存椂鐩綍
        NSString *tempDir = NSTemporaryDirectory();

        // Library鐩綍涓嬬殑缂撳瓨鐩綍
        NSArray<NSString *> *customDirs = @[@"Caches", @"BDByteCast", @"kitelog"];
        NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;

        NSMutableArray<NSString *> *allPaths = [NSMutableArray arrayWithObject:tempDir];
        for (NSString *sub in customDirs) {
            NSString *fullPath = [libraryDir stringByAppendingPathComponent:sub];
            if ([fileManager fileExistsAtPath:fullPath]) {
                [allPaths addObject:fullPath];
            }
        }

        // 閬嶅巻鎵€鏈夌洰褰曞苟娓呯悊
        for (NSString *basePath in allPaths) {
            totalSize += [DYYYUtils clearDirectoryContents:basePath];
        }

        float sizeInMB = totalSize / 1024.0 / 1024.0;
        NSString *toastMsg = [NSString stringWithFormat:@"宸叉竻鐞?%.2f MB 鐨勭紦瀛?, sizeInMB];
        [DYYYManager showToast:toastMsg];
    }];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DYYY璁剧疆";
    self.expandedSections = [NSMutableSet set];
    self.isSearching = NO;
    self.isKVOAdded = NO;
    
    // 闅愯棌椤堕儴鎸囩ず鍣ㄦ潯
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithTransparentBackground];
        appearance.backgroundEffect = nil;
        appearance.shadowColor = nil;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    
    // 鍒濆鍖栬Е瑙夊弽棣堢敓鎴愬櫒
    self.feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [self.feedbackGenerator prepare];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.left"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self setupAppearance];
    [self setupBackgroundColorView];
    [self setupAvatarView];
    [self setupSearchBar];
    [self setupTableView];
    [self setupSettingItems];
    [self setupSectionTitles];
    [self setupFooterLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBackgroundColorChanged) name:@"DYYYBackgroundColorChanged" object:nil];
    
    // 璁剧疆閾炬帴瑙ｆ瀽鐨勯粯璁ゅ€?
    NSString *interfaceDownload = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYInterfaceDownload"];
    if (interfaceDownload == nil || [interfaceDownload stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"https://api.qsy.ink/api/douyin?key=DYYY&url=" forKey:@"DYYYInterfaceDownload"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 鍒濆鍖栫儹鏇存柊鏁版嵁锛堜娇鐢?DYYYABTestHook 缁熶竴鎺ュ彛锛?
    ensureABTestDataLoaded();

    [self ensureCustomAlbumSizeDefault];
}

- (void)ensureCustomAlbumSizeDefault {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL large = [defaults objectForKey:@"DYYYCustomAlbumSizeLarge"] ? [defaults boolForKey:@"DYYYCustomAlbumSizeLarge"] : NO;
    BOOL medium = [defaults objectForKey:@"DYYYCustomAlbumSizeMedium"] ? [defaults boolForKey:@"DYYYCustomAlbumSizeMedium"] : NO;
    BOOL small = [defaults objectForKey:@"DYYYCustomAlbumSizeSmall"] ? [defaults boolForKey:@"DYYYCustomAlbumSizeSmall"] : NO;

    // 濡傛灉閮芥病璁剧疆杩囷紝榛樿鈥滀腑鈥濅负YES锛屽叾瀹僋O
    if (!large && !medium && !small) {
        [defaults setBool:NO forKey:@"DYYYCustomAlbumSizeLarge"];
        [defaults setBool:YES forKey:@"DYYYCustomAlbumSizeMedium"];
        [defaults setBool:NO forKey:@"DYYYCustomAlbumSizeSmall"];
        [defaults synchronize];
    } else {
        // 淇濊瘉浜掓枼锛氬鏋滄湁澶氫釜涓篩ES锛屽彧淇濈暀绗竴涓负YES
        NSArray *keys = @[@"DYYYCustomAlbumSizeLarge", @"DYYYCustomAlbumSizeMedium", @"DYYYCustomAlbumSizeSmall"];
        NSMutableArray *onKeys = [NSMutableArray array];
        for (NSString *key in keys) {
            if ([defaults boolForKey:key]) {
                [onKeys addObject:key];
            }
        }
        if (onKeys.count > 1) {
            // 鍙繚鐣欑涓€涓负YES锛屽叾瀹冭涓篘O
            for (NSInteger i = 1; i < onKeys.count; i++) {
                [defaults setBool:NO forKey:onKeys[i]];
            }
            [defaults synchronize];
        }
    }
}

- (void)backButtonTapped:(id)sender {
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.isSearching = NO;
    self.searchBar.text = @"";
    self.filteredSections = nil;
    self.filteredSectionTitles = nil;
    [self.expandedSections removeAllObjects];
    
    if (self.tableView && [self.tableView numberOfSections] > 0) {
        @try {
            [self.tableView reloadData];
        } @catch (NSException *exception) {
        }
    }
    
    if (self.isKVOAdded && self.tableView) {
        @try {
            [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
            self.isKVOAdded = NO;
        } @catch (NSException *exception) {
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.isKVOAdded && self.tableView) {
        @try {
            [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
            self.isKVOAdded = NO;
        } @catch (NSException *exception) {
        }
    }
}

#pragma mark - Setup Methods

- (void)setupAppearance {
    if (self.navigationController) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
            [appearance configureWithTransparentBackground];
            appearance.backgroundColor = [UIColor clearColor];
            appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
            appearance.largeTitleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
            self.navigationController.navigationBar.standardAppearance = appearance;
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        }
    }
}

- (void)setupBackgroundColorView {
    self.backgroundColorView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.backgroundColorView.frame = self.view.bounds;
    self.backgroundColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.backgroundColorView atIndex:0];
}

- (void)setupAvatarView {
    // 鏆楅粦鏋佺畝椋庢牸锛氫笉鏄剧ず澶村儚鍖哄煙
}

- (void)setupSearchBar {
    // 鏆楅粦鏋佺畝椋庢牸锛氫笉鏄剧ず鎼滅储鏍?
}
- (void)handleBackgroundColorChanged {
    // 鏆楅粦姣涚幓鐠冮鏍硷細鏃犻渶鏍规嵁鑳屾櫙鑹茶皟鏁?
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    // 璋冩暣section澶撮儴闂磋窛锛屽噺灏忔垨绉婚櫎杩欎釜璁剧疆
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 2; // 鍑忓皬缁勫ご閮ㄤ箣闂寸殑鍨傜洿璺濈
    }
    
    self.tableView.tableHeaderView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.tableView addGestureRecognizer:longPress];
}

- (void)setupSettingItems {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *sections = @[
            // 绗竴閮ㄥ垎 - 鍩烘湰璁剧疆
            @[
                [DYYYSettingItem itemWithTitle:@"鍚敤寮瑰箷鏀硅壊" key:@"DYYYEnableDanmuColor" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鑷畾寮瑰箷棰滆壊" key:@"DYYYDanmuColor" type:DYYYSettingItemTypeTextField placeholder:@"鍗佸叚杩涘埗"],
                [DYYYSettingItem itemWithTitle:@"鏄剧ず杩涘害鏃堕暱" key:@"DYYYShowScheduleDisplay" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"杩涘害绾佃酱浣嶇疆" key:@"DYYYTimelineVerticalPosition" type:DYYYSettingItemTypeTextField placeholder:@"-12.5"],
                [DYYYSettingItem itemWithTitle:@"鏃堕棿杩涘害浣嶇疆" key:@"DYYYScheduleStyle" type:DYYYSettingItemTypeCustomPicker placeholder:@"鐐瑰嚮閫夋嫨"],
                [DYYYSettingItem itemWithTitle:@"杩涘害鏍囩棰滆壊" key:@"DYYYProgressLabelColor" type:DYYYSettingItemTypeTextField placeholder:@"鍗佸叚杩涘埗"],
                [DYYYSettingItem itemWithTitle:@"闅愯棌瑙嗛杩涘害" key:@"DYYYHideVideoProgress" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"杩囨护鐩存挱" key:@"DYYYSkipLive" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"杩囨护鐑偣" key:@"DYYYSkipHotSpot" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"杩囨护鍥鹃泦" key:@"DYYYSkipPhoto" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"杩囨护鍥炬枃" key:@"DYYYSkipPhotoText" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"杩囨护闊充箰鍗? key:@"DYYYSkipMusic" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"杩囨护鎶栭煶AI" key:@"DYYYSkipAIInteraction" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"杩囨护閬撳叿" key:@"DYYYFilterProp" type:DYYYSettingItemTypeTextField placeholder:@"鑻辨枃閫楀彿鍒嗛殧"],
                [DYYYSettingItem itemWithTitle:@"绂佺敤鑷姩杩涘叆鐩存挱" key:@"DYYYDisableAutoEnterLive" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"杩囨护浣庤禐" key:@"DYYYFilterLowLikes" type:DYYYSettingItemTypeTextField placeholder:@"濉?鍏抽棴"],
                [DYYYSettingItem itemWithTitle:@"杩囨护鏂囨" key:@"DYYYFilterKeywords" type:DYYYSettingItemTypeTextField placeholder:@"涓嶅～鍏抽棴"],
                [DYYYSettingItem itemWithTitle:@"瑙嗛鏃堕檺" key:@"DYYYFilterTimeLimit" type:DYYYSettingItemTypeTextField placeholder:@"濉?鍏抽棴锛屽崟浣嶄负澶?],
                [DYYYSettingItem itemWithTitle:@"棣栭〉鍏ㄥ睆+閫忔槑" key:@"DYYYEnableFullScreen" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍘婚櫎App鍐呮洿鏂? key:@"DYYYNoUpdates" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍘婚潚灏戝勾寮圭獥" key:@"DYYYHideTeenMode" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"璇勮鍖烘瘺鐜荤拑" key:@"DYYYEnableCommentBlur" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"姣涚幓鐠冮€忔槑搴? key:@"DYYYCommentBlurTransparent" type:DYYYSettingItemTypeTextField placeholder:@"0-1灏忔暟"],
                [DYYYSettingItem itemWithTitle:@"閫氱煡鐜荤拑鏁堟灉" key:@"DYYYEnableNotificationTransparency" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"閫氱煡鍦嗚鍗婂緞" key:@"DYYYNotificationCornerRadius" type:DYYYSettingItemTypeTextField placeholder:@"榛樿12"],
                [DYYYSettingItem itemWithTitle:@"鏃堕棿鏍囩棰滆壊" key:@"DYYYLabelColor" type:DYYYSettingItemTypeTextField placeholder:@"鍗佸叚杩涘埗"],
                [DYYYSettingItem itemWithTitle:@"闅愯棌绯荤粺椤舵爮" key:@"DYYYHideStatusbar" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍏虫敞浜屾纭" key:@"DYYYFollowTips" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鏀惰棌浜屾纭" key:@"DYYYCollectTips" type:DYYYSettingItemTypeSwitch]
            ],
            
            // 绗簩閮ㄥ垎 - 鐣岄潰璁剧疆
            @[
                [DYYYSettingItem itemWithTitle:@"璁剧疆椤舵爮鏂囧瓧閫忔槑" key:@"DYYYtopbartransparent" type:DYYYSettingItemTypeTextField placeholder:@"0-1灏忔暟"],
                [DYYYSettingItem itemWithTitle:@"璁剧疆鍏ㄥ眬閫忔槑" key:@"DYYYGlobalTransparency" type:DYYYSettingItemTypeTextField placeholder:@"0-1灏忔暟"],
                [DYYYSettingItem itemWithTitle:@"棣栭〉澶村儚閫忔槑" key:@"DYYYAvatarViewTransparency" type:DYYYSettingItemTypeTextField placeholder:@"0-1灏忔暟"],
                [DYYYSettingItem itemWithTitle:@"鍙充晶鏍忕缉鏀惧害" key:@"DYYYElementScale" type:DYYYSettingItemTypeTextField placeholder:@"涓嶅～榛樿"],
                [DYYYSettingItem itemWithTitle:@"鏄电О鏂囨缂╂斁" key:@"DYYYNicknameScale" type:DYYYSettingItemTypeTextField placeholder:@"涓嶅～榛樿"],
                [DYYYSettingItem itemWithTitle:@"鏄电О涓嬬Щ璺濈" key:@"DYYYNicknameVerticalOffset" type:DYYYSettingItemTypeTextField placeholder:@"涓嶅～榛樿"],
                [DYYYSettingItem itemWithTitle:@"鏂囨涓嬬Щ璺濈" key:@"DYYYDescriptionVerticalOffset" type:DYYYSettingItemTypeTextField placeholder:@"涓嶅～榛樿"],
                [DYYYSettingItem itemWithTitle:@"灞炲湴涓嬬Щ璺濈" key:@"DYYYIPLabelVerticalOffset" type:DYYYSettingItemTypeTextField placeholder:@"涓嶅～榛樿"],
                [DYYYSettingItem itemWithTitle:@"璁剧疆棣栭〉鏍囬" key:@"DYYYIndexTitle" type:DYYYSettingItemTypeTextField placeholder:@"涓嶅～榛樿"],
                [DYYYSettingItem itemWithTitle:@"璁剧疆鏈嬪弸鏍囬" key:@"DYYYFriendsTitle" type:DYYYSettingItemTypeTextField placeholder:@"涓嶅～榛樿"],
                [DYYYSettingItem itemWithTitle:@"璁剧疆娑堟伅鏍囬" key:@"DYYYMsgTitle" type:DYYYSettingItemTypeTextField placeholder:@"涓嶅～榛樿"],
                [DYYYSettingItem itemWithTitle:@"璁剧疆鎴戠殑鏍囬" key:@"DYYYSelfTitle" type:DYYYSettingItemTypeTextField placeholder:@"涓嶅～榛樿"],
                [DYYYSettingItem itemWithTitle:@"璁剧疆椤舵爮妯箙" key:@"DYYYModifyTopTabText" type:DYYYSettingItemTypeTextField placeholder:@"鏍煎紡:鍘熸爣棰?鏂版爣棰?]
            ],
            
            // 绗笁閮ㄥ垎 - 闅愯棌璁剧疆
            @[
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍏ㄥ睆瑙傜湅" key:@"DYYYHideEntry" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌搴曟爮鍟嗗煄" key:@"DYYYHideShopButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌搴曟爮娑堟伅" key:@"DYYYHideMessageButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌搴曟爮鏈嬪弸" key:@"DYYYHideFriendsButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌搴曟爮鍔犲彿" key:@"DYYYisHiddenJia" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌搴曟爮绾㈢偣" key:@"DYYYHideBottomDot" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌搴曟爮鑳屾櫙" key:@"DYYYHideBottomBg" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌渚ф爮绾㈢偣" key:@"DYYYHideSidebarDot" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍙戜綔鍝佹" key:@"DYYYHidePostView" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌澶村儚鍔犲彿" key:@"DYYYHideLOTAnimationView" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐐硅禐鏁板€? key:@"DYYYHideLikeLabel" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌璇勮鏁板€? key:@"DYYYHideCommentLabel" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鏀惰棌鏁板€? key:@"DYYYHideCollectLabel" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍒嗕韩鏁板€? key:@"DYYYHideShareLabel" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐐硅禐鎸夐挳" key:@"DYYYHideLikeButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌璇勮鎸夐挳" key:@"DYYYHideCommentButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鏀惰棌鎸夐挳" key:@"DYYYHideCollectButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌澶村儚鎸夐挳" key:@"DYYYHideAvatarButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闊充箰鎸夐挳" key:@"DYYYHideMusicButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍒嗕韩鎸夐挳" key:@"DYYYHideShareButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌瑙嗛瀹氫綅" key:@"DYYYHideLocation" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍙充笂鎼滅储" key:@"DYYYHideDiscover" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐩稿叧鎼滅储" key:@"DYYYHideInteractionSearch" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌杩涘叆鐩存挱" key:@"DYYYHideEnterLive" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌璇勮瑙嗗浘" key:@"DYYYHideCommentViews" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌閫氱煡鎻愮ず" key:@"DYYYHidePushBanner" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌澶村儚鍒楄〃" key:@"DYYYHideAvatarList" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌澶村儚姘旀场" key:@"DYYYHideAvatarBubble" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌宸︿晶杈规爮" key:@"DYYYHideLeftSideBar" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍚冨枬鐜╀箰" key:@"DYYYHideNearbyCapsuleView" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌寮瑰箷鎸夐挳" key:@"DYYYHideDanmuButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍙栨秷闈欓煶" key:@"DYYYHideCancelMute" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍘绘苯姘村惉" key:@"DYYYHideQuqishuiting" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍏卞垱澶村儚" key:@"DYYYHideGongChuang" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐑偣鎻愮ず" key:@"DYYYHideHotspot" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鎺ㄨ崘鎻愮ず" key:@"DYYYHideRecommendTips" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍒嗕韩鎻愮ず" key:@"DYYYHideShareContentView" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌浣滆€呭０鏄? key:@"DYYYHideAntiAddictedNotice" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌搴曢儴鐩稿叧" key:@"DYYYHideBottomRelated" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鎷嶆憚鍚屾" key:@"DYYYHideFeedAnchorContainer" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鎸戞垬璐寸焊" key:@"DYYYHideChallengeStickers" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鏍″洯鎻愮ず" key:@"DYYYHideTemplateTags" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌浣滆€呭簵閾? key:@"DYYYHideHisShop" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍏虫敞鐩存挱" key:@"DYYYHideConcernCapsuleView" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌椤舵爮妯嚎" key:@"DYYYHidentopbarprompt" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌瑙嗛鍚堥泦" key:@"DYYYHideTemplateVideo" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐭墽鍚堥泦" key:@"DYYYHideTemplatePlaylet" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍔ㄥ浘鏍囩" key:@"DYYYHideLiveGIF" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌绗旇鏍囩" key:@"DYYYHideItemTag" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌搴曢儴璇濋" key:@"DYYYHideTemplateGroup" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐩告満瀹氫綅" key:@"DYYYHideCameraLocation" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌瑙嗛婊戞潯" key:@"DYYYHideStoryProgressSlide" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍥剧墖婊戞潯" key:@"DYYYHideDotsIndicator" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍒嗕韩绉佷俊" key:@"DYYYHidePrivateMessages" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鏄电О鍙充晶" key:@"DYYYHideRightLabel" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌缇よ亰鍟嗗簵" key:@"DYYYHideGroupShop" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐩存挱鑳跺泭" key:@"DYYYHideLiveCapsuleView" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍏虫敞椤剁" key:@"DYYYHidenLiveView" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍚屽煄椤剁" key:@"DYYYHideMenuView" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌缇ょ洿鎾腑" key:@"DYYYGroupLiving" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌缇ゅ伐鍏锋爮" key:@"DYYYHideGroupInputActionBar" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐩存挱骞垮満" key:@"DYYYHideLivePlayground" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌绀肩墿灞曢" key:@"DYYYHideGiftPavilion" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌椤舵爮绾㈢偣" key:@"DYYYHideTopBarBadge" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌閫€鍑烘竻灞? key:@"DYYYHideLiveRoomClear" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鎶曞睆鎸夐挳" key:@"DYYYHideLiveRoomMirroring" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐩存挱鍙戠幇" key:@"DYYYHideLiveDiscovery" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐩存挱鐐规瓕" key:@"DYYYHideKTVSongIndicator" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌娴侀噺鎻愰啋" key:@"DYYYHideCellularAlert" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鑱婂ぉ璇勮閫忔槑" key:@"DYYYHideChatCommentBg" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌璇勮鑳屾櫙" key:@"DYYYHideComment" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌杩斿洖鎸夐挳" key:@"DYYYHideBack" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍥炲妗? key:@"DYYYHideReply" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鎼滅储姘旀场" key:@"DYYYHideSearchBubble" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌绔犺妭杩涘害鏉? key:@"DYYYHideChapterProgress" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐩存挱闂磋缃? key:@"DYYYHideLiveRoomClose" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐩存挱闂存í灞? key:@"DYYYHideLiveRoomFullscreen" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐩存挱鍟嗗搧淇℃伅" key:@"DYYYHideLiveGoodsMsg" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐩存挱鐐硅禐鍔ㄧ敾" key:@"DYYYHideLiveLikeAnimation" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌婵€鍔辩孩鍖呮寕浠? key:@"DYYYHidePendantGroup" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍙屾爮鍏ュ彛" key:@"DYYYHideDoubleColumnEntry" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌涓婃鐪嬪埌鎻愮ず" key:@"DYYYHidePopover" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌瑙嗛鎼滅储闀挎" key:@"DYYYHideSearchEntrance" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鏈嬪弸鍏虫敞鎸夐挳" key:@"DYYYHideFamiliar" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌娣诲姞鏈嬪弸" key:@"DYYYHideButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鎷嶇収鎼滃悓娆炬壂涓€鎵? key:@"DYYYHideScancode" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鎼滅储鎸囩ず鏉? key:@"DYYYHideSearchEntranceIndicator" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌璇勮鎼滅储" key:@"DYYYHideCommentDiscover" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌璇勮鎻愮ず" key:@"DYYYHideCommentTips" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鍏虫敞鎻愮ず瑙嗗浘" key:@"DYYYHideFollowPromptView" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鎴戠殑鎸夐挳" key:@"DYYYHideMyButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鏆傚仠鍏抽敭璇? key:@"DYYYHidePauseVideoRelatedWord" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鎼滅储寮曞鎻愮ず妗? key:@"DYYYHideGuideTipView" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌椤舵爮寮曞鎻愮ず" key:@"DYYYHideFeedTabJumpGuide" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌澶у閮藉湪鎼? key:@"DYYYHideWords" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌瑙傜湅鍘嗗彶鎼滅储" key:@"DYYYHideDiscoverFeedEntry" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌鐭墽鍏嶈垂鍘荤湅" key:@"DYYYHideShowPlayletComment" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌璇勮闊充箰" key:@"DYYYHideCommentMusicAnchor" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌璇勮瀹氫綅" key:@"DYYYHidePOIEntryAnchor" type:DYYYSettingItemTypeSwitch]
            ],
            
            // 绗洓閮ㄥ垎 - 绉婚櫎璁剧疆
            @[
                [DYYYSettingItem itemWithTitle:@"绉婚櫎鎺ㄨ崘" key:@"DYYYHideHotContainer" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绉婚櫎鍏虫敞" key:@"DYYYHideFollow" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绉婚櫎绮鹃€? key:@"DYYYHideMediumVideo" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绉婚櫎鍟嗗煄" key:@"DYYYHideMall" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绉婚櫎鏈嬪弸" key:@"DYYYHideFriend" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绉婚櫎鍚屽煄" key:@"DYYYHideNearby" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绉婚櫎鍥㈣喘" key:@"DYYYHideGroupon" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绉婚櫎鐩存挱" key:@"DYYYHideTabLive" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绉婚櫎鐑偣" key:@"DYYYHidePadHot" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绉婚櫎缁忛獙" key:@"DYYYHideHangout" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绉婚櫎鐭墽" key:@"DYYYHideTemplatePlaylet" type:DYYYSettingItemTypeSwitch]
            ],
            
                // 绗簲閮ㄥ垎 - 澧炲己鍔熻兘
                @[
                [DYYYSettingItem itemWithTitle:@"鍚敤鏂扮増鐜荤拑闈㈡澘" key:@"DYYYisEnableModern" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"灞忚斀-HDR瑙嗛" key:@"DYYYFilterFeedHDR" type:DYYYSettingItemTypeSwitch],            
                [DYYYSettingItem itemWithTitle:@"鍚敤淇濆瓨浠栦汉澶村儚" key:@"DYYYEnableSaveAvatar" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绂佺敤鐐瑰嚮棣栭〉鍒锋柊" key:@"DYYYDisableHomeRefresh" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绂佺敤鍙屽嚮瑙嗛鐐硅禐" key:@"DYYYDouble" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"璇勮鍖?鍙屽嚮瑙﹀彂" key:@"DYYYEnableDoubleOpenComment" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"璇勮鏂囨湰澶嶅埗" key:@"DYYYCommentCopyText" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"璇勮鍖?闀挎寜澶嶅埗鏂囨湰" key:@"DYYYEnableCommentCopyText" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"璇勮鍖?淇濆瓨鍔ㄦ€佸浘" key:@"DYYYCommentLivePhotoNotWaterMark" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"璇勮鍖?淇濆瓨鍥剧墖" key:@"DYYYCommentNotWaterMark" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"璇勮鍖?淇濆瓨琛ㄦ儏鍖? key:@"DYYYFourceDownloadEmotion" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"琛ㄦ儏棰勮淇濆瓨" key:@"DYYYForceDownloadPreviewEmotion" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绉佷俊琛ㄦ儏淇濆瓨" key:@"DYYYForceDownloadIMEmotion" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"瑙嗛-鏄剧ず鏃ユ湡鏃堕棿" key:@"DYYYShowDateTime" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -骞?鏈?鏃?鏃?鍒? key:@"DYYYDateTimeFormat_YMDHM" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鏈?鏃?鏃?鍒? key:@"DYYYDateTimeFormat_MDHM" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鏃?鍒?绉? key:@"DYYYDateTimeFormat_HMS" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鏃?鍒? key:@"DYYYDateTimeFormat_HM" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -骞?鏈?鏃? key:@"DYYYDateTimeFormat_YMD" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"灞炲湴鍓嶇紑" key:@"DYYYLocationPrefix" type:DYYYSettingItemTypeTextField placeholder:@"鍙互鑷畾涔変慨鏀?"],
                [DYYYSettingItem itemWithTitle:@"鏃堕棿灞炲湴鏄剧ず-寮€鍏? key:@"DYYYEnableArea" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鐪佺骇" key:@"DYYYEnableAreaProvince" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鍩庡競" key:@"DYYYEnableAreaCity" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -甯傚尯鎴栧幙鍩? key:@"DYYYEnableAreaDistrict" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -琛楅亾鎴栧皬鍖? key:@"DYYYEnableAreaStreet" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"閾炬帴瑙ｆ瀽API" key:@"DYYYInterfaceDownload" type:DYYYSettingItemTypeTextField placeholder:@"涓嶈缃紝榛樿"],
                [DYYYSettingItem itemWithTitle:@"寮瑰嚭-娓呮櫚搴﹂€夐」" key:@"DYYYShowAllVideoQuality" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鎷︽埅骞垮憡锛堝紑灞忋€佷俊鎭祦銆佸惎鍔ㄨ棰戯級"  key:@"DYYYNoAds" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"澶村儚鏂囨湰-淇敼" key:@"DYYYAvatarTapText" type:DYYYSettingItemTypeTextField placeholder:@"鍙互鑷畾涔変慨鏀?],
                [DYYYSettingItem itemWithTitle:@"鑿滃崟鑳屾櫙棰滆壊" key:@"DYYYBackgroundColor" type:DYYYSettingItemTypeColorPicker],
                [DYYYSettingItem itemWithTitle:@"榛樿鍊嶉€燂紙濡傛灉娌℃湁鍊嶆暟璁剧疆锛? key:@"DYYYDefaultSpeed" type:DYYYSettingItemTypeSpeedPicker placeholder:@"鐐瑰嚮閫夋嫨"],
                [DYYYSettingItem itemWithTitle:@"闀挎寜鍊嶉€? key:@"DYYYLongPressSpeed" type:DYYYSettingItemTypeSpeedPicker placeholder:@"鐐瑰嚮閫夋嫨"],
                [DYYYSettingItem itemWithTitle:@"涓婁笅鎵嬪娍鎺у埗鍊嶉€? key:@"DYYYEnableLongPressSpeedGesture" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍊嶉€熸寜閽姛鑳?寮€鍏? key:@"DYYYEnableFloatSpeedButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍊嶉€熸暟鍊硷紙寮哄埗鍊嶆暟锛? key:@"DYYYSpeedSettings" type:DYYYSettingItemTypeTextField placeholder:@"鑻辨枃閫楀彿鍒嗛殧"],
                [DYYYSettingItem itemWithTitle:@"涓嬩竴涓棰戜細鑷姩鎭㈠榛樿鍊嶉€? key:@"DYYYAutoRestoreSpeed" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍊嶉€熸寜閽樉绀哄悗缂€" key:@"DYYYSpeedButtonShowX" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍊嶉€熸寜閽ぇ灏? key:@"DYYYSpeedButtonSize" type:DYYYSettingItemTypeTextField placeholder:@"榛樿40"],
                [DYYYSettingItem itemWithTitle:@"瑙嗛娓呭睆闅愯棌-寮€鍏? key:@"DYYYEnableFloatClearButton" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鎸夐挳澶? key:@"DYYYCustomAlbumSizeLarge" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鎸夐挳涓? key:@"DYYYCustomAlbumSizeMedium" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鎸夐挳灏? key:@"DYYYCustomAlbumSizeSmall" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鎸夐挳鑷畾涔? key:@"DYYYEnableFloatClearButtonSize" type:DYYYSettingItemTypeTextField placeholder:@"榛樿40"],
                [DYYYSettingItem itemWithTitle:@"鍥炬爣鏇存崲-寮€鍏? key:@"DYYYEnableCustomAlbum" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鏈湴鐩稿唽" key:@"DYYYCustomAlbumImage" type:DYYYSettingItemTypeTextField placeholder:@"鐐瑰嚮閫夋嫨鍥剧墖"],
                [DYYYSettingItem itemWithTitle:@"  -娓呭睆闅愯棌寮瑰箷" key:@"DYYYHideDanmaku" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -娓呭睆绉婚櫎杩涘害" key:@"DYYYEnabshijianjindu" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -娓呭睆闅愯棌杩涘害" key:@"DYYYHideTimeProgress" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -娓呭睆闅愯棌绔犺妭" key:@"DYYYHideChapter" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -娓呭睆闅愯棌婊戞潯" key:@"DYYYHideSlider" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -娓呭睆闅愯棌搴曟爮" key:@"DYYYHideTabBar" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -娓呭睆闅愯棌鍊嶉€? key:@"DYYYHideSpeed" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闀挎寜鍔熻兘-寮€鍏? key:@"DYYYLongPressDownload" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -淇濆瓨瑙嗛" key:@"DYYYLongPressSaveVideo" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鍒嗕韩闊抽" key:@"DYYYLongPressSaveAudio" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鍚敤FLEX" key:@"DYYYEnableFLEX" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -PIP灏忕獥鎾斁" key:@"DYYYLongPressPip" type:DYYYSettingItemTypeSwitch],                
                [DYYYSettingItem itemWithTitle:@"  -淇濆瓨褰撳墠鍥剧墖" key:@"DYYYLongPressSaveCurrentImage" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -淇濆瓨鎵€鏈夊浘鐗? key:@"DYYYLongPressSaveAllImages" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -澶嶅埗閾炬帴" key:@"DYYYLongPressCopyLink" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鎺ュ彛瑙ｆ瀽" key:@"DYYYLongPressApiDownload" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -杩囨护鐢ㄦ埛" key:@"DYYYLongPressFilterUser" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -杩囨护鏂囨" key:@"DYYYLongPressFilterTitle" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -瀹氭椂鍏抽棴" key:@"DYYYLongPressTimerClose" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鍒朵綔瑙嗛" key:@"DYYYLongPressCreateVideo" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-杞彂鏃ュ父" key:@"DYYYHideDaily" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-鎺ㄨ崘" key:@"DYYYHideRecommend" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-涓嶆劅鍏磋叮" key:@"DYYYHideNotInterested" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-涓炬姤" key:@"DYYYHideReport" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-鍊嶉€? key:@"DYYYHideSpeed" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-娓呭睆鎾斁" key:@"DYYYHideClearScreen" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-缂撳瓨瑙嗛" key:@"DYYYHideFavorite" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-绋嶅悗鍐嶇湅" key:@"DYYYHideLater" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-鎶曞睆" key:@"DYYYHideCast" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-PC鎵撳紑" key:@"DYYYHideOpenInPC" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-寮瑰箷" key:@"DYYYHideSubtitle" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-鑷姩杩炴挱" key:@"DYYYHideAutoPlay" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-璇嗗埆鍥剧墖" key:@"DYYYHideSearchImage" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-鍚姈闊? key:@"DYYYHideListenDouyin" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-鍚庡彴鎾斁" key:@"DYYYHideBackgroundPlay" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-鍙屽垪鍏ュ彛" key:@"DYYYHideBiserial" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-瀹氭椂鍏抽棴" key:@"DYYYHideTimerclose" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-淇濆瓨鑷崇浉鍐? key:@"DYYYHideSaveToAlbum" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闅愯棌闀挎寜-璇嗗浘鎼滃悓娆? key:@"DYYYHideImageSearch" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闀挎寜闈㈡澘-澶嶅埗鍔熻兘" key:@"DYYYCopyText" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -澶嶅埗鍘熸枃鏈? key:@"DYYYCopyOriginalText" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -澶嶅埗鍒嗕韩閾炬帴" key:@"DYYYCopyShareLink" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍙屽嚮鎿嶄綔-寮€鍏? key:@"DYYYEnableDoubleOpenAlertController" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -淇濆瓨瑙嗛/鍥剧墖/瀹炲喌鍔ㄥ浘" key:@"DYYYDoubleTapDownload" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -闊抽寮瑰嚭鍒嗕韩" key:@"DYYYDoubleTapDownloadAudio" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -澶嶅埗鏂囨" key:@"DYYYDoubleTapCopyDesc" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鎵撳紑璇勮" key:@"DYYYDoubleTapComment" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鐐硅禐瑙嗛" key:@"DYYYDoubleTapLike" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鍒嗕韩瑙嗛" key:@"DYYYDoubleTapshowSharePanel" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -闀挎寜闈㈡澘" key:@"DYYYDoubleTapshowDislikeOnVideo" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鎺ュ彛瑙ｆ瀽" key:@"DYYYDoubleInterfaceDownload" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -PIP灏忕獥鎾斁" key:@"DYYYEnablePipPlayer" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"榛樿鏈€楂樼敾璐? key:@"DYYYEnableVideoHighestQuality" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"瑙嗛闄嶅櫔澧炲己" key:@"DYYYEnableNoiseFilter" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"榛樿娓呮櫚搴?鏈€楂? key:@"DYYYDefaultQualityBest" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"榛樿娓呮櫚搴?鍘熺敾" key:@"DYYYDefaultQualityOriginal" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"榛樿娓呮櫚搴?1080P" key:@"DYYYDefaultQuality1080p" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"榛樿娓呮櫚搴?720P" key:@"DYYYDefaultQuality720p" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鐩存挱瑙嗛-鏈€楂樼敾璐? key:@"DYYYEnableLiveHighestQuality" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绂佺敤鐩存挱PCDN鍔熻兘" key:@"DYYYDisableLivePCDN" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鑷姩鍕鹃€夊師鍥? key:@"DYYYAutoSelectOriginalPhoto" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"瑙嗛闄嶅櫔-浜哄０澧炲己" key:@"DYYYEnableNoiseFilter" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鏃犵棔妯″紡" key:@"DYYYEnableIncognitoMode" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"涓婚〉-鑷畾涔夋€诲紑鍏? key:@"DYYYEnableSocialStatsCustom" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -绮変笣鏁伴噺" key:@"DYYYCustomFollowers" type:DYYYSettingItemTypeTextField placeholder:@"濉啓鏁板瓧"],
                [DYYYSettingItem itemWithTitle:@"  -鑾疯禐鏁伴噺" key:@"DYYYCustomLikes" type:DYYYSettingItemTypeTextField placeholder:@"濉啓鏁板瓧"],
                [DYYYSettingItem itemWithTitle:@"  -鍏虫敞鏁伴噺" key:@"DYYYCustomFollowing" type:DYYYSettingItemTypeTextField placeholder:@"濉啓鏁板瓧"],
                [DYYYSettingItem itemWithTitle:@"  -浜掑叧鏁伴噺" key:@"DYYYCustomMutual" type:DYYYSettingItemTypeTextField placeholder:@"濉啓鏁板瓧"],
                [DYYYSettingItem itemWithTitle:@"瑙嗛-鑷畾涔夋€诲紑鍏? key:@"DYYYEnableVideoStatsCustom" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"  -鐐硅禐鏁伴噺" key:@"DYYYVideoCustomLikes" type:DYYYSettingItemTypeTextField placeholder:@"濉啓鏁板瓧"],
                [DYYYSettingItem itemWithTitle:@"  -璇勮鏁伴噺" key:@"DYYYVideoCustomComments" type:DYYYSettingItemTypeTextField placeholder:@"濉啓鏁板瓧"],
                [DYYYSettingItem itemWithTitle:@"  -鏀惰棌鏁伴噺" key:@"DYYYVideoCustomCollects" type:DYYYSettingItemTypeTextField placeholder:@"濉啓鏁板瓧"],
                [DYYYSettingItem itemWithTitle:@"  -鍒嗕韩鏁伴噺" key:@"DYYYVideoCustomShares" type:DYYYSettingItemTypeTextField placeholder:@"濉啓鏁板瓧"],
                [DYYYSettingItem itemWithTitle:@"寮哄埗鑷姩鎾斁锛堜笉鑳藉叧闂級" key:@"DYYYEnableAutoPlay" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍚敤娣辫壊閿洏" key:@"DYYYisDarkKeyBoard" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"闀挎寜-澶嶅埗瑙嗛鏂囨" key:@"DYYYLongPressCopyTextEnabled" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍚敤闊充箰鏂囨湰澶嶅埗" key:@"DYYYMusicCopyText" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"绠€鍖栦晶杈规爮" key:@"DYYYStreamlinethesidebar" type:DYYYSettingItemTypeSwitch]
            ],

            // 绗叚閮ㄥ垎 - 鍥炬爣鑷畾涔夊姛鑳?
            @[
                [DYYYSettingItem itemWithTitle:@"鏈偣璧炲浘鏍? key:@"DYYYIconLikeBefore" type:DYYYSettingItemTypeTextField placeholder:@"鐐瑰嚮閫夋嫨鍥剧墖"],
                [DYYYSettingItem itemWithTitle:@"宸茬偣璧炲浘鏍? key:@"DYYYIconLikeAfter" type:DYYYSettingItemTypeTextField placeholder:@"鐐瑰嚮閫夋嫨鍥剧墖"],
                [DYYYSettingItem itemWithTitle:@"璇勮鐨勫浘鏍? key:@"DYYYIconComment" type:DYYYSettingItemTypeTextField placeholder:@"鐐瑰嚮閫夋嫨鍥剧墖"],
                [DYYYSettingItem itemWithTitle:@"鏈敹钘忓浘鏍? key:@"DYYYIconUnfavorite" type:DYYYSettingItemTypeTextField placeholder:@"鐐瑰嚮閫夋嫨鍥剧墖"],
                [DYYYSettingItem itemWithTitle:@"宸叉敹钘忓浘鏍? key:@"DYYYIconFavorite" type:DYYYSettingItemTypeTextField placeholder:@"鐐瑰嚮閫夋嫨鍥剧墖"],
                [DYYYSettingItem itemWithTitle:@"鍒嗕韩鐨勫浘鏍? key:@"DYYYIconShare" type:DYYYSettingItemTypeTextField placeholder:@"鐐瑰嚮閫夋嫨鍥剧墖"]
            ],
            
            // 绗竷閮ㄥ垎 - 娓呯悊鍔熻兘
            @[
                [DYYYSettingItem itemWithTitle:@"娓呴櫎璁剧疆" key:@"DYYYCleanSettings" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"娓呯悊缂撳瓨" key:@"DYYYCleanCache" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"澶囦唤璁剧疆" key:@"DYYYBackupSettings" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鎭㈠璁剧疆" key:@"DYYYRestoreSettings" type:DYYYSettingItemTypeSwitch]
            ],
            
            // 绗叓閮ㄥ垎 - 鐑洿鏂板姛鑳?
            @[
                [DYYYSettingItem itemWithTitle:@"绂佺敤涓嬪彂閰嶇疆" key:@"DYYYABTestBlockEnabled" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍚敤琛ヤ竵妯″紡" key:@"DYYYABTestPatchEnabled" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"淇濆瓨褰撳墠閰嶇疆" key:@"SaveCurrentABTestData" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鏈湴閫夋嫨閰嶇疆" key:@"LoadABTestConfigFile" type:DYYYSettingItemTypeSwitch],
                [DYYYSettingItem itemWithTitle:@"鍒犻櫎鏈湴閰嶇疆" key:@"DeleteABTestConfigFile" type:DYYYSettingItemTypeSwitch]
            ]
        ];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.settingSections = sections;
            self.filteredSections = sections;
            self.filteredSectionTitles = [self.sectionTitles mutableCopy];
            if (self.tableView) {
                [self.tableView reloadData];
            }
            
            // 璁剧疆澶囦唤鍔熻兘
            [self setupBackupFunctions];
        });
    });
}

- (void)setupBackupFunctions {
    // 纭繚琛ㄦ牸宸茬粡鍔犺浇
    if (!self.tableView) return;
    
    // 鎵惧埌澶囦唤璁剧疆椤瑰苟娣诲姞鐐瑰嚮浜嬩欢
    for (NSInteger section = 0; section < self.settingSections.count; section++) {
        NSArray<DYYYSettingItem *> *items = self.settingSections[section];
        for (NSInteger row = 0; row < items.count; row++) {
            DYYYSettingItem *item = items[row];
            
            if ([item.key isEqualToString:@"DYYYBackupSettings"]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                if (cell) {
                    // 绉婚櫎鐜版湁鐨勫紑鍏?
                    if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
                        [cell.accessoryView removeFromSuperview];
                    }
                    
                    // 鍒涘缓鏂扮殑鎸夐挳
                    UIButton *backupButton = [UIButton buttonWithType:UIButtonTypeSystem];
                    [backupButton setTitle:@"澶囦唤" forState:UIControlStateNormal];
                    backupButton.frame = CGRectMake(0, 0, 60, 30);
                    backupButton.layer.cornerRadius = 8;
                    backupButton.backgroundColor = [UIColor systemBlueColor];
                    [backupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [backupButton addTarget:self action:@selector(backupSettings) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = backupButton;
                }
            }
            else if ([item.key isEqualToString:@"DYYYRestoreSettings"]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                if (cell) {
                    // 绉婚櫎鐜版湁鐨勫紑鍏?
                    if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
                        [cell.accessoryView removeFromSuperview];
                    }
                    
                    // 鍒涘缓鏂扮殑鎸夐挳
                    UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeSystem];
                    [restoreButton setTitle:@"鎭㈠" forState:UIControlStateNormal];
                    restoreButton.frame = CGRectMake(0, 0, 60, 30);
                    restoreButton.layer.cornerRadius = 8;
                    restoreButton.backgroundColor = [UIColor systemBlueColor];
                    [restoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [restoreButton addTarget:self action:@selector(restoreSettings) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = restoreButton;
                }
            }
        }
    }
}

- (void)backupSettings {
    // 鑾峰彇鎵€鏈変互DYYY寮€澶寸殑NSUserDefaults閿€?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *allDefaults = [defaults dictionaryRepresentation];
    NSMutableDictionary *dyyySettings = [NSMutableDictionary dictionary];

    for (NSString *key in allDefaults.allKeys) {
        if ([key hasPrefix:@"DYYY"]) {
            dyyySettings[key] = [defaults objectForKey:key];
        }
    }

    // 澶囦唤鍥炬爣鏂囦欢
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dyyyFolderPath = [documentsPath stringByAppendingPathComponent:@"DYYY"];

    NSArray *iconFileNames = @[ @"like_before.png", @"like_after.png", @"comment.png", @"unfavorite.png", @"favorite.png", @"share.png", @"qingping.gif" ];

    NSMutableDictionary *iconBase64Dict = [NSMutableDictionary dictionary];

    for (NSString *iconFileName in iconFileNames) {
        NSString *iconPath = [dyyyFolderPath stringByAppendingPathComponent:iconFileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
            // 璇诲彇鍥剧墖鏁版嵁骞惰浆鎹负Base64
            NSData *imageData = [NSData dataWithContentsOfFile:iconPath];
            if (imageData) {
                NSString *base64String = [imageData base64EncodedStringWithOptions:0];
                iconBase64Dict[iconFileName] = base64String;
            }
        }
    }

    // 灏嗗浘鏍嘊ase64鏁版嵁娣诲姞鍒板浠借缃腑
    if (iconBase64Dict.count > 0) {
        dyyySettings[@"DYYYIconsBase64"] = iconBase64Dict;
    }

    // 杞崲涓篔SON鏁版嵁
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dyyySettings options:NSJSONWritingPrettyPrinted error:&error];

    if (error) {
        [DYYYManager showToast:@"澶囦唤澶辫触锛氭棤娉曞簭鍒楀寲璁剧疆鏁版嵁"];
        return;
    }

    // 纭繚鐩綍瀛樺湪
    if (![[NSFileManager defaultManager] fileExistsAtPath:dyyyFolderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dyyyFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    NSString *backupFileName = [NSString stringWithFormat:@"DYYY_Backup_%@.json", timestamp];
    NSString *tempDir = NSTemporaryDirectory();
    NSString *tempFilePath = [tempDir stringByAppendingPathComponent:backupFileName];

    BOOL success = [jsonData writeToFile:tempFilePath atomically:YES];

    if (!success) {
        [DYYYManager showToast:@"澶囦唤澶辫触锛氭棤娉曞垱寤轰复鏃舵枃浠?];
        return;
    }

    // 鍒涘缓鏂囨。閫夋嫨鍣ㄨ鐢ㄦ埛閫夋嫨淇濆瓨浣嶇疆
    NSURL *tempFileURL = [NSURL fileURLWithPath:tempFilePath];
    
    // 浣跨敤姝ｇ‘鐨勬ā寮忓拰鏂囨。绫诲瀷
    UIDocumentPickerViewController *documentPicker;
    if (@available(iOS 11.0, *)) {
        documentPicker = [[UIDocumentPickerViewController alloc] initWithURLs:@[tempFileURL] inMode:UIDocumentPickerModeExportToService];
    } else {
        documentPicker = [[UIDocumentPickerViewController alloc] initWithURL:tempFileURL inMode:UIDocumentPickerModeExportToService];
    }

    // 寮哄紩鐢ㄤ唬鐞嗗璞?
    self.backupPickerDelegate = [[DYYYBackupPickerDelegate alloc] init];
    self.backupPickerDelegate.tempFilePath = tempFilePath;
    self.backupPickerDelegate.completionBlock = ^(NSURL *url) {
        // 澶囦唤鎴愬姛
        dispatch_async(dispatch_get_main_queue(), ^{
            [DYYYManager showToast:@"澶囦唤鎴愬姛"];
        });
    };

    // 浣跨敤瀹炰緥鍙橀噺鑰岄潪鍏宠仈瀵硅薄
    documentPicker.delegate = self.backupPickerDelegate;

    // iPad涓婄殑灞曠ず鏂瑰紡
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        documentPicker.popoverPresentationController.sourceView = self.view;
        documentPicker.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, 
                                                                           self.view.bounds.size.height / 2, 
                                                                           0, 0);
    }

    // 淇锛氬畨鍏ㄥ湴鍛堢幇瑙嗗浘鎺у埗鍣?
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:documentPicker animated:YES completion:nil];
    });
}

- (void)restoreSettings {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.json", @"public.text"] inMode:UIDocumentPickerModeImport];
    documentPicker.allowsMultipleSelection = NO;

    // 寮哄紩鐢ㄤ唬鐞嗗璞?
    self.restorePickerDelegate = [[DYYYBackupPickerDelegate alloc] init];
    self.restorePickerDelegate.completionBlock = ^(NSURL *url) {
        if (!url) {
            [DYYYManager showToast:@"鏈€夋嫨澶囦唤鏂囦欢"];
            return;
        }
        
        NSData *jsonData = [NSData dataWithContentsOfURL:url];
        if (!jsonData) {
            [DYYYManager showToast:@"鏃犳硶璇诲彇澶囦唤鏂囦欢"];
            return;
        }

        NSError *jsonError;
        NSDictionary *dyyySettings = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
        if (jsonError || ![dyyySettings isKindOfClass:[NSDictionary class]]) {
            [DYYYManager showToast:@"澶囦唤鏂囦欢鏍煎紡閿欒"];
            return;
        }

        // 鎭㈠鍥炬爣鏂囦欢
        NSDictionary *iconBase64Dict = dyyySettings[@"DYYYIconsBase64"];
        if (iconBase64Dict && [iconBase64Dict isKindOfClass:[NSDictionary class]]) {
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *dyyyFolderPath = [documentsPath stringByAppendingPathComponent:@"DYYY"];

            // 纭繚DYYY鏂囦欢澶瑰瓨鍦?
            if (![[NSFileManager defaultManager] fileExistsAtPath:dyyyFolderPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:dyyyFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
            }

            // 浠嶣ase64杩樺師鍥炬爣鏂囦欢
            for (NSString *iconFileName in iconBase64Dict) {
                NSString *base64String = iconBase64Dict[iconFileName];
                if ([base64String isKindOfClass:[NSString class]]) {
                    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
                    if (imageData) {
                        NSString *iconPath = [dyyyFolderPath stringByAppendingPathComponent:iconFileName];
                        [imageData writeToFile:iconPath atomically:YES];
                    }
                }
            }

            NSMutableDictionary *cleanSettings = [dyyySettings mutableCopy];
            [cleanSettings removeObjectForKey:@"DYYYIconsBase64"];
            dyyySettings = cleanSettings;
        }

        // 鎭㈠璁剧疆
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        for (NSString *key in dyyySettings) {
            [defaults setObject:dyyySettings[key] forKey:key];
        }
        [defaults synchronize];

        // 鍦ㄤ富绾跨▼鏇存柊UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [DYYYManager showToast:@"璁剧疆宸叉仮澶嶏紝璇烽噸鍚簲鐢ㄤ互搴旂敤鎵€鏈夋洿鏀?];
            
            // 鍒锋柊璁剧疆鐣岄潰
            [self.tableView reloadData];
        });
    };

    documentPicker.delegate = self.restorePickerDelegate;

    // iPad涓婄殑灞曠ず鏂瑰紡
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        documentPicker.popoverPresentationController.sourceView = self.view;
        documentPicker.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, 
                                                                           self.view.bounds.size.height / 2, 
                                                                           0, 0);
    }

    // 瀹夊叏鍦板憟鐜拌鍥炬帶鍒跺櫒
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:documentPicker animated:YES completion:nil];
    });
}

- (void)setupFooterLabel {
    // 鍒涘缓搴曢儴鏍囪瘑鏍囩
    UIView *footerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    
    self.footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    self.footerLabel.text = @"Developer By @hackxq\nVersion: 1.00 (261001)";
    self.footerLabel.textAlignment = NSTextAlignmentCenter;
    self.footerLabel.font = [UIFont systemFontOfSize:12];
    self.footerLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.footerLabel.numberOfLines = 2;
    [footerContainer addSubview:self.footerLabel];
    
    // 璁剧疆瀹瑰櫒涓鸿〃鏍煎簳閮ㄨ鍥?
    self.tableView.tableFooterView = footerContainer;
}

- (void)setupSectionTitles {
    self.sectionTitles = [NSMutableArray arrayWithObjects:
                          @"鍩烘湰璁剧疆",
                          @"鐣岄潰璁剧疆",
                          @"闅愯棌璁剧疆",
                          @"绉婚櫎璁剧疆",
                          @"澧炲己鍔熻兘",
                          @"鍥炬爣",
                          @"娓呯悊&澶囦唤",
                          @"鐑洿鏂?,
                          nil];
}

#pragma mark - Avatar Handling

- (void)avatarTapped:(UITapGestureRecognizer *)gesture {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.allowsEditing = YES;
                [self presentViewController:picker animated:YES completion:nil];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"鏃犳硶璁块棶鐩稿唽"
                                                                               message:@"璇峰湪璁剧疆涓厑璁歌闂浉鍐?
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"纭畾" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    if (!selectedImage) {
        [DYYYManager showToast:@"鏃犳硶鑾峰彇鎵€閫夊浘鐗?];
        return;
    }
    
    BOOL isCustomAlbumPicker = [objc_getAssociatedObject(picker, "isCustomAlbumPicker") boolValue];
    if (isCustomAlbumPicker) {
        NSString *customAlbumImagePath = [self saveCustomAlbumImage:selectedImage];
        if (customAlbumImagePath) {
            [[NSUserDefaults standardUserDefaults] setObject:customAlbumImagePath forKey:@"DYYYCustomAlbumImagePath"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [DYYYManager showToast:@"鑷畾涔夌浉鍐屽浘鐗囧凡璁剧疆"];
            [self.tableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYCustomAlbumSettingChanged" object:nil];
        } else {
            [DYYYManager showToast:@"淇濆瓨鑷畾涔夌浉鍐屽浘鐗囧け璐?];
        }
    } else {
        NSString *avatarPath = [self avatarImagePath];
        NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.8);
        [imageData writeToFile:avatarPath atomically:YES];
        self.avatarImageView.image = selectedImage;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)avatarImagePath {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentsPath stringByAppendingPathComponent:@"DYYYAvatar.jpg"];
}

- (NSString *)saveCustomAlbumImage:(UIImage *)image {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dyyyFolder = [documentsPath stringByAppendingPathComponent:@"DYYY"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:dyyyFolder 
                              withIntermediateDirectories:YES 
                                               attributes:nil 
                                                    error:&error];
    if (error) {
        return nil;
    }
    
    NSString *imagePath = [dyyyFolder stringByAppendingPathComponent:@"custom_album_image.png"];
    NSData *imageData = UIImagePNGRepresentation(image);
    if ([imageData writeToFile:imagePath atomically:YES]) {
        return imagePath;
    }
    
    return nil;
}

#pragma mark - Color Picker

- (void)showColorPicker {
    if (@available(iOS 14.0, *)) {
        UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYBackgroundColor"];
        UIColor *currentColor = colorData ? [NSKeyedUnarchiver unarchiveObjectWithData:colorData] : [UIColor systemBackgroundColor];
        picker.selectedColor = currentColor;
        picker.delegate = (id)self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"閫夋嫨鑳屾櫙棰滆壊"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        NSArray<NSDictionary *> *colors = @[
            @{@"name": @"绮夌孩", @"color": [UIColor systemRedColor]},
            @{@"name": @"钃濊壊", @"color": [UIColor systemBlueColor]},
            @{@"name": @"缁胯壊", @"color": [UIColor systemGreenColor]},
            @{@"name": @"榛勮壊", @"color": [UIColor systemYellowColor]},
            @{@"name": @"绱壊", @"color": [UIColor systemPurpleColor]},
            @{@"name": @"姗欒壊", @"color": [UIColor systemOrangeColor]},
            @{@"name": @"绮夎壊", @"color": [UIColor systemPinkColor]},
            @{@"name": @"鐏拌壊", @"color": [UIColor systemGrayColor]},
            @{@"name": @"鐧借壊", @"color": [UIColor whiteColor]},
            @{@"name": @"榛戣壊", @"color": [UIColor blackColor]}
        ];
        for (NSDictionary *colorInfo in colors) {
            NSString *name = colorInfo[@"name"];
            UIColor *color = colorInfo[@"color"];
            UIAlertAction *action = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.backgroundColorView.backgroundColor = color;
                NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
                [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"DYYYBackgroundColor"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                for (NSInteger section = 0; section < self.settingSections.count; section++) {
                    NSArray *items = self.settingSections[section];
                    for (NSInteger row = 0; row < items.count; row++) {
                        DYYYSettingItem *item = items[row];
                        if (item.type == DYYYSettingItemTypeColorPicker) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                            if (self.tableView) {
                                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                            }
                            break;
                        }
                    }
                }
            }];
            UIImage *colorImage = [self imageWithColor:color size:CGSizeMake(20, 20)];
            [action setValue:colorImage forKey:@"image"];
            [alert addAction:action];
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"鍙栨秷" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            alert.popoverPresentationController.sourceView = self.tableView;
            alert.popoverPresentationController.sourceRect = self.tableView.bounds;
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
}


// 鏀寔 UIColorPickerViewController 鍥炶皟
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)){
    UIColor *color = viewController.selectedColor;
    self.backgroundColorView.backgroundColor = color;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"DYYYBackgroundColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // 閫氱煡寮圭獥鍒锋柊
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYBackgroundColorChanged" object:nil];
    for (NSInteger section = 0; section < self.settingSections.count; section++) {
        NSArray *items = self.settingSections[section];
        for (NSInteger row = 0; row < items.count; row++) {
            DYYYSettingItem *item = items[row];
            if (item.type == DYYYSettingItemTypeColorPicker) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                if (self.tableView) {
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
                break;
            }
        }
    }
}
- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)){
    [self colorPickerViewControllerDidSelectColor:viewController];
}
#endif

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [color setFill];
    [[UIColor whiteColor] setStroke];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(1, 1, size.width - 2, size.height - 2)];
    path.lineWidth = 1.0;
    [path fill];
    [path stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.isSearching = NO;
        self.filteredSections = nil;
        self.filteredSectionTitles = nil;
    } else {
        self.isSearching = YES;
        [self filterContentForSearchText:searchText];
    }
    
    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString *)searchText {
    NSMutableArray *filteredSections = [NSMutableArray array];
    NSMutableArray *filteredTitles = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.settingSections.count; i++) {
        NSArray *section = self.settingSections[i];
        NSMutableArray *filteredSection = [NSMutableArray array];
        
        for (DYYYSettingItem *item in section) {
            // 鎼滅储鏍囬鎴杒ey
            if ([item.title.lowercaseString containsString:searchText.lowercaseString] ||
                [item.key.lowercaseString containsString:searchText.lowercaseString]) {
                [filteredSection addObject:item];
            }
        }
        
        if (filteredSection.count > 0) {
            [filteredSections addObject:filteredSection];
            [filteredTitles addObject:self.sectionTitles[i]];
        }
    }
    
    self.filteredSections = filteredSections;
    self.filteredSectionTitles = filteredTitles;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *sections = self.isSearching ? self.filteredSections : self.settingSections;
    return sections ? sections.count : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // 纭繚澶撮儴瑙嗗浘楂樺害涓庤繑鍥炵殑楂樺害涓€鑷?35)
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 45)];
    headerView.backgroundColor = [UIColor clearColor];
    
    // 淇澶撮儴鎸夐挳鐨勫搴﹀拰浣嶇疆锛屼娇鍏跺眳涓笖瀹藉害閫傚綋
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // 璁剧疆鎸夐挳姘村钩灞呬腑锛屽苟璁剧疆鍚堥€傜殑瀹藉害
    CGFloat buttonWidth = tableView.bounds.size.width - 55;
    CGFloat buttonX = (tableView.bounds.size.width - buttonWidth) / 5; // 璁＄畻浣挎寜閽按骞冲眳涓殑X鍧愭爣
    headerButton.frame = CGRectMake(buttonX, 2, buttonWidth, 41);
    
    // 浣跨敤绯荤粺鑳屾櫙鑹插苟娣诲姞鍦嗚
    headerButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9]; // 鍗婇€忔槑鐧借壊鑳屾櫙
    headerButton.layer.cornerRadius = 10;
    headerButton.layer.masksToBounds = YES; // 纭繚鍐呭涓嶈秴鍑哄渾瑙掕寖鍥?
    
    // 璁剧疆鏍囬鎸夐挳灞炴€?
    headerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    headerButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [headerButton setTitle:self.isSearching ? self.filteredSectionTitles[section] : self.sectionTitles[section] forState:UIControlStateNormal];
    [headerButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    headerButton.tag = section;
    [headerButton addTarget:self action:@selector(headerTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // 娣诲姞宸︿晶鍥炬爣 - 浣跨敤iPhone鍘熺敓鐣岄潰澶у皬
    UIImageView *leftIconImageView = [[UIImageView alloc] init];
    if (@available(iOS 13.0, *)) {
        NSString *iconName = [self iconNameForSection:section];
        UIColor *iconColor = [self iconColorForSection:section];
        
        // 浣跨敤鏇村ぇ鐨勫浘鏍囧昂瀵革紝妯′豢iPhone鍘熺敓璁剧疆鐣岄潰
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightMedium];
        UIImage *iconImage = [[UIImage systemImageNamed:iconName] imageWithConfiguration:config];
        leftIconImageView.image = iconImage;
        leftIconImageView.tintColor = iconColor;
    } else {
        leftIconImageView.image = [UIImage systemImageNamed:@"gear"];
        leftIconImageView.tintColor = [UIColor systemBlueColor];
    }
    
    // 璁剧疆宸︿晶鍥炬爣浣嶇疆 - 璋冩暣涓烘洿澶х殑灏哄鍜屼綅缃?
    CGFloat leftIconMargin = 15;
    CGFloat iconSize = 24; // 澧炲ぇ鍥炬爣灏哄锛屾ā浠垮師鐢熺晫闈?
    CGFloat iconY = (41 - iconSize) / 2; // 鍨傜洿灞呬腑
    leftIconImageView.frame = CGRectMake(leftIconMargin, iconY, iconSize, iconSize);
    leftIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 璋冩暣鏍囬鎸夐挳鐨勫唴瀹硅竟璺濓紝涓哄乏渚у浘鏍囩暀鍑虹┖闂?
    headerButton.contentEdgeInsets = UIEdgeInsetsMake(0, leftIconMargin + iconSize + 10, 0, 35); // 宸﹁竟璺?= 鍥炬爣宸﹁竟璺?+ 鍥炬爣瀹藉害 + 闂磋窛
    
    // 娣诲姞鍙充晶绠ご鎸囩ず鍣?
    UIImageView *arrowImageView = [[UIImageView alloc] init];
    if (@available(iOS 13.0, *)) {
        UIImage *arrowImage = [UIImage systemImageNamed:[self.expandedSections containsObject:@(section)] ? @"chevron.down" : @"chevron.right"];
        
        // 绠ご涔熶娇鐢ㄦ洿澶х殑灏哄
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightSemibold];
        arrowImage = [arrowImage imageWithConfiguration:config];
        arrowImageView.image = arrowImage;
        arrowImageView.tintColor = [UIColor systemGrayColor];
    } else {
        arrowImageView.image = [UIImage systemImageNamed:[self.expandedSections containsObject:@(section)] ? @"chevron.down" : @"chevron.right"];
        arrowImageView.tintColor = [UIColor systemGrayColor];
    }
    
    // 璋冩暣绠ご浣嶇疆鍒板彸渚?- 浣跨敤鏇村ぇ鐨勫昂瀵?
    CGFloat arrowRightMargin = 15;
    CGFloat arrowSize = 18; // 澧炲ぇ绠ご灏哄
    CGFloat arrowY = (41 - arrowSize) / 2; // 鍨傜洿灞呬腑
    arrowImageView.frame = CGRectMake(buttonWidth - arrowSize - arrowRightMargin, arrowY, arrowSize, arrowSize);
    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    arrowImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    arrowImageView.layer.shadowOffset = CGSizeMake(0, 1);
    arrowImageView.layer.shadowOpacity = 0.2;
    arrowImageView.layer.shadowRadius = 1.5;
    arrowImageView.tag = 100;
    
    [headerView addSubview:headerButton];
    [headerButton addSubview:leftIconImageView];
    [headerButton addSubview:arrowImageView];
    
    return headerView;
}

- (NSString *)iconNameForSection:(NSInteger)section {
    NSArray *iconNames = @[
        @"slider.horizontal.3",        // 鍩烘湰璁剧疆 - 鏇寸洿瑙傜殑鎺у埗闈㈡澘鍥炬爣
        @"paintpalette.fill",          // 鐣岄潰璁剧疆 - 璋冭壊鏉挎洿绗﹀悎鐣岄潰瀹氬埗
        @"eye.slash.circle.fill",      // 闅愯棌璁剧疆 - 鍦嗗舰鐗堟湰鏇寸幇浠?
        @"minus.circle.fill",          // 绉婚櫎璁剧疆 - 鍑忓彿鏇村噯纭〃杈剧Щ闄?
        @"wand.and.stars",             // 澧炲己鍔熻兘 - 榄旀硶妫掕〃绀哄寮?浼樺寲
        @"app.badge.fill",             // 鍥炬爣 - 搴旂敤寰界珷鏇磋创鍒囧浘鏍囧畾鍒?
        @"archivebox.fill",            // 娓呯悊&澶囦唤 - 褰掓。鐩掑瓙鏇翠笓涓?
        @"arrow.clockwise.icloud.fill" // 鐑洿鏂?- 浜戠鏇存柊鍥炬爣鏇村噯纭?
    ];
    
    // 鑾峰彇鎼滅储鏃剁殑鍘熷鍒嗙粍绱㈠紩
    NSInteger originalSection = section;
    if (self.isSearching && section < self.filteredSectionTitles.count) {
        NSString *sectionTitle = self.filteredSectionTitles[section];
        originalSection = [self.sectionTitles indexOfObject:sectionTitle];
        if (originalSection == NSNotFound) {
            originalSection = section;
        }
    }
    
    if (originalSection < iconNames.count) {
        return iconNames[originalSection];
    }
    return @"slider.horizontal.3";
}

- (UIColor *)iconColorForSection:(NSInteger)section {
    NSArray *colors = @[
        [UIColor systemBlueColor],      // 鍩烘湰璁剧疆
        [UIColor systemPurpleColor],    // 鐣岄潰璁剧疆  
        [UIColor systemRedColor],       // 闅愯棌璁剧疆
        [UIColor systemOrangeColor],    // 绉婚櫎璁剧疆
        [UIColor systemGreenColor],     // 澧炲己鍔熻兘
        [UIColor systemPinkColor],      // 鍥炬爣
        [UIColor systemTealColor],      // 娓呯悊&澶囦唤
        [UIColor systemIndigoColor]     // 鐑洿鏂?
    ];
    
    // 鑾峰彇鎼滅储鏃剁殑鍘熷鍒嗙粍绱㈠紩
    NSInteger originalSection = section;
    if (self.isSearching && section < self.filteredSectionTitles.count) {
        NSString *sectionTitle = self.filteredSectionTitles[section];
        originalSection = [self.sectionTitles indexOfObject:sectionTitle];
        if (originalSection == NSNotFound) {
            originalSection = section;
        }
    }
    
    if (originalSection < colors.count) {
        return colors[originalSection];
    }
    return [UIColor systemBlueColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0; // 浣跨敤鏍囧噯琛岄珮
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0; // 淇濇寔涓€鑷寸殑鍒嗙粍澶撮儴楂樺害
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = self.isSearching ? self.filteredSections : self.settingSections;
    if (!sections || section >= sections.count) return 0;
    return [self.expandedSections containsObject:@(section)] ? [sections[section] count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sections = self.isSearching ? self.filteredSections : self.settingSections;
    if (!sections || indexPath.section >= sections.count) return [[UITableViewCell alloc] init];
    NSArray *sectionItems = sections[indexPath.section];
    if (indexPath.row >= sectionItems.count) return [[UITableViewCell alloc] init];
    
    DYYYSettingItem *item = sectionItems[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 绉婚櫎鏃х殑閲嶇疆鎸夐挳鍜屽叾浠栬嚜瀹氫箟瑙嗗浘
    for (UIView *view in cell.contentView.subviews) {
        if (view.tag == 555) {
            [view removeFromSuperview];
        }
    }
    
    // 璋冩暣鏂囧瓧闂磋窛
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    paragraphStyle.paragraphSpacing = 0;
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                         initWithString:item.title
                                         attributes:@{
                                             NSParagraphStyleAttributeName: paragraphStyle,
                                             NSFontAttributeName: [UIFont systemFontOfSize:16],
                                             NSForegroundColorAttributeName: [UIColor whiteColor],
                                             NSKernAttributeName: @(-0.5)
                                         }];
    cell.textLabel.attributedText = attributedText;
    cell.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = nil;
    
    // 鐗规畩澶勭悊澶囦唤鍜屾仮澶嶅姛鑳?
    if ([item.key isEqualToString:@"DYYYBackupSettings"] || [item.key isEqualToString:@"DYYYRestoreSettings"]) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    // 鐗规畩澶勭悊娓呯悊鍔熻兘
    if ([item.key isEqualToString:@"DYYYCleanCache"] || [item.key isEqualToString:@"DYYYCleanSettings"]) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    // 鐗规畩澶勭悊鐑洿鏂板姛鑳?
    if ([item.key isEqualToString:@"SaveCurrentABTestData"] ||
        [item.key isEqualToString:@"LoadABTestConfigFile"] ||
        [item.key isEqualToString:@"DeleteABTestConfigFile"]) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    // 鐗规畩澶勭悊鍥炬爣鑷畾涔夊姛鑳?
    if ([item.key hasPrefix:@"DYYYIcon"]) {
        NSString *saveFilename = nil;
        if ([item.key isEqualToString:@"DYYYIconLikeBefore"]) {
            saveFilename = @"like_before.png";
        } else if ([item.key isEqualToString:@"DYYYIconLikeAfter"]) {
            saveFilename = @"like_after.png";
        } else if ([item.key isEqualToString:@"DYYYIconComment"]) {
            saveFilename = @"comment.png";
        } else if ([item.key isEqualToString:@"DYYYIconUnfavorite"]) {
            saveFilename = @"unfavorite.png";
        } else if ([item.key isEqualToString:@"DYYYIconFavorite"]) {
            saveFilename = @"favorite.png";
        } else if ([item.key isEqualToString:@"DYYYIconShare"]) {
            saveFilename = @"share.png";
        }
        if (saveFilename) {
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *dyyyFolderPath = [documentsPath stringByAppendingPathComponent:@"DYYY"];
            NSString *imagePath = [dyyyFolderPath stringByAppendingPathComponent:saveFilename];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
            UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
            iconButton.frame = CGRectMake(0, 0, 40, 40);
            iconButton.layer.cornerRadius = 20;
            iconButton.clipsToBounds = YES;
            iconButton.layer.borderWidth = 1.0;
            iconButton.layer.borderColor = [UIColor systemGrayColor].CGColor;
            iconButton.backgroundColor = [UIColor systemBackgroundColor];
            if (fileExists) {
                UIImage *icon = [UIImage imageWithContentsOfFile:imagePath];
                if (icon) {
                    [iconButton setImage:icon forState:UIControlStateNormal];
                    iconButton.contentMode = UIViewContentModeScaleAspectFit;
                } else {
                    [iconButton setImage:[UIImage systemImageNamed:@"photo"] forState:UIControlStateNormal];
                    [iconButton setTintColor:[UIColor systemBlueColor]];
                }
            } else {
                [iconButton setImage:[UIImage systemImageNamed:@"plus.circle"] forState:UIControlStateNormal];
                [iconButton setTintColor:[UIColor systemBlueColor]];
            }
            [iconButton addTarget:self action:@selector(iconButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            iconButton.tag = indexPath.section * 1000 + indexPath.row;
            cell.accessoryView = iconButton;
            return cell;
        }
    }
    // 鏆楅粦鏋佺畝椋庢牸锛氱Щ闄ゅ乏渚у浘鏍?
    cell.imageView.image = nil;
    cell.imageView.contentMode = UIViewContentModeCenter;
    // 寰蒋椋庢牸鍗＄墖鑳屾櫙
    UIView *card = [cell.contentView viewWithTag:8888];
    if (!card) {
        card = [[UIView alloc] initWithFrame:CGRectInset(cell.contentView.bounds, 8, 4)];
        card.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        card.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.08];
        card.layer.cornerRadius = 12;
        card.layer.shadowColor = [UIColor blackColor].CGColor;
        card.layer.shadowOpacity = 0.06;
        card.layer.shadowOffset = CGSizeMake(0, 2);
        card.layer.shadowRadius = 4;
        card.tag = 8888;
        [cell.contentView insertSubview:card atIndex:0];
    }
    // 鍒涘缓鍗曞厓鏍肩殑閰嶄欢瑙嗗浘
    UIView *accessoryView = nil;
    // 閽堝scheduleStyle鐨勭壒娈婂鐞?
    if ([item.key isEqualToString:@"DYYYScheduleStyle"]) {
        UIButton *styleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        styleButton.frame = CGRectMake(0, 0, 120, 30);
        NSString *currentStyle = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYScheduleStyle"];
        BOOL displayEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYShowScheduleDisplay"];
        if (currentStyle.length == 0) {
            [styleButton setTitle:@"榛樿" forState:UIControlStateNormal];
        } else {
            NSString *displayValue = currentStyle;
            if ([currentStyle containsString:@"-"]) {
                displayValue = [currentStyle componentsSeparatedByString:@"-"].lastObject;
            }
            [styleButton setTitle:displayValue forState:UIControlStateNormal];
        }
        styleButton.enabled = displayEnabled;
        styleButton.alpha = displayEnabled ? 1.0 : 0.5;
        if (!displayEnabled) {
            cell.detailTextLabel.text = @"闇€鍏堝紑鍚樉绀鸿繘搴︽椂闀?;
            cell.detailTextLabel.textColor = [UIColor systemRedColor];
        } else {
            cell.detailTextLabel.text = nil;
        }
        [styleButton addTarget:self action:@selector(showScheduleStylePicker) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = styleButton;
        return cell;
    }
    if (item.type == DYYYSettingItemTypeSwitch) {
        UISwitch *switchView = [[UISwitch alloc] init];
        switchView.onTintColor = [UIColor systemBlueColor];
        if ([item.key hasPrefix:@"DYYYEnableArea"] &&
            ![item.key isEqualToString:@"DYYYEnableArea"]) {
            BOOL parentEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableArea"];
            switchView.enabled = parentEnabled;
            BOOL isOn = parentEnabled ? [[NSUserDefaults standardUserDefaults] boolForKey:item.key] : NO;
            [switchView setOn:isOn];
        } else {
            [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:item.key]];
        }
        [switchView applyFuturisticEffects];
        [switchView updateFuturisticEffectsWithState:switchView.isOn animated:NO];
        [switchView addTarget:self action:@selector(animatedSwitchToggled:) forControlEvents:UIControlEventValueChanged];
        switchView.tag = indexPath.section * 1000 + indexPath.row;
        accessoryView = switchView;
    } else if (item.type == DYYYSettingItemTypeTextField) {
        if ([item.key isEqualToString:@"DYYYCustomAlbumImage"]) {
            NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYCustomAlbumImagePath"];
            BOOL fileExists = imagePath && [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
            if (fileExists) {
                UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
                previewButton.frame = CGRectMake(0, 0, 40, 40);
                previewButton.layer.cornerRadius = 8;
                previewButton.clipsToBounds = YES;
                UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
                [previewButton setImage:img forState:UIControlStateNormal];
                [previewButton addTarget:self action:@selector(showImagePickerForCustomAlbum) forControlEvents:UIControlEventTouchUpInside];
                accessoryView = previewButton;
            } else {
                UIButton *chooseButton = [UIButton buttonWithType:UIButtonTypeSystem];
                [chooseButton setTitle:@"閫夋嫨鍥剧墖" forState:UIControlStateNormal];
                [chooseButton addTarget:self action:@selector(showImagePickerForCustomAlbum) forControlEvents:UIControlEventTouchUpInside];
                chooseButton.frame = CGRectMake(0, 0, 80, 30);
                accessoryView = chooseButton;
            }
        } else {
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 160, 30)];
            textField.layer.cornerRadius = 8;
            textField.clipsToBounds = YES;
            textField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
            textField.textColor = [UIColor whiteColor];
            textField.placeholder = item.placeholder;
            textField.textAlignment = NSTextAlignmentRight;
            textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:item.key];
            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingDidEnd];
            textField.tag = indexPath.section * 1000 + indexPath.row;
            accessoryView = textField;
            if ([item.key isEqualToString:@"DYYYAvatarTapText"]) {
                [textField addTarget:self action:@selector(avatarTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            }
        }
    } else if (item.type == DYYYSettingItemTypeSpeedPicker || item.type == DYYYSettingItemTypeColorPicker) {
        if (item.type == DYYYSettingItemTypeSpeedPicker) {
            UITextField *speedField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
            speedField.text = [NSString stringWithFormat:@"%.2f", [[NSUserDefaults standardUserDefaults] floatForKey:@"DYYYDefaultSpeed"]];
            speedField.textColor = [UIColor labelColor];
            speedField.borderStyle = UITextBorderStyleNone;
            speedField.backgroundColor = [UIColor clearColor];
            speedField.textAlignment = NSTextAlignmentRight;
            speedField.enabled = NO;
            speedField.tag = 999;
            accessoryView = speedField;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            colorView.layer.cornerRadius = 15;
            colorView.clipsToBounds = YES;
            colorView.layer.borderWidth = 1.0;
            colorView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor;
            NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYBackgroundColor"];
            UIColor *currentColor = colorData ? [NSKeyedUnarchiver unarchiveObjectWithData:colorData] : [UIColor systemBackgroundColor];
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = colorView.bounds;
            gradientLayer.cornerRadius = 15;
            if ([currentColor isEqual:[UIColor whiteColor]] || [currentColor isEqual:[UIColor systemBackgroundColor]]) {
                gradientLayer.colors = @[
                    (id)[UIColor systemRedColor].CGColor,
                    (id)[UIColor systemOrangeColor].CGColor,
                    (id)[UIColor systemYellowColor].CGColor,
                    (id)[UIColor systemGreenColor].CGColor,
                    (id)[UIColor systemBlueColor].CGColor,
                    (id)[UIColor systemPurpleColor].CGColor
                ];
                gradientLayer.startPoint = CGPointMake(0, 0);
                gradientLayer.endPoint = CGPointMake(1, 1);
            } else {
                gradientLayer.colors = @[
                    (id)[currentColor colorWithAlphaComponent:0.7].CGColor,
                    (id)currentColor.CGColor,
                    (id)[currentColor colorWithAlphaComponent:0.9].CGColor
                ];
                gradientLayer.startPoint = CGPointMake(0, 0);
                gradientLayer.endPoint = CGPointMake(1, 1);
            }
            [colorView.layer insertSublayer:gradientLayer atIndex:0];
            accessoryView = colorView;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    if (accessoryView) {
        cell.accessoryView = accessoryView;
    }
    return cell;
}

// 娣诲姞鍥炬爣鎸夐挳鐐瑰嚮澶勭悊鏂规硶
- (void)iconButtonTapped:(UIButton *)sender {
    NSInteger tag = sender.tag;
    NSInteger section = tag / 1000;
    NSInteger row = tag % 1000;
    
    NSArray<NSArray<DYYYSettingItem *> *> *sections = self.isSearching ? self.filteredSections : self.settingSections;
    if (section >= sections.count || row >= sections[section].count) {
        return;
    }
    
    DYYYSettingItem *item = sections[section][row];
    
    NSString *saveFilename = nil;
    if ([item.key isEqualToString:@"DYYYIconLikeBefore"]) {
        saveFilename = @"like_before.png";
    } else if ([item.key isEqualToString:@"DYYYIconLikeAfter"]) {
        saveFilename = @"like_after.png";
    } else if ([item.key isEqualToString:@"DYYYIconComment"]) {
        saveFilename = @"comment.png";
    } else if ([item.key isEqualToString:@"DYYYIconUnfavorite"]) {
        saveFilename = @"unfavorite.png";
    } else if ([item.key isEqualToString:@"DYYYIconFavorite"]) {
        saveFilename = @"favorite.png";
    } else if ([item.key isEqualToString:@"DYYYIconShare"]) {
        saveFilename = @"share.png";
    }
    
    if (saveFilename) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *dyyyFolderPath = [documentsPath stringByAppendingPathComponent:@"DYYY"];
        NSString *imagePath = [dyyyFolderPath stringByAppendingPathComponent:saveFilename];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
        UIImage *previewImage = fileExists ? [UIImage imageWithContentsOfFile:imagePath] : nil;
        
        // 鏄剧ず鍥炬爣閫夋嫨寮圭獥
        [self showIconOptionsDialogWithTitle:item.title previewImage:previewImage saveFilename:saveFilename];
    }
}

// 娣诲姞鐑洿鏂板姛鑳藉疄鐜版柟娉?
- (void)saveCurrentABTestData {
    NSDictionary *currentData = getCurrentABTestData();
    if (!currentData) {
        [DYYYManager showToast:@"鑾峰彇ABTest鏁版嵁澶辫触"];
        return;
    }
    
    // 淇濆瓨鍒版枃妗ｇ洰褰?
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dyyyFolderPath = [documentsPath stringByAppendingPathComponent:@"DYYY"];
    NSString *configPath = [dyyyFolderPath stringByAppendingPathComponent:@"abtest_config.json"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:currentData options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        [DYYYManager showToast:@"搴忓垪鍖栨暟鎹け璐?];
        return;
    }
    
    // 纭繚鐩綍瀛樺湪
    [[NSFileManager defaultManager] createDirectoryAtPath:dyyyFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    if ([jsonData writeToFile:configPath atomically:YES]) {
        [DYYYManager showToast:@"ABTest閰嶇疆宸蹭繚瀛?];
    } else {
        [DYYYManager showToast:@"淇濆瓨澶辫触"];
    }
}

- (void)loadABTestConfigFile {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.json"] inMode:UIDocumentPickerModeImport];
    picker.delegate = self.restorePickerDelegate;
    picker.allowsMultipleSelection = NO;
    
    self.restorePickerDelegate.completionBlock = ^(NSURL *url) {
        [self processABTestConfigFile:url];
    };
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)processABTestConfigFile:(NSURL *)url {
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (error) {
        [DYYYManager showToast:@"璇诲彇鏂囦欢澶辫触"];
        return;
    }
    
    NSDictionary *configData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        [DYYYManager showToast:@"瑙ｆ瀽JSON澶辫触"];
        return;
    }
    
    // 搴旂敤ABTest閰嶇疆
    Class AWEABTestManagerClass = NSClassFromString(@"AWEABTestManager");
    if (AWEABTestManagerClass) {
        id manager = [AWEABTestManagerClass performSelector:@selector(sharedManager)];
        if ([manager respondsToSelector:@selector(setAbTestData:)]) {
            [manager performSelector:@selector(setAbTestData:) withObject:configData];
            [DYYYManager showToast:@"ABTest閰嶇疆宸插簲鐢?];
        }
    }
}

- (void)deleteABTestConfigFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dyyyFolderPath = [documentsDirectory stringByAppendingPathComponent:@"DYYY"];
    NSString *jsonFilePath = [dyyyFolderPath stringByAppendingPathComponent:@"abtest_data_fixed.json"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:jsonFilePath]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:jsonFilePath error:&error];
        
        if (!error) {
            gFileExists = NO;
            gFixedABTestData = nil;
            gDataLoaded = NO;
            [DYYYManager showToast:@"ABTest閰嶇疆鏂囦欢宸插垹闄?];
        } else {
            [DYYYManager showToast:[NSString stringWithFormat:@"鍒犻櫎閰嶇疆鏂囦欢澶辫触: %@", error.localizedDescription]];
        }
    } else {
        [DYYYManager showToast:@"娌℃湁鎵惧埌ABTest閰嶇疆鏂囦欢"];
    }
}

// 鏍规嵁璁剧疆椤硅繑鍥炲浘鏍囧悕绉?
- (UIImage *)iconImageForSettingItem:(DYYYSettingItem *)item {
    NSString *iconName;
    
    // 涓烘柊澧炲姛鑳芥坊鍔犲浘鏍?
    if ([item.key isEqualToString:@"DYYYEnableVideoHighestQuality"]) {
        iconName = @"4k.tv.fill";
    } else if ([item.key isEqualToString:@"DYYYEnableNoiseFilter"]) {
        iconName = @"waveform.path.ecg";
    } else if ([item.key isEqualToString:@"DYYYEnableAutoPlay"]) {
        iconName = @"play.circle.fill";
    } else if ([item.key isEqualToString:@"DYYYisEnableModern"]) {
        iconName = @"rectangle.3.group.fill";
    } else if ([item.key isEqualToString:@"DYYYEnableSaveAvatar"]) {
        iconName = @"person.crop.circle.badge.plus";
    } else if ([item.key containsString:@"Comment"] && [item.key containsString:@"NotWaterMark"]) {
        iconName = @"bubble.left.and.bubble.right.fill";
    } else if ([item.key isEqualToString:@"DYYYFourceDownloadEmotion"]) {
        iconName = @"face.smiling.inverse";
    } 
    // 涓哄僵鑹插彇鑹插櫒娣诲姞鐗规畩澶勭悊
    else if ([item.key isEqualToString:@"DYYYBackgroundColor"]) {
        iconName = @"paintpalette.fill";
    } 
    // 涓轰晶鏍忕畝鍖栧姛鑳芥坊鍔犵壒娈婂鐞?
    else if ([item.key isEqualToString:@"DYYYStreamlinethesidebar"]) {
        iconName = @"sidebar.left";
    }
    // 涓烘繁鑹查敭鐩樺姛鑳芥坊鍔犵壒娈婂鐞?
    else if ([item.key isEqualToString:@"DYYYisDarkKeyBoard"]) {
        iconName = @"keyboard";
    }
    // 鍏朵粬鏍规嵁璁剧疆椤圭殑key閫夋嫨鍚堥€傜殑鍥炬爣...
    else if ([item.key containsString:@"Danmu"] || [item.key containsString:@"寮瑰箷"]) {
        iconName = @"text.bubble.fill";
    } else if ([item.key containsString:@"Color"] || [item.key containsString:@"棰滆壊"]) {
        iconName = @"paintbrush.fill";
    } else if ([item.key containsString:@"Hide"] || [item.key containsString:@"hidden"]) {
        iconName = @"eye.slash.fill";
    } else if ([item.key containsString:@"Download"] || [item.key containsString:@"涓嬭浇"]) {
        iconName = @"arrow.down.circle.fill";
    } else if ([item.key containsString:@"Video"] || [item.key containsString:@"瑙嗛"]) {
        iconName = @"video.fill";
    } else if ([item.key containsString:@"Audio"] || [item.key containsString:@"闊抽"]) {
        iconName = @"speaker.wave.2.fill";
    } else if ([item.key containsString:@"Image"] || [item.key containsString:@"鍥剧墖"]) {
        iconName = @"photo.fill";
    } else if ([item.key containsString:@"Speed"] || [item.key containsString:@"鍊嶉€?]) {
        iconName = @"speedometer";
    } else if ([item.key containsString:@"Enable"] || [item.key containsString:@"鍚敤"]) {
        iconName = @"checkmark.circle.fill";
    } else if ([item.key containsString:@"Disable"] || [item.key containsString:@"绂佺敤"]) {
        iconName = @"xmark.circle.fill";
    } else if ([item.key containsString:@"Time"] || [item.key containsString:@"鏃堕棿"]) {
        iconName = @"clock.fill";
    } else if ([item.key containsString:@"Date"] || [item.key containsString:@"鏃ユ湡"]) {
        iconName = @"calendar";
    } else if ([item.key containsString:@"Button"] || [item.key containsString:@"鎸夐挳"]) {
        iconName = @"hand.tap.fill";
    } else if ([item.key containsString:@"Avatar"] || [item.key containsString:@"澶村儚"]) {
        iconName = @"person.crop.circle.fill";
    } else if ([item.key containsString:@"Comment"] || [item.key containsString:@"璇勮"]) {
        iconName = @"message.fill";
    } else if ([item.key containsString:@"Clean"] || [item.key containsString:@"娓呯悊"] || [item.key containsString:@"娓呭睆"]) {
        iconName = @"trash.fill";
    } else if ([item.key containsString:@"Share"] || [item.key containsString:@"鍒嗕韩"]) {
        iconName = @"square.and.arrow.up.fill";
    } else if ([item.key containsString:@"Background"] || [item.key containsString:@"鑳屾櫙"]) {
        iconName = @"rectangle.fill.on.rectangle.fill";
    } else if ([item.key containsString:@"Like"] || [item.key containsString:@"鐐硅禐"]) {
        iconName = @"heart.fill";
    } else if ([item.key containsString:@"Notification"] || [item.key containsString:@"閫氱煡"]) {
        iconName = @"bell.fill";
    } else if ([item.key containsString:@"Copy"] || [item.key containsString:@"澶嶅埗"]) {
        iconName = @"doc.on.doc.fill";
    } else if ([item.key containsString:@"Emotion"] || [item.key containsString:@"琛ㄦ儏"]) {
        iconName = @"face.smiling.fill";
    } else if ([item.key containsString:@"Text"] || [item.key containsString:@"鏂囨湰"]) {
        iconName = @"text.alignleft";
    } else if ([item.key containsString:@"Location"] || [item.key containsString:@"浣嶇疆"] || [item.key containsString:@"灞炲湴"]) {
        iconName = @"location.fill";
    } else if ([item.key containsString:@"Area"] || [item.key containsString:@"鍦板尯"]) {
        iconName = @"mappin.and.ellipse";
    } else if ([item.key containsString:@"Layout"] || [item.key containsString:@"甯冨眬"]) {
        iconName = @"square.grid.2x2.fill";
    } else if ([item.key containsString:@"Transparent"] || [item.key containsString:@"閫忔槑"]) {
        iconName = @"square.on.circle.fill";
    } else if ([item.key containsString:@"Live"] || [item.key containsString:@"鐩存挱"]) {
        iconName = @"antenna.radiowaves.left.and.right";
    } else if ([item.key containsString:@"Double"] || [item.key containsString:@"鍙屽嚮"]) {
        iconName = @"hand.tap.fill";
    } else if ([item.key containsString:@"Long"] || [item.key containsString:@"闀挎寜"]) {
        iconName = @"hand.draw.fill";
    } else if ([item.key containsString:@"ScreenDisplay"] || [item.key containsString:@"鍏ㄥ睆"]) {
        iconName = @"rectangle.expand.vertical";
    } else if ([item.key containsString:@"Index"] || [item.key containsString:@"棣栭〉"]) {
        iconName = @"house.fill";
    } else if ([item.key containsString:@"Friends"] || [item.key containsString:@"鏈嬪弸"]) {
        iconName = @"person.2.fill";
    } else if ([item.key containsString:@"Msg"] || [item.key containsString:@"娑堟伅"]) {
        iconName = @"envelope.fill";
    } else if ([item.key containsString:@"Self"] || [item.key containsString:@"鎴戠殑"]) {
        iconName = @"person.crop.square.fill";
    } else if ([item.key containsString:@"NoAds"] || [item.key containsString:@"骞垮憡"]) {
        iconName = @"xmark.octagon.fill";
    } else if ([item.key containsString:@"NoUpdates"] || [item.key containsString:@"鏇存柊"]) {
        iconName = @"arrow.triangle.2.circlepath";
    } else if ([item.key containsString:@"InterfaceDownload"] || [item.key containsString:@"鎺ュ彛"]) {
        iconName = @"link.circle.fill";
    } else if ([item.key containsString:@"Scale"] || [item.key containsString:@"缂╂斁"]) {
        iconName = @"arrow.up.left.and.down.right.magnifyingglass";
    } else if ([item.key containsString:@"Blur"] || [item.key containsString:@"妯＄硦"] || [item.key containsString:@"鐜荤拑"]) {
        iconName = @"drop.fill";
    } else if ([item.key containsString:@"Shop"] || [item.key containsString:@"鍟嗗煄"]) {
        iconName = @"cart.fill";
    } else if ([item.key containsString:@"Tips"] || [item.key containsString:@"鎻愮ず"]) {
        iconName = @"exclamationmark.bubble.fill";
    } else if ([item.key containsString:@"Format"] || [item.key containsString:@"鏍煎紡"]) {
        iconName = @"textformat";
    } else if ([item.key containsString:@"Filter"] || [item.key containsString:@"杩囨护"]) {
        iconName = @"line.horizontal.3.decrease.circle.fill";
    } else {
        // 榛樿鍥炬爣
        iconName = @"gearshape.fill";
    }
    
    UIImage *icon = [UIImage systemImageNamed:iconName];
    if (@available(iOS 15.0, *)) {
        // 涓洪鑹茶儗鏅壒娈婂鐞?
        if ([item.key isEqualToString:@"DYYYBackgroundColor"]) {
            return [icon imageWithConfiguration:[UIImageSymbolConfiguration configurationWithHierarchicalColor:[UIColor systemPinkColor]]];
        }
        return [icon imageWithConfiguration:[UIImageSymbolConfiguration configurationWithHierarchicalColor:[self colorForSettingItem:item]]];
    } else {
        return icon;
    }
}

// 鏍规嵁璁剧疆椤硅繑鍥為鑹?
- (UIColor *)colorForSettingItem:(DYYYSettingItem *)item {
    // 涓哄彇鑹插櫒鍜岀壒瀹氬姛鑳借缃壒娈婇鑹?
    if ([item.key isEqualToString:@"DYYYBackgroundColor"]) {
        return [UIColor systemPinkColor];
    } else if ([item.key isEqualToString:@"DYYYStreamlinethesidebar"]) {
        return [UIColor systemIndigoColor];
    } else if ([item.key isEqualToString:@"DYYYisDarkKeyBoard"]) {
        return [UIColor systemGrayColor];
    }
    
    // 鏍规嵁璁剧疆椤圭被鍨嬭繑鍥炰笉鍚岄鑹?
    if ([item.key containsString:@"Hide"] || [item.key containsString:@"hidden"]) {
        return [UIColor systemRedColor];
    } else if ([item.key containsString:@"Enable"] || [item.key containsString:@"鍚敤"]) {
        return [UIColor systemGreenColor];
    } else if ([item.key containsString:@"Color"] || [item.key containsString:@"棰滆壊"]) {
        return [UIColor systemPurpleColor];
    } else if ([item.key containsString:@"Copy"] || [item.key containsString:@"澶嶅埗"]) {
        return [UIColor systemTealColor];
    } else if ([item.key containsString:@"Emotion"] || [item.key containsString:@"琛ㄦ儏"]) {
        return [UIColor systemYellowColor];
    } else if ([item.key containsString:@"Double"] || [item.key containsString:@"鍙屽嚮"]) {
        return [UIColor systemOrangeColor];
    } else if ([item.key containsString:@"Download"] || [item.key containsString:@"涓嬭浇"]) {
        return [UIColor systemBlueColor];
    } else if ([item.key containsString:@"Video"] || [item.key containsString:@"瑙嗛"]) {
        return [UIColor systemIndigoColor];
    } else if ([item.key containsString:@"Audio"] || [item.key containsString:@"闊抽"]) {
        return [UIColor systemTealColor];
    } else if ([item.key containsString:@"Speed"] || [item.key containsString:@"鍊嶉€?]) {
        return [UIColor systemYellowColor];
    } else if ([item.key containsString:@"Time"] || [item.key containsString:@"鏃堕棿"]) {
        return [UIColor systemOrangeColor];
    }
    
    // 榛樿棰滆壊
    return [UIColor systemBlueColor];
}

// 寰蒋椋庢牸UISwitch鍔ㄧ敾锛岃仈鍔ㄥ崱鐗?
- (void)animatedSwitchToggled:(UISwitch *)sender {
    [sender applyFuturisticEffects];
    [sender updateFuturisticEffectsWithState:sender.isOn animated:YES];
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    UIView *card = [cell.contentView viewWithTag:8888];
    // 鍗＄墖鍜宻witch鑱斿姩寮硅烦+楂樺厜
    [UIView animateWithDuration:0.10 animations:^{
        sender.transform = CGAffineTransformMakeScale(0.90, 0.90);
        sender.alpha = 0.7;
        sender.layer.shadowColor = [UIColor systemBlueColor].CGColor;
        sender.layer.shadowOpacity = 0.18;
        sender.layer.shadowRadius = 8;
        sender.layer.shadowOffset = CGSizeMake(0, 2);
        card.transform = CGAffineTransformMakeScale(0.97, 0.97);
               card.layer.shadowOpacity =0.18;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.22 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.7 options:0 animations:^{
            sender.transform = CGAffineTransformIdentity;
            sender.alpha = 1.0;
            sender.layer.shadowOpacity = 0.0;
            card.transform = CGAffineTransformIdentity;
            card.layer.shadowOpacity = 0.06;
        } completion:nil];
    }];
    [self switchToggled:sender];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cornerRadius = 10.0;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds
                                                  byRoundingCorners:(indexPath.row == 0 ? (UIRectCornerTopLeft | UIRectCornerTopRight) : 0) |
                                                                   (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1 ? (UIRectCornerBottomLeft | UIRectCornerBottomRight) : 0)
                                                        cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    cell.layer.mask = maskLayer;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<NSArray<DYYYSettingItem *> *> *sections = self.isSearching ? self.filteredSections : self.settingSections;
    if (indexPath.section >= sections.count || indexPath.row >= sections[indexPath.section].count) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    DYYYSettingItem *item = sections[indexPath.section][indexPath.row];
    
    // 娣诲姞娓呯悊缂撳瓨鍔熻兘澶勭悊
    if ([item.key isEqualToString:@"DYYYCleanCache"]) {
        [self handleCleanCache];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    // 娣诲姞娓呴櫎璁剧疆鍔熻兘
    if ([item.key isEqualToString:@"DYYYCleanSettings"]) {
        [DYYYBottomAlertView showAlertWithTitle:@"娓呴櫎鎶栭煶璁剧疆"
                message:@"纭畾瑕佹竻闄ゆ姈闊虫墍鏈夎缃悧锛焅n杩欏皢鏃犳硶鎭㈠锛屽簲鐢ㄤ細鑷姩閫€鍑猴紒"
                cancelButtonText:@"鍙栨秷"
                confirmButtonText:@"纭畾"
                cancelAction:nil
                confirmAction:^{
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                    if (paths.count > 0) {
                        NSString *preferencesPath = [paths.firstObject stringByAppendingPathComponent:@"Preferences"];
                        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                        NSString *plistPath = [preferencesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", bundleIdentifier]];

                        NSError *error = nil;
                        [[NSFileManager defaultManager] removeItemAtPath:plistPath error:&error];

                        if (!error) {
                            [DYYYManager showToast:@"鎶栭煶璁剧疆宸叉竻闄わ紝搴旂敤鍗冲皢閫€鍑?];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                              exit(0);
                            });
                        } else {
                            [DYYYManager showToast:[NSString stringWithFormat:@"娓呴櫎澶辫触: %@", error.localizedDescription]];
                        }
                    }
                }];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    // 娣诲姞澶囦唤璁剧疆鍔熻兘澶勭悊
    if ([item.key isEqualToString:@"DYYYBackupSettings"]) {
        [self backupSettings];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    // 娣诲姞鎭㈠璁剧疆鍔熻兘澶勭悊
    if ([item.key isEqualToString:@"DYYYRestoreSettings"]) {
        [self restoreSettings];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    // 澶勭悊鍥炬爣鑷畾涔夐」
    if ([item.key hasPrefix:@"DYYYIcon"]) {
        [self handleIconSelection:item];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    // 鐑洿鏂板姛鑳藉鐞?
    if ([item.key isEqualToString:@"SaveCurrentABTestData"]) {
        [self saveCurrentABTestData];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    } else if ([item.key isEqualToString:@"LoadABTestConfigFile"]) {
        [self loadABTestConfigFile];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    } else if ([item.key isEqualToString:@"DeleteABTestConfigFile"]) {
        [self deleteABTestConfigFile];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if (item.type == DYYYSettingItemTypeCustomPicker && [item.key isEqualToString:@"DYYYScheduleStyle"]) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYShowScheduleDisplay"]) {
            [DYYYManager showToast:@"璇峰厛寮€鍚痋"鏄剧ず杩涘害鏃堕暱\"閫夐」"];
            return;
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"閫夋嫨杩涘害鏉℃牱寮?
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        NSArray *styles = @[
            @{@"title": @"杩涘害鏉″彸渚у墿浣?, @"value": @"杩涘害鏉″彸渚у墿浣?},
            @{@"title": @"杩涘害鏉″彸渚у畬鏁?, @"value": @"杩涘害鏉″彸渚у畬鏁?},
            @{@"title": @"杩涘害鏉″乏渚у墿浣?, @"value": @"杩涘害鏉″乏渚у墿浣?},
            @{@"title": @"杩涘害鏉″乏渚у畬鏁?, @"value": @"杩涘害鏉″乏渚у畬鏁?},
            @{@"title": @"杩涘害鏉′袱渚у乏鍙?, @"value": @"杩涘害鏉′袱渚у乏鍙?}
        ];
        for (NSDictionary *style in styles) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:style[@"title"]
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                [[NSUserDefaults standardUserDefaults] setObject:style[@"value"] forKey:@"DYYYScheduleStyle"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.tableView reloadData];
            }];
            [alert addAction:action];
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"鍙栨秷" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
            alert.popoverPresentationController.sourceView = selectedCell;
            alert.popoverPresentationController.sourceRect = selectedCell.bounds;
        }
        [self presentViewController:alert animated:YES completion:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if (item.type == DYYYSettingItemTypeSpeedPicker) {
        [self showSpeedPicker];
    } else if (item.type == DYYYSettingItemTypeColorPicker) {
        [self showColorPicker];
    } else if ([item.key isEqualToString:@"DYYYFilterKeywords"]) {
        // 鑾峰彇褰撳墠宸蹭繚瀛樼殑鍏抽敭璇?
        NSString *currentKeywords = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYFilterKeywords"];
        
        // 鍒涘缓骞舵樉绀鸿繃婊よ缃鍥?
        DYYYFilterSettingsView *filterView = [[DYYYFilterSettingsView alloc] initWithTitle:@"璁剧疆杩囨护鍏抽敭璇? text:currentKeywords];
        [filterView showWithConfirmBlock:^(NSString *selectedText) {
            [[NSUserDefaults standardUserDefaults] setObject:selectedText forKey:@"DYYYFilterKeywords"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.tableView reloadData];
        } cancelBlock:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)handleIconSelection:(DYYYSettingItem *)item {
    NSString *saveFilename = nil;
    
    // 鏄犲皠鍥炬爣绫诲瀷鍒版枃浠跺悕
    if ([item.key isEqualToString:@"DYYYIconLikeBefore"]) {
        saveFilename = @"like_before.png";
    } else if ([item.key isEqualToString:@"DYYYIconLikeAfter"]) {
        saveFilename = @"like_after.png";
    } else if ([item.key isEqualToString:@"DYYYIconComment"]) {
        saveFilename = @"comment.png";
    } else if ([item.key isEqualToString:@"DYYYIconUnfavorite"]) {
        saveFilename = @"unfavorite.png";
    } else if ([item.key isEqualToString:@"DYYYIconFavorite"]) {
        saveFilename = @"favorite.png";
    } else if ([item.key isEqualToString:@"DYYYIconShare"]) {
        saveFilename = @"share.png";
    }
    
    if (saveFilename) {
        // 鑾峰彇鍥炬爣璺緞
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *dyyyFolderPath = [documentsPath stringByAppendingPathComponent:@"DYYY"];
        NSString *imagePath = [dyyyFolderPath stringByAppendingPathComponent:saveFilename];
        
        // 妫€鏌ユ槸鍚﹀凡鏈夎嚜瀹氫箟鍥炬爣
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
        UIImage *previewImage = fileExists ? [UIImage imageWithContentsOfFile:imagePath] : nil;
        
        // 鏄剧ず鍥炬爣閫夐」瀵硅瘽妗?
        [self showIconOptionsDialogWithTitle:item.title previewImage:previewImage saveFilename:saveFilename];
    }
}

// 娣诲姞杩欎釜杈呭姪鏂规硶
- (void)showIconOptionsDialogWithTitle:(NSString *)title previewImage:(UIImage *)previewImage saveFilename:(NSString *)saveFilename {
    DYYYIconOptionsDialogView *optionsDialog = [[DYYYIconOptionsDialogView alloc] initWithTitle:title previewImage:previewImage];
    
    // 纭繚DYYY鏂囦欢澶瑰瓨鍦?
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dyyyFolderPath = [documentsPath stringByAppendingPathComponent:@"DYYY"];
    NSString *imagePath = [dyyyFolderPath stringByAppendingPathComponent:saveFilename];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dyyyFolderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dyyyFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    __weak typeof(self) weakSelf = self;
    
    // 璁剧疆娓呴櫎鎸夐挳鍥炶皟
    optionsDialog.onClear = ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error];
            if (!error) {
                [DYYYManager showToast:@"宸叉仮澶嶉粯璁ゅ浘鏍?];
                [weakSelf.tableView reloadData];
            }
        }
    };
    
    // 璁剧疆閫夋嫨鎸夐挳鍥炶皟
    optionsDialog.onSelect = ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = NO;
        picker.mediaTypes = @[@"public.image"];
        DYYYImagePickerDelegate *pickerDelegate = [[DYYYImagePickerDelegate alloc] init];
        pickerDelegate.completionBlock = ^(NSDictionary *info) {
            NSURL *imageURL = info[UIImagePickerControllerImageURL];
            if (!imageURL) {
                imageURL = info[UIImagePickerControllerReferenceURL];
            }
            
            if (imageURL) {
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                if (imageData) {
                    // 妫€娴嬫槸鍚︿负GIF
                    const char *bytes = (const char *)imageData.bytes;
                    BOOL isGIF = (imageData.length >= 6 && (memcmp(bytes, "GIF87a", 6) == 0 || memcmp(bytes, "GIF89a", 6) == 0));
                    
                    if (isGIF) {
                        [imageData writeToFile:imagePath atomically:YES];
                    } else {
                        UIImage *selectedImage = [UIImage imageWithData:imageData];
                        NSData *pngData = UIImagePNGRepresentation(selectedImage);
                        [pngData writeToFile:imagePath atomically:YES];
                    }
                    
                    [DYYYManager showToast:@"鍥炬爣宸茶缃紝閲嶅惎搴旂敤鐢熸晥"];
                    [weakSelf.tableView reloadData];
                }
            }
        };
        
        static char kDYYYPickerDelegateKey;
        picker.delegate = pickerDelegate;
        objc_setAssociatedObject(picker, &kDYYYPickerDelegateKey, pickerDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [weakSelf presentViewController:picker animated:YES completion:nil];
    };
    
    [optionsDialog show];
}

- (void)showSpeedPicker {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"閫夋嫨鍊嶉€?
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *speeds = @[@0.75, @1.0, @1.25, @1.5, @2.0, @2.5, @3.0];
    for (NSNumber *speed in speeds) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%.2f", speed.floatValue]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults] setFloat:speed.floatValue forKey:@"DYYYDefaultSpeed"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            for (NSInteger section = 0; section < self.settingSections.count; section++) {
                NSArray *items = self.settingSections[section];
                for (NSInteger row = 0; row < items.count; row++) {
                    DYYYSettingItem *item = items[row];
                    if (item.type == DYYYSettingItemTypeSpeedPicker) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                        UITextField *speedField = [cell.accessoryView viewWithTag:999];
                        if (speedField) {
                            speedField.text = [NSString stringWithFormat:@"%.2f", speed.floatValue];
                        }
                        break;
                    }
                }
            }
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"鍙栨秷" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        alert.popoverPresentationController.sourceView = selectedCell;
        alert.popoverPresentationController.sourceRect = selectedCell.bounds;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Actions

- (void)switchToggled:(UISwitch *)sender {
    // 娣诲姞闃插穿婧冩鏌?
    if (!sender) {
        return;
    }
    
    NSInteger section = sender.tag / 1000;
    NSInteger row = sender.tag % 1000;

    NSArray *sections = self.isSearching ? self.filteredSections : self.settingSections;
    if (!sections || section < 0 || section >= sections.count) {
        return;
    }

    NSArray *currentSection = sections[section];
    if (!currentSection || row < 0 || row >= currentSection.count) {
        return;
    }

    DYYYSettingItem *item = currentSection[row];
    if (!item) {
        return;
    }

    // 浣跨敤寮€鍏崇鐞嗗櫒澶勭悊鍒囨崲閫昏緫
    [[DYYYSwitchManager sharedManager] handleSwitchToggled:sender 
                                                  withItem:item 
                                                   section:section 
                                                       row:row
                                                 tableView:self.tableView
                                          settingSections:self.settingSections];

    // 瑙﹁鍙嶉
    [self.feedbackGenerator impactOccurred];

    // 杩涘害鏃堕暱渚濊禆澶勭悊
    if ([item.key isEqualToString:@"DYYYShowScheduleDisplay"]) {
        // 鍏抽棴鏃讹紝娓呯┖鏍峰紡璁剧疆
        if (!sender.isOn) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYScheduleStyle"];
        }
        // 鍒锋柊鐩稿叧cell
        for (NSInteger s = 0; s < self.settingSections.count; s++) {
            NSArray *items = self.settingSections[s];
            for (NSInteger r = 0; r < items.count; r++) {
                DYYYSettingItem *subItem = items[r];
                if ([subItem.key isEqualToString:@"DYYYScheduleStyle"]) {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:r inSection:s];
                    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }
    }

    // 瀹夊叏鍦板悓姝ヨ缃?
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

- (void)updateClearButtonSubSwitchesUI:(NSInteger)section enabled:(BOOL)enabled {
    NSArray<NSString *> *subKeys = @[
        @"DYYYHideDanmaku",
        @"DYYYEnabshijianjindu", 
        @"DYYYHideTimeProgress",
        @"DYYYHideSlider",
        @"DYYYHideTabBar",
        @"DYYYHideSpeed"
    ];
    
    // 浣跨敤 DYYYSwitchManager 鐨勬柟娉?
    [[DYYYSwitchManager sharedManager] updateSubSwitchesInSection:section 
                                                         withKeys:subKeys 
                                                          enabled:enabled 
                                                        tableView:self.tableView 
                                                 settingSections:self.settingSections];
}

- (void)updateLongPressSubSwitchesUI:(NSInteger)section enabled:(BOOL)enabled {
    NSArray<NSString *> *subKeys = @[
        @"DYYYLongPressSaveVideo",
        @"DYYYLongPressSaveAudio",
        @"DYYYEnableFLEX",
        @"DYYYLongPressSaveCurrentImage",
        @"DYYYLongPressSaveAllImages",
        @"DYYYLongPressCopyLink",
        @"DYYYLongPressApiDownload",
        @"DYYYLongPressFilterUser",
        @"DYYYLongPressFilterTitle",
        @"DYYYLongPressTimerClose",
        @"DYYYLongPressCreateVideo"
    ];
    
    // 浣跨敤 DYYYSwitchManager 鐨勬柟娉?
    [[DYYYSwitchManager sharedManager] updateSubSwitchesInSection:section 
                                                         withKeys:subKeys 
                                                          enabled:enabled 
                                                        tableView:self.tableView 
                                                 settingSections:self.settingSections];
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:textField.tag % 1000 inSection:textField.tag / 1000];
    NSArray<NSArray<DYYYSettingItem *> *> *sections = self.isSearching ? self.filteredSections : self.settingSections;
    if (indexPath.section >= sections.count || indexPath.row >= sections[indexPath.section].count) {
        return;
    }
    
    DYYYSettingItem *item = sections[indexPath.section][indexPath.row];
    
    // 娣诲姞瀵归摼鎺ヨВ鏋愭帴鍙ｇ殑鐗规畩澶勭悊
    if ([item.key isEqualToString:@"DYYYInterfaceDownload"]) {
        NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (text.length == 0) {
            textField.text = @"https://api.qsy.ink/api/douyin?key=DYYY&url=";
            [[NSUserDefaults standardUserDefaults] setObject:@"https://api.qsy.ink/api/douyin?key=DYYY&url=" forKey:item.key];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:item.key];
        }
    } 
    // 鍊嶉€熸暟鍊艰缃殑鐗规畩澶勭悊
    else if ([item.key isEqualToString:@"DYYYSpeedSettings"]) {
        NSString *speedConfig = textField.text;
        if (speedConfig.length == 0) {
            speedConfig = @"1.0,1.25,1.5,2.0";
            textField.text = speedConfig;
        }
        [[NSUserDefaults standardUserDefaults] setObject:speedConfig forKey:item.key];
        [DYYYManager showToast:@"鍊嶉€熼€夐」宸叉洿鏂?];
    }
    // 鍊嶉€熸寜閽ぇ灏忕殑鐗规畩澶勭悊
    else if ([item.key isEqualToString:@"DYYYSpeedButtonSize"]) {
        NSString *sizeStr = textField.text;
        if (sizeStr.length == 0 || [sizeStr floatValue] <= 0) {
            sizeStr = @"40";
            textField.text = sizeStr;
        }
        [[NSUserDefaults standardUserDefaults] setObject:sizeStr forKey:item.key];
        [DYYYManager showToast:@"鍊嶉€熸寜閽ぇ灏忓凡鏇存柊"];
    } 
    else {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:item.key];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 鍦ㄨ缃€间繚瀛樺悗娣诲姞锛?
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYSettingChanged" object:nil userInfo:@{
        @"key": item.key,
        @"value": textField.text ?: [NSNull null]
    }];
    
    // 澶勭悊鐗规畩閿?
    if ([item.key isEqualToString:@"DYYYCustomAlbumImage"]) {
        [self showImagePickerForCustomAlbum];
    }
}

- (void)avatarTextFieldDidChange:(UITextField *)textField {
    self.avatarTapLabel.text = textField.text.length > 0 ? textField.text : @"pxx917144686";
}

- (void)headerTapped:(UIButton *)sender {
    // 瑙﹀彂瑙﹁鍙嶉
    [self.feedbackGenerator impactOccurred];
    [self.feedbackGenerator prepare];
    
    NSInteger section = sender.tag;
    NSArray<NSArray<DYYYSettingItem *> *> *sections = self.isSearching ? self.filteredSections : self.settingSections;
    if (section >= sections.count) {
        return;
    }
    
    BOOL isCurrentExpanded = [self.expandedSections containsObject:@(section)];
    
    // 鑾峰彇鎵€鏈夐渶瑕佹洿鏂扮殑琛屼俊鎭?- 鍦ㄤ慨鏀筫xpandedSections涔嬪墠
    NSMutableArray<NSIndexPath *> *allRowsToUpdate = [NSMutableArray array];
    NSMutableArray<NSNumber *> *sectionsToUpdate = [NSMutableArray array];
    
    // 鏀堕泦褰撳墠瑕佺偣鍑荤殑section鐨勬墍鏈夎
    NSArray<NSIndexPath *> *currentSectionRows = [self rowsForSection:section];
    [allRowsToUpdate addObjectsFromArray:currentSectionRows];
    [sectionsToUpdate addObject:@(section)];
    
    // 濡傛灉褰撳墠section涓嶆槸灞曞紑鐨勶紝闇€瑕佹敹闆嗗叾浠栧凡灞曞紑section鐨勬墍鏈夎
    if (!isCurrentExpanded) {
        for (NSNumber *expandedSection in [self.expandedSections copy]) {
            if (![expandedSection isEqualToNumber:@(section)]) {
                NSArray<NSIndexPath *> *expandedSectionRows = [self rowsForSection:[expandedSection integerValue]];
                [allRowsToUpdate addObjectsFromArray:expandedSectionRows];
                [sectionsToUpdate addObject:expandedSection];
            }
        }
        
        // 娓呯┖宸插睍寮€sections锛屽彧淇濈暀褰撳墠section
        [self.expandedSections removeAllObjects];
        [self.expandedSections addObject:@(section)];
    } else {
        // 褰撳墠section宸插睍寮€锛岄渶瑕佸皢鍏跺叧闂?
        [self.expandedSections removeObject:@(section)];
    }
    
    // 鏇存柊鎵€鏈夋秹鍙婄殑section澶撮儴绠ご
    for (NSNumber *sectionNumber in sectionsToUpdate) {
        NSInteger sectionIndex = [sectionNumber integerValue];
        UIView *headerView = [self.tableView headerViewForSection:sectionIndex];
        UIButton *headerButton = [headerView viewWithTag:sectionIndex];
        UIImageView *arrow = [headerButton viewWithTag:100];
        
        BOOL shouldBeExpanded = [self.expandedSections containsObject:sectionNumber];
        
        if (@available(iOS 13.0, *)) {
            UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:17 weight:UIImageSymbolWeightSemibold];
            arrow.image = [[UIImage systemImageNamed:shouldBeExpanded ? @"chevron.down" : @"chevron.right"] imageWithConfiguration:config];
        } else {
            arrow.image = [UIImage systemImageNamed:shouldBeExpanded ? @"chevron.down" : @"chevron.right"];
        }
        
        // 鍔ㄧ敾杩囨浮鏁堟灉
        [UIView animateWithDuration:0.3 animations:^{
            arrow.transform = shouldBeExpanded ? CGAffineTransformMakeRotation(M_PI/2) : CGAffineTransformIdentity;
        }];
    }
    
    // 绠€鍗曟柟寮忥細鐩存帴鍒锋柊琛ㄦ牸鑰屼笉鏄瘯鍥捐拷韪崟鐙殑琛屾搷浣?
    [self.tableView reloadData];
    
    // 濡傛灉灞曞紑浜嗘煇涓猻ection锛岃琛ㄦ牸瑙嗗浘婊氬姩鍒拌section鐨勪綅缃?
    if (!isCurrentExpanded) {
        NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:0 inSection:section];
        if ([self.tableView numberOfRowsInSection:section] > 0) {
            [self.tableView scrollToRowAtIndexPath:firstRowPath 
                                  atScrollPosition:UITableViewScrollPositionTop 
                                          animated:YES];
        }
    }
}

// 娣诲姞涓绘爣棰樻枃瀛楅棿璺濊皟鏁?
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UIView class]]) {
        UIButton *headerButton = [view viewWithTag:section];
        if ([headerButton isKindOfClass:[UIButton class]]) {
            // 璋冩暣鏍囬鏂囧瓧鐨勫睘鎬?
            UIColor *textColor;
            if (@available(iOS 13.0, *)) {
                textColor = [UIColor labelColor];
            } else {
                textColor = [UIColor darkTextColor];
            }
            
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] 
                                                 initWithString:headerButton.titleLabel.text 
                                                 attributes:@{
                                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:17],
                                                     NSForegroundColorAttributeName: textColor,
                                                     NSKernAttributeName: @(-0.8) // 鍑忓皬瀛楃闂磋窛
                                                 }];
            [headerButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
        }
    }
}

- (NSArray<NSIndexPath *> *)rowsForSection:(NSInteger)section {
    NSArray<NSArray<DYYYSettingItem *> *> *sections = self.isSearching ? self.filteredSections : self.settingSections;
    if (section >= sections.count) {
        return @[];
    }
    NSInteger rowCount = sections[section].count;
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:rowCount];
    for (NSInteger row = 0; row < rowCount; row++) {
        [rows addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    }
    return rows;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        if (!indexPath) {
            return;
        }
        
        NSArray<NSArray<DYYYSettingItem *> *> *sections = self.isSearching ? self.filteredSections : self.settingSections;
        if (indexPath.section >= sections.count || indexPath.row >= sections[indexPath.section].count) {
            return;
        }
        
        DYYYSettingItem *item = sections[indexPath.section][indexPath.row];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"閫夐」"
                                                                      message:item.title
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
        
        if ([item.key isEqualToString:@"DYYYCustomAlbumImage"]) {
            [alert addAction:[UIAlertAction actionWithTitle:@"浠庣浉鍐岄€夋嫨"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary forCustomAlbum:YES];
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"浣跨敤鐩告満"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera forCustomAlbum:YES];
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"鎭㈠榛樿鍥剧墖"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYCustomAlbumImagePath"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [DYYYManager showToast:@"鑷畾涔夌浉鍐屽浘鐗囧凡璁剧疆"];
                [self.tableView reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYCustomAlbumSettingChanged" object:nil];
            }]];
        }
        
        // 榛樿閲嶇疆閫夐」
        UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"閲嶇疆"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:item.key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // 鐗规畩澶勭悊娓呭睆鎸夐挳灏哄閲嶇疆
            if ([item.key isEqualToString:@"DYYYEnableFloatClearButton"] || 
                [item.key isEqualToString:@"DYYYFloatClearButtonSizePreference"]) {
                [[NSUserDefaults standardUserDefaults] setInteger:DYYYButtonSizeMedium 
                                                           forKey:@"DYYYFloatClearButtonSizePreference"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            // 鐗规畩澶勭悊鏃ユ湡鏃堕棿鏍煎紡鐩稿叧璁剧疆
            if ([item.key isEqualToString:@"DYYYShowDateTime"]) {
                // 閲嶇疆涓诲紑鍏充篃閲嶇疆鎵€鏈夊瓙寮€鍏冲拰鏍煎紡璁剧疆
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYDateTimeFormat_YMDHM"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYDateTimeFormat_MDHM"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYDateTimeFormat_HMS"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYDateTimeFormat_HM"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYDateTimeFormat_YMD"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYDateTimeFormat"];
                
                // 浣跨敤 DYYYSwitchManager 鐨勬柟娉曟洿鏂癠I涓瓙寮€鍏崇殑鐘舵€?
                for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
                    [[DYYYSwitchManager sharedManager] updateDateTimeFormatSubSwitchesUI:section 
                                                                                 enabled:NO 
                                                                               tableView:self.tableView 
                                                                        settingSections:self.settingSections];
                }
            }
            else if ([item.key hasPrefix:@"DYYYDateTimeFormat_"]) {
                // 閲嶇疆涓€涓瓙寮€鍏虫椂妫€鏌ユ槸鍚︽湁鍏朵粬瀛愬紑鍏冲惎鐢?
                BOOL anyEnabled = NO;
                for (NSString *checkKey in @[@"DYYYDateTimeFormat_YMDHM", @"DYYYDateTimeFormat_MDHM", 
                                             @"DYYYDateTimeFormat_HMS", @"DYYYDateTimeFormat_HM", 
                                             @"DYYYDateTimeFormat_YMD"]) {
                    if (![checkKey isEqualToString:item.key] && [[NSUserDefaults standardUserDefaults] boolForKey:checkKey]) {
                        anyEnabled = YES;
                        break;
                    }
                }
                
                // 濡傛灉鎵€鏈夊瓙寮€鍏抽兘鍏抽棴锛屼篃鍏抽棴涓诲紑鍏冲苟娓呴櫎鏍煎紡
                if (!anyEnabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYShowDateTime"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYDateTimeFormat"];
                    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
                        [[DYYYSwitchManager sharedManager] updateDateTimeFormatMainSwitchUI:section 
                                                                                  tableView:self.tableView 
                                                                           settingSections:self.settingSections];
                    }
                }
            }
            
            // 鐗规畩澶勭悊鏃堕棿灞炲湴鏄剧ず寮€鍏崇粍
            if ([item.key isEqualToString:@"DYYYEnableArea"]) {
                // 閲嶇疆涓诲紑鍏充篃閲嶇疆鎵€鏈夊瓙寮€鍏?
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYEnableAreaProvince"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYEnableAreaCity"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYEnableAreaDistrict"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYEnableAreaStreet"];
                
                // 浣跨敤 DYYYSwitchManager 鐨勬柟娉曟洿鏂癠I
                for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
                    [[DYYYSwitchManager sharedManager] updateAreaSubSwitchesUI:section 
                                                                       enabled:NO 
                                                                     tableView:self.tableView 
                                                              settingSections:self.settingSections];
                }
            }
            
            // 閽堝鑷畾涔夌浉鍐屽浘鐗囧拰澶у皬锛岄噸缃悗鍒锋柊鎸夐挳
            if ([item.key isEqualToString:@"DYYYCustomAlbumImagePath"] ||
                [item.key isEqualToString:@"DYYYCustomAlbumSizeSmall"] ||
                [item.key isEqualToString:@"DYYYCustomAlbumSizeMedium"] ||
                [item.key isEqualToString:@"DYYYCustomAlbumSizeLarge"] ||
                [item.key isEqualToString:@"DYYYEnableCustomAlbum"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYCustomAlbumSettingChanged" object:nil];
            }
            
            // 澶勭悊澶村儚鏂囨湰
            if ([item.key isEqualToString:@"DYYYAvatarTapText"]) {
                self.avatarTapLabel.text = @"pxx917144686";
            }
            
            // 鍒锋柊UI
            [self.tableView reloadData];
            
            // 鏄剧ず鎻愮ず
            [DYYYManager showToast:[NSString stringWithFormat:@"宸查噸缃? %@", item.title]];
            NSLog(@"DYYY: Reset %@", item.key);
        }];
        
        // 閲嶇疆鎿嶄綔鍒板脊鍑鸿彍鍗?
        [alert addAction:resetAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"鍙栨秷" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            alert.popoverPresentationController.sourceView = self.tableView;
            alert.popoverPresentationController.sourceRect = CGRectMake(point.x, point.y, 1, 1);
        }
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)showImagePickerForCustomAlbum {
    // 妫€鏌ヨ嚜瀹氫箟閫夋嫨鐩稿唽鍥剧墖鍔熻兘鏄惁鍚敤
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYEnableCustomAlbum"]) {
        [DYYYManager showToast:@"璇峰厛寮€鍚€岃嚜瀹氫箟閫夋嫨鐩稿唽鍥剧墖銆?];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"閫夋嫨鍥剧墖鏉ユ簮" 
                                                                  message:nil 
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"鐩稿唽" 
                                             style:UIAlertActionStyleDefault 
                                           handler:^(UIAlertAction * _Nonnull action) {
        [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary forCustomAlbum:YES];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"鐩告満" 
                                             style:UIAlertActionStyleDefault 
                                           handler:^(UIAlertAction * _Nonnull action) {
        [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera forCustomAlbum:YES];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"鎭㈠榛樿" 
                                             style:UIAlertActionStyleDefault 
                                           handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYCustomAlbumImagePath"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [DYYYManager showToast:@"宸叉仮澶嶉粯璁ょ浉鍐屽浘鐗?];
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYCustomAlbumSettingChanged" object:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"鍙栨秷" 
                                             style:UIAlertActionStyleCancel 
                                           handler:nil]];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, 
                                                                   self.view.bounds.size.height / 2, 
                                                                   0, 0);
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType forCustomAlbum:(BOOL)isCustomAlbum {
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [DYYYManager showToast:@"璁惧涓嶆敮鎸佽鍥剧墖鏉ユ簮"];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    
    objc_setAssociatedObject(picker, "isCustomAlbumPicker", isCustomAlbum ? @YES : @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)resetButtonTapped:(UIButton *)sender {
    NSString *key = sender.accessibilityLabel;
    if (!key) return;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 鐗规畩澶勭悊娓呭睆鎸夐挳灏哄閲嶇疆
    if ([key isEqualToString:@"DYYYEnableFloatClearButton"] || 
        [key isEqualToString:@"DYYYFloatClearButtonSizePreference"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:DYYYButtonSizeMedium 
                                                           forKey:@"DYYYFloatClearButtonSizePreference"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 鐗规畩澶勭悊鏃ユ湡鏃堕棿鏍煎紡鐩稿叧璁剧疆
    if ([key isEqualToString:@"DYYYShowDateTime"]) {
        // 閲嶇疆涓诲紑鍏充篃閲嶇疆鎵€鏈夊瓙寮€鍏冲拰鏍煎紡璁剧疆
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYDateTimeFormat_YMDHM"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYDateTimeFormat_MDHM"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYDateTimeFormat_HMS"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYDateTimeFormat_HM"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYDateTimeFormat_YMD"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYDateTimeFormat"];
        
        // 浣跨敤 DYYYSwitchManager 鐨勬柟娉曟洿鏂癠I涓瓙寮€鍏崇殑鐘舵€?
        for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
            [[DYYYSwitchManager sharedManager] updateDateTimeFormatSubSwitchesUI:section 
                                                                         enabled:NO 
                                                                       tableView:self.tableView 
                                                                settingSections:self.settingSections];
        }
    }
    else if ([key hasPrefix:@"DYYYDateTimeFormat_"]) {
        // 閲嶇疆涓€涓瓙寮€鍏虫椂妫€鏌ユ槸鍚︽湁鍏朵粬瀛愬紑鍏冲惎鐢?
        BOOL anyEnabled = NO;
        for (NSString *checkKey in @[@"DYYYDateTimeFormat_YMDHM", @"DYYYDateTimeFormat_MDHM", 
                                     @"DYYYDateTimeFormat_HMS", @"DYYYDateTimeFormat_HM", 
                                     @"DYYYDateTimeFormat_YMD"]) {
            if (![checkKey isEqualToString:key] && [[NSUserDefaults standardUserDefaults] boolForKey:checkKey]) {
                anyEnabled = YES;
                break;
            }
        }
        
        // 濡傛灉鎵€鏈夊瓙寮€鍏抽兘鍏抽棴锛屼篃鍏抽棴涓诲紑鍏冲苟娓呴櫎鏍煎紡
        if (!anyEnabled) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYShowDateTime"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYDateTimeFormat"];
            for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
                [[DYYYSwitchManager sharedManager] updateDateTimeFormatMainSwitchUI:section 
                                                                          tableView:self.tableView 
                                                                   settingSections:self.settingSections];
            }
        }
    }
    
    // 鐗规畩澶勭悊鏃堕棿灞炲湴鏄剧ず寮€鍏崇粍
    if ([key isEqualToString:@"DYYYEnableArea"]) {
        // 閲嶇疆涓诲紑鍏充篃閲嶇疆鎵€鏈夊瓙寮€鍏?
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYEnableAreaProvince"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYEnableAreaCity"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYEnableAreaDistrict"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DYYYEnableAreaStreet"];
        
        // 浣跨敤 DYYYSwitchManager 鐨勬柟娉曟洿鏂癠I
        for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
            [[DYYYSwitchManager sharedManager] updateAreaSubSwitchesUI:section 
                                                               enabled:NO 
                                                             tableView:self.tableView 
                                                      settingSections:self.settingSections];
        }
    }
    
    // 閽堝鑷畾涔夌浉鍐屽浘鐗囧拰澶у皬锛岄噸缃悗鍒锋柊鎸夐挳
    if ([key isEqualToString:@"DYYYCustomAlbumImagePath"] ||
        [key isEqualToString:@"DYYYCustomAlbumSizeSmall"] ||
        [key isEqualToString:@"DYYYCustomAlbumSizeMedium"] ||
        [key isEqualToString:@"DYYYCustomAlbumSizeLarge"] ||
        [key isEqualToString:@"DYYYEnableCustomAlbum"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DYYYCustomAlbumSettingChanged" object:nil];
    }
    
    // 澶勭悊澶村儚鏂囨湰
    if ([key isEqualToString:@"DYYYAvatarTapText"]) {
        self.avatarTapLabel.text = @"pxx917144686";
    }
    
    // 鍒锋柊UI
    [self.tableView reloadData];
    
    // 鏄剧ず鎻愮ず
    [DYYYManager showToast:[NSString stringWithFormat:@"宸查噸缃? %@", key]];
}

- (void)showSourceCodePopup {
    NSString *githubURL = @"https://github.com/pxx917144686/DYYY";
    
    // 娣诲姞璺宠浆鍓嶇殑鍔ㄧ敾鏁堟灉
    CAKeyframeAnimation *pulseAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.values = @[@1.0, @1.08, @1.0];
    pulseAnimation.keyTimes = @[@0, @0.5, @1.0];
    pulseAnimation.duration = 0.5;
    pulseAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    UIButton *sourceCodeButton = (UIButton *)[self.tableView.tableFooterView viewWithTag:101];
    [sourceCodeButton.layer addAnimation:pulseAnimation forKey:@"pulse"];
    
    // 璺宠浆鍒癎itHub椤甸潰
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:githubURL] options:@{} completionHandler:nil];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showScheduleStylePicker {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"閫夋嫨杩涘害鏉℃牱寮?
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *styles = @[
        @{@"title": @"杩涘害鏉″彸渚у墿浣?, @"value": @"杩涘害鏉″彸渚у墿浣?},
        @{@"title": @"杩涘害鏉″彸渚у畬鏁?, @"value": @"杩涘害鏉″彸渚у畬鏁?},
        @{@"title": @"杩涘害鏉″乏渚у墿浣?, @"value": @"杩涘害鏉″乏渚у墿浣?},
        @{@"title": @"杩涘害鏉″乏渚у畬鏁?, @"value": @"杩涘害鏉″乏渚у畬鏁?},
        @{@"title": @"杩涘害鏉′袱渚у乏鍙?, @"value": @"杩涘害鏉′袱渚у乏鍙?}
    ];
    
    for (NSDictionary *style in styles) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:style[@"title"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults] setObject:style[@"value"] forKey:@"DYYYScheduleStyle"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.tableView reloadData];
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"鍙栨秷" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 杈呭姪鏂规硶鐢ㄤ簬鏄剧ず鏇寸畝鐭殑鏍峰紡鍚嶇О
- (NSString *)getShortNameForStyleValue:(NSString *)styleValue {
    if ([styleValue isEqualToString:@"杩涘害鏉″彸渚у墿浣?]) return @"鍙充晶鍓╀綑";
    if ([styleValue isEqualToString:@"杩涘害鏉″彸渚у畬鏁?]) return @"鍙充晶瀹屾暣";
    if ([styleValue isEqualToString:@"杩涘害鏉″乏渚у墿浣?]) return @"宸︿晶鍓╀綑";
    if ([styleValue isEqualToString:@"杩涘害鏉″乏渚у畬鏁?]) return @"宸︿晶瀹屾暣";
    if ([styleValue isEqualToString:@"杩涘害鏉′袱渚у乏鍙?]) return @"涓や晶宸﹀彸";
    return styleValue;
}

@end
