#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "DYYYUtils.h"

NS_ASSUME_NONNULL_BEGIN

/* ============================================================
 * DYYYNew23.h — 2.3-0 成品新增模块统一头文件
 * 基于成品 DYYY_2.3-0.dylib 反编译规格实现
 * ============================================================ */

#pragma mark - 通用开关读取（兼容源码宏风格）
#define D23Bool(key, def) ([[NSUserDefaults standardUserDefaults] objectForKey:key] ? [[NSUserDefaults standardUserDefaults] boolForKey:key] : def)
#define D23Float(key, def) ([[NSUserDefaults standardUserDefaults] objectForKey:key] ? [[NSUserDefaults standardUserDefaults] floatForKey:key] : def)
#define D23Int(key, def) ([[NSUserDefaults standardUserDefaults] objectForKey:key] ? [[NSUserDefaults standardUserDefaults] integerForKey:key] : def)

#pragma mark - 备份 / 恢复
@interface DYYYBackupManager : NSObject
+ (instancetype)shared;
- (BOOL)createBackupAtURL:(NSURL *)url
          includeSensitive:(BOOL)includeSensitive
                   summary:(NSString *_Nullable *_Nullable)summary
                     error:(NSError *_Nullable *_Nullable)error;
- (BOOL)restoreBackupAtURL:(NSURL *)url
                     mode:(NSUInteger)mode
                  summary:(NSString *_Nullable *_Nullable)summary
                    error:(NSError *_Nullable *_Nullable)error;
- (BOOL)inspectBackupAtURL:(NSURL *)url
                   summary:(NSString *_Nullable *_Nullable)summary
                     error:(NSError *_Nullable *_Nullable)error;
+ (NSString *)backupFileFormatVersion;
+ (NSString *)backupFileExtension; // "dyyybackup"
@end

@interface DYYYBackupSettings : NSObject
@property (nonatomic, copy) NSString *backupPath;
@property (nonatomic, assign) BOOL includeSensitive;
+ (void)savePendingBackupSettings:(DYYYBackupSettings *)settings;
+ (DYYYBackupSettings *)pendingBackupSettings;
@end

#pragma mark - 登录绕过
@interface DYYYLoginBypassManager : NSObject
+ (instancetype)shared;
- (BOOL)isLoginBypassEnabled;
- (void)persistLoginBypassEnabled:(BOOL)enabled;
- (BOOL)hasPersistentLoginBypassSetting;
@end

#pragma mark - 隐私记录上传防护
@interface DYYYPrivacyRecordUploadGuard : NSObject
+ (instancetype)shared;
- (void)install;
@property (nonatomic, readonly) BOOL castVPNCheckDisabled;
@property (nonatomic, readonly) BOOL awemeViewRecordUploadDisabled;
@property (nonatomic, readonly) BOOL profileVisitRecordUploadDisabled;
@end

#pragma mark - 直播 / 预告流
@interface DYYYLivePreStreamTransformState : NSObject
@property (nonatomic, assign) BOOL preStreamActive;
@property (nonatomic, assign) CGAffineTransform transform;
@property (nonatomic, assign) CGFloat contentOffsetY;
@property (nonatomic, assign) CGFloat alpha;
+ (instancetype)transformStateForView:(nullable UIView *)view createIfNeeded:(BOOL)createIfNeeded;
@end

@interface DYYYLivePreStreamControllerState : NSObject
@property (nonatomic, strong) DYYYLivePreStreamTransformState *transformState;
@property (nonatomic, assign) BOOL layoutValid;
@property (nonatomic, assign) NSTimeInterval lastLayoutTime;
@end

@interface DYYYLiveDurationView : UIView
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) CAGradientLayer *bgGradient;
@property (nonatomic, assign) BOOL locked;
- (void)updateWithCurrentTime:(NSTimeInterval)currentTime
                totalDuration:(NSTimeInterval)totalDuration;
- (void)applyCenterXPercent:(CGFloat)x centerYPercent:(CGFloat)y inBounds:(CGRect)bounds;
- (void)removeAllLabels;
- (void)schedulePresentationTimersIfNeeded;
- (void)cancelTimers;
@end

@interface DYYYLiveDurationTicker : NSObject
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval totalDuration;
@property (nonatomic, copy, nullable) void (^onTick)(DYYYLiveDurationTicker *);
- (void)start;
- (void)stop;
+ (NSString *)formatTimeFromSeconds:(NSTimeInterval)seconds;
@end

@interface DYYYLiveDurationWeakViewBox : NSValue
+ (instancetype)valueWithWeakView:(nullable UIView *)view;
@property (nonatomic, readonly, nullable) UIView *weakView;
@end

@interface DYYYLivePreStreamLayoutCoordinator : NSObject
@property (nonatomic, weak) UIViewController *controller;
- (void)scheduleUpdateForController:(UIViewController *)controller;
- (void)scheduleUpdateForView:(UIView *)view;
- (void)updateScheduled:(BOOL)scheduled;
@end

#pragma mark - 全局透明 / 边缘停靠
@interface DYYYKeyboardAvoidanceCoordinator : NSObject
+ (instancetype)shared;
- (void)install;
@property (nonatomic, strong, nullable) id keyboardChangeObserver;
@end

#pragma mark - 对象缓存（OSCache）
@interface DYYYOSCacheEntry : NSObject
@property (nonatomic, strong, nullable) id object;
@property (nonatomic, assign) CFAbsoluteTime timestamp;
@property (nonatomic, copy, nullable) NSString *key;
@end

@interface DYYYOSCache : NSObject
- (instancetype)initWithLimit:(NSUInteger)limit;
@property (nonatomic, readwrite, nullable) id delegate;
- (void)storeObject:(id)object forKey:(NSString *)key;
- (nullable id)objectForKey:(NSString *)key;
- (BOOL)cacheShouldEvictObject:(id)obj forKey:(NSString *)key NS_REQUIRES_SUPER;
- (void)cacheWillEvictObject:(id)obj forKey:(NSString *)key NS_REQUIRES_SUPER;
- (void)cacheLimitAdjustedTo:(NSUInteger)limit;
- (void)clear;
@end

#pragma mark - 设置界面：菜单样式 / 关于 / 更新 / 清理
@interface DYYYMenuModule : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, strong, nullable) NSArray<DYYYMenuModule *> *children;
@property (nonatomic, copy, nullable) void (^handler)(void);
@end

@interface DYYYMenuStyleBuilder : NSObject
@property (nonatomic, copy, nullable) NSString *styleName; // "Classic" / "Neuomorphic"
+ (DYYYMenuStyleBuilder *)classicStyle;
+ (DYYYMenuStyleBuilder *)neuomorphicStyle;
- (void)setColorStyle:(NSString *)color;
- (void)setLineCapStyle:(NSString *)cap;
- (void)setLineJoinStyle:(NSString *)join;
- (void)setBorderStyle:(NSString *)border;
- (void)setDecorationStyle:(NSString *)decoration;
- (BOOL)applyToView:(UIView *)view;
@end

@interface DYYYListStyleBuilder : NSObject
@property (nonatomic, copy, nullable) NSString *listStyle; // "plain" / "insetGrouped"
- (UIListStyle)listStyleValue;
@end

@interface DYYYAboutDialogView : UIView
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                   onConfirm:(nullable void (^)(void))onConfirm;
+ (void)showAboutDialog:message:(NSString *)message onConfirm:(nullable void (^)(void))onConfirm;
- (void)show;
@end

#pragma mark - 玻璃确认弹窗
@interface DYYYGlassConfirmView : UIView
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, copy, nullable) void (^confirmBlock)(void);
@property (nonatomic, copy, nullable) void (^cancelBlock)(void);
- (void)showInView:(UIView *)parentView;
- (void)dismiss;
@end

#pragma mark - 头像预览保存
@interface DYYYAvatarPreviewSaver : NSObject
+ (void)handleAvatarPreviewSaveLongPress:(UILongPressGestureRecognizer *)gesture;
+ (void)saveAvatarPreviewFromDouyinSource:(UIView *)sourceView;
@end

#pragma mark - 迷你程序广告奖励
@interface DYYYMiniProgramRewardSession : NSObject
@property (nonatomic, copy, nullable) NSString *rewardToken;
@property (nonatomic, assign) NSTimeInterval startedAt;
+ (instancetype)currentSession;
- (void)markRewardGranted;
- (void)cancel;
@end

#pragma mark - 视频编辑 / 自定义数据
@interface DYYYVideoEditViewController : UIViewController
@property (nonatomic, copy, nullable) NSString *videoId;
@property (nonatomic, strong, nullable) NSDictionary *customStats;
- (void)commitCustomStats;
@end

#pragma mark - 推荐过滤配置
@interface DYYYRecommendationFilterConfig : NSObject
@property (nonatomic, assign) BOOL filterLowLikes;
@property (nonatomic, assign) CGFloat lowLikesThreshold;
@property (nonatomic, assign) BOOL filterTimeLimit;
@property (nonatomic, assign) NSTimeInterval maxAgeSeconds;
@property (nonatomic, strong, nullable) NSArray<NSString *> *filteredUserIds;
@property (nonatomic, strong, nullable) NSArray<NSString *> *filteredProperties;
+ (instancetype)config;
- (BOOL)shouldFilterAwemeModel:(id)model;
@end

#pragma mark - 远程配置
@interface DYYYRemoteConfig : NSObject
+ (instancetype)shared;
@property (nonatomic, readonly) BOOL useRemote;
@property (nonatomic, readonly, nullable) NSString *currentFlagKey;
@property (nonatomic, readonly, nullable) NSString *remoteModeString;
- (void)checkForRemoteConfigUpdate;
- (void)notifyStateChanged:(BOOL)changed;
@end

#pragma mark - 消息定制
@interface DYYYMessageCustomizer : NSObject
+ (NSString *)formatVideoDate:(NSDate *)date customFormat:(nullable NSString *)fmt;
+ (NSString *)customAudioDurationString:(NSTimeInterval)seconds;
+ (BOOL)isOneWayReadReceiptEnabled;
+ (NSArray<NSString *> *)readReceiptTargets;
+ (void)applyReadReceiptStyles;
@end

#pragma mark - 地理名称缓存
@interface DYYYGeoNamesCache : NSObject
+ (instancetype)shared;
- (NSString *)cachedNameForGeonameId:(NSString *)geonameId;
- (void)storeName:(NSString *)name forGeonameId:(NSString *)geonameId;
+ (NSString *)geonamesUsername;
@end

#pragma mark - HDR / 广告过滤
@interface DYYYContentFilter : NSObject
+ (BOOL)containsHDRMetadataInObject:(id)obj depth:(NSInteger)depth;
+ (BOOL)shouldExcludeFromGlobalHDRFilter:(id)obj;
+ (BOOL)objectContainsMeaningfulAdPayload:(id)obj;
+ (NSNumber *)numberValueForLowLikesFilter:(id)model;
+ (NSNumber *)resolvedDiggCountForAweme:(id)aweme;
@end

#pragma mark - 双击 / 长按菜单扩展
@interface DYYYDoubleClickMenu : NSObject
+ (BOOL)isEnabled;
+ (void)showMenuForAweme:(id)aweme fromView:(UIView *)view;
+ (void)openCommentPanelForAweme:(id)aweme;
+ (void)copyDescriptionForAweme:(id)aweme;
+ (void)downloadVideoForAweme:(id)aweme;
+ (void)downloadAudioForAweme:(id)aweme;
+ (void)createVideoFromAweme:(id)aweme;
+ (void)interfaceDownloadForAweme:(id)aweme;
+ (void)showSharePanelForAweme:(id)aweme;
+ (void)markNotInterestedForAweme:(id)aweme;
+ (void)longPressSaveCoverForAweme:(id)aweme;
+ (void)longPressSaveAudioForAweme:(id)aweme;
+ (void)longPressSaveCurrentImageForAweme:(id)aweme;
+ (void)longPressSaveAllImagesForAweme:(id)aweme;
+ (void)longPressCopyLinkForAweme:(id)aweme;
+ (void)longPressCopyTextForAweme:(id)aweme;
+ (void)longPressFilterUserForAweme:(id)aweme;
+ (void)longPressFilterTitleForAweme:(id)aweme;
+ (void)longPressApiDownloadForAweme:(id)aweme;
+ (void)longPressCreateVideoForAweme:(id)aweme;
+ (void)longPressTimerCloseForAweme:(id)aweme;
@end

#pragma mark - 全局函数
void dyyy_playTapFeedback(void);
void dyyy_restoreTapTransform(UIView *view);
void dyyy_applyGlobalTransparency(float alpha);
void dyyy_applyEdgeHiddenState(UIView *view, BOOL hidden);
void dyyy_applySelfHiddenAlpha(UIView *view);
void dyyy_hideToEdgeForClearMode(UIView *view);
void dyyy_restoreFromClearMode(UIView *view);
void dyyy_restoreFromEdgeHidden(UIView *view);
BOOL dyyy_isInSelfHiddenState(UIView *view);
BOOL dyyy_shouldSelfHideOnClear(UIView *view);
BOOL dyyyEdgeHiddenByClearMode(UIView *view);
void dyyy_showEdgeIndicator(UIView *view, CGPoint location);
void dyyy_hideEdgeIndicator(UIView *view);
CGRect dyyy_edgeGeometryForSuperviewSize:(CGSize)superViewSize
                                halfWidth:(CGFloat)halfWidth
                               halfHeight:(CGFloat)halfHeight
                              leftCenterX:(CGFloat)leftCenterX
                             rightCenterX:(CGFloat)rightCenterX
                                topCenterY:(CGFloat)topCenterY
                             bottomCenterY:(CGFloat)bottomCenterY
                               minAlongEdgeX:(CGFloat)minAlongEdgeX
                               maxAlongEdgeX:(CGFloat)maxAlongEdgeX
                               minAlongEdgeY:(CGFloat)minAlongEdgeY
                               maxAlongEdgeY:(CGFloat)maxAlongEdgeY;
CGFloat dyyyDistanceFromPoint:(CGPoint)point toEdge:(NSString *)edge;
NSString *dyyyEdgeForCenter:(CGPoint)center inView:(UIView *)view;
NSString *dyyyNearestEdgeForPoint:(CGPoint)point;
CGPoint dyyySnappedCenterForProposedCenter:(CGPoint)proposed inView:(UIView *)view;
CGPoint dyyyCenterOnEdge:(NSString *)edge forPoint:(CGPoint)point inView:(UIView *)view;
void dyyy_cancelAutoHideTimer(UIView *view);
void dyyy_schedulePresentationTimersIfNeeded(UIView *view);
NSString *dyyy_formatTimeFromSeconds(NSTimeInterval seconds);
NSString *dyyy_legacyFormatTimeFromSeconds(NSTimeInterval seconds);
CGFloat dyyy_modelDurationInSeconds(id model);
CGFloat dyyy_legacyModelDurationInSeconds(id model);
void dyyy_removeScheduleLabels(UIView *container);
void dyyy_updateScheduleLabelsWithCurrentTime:(NSTimeInterval)currentTime totalDuration:(NSTimeInterval)total;
void dyyy_updateScheduleLabelsLegacyWithCurrentTime:(NSTimeInterval)currentTime totalDuration:(NSTimeInterval)total model:(id)model;
void dyyy_syncScheduleLabelsWithCurrentTime:(NSTimeInterval)currentTime totalDuration:(NSTimeInterval)total;
void dyyy_saveButtonTapped(UIView *view);
BOOL dyyyHasSavedPosition(UIView *view);
BOOL dyyyJustRestoredFromEdgeHidden(UIView *view);
id dyyy_safeValueForKey:(NSString *)key fromObject:(id)obj;
UIView *dyyy_makePillButtonWithTitle:(NSString *)title
                               frame:(CGRect)frame
                              darkMode:(BOOL)darkMode
                            emphasized:(BOOL)emphasized
                                action:(nullable void (^)(void))action;

#pragma mark - 关于 / 更新 / 清理
@interface DYYYAbout : NSObject
+ (instancetype)shared;
- (void)show;
@end

@interface DYYYCheckUpdate : NSObject
+ (void)check;
@end

@interface DYYYCleanCache : NSObject
+ (void)run;
@end

@interface DYYYCleanSettings : NSObject
+ (void)run;
@end

#pragma mark - 头像预览保存
@interface DYYYAvatarPreviewSaver : NSObject
+ (void)handleAvatarPreviewSaveLongPress:(UILongPressGestureRecognizer *)gesture;
+ (void)saveAvatarPreviewFromDouyinSource:(UIView *)sourceView;
@end

#pragma mark - 迷你程序奖励会话
@interface DYYYMiniProgramRewardSession : NSObject
@property (nonatomic, copy, nullable) NSString *rewardToken;
@property (nonatomic, assign) NSTimeInterval startedAt;
+ (instancetype)currentSession;
+ (void)startSession;
- (void)markRewardGranted;
- (void)cancel;
@end

#pragma mark - 直播预告协调器
@interface DYYYLivePreStreamLayoutCoordinator : NSObject
@property (nonatomic, weak, nullable) UIViewController *controller;
- (void)scheduleUpdateForController:(UIViewController *)controller;
- (void)scheduleUpdateForView:(UIView *)view;
- (void)updateScheduled:(BOOL)scheduled;
- (void)setUpdateScheduled:(BOOL)scheduled;
- (nullable DYYYLivePreStreamTransformState *)currentTransformState;
@end

#pragma mark - 直播画质
@interface DYYYLiveQuality : NSObject
+ (instancetype)shared;
- (NSArray<NSNumber *> *)availableLevels;
- (NSInteger)currentLevel;
- (void)setCurrentLevel:(NSInteger)level;
- (NSString *)displayNameForLevel:(NSInteger)level;
@end

#pragma mark - 直播预告变换状态
@interface DYYYLivePreStreamTransformState : NSObject
@property (nonatomic, assign) BOOL preStreamActive;
@property (nonatomic, assign) CGAffineTransform transform;
@property (nonatomic, assign) CGFloat contentOffsetY;
@property (nonatomic, assign) CGFloat alpha;
+ (nullable instancetype)transformStateForView:(nullable UIView *)view createIfNeeded:(BOOL)createIfNeeded;
@end

#pragma mark - 直播预告控制器状态
@interface DYYYLivePreStreamControllerState : NSObject
@property (nonatomic, strong, nullable) DYYYLivePreStreamTransformState *transformState;
@property (nonatomic, assign) BOOL layoutValid;
@property (nonatomic, assign) NSTimeInterval lastLayoutTime;
@end

#pragma mark - 选项选择视图
@interface DYYYOptionsSelectionView : UIView
@property (nonatomic, copy, nullable) NSArray<NSString *> *options;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy, nullable) void (^onSelectionChanged)(NSInteger index);
- (instancetype)initWithOptions:(NSArray<NSString *> *)options;
- (void)dyyyInlineOptionsSegmentChanged:(id)sender;
- (void)dyyyInlineTextEditingDidBegin:(id)sender;
- (void)dyyyInlineTextEditingDidEnd:(id)sender;
- (void)dyyyInlineTextReturn:(id)sender;
@end
#pragma mark - 倍速系统 C 函数
double dyyy_configuredPlaybackSpeed(void);
BOOL dyyy_autoRestoreSpeedEnabled(void);
int dyyy_currentSpeedIndex(void);
void dyyy_setCurrentSpeedIndex(int index);
BOOL dyyy_shouldPrepareDefaultPlaybackSpeedForPlayer(id player);
double dyyy_preparedPlaybackSpeedForPlayer(id player);
void dyyy_applyPreparedPlaybackSpeedToPlayer(id player);
void dyyy_bindAndApplyCurrentPlaybackSpeed(void);
void dyyy_scheduleConfiguredPlaybackSpeedRestoreAfterDelay(NSTimeInterval delay);
void dyyy_scheduleConfiguredPlaybackSpeedRestore(void);
void dyyy_endLockedLongPressSpeedAndRestoreIfNeeded(void);
BOOL dyyy_speedButtonLocked(void);
void dyyy_setSpeedButtonLocked(BOOL locked);
CGFloat dyyy_speedButtonSize(void);
CGFloat dyyy_speedButtonCenterXPercent(void);
CGFloat dyyy_speedButtonCenterYPercent(void);
BOOL dyyy_autoHideSpeedButtonEnabled(void);
NSTimeInterval dyyy_autoHideSpeedButtonTime(void);
void dyyy_cancelAutoHideSpeedButtonTimer(UIView *view);
void dyyy_showSpeedButton(UIView *view);
void dyyy_hideSpeedButton(UIView *view);

#pragma mark - 画中画管理
@interface DYYYPipManager : NSObject
+ (instancetype)shared;
@property (nonatomic, readonly) UIView *pipContainerView;
- (void)restorePipVideo;
- (void)markDisablePipelineFinishedWithUserID:(nullable NSString *)userId;
- (BOOL)shouldStartDisablePipelineForUserID:(nullable NSString *)userId;
@end

// DYYYPipContainerView is just the pipContainerView property above

#pragma mark - 倍速悬浮按钮
@interface DYYYSpeedSwitchButton : UIButton
- (void)showInView:(UIView *)parentView;
- (void)startAutoHideTimer;
- (void)cancelAutoHideTimer;
@end

#pragma mark - 设置相关
@interface DYYYSettingsHelper : NSObject
+ (void)registerDefaults;
@end
@interface DYYYSettingsSearchCoordinator : NSObject
@end
@interface DYYYSettingsVC : NSObject
@end
@interface DYYYSettingsButton : NSObject
@end
@interface DYYYUISettings : NSObject
@end

#pragma mark - 玻璃确认弹窗
@interface DYYYGlassConfirmView : UIView
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, copy, nullable) void (^confirmBlock)(void);
@property (nonatomic, copy, nullable) void (^cancelBlock)(void);
- (void)showInView:(UIView *)parentView;
- (void)dismiss;
@end

#pragma mark - 新拟态样式
@interface DYYYNeuomorphicStyleBuilder : DYYYMenuStyleBuilder
@end

CGFloat dyyy_legacyScheduleVerticalOffset(void);
void dyyy_scheduleVerticalOffset(CGFloat offsetY);
#pragma mark - 备份选择代理
@interface DYYYBackupPickerDelegate : NSObject <UIDocumentPickerDelegate>
@property (nonatomic, copy, nullable) void (^completionBlock)(nullable NSURL *url);
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url;
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller;
@end
NS_ASSUME_NONNULL_END