# ============================================================
# DYYY++ Theos Makefile (Rootless TrollStore / jailbreak)
# ARCHS=arm64 | TARGET=iphone:clang:15.0:15.0
# ============================================================

PACKAGE_IDENTIFIER = com.huami.dyyy
PACKAGE_NAME = DYYY++
PACKAGE_VERSION = 2.1-7++
PACKAGE_ARCHITECTURE = iphoneos-arm64
PACKAGE_REVISION = 1
PACKAGE_SECTION = Tweaks
PACKAGE_DEPENDS = firmware (>= 14.0), mobilesubstrate
PACKAGE_DESCRIPTION = DYYY++ (original: huami1314; modified: pxx917144686)

define Package/$(PACKAGE_IDENTIFIER)
  Package: com.huami.dyyy
  Name: DYYY++
  Version: 2.1-7++
  Architecture: iphoneos-arm64
  Author: pxx917144686
  Section: Tweaks
  Depends: firmware (>= 14.0), mobilesubstrate
endef

export THEOS_PACKAGE_DIR = $(CURDIR)

ARCHS = arm64
TARGET = iphone:clang:15.0

export DEBUG = 0
export THEOS_STRICT_LOGOS = 0
export ERROR_ON_WARNINGS = 0
export LOGOS_DEFAULT_GENERATOR = internal

export THEOS_PACKAGE_SCHEME = rootless
THEOS_PACKAGE_INSTALL_PREFIX = /var/jb

INSTALL_TARGET_PROCESSES = Aweme

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DYYY++

$(TWEAK_NAME)_FILES =             AFDPrivacyHalfScreenViewController.xm \
            AWEElementStackView.xm \
            AWEFeedProgressSlider.xm \
            AWELeftSideBarViewController.xm \
            AWEModernLongPressPanelTableViewController.xm \
            AWEPOIDetailUGCPhotosPreviewViewController.xm \
            AWEPlayInteractionViewController.xm \
            AWEPlayerPlayControlHandler.xm \
            DYYY.xm \
            DYYYABTestHook.xm \
            DYYYFloatClearButton.xm \
            DYYYFloatSpeedButton.xm \
            DYYYSocialStats.xm \
            DYYYSystemVersionSpoof.xm \
            UITextField.xm
$(TWEAK_NAME)_FILES +=             DYYYBottomAlertView.m \
            DYYYCityManager.m \
            DYYYConfirmCloseView.m \
            DYYYCustomInputView.m \
            DYYYFilterSettingsView.m \
            DYYYKeywordListView.m \
            DYYYManager.m \
            DYYYPipPlayer.m \
            DYYYSDKPatch.m \
            DYYYScreenshot.m \
            DYYYSettingViewController.m \
            DYYYSwitchManager.m \
            DYYYToast.m \
            DYYYUtils.m \
            FLEX/CALayer+FLEX.m \
            FLEX/Cocoa+FLEXShortcuts.m \
            FLEX/DYYYFHSRangeSlider.m \
            FLEX/DYYYFHSSnapshotNodes.m \
            FLEX/DYYYFHSSnapshotView.m \
            FLEX/DYYYFHSView.m \
            FLEX/DYYYFHSViewController.m \
            FLEX/DYYYFHSViewSnapshot.m \
            FLEX/DYYYFLEXAPITestViewController.m \
            FLEX/DYYYFLEXAPNSViewController.m \
            FLEX/DYYYFLEXASLLogController.m \
            FLEX/DYYYFLEXActivityViewController.m \
            FLEX/DYYYFLEXAddressExplorerCoordinator.m \
            FLEX/DYYYFLEXAlert.m \
            FLEX/DYYYFLEXAppInfoViewController.m \
            FLEX/DYYYFLEXArgumentInputColorView.m \
            FLEX/DYYYFLEXArgumentInputDateView.m \
            FLEX/DYYYFLEXArgumentInputFontView.m \
            FLEX/DYYYFLEXArgumentInputFontsPickerView.m \
            FLEX/DYYYFLEXArgumentInputNotSupportedView.m \
            FLEX/DYYYFLEXArgumentInputNumberView.m \
            FLEX/DYYYFLEXArgumentInputObjectView.m \
            FLEX/DYYYFLEXArgumentInputStringView.m \
            FLEX/DYYYFLEXArgumentInputStructView.m \
            FLEX/DYYYFLEXArgumentInputSwitchView.m \
            FLEX/DYYYFLEXArgumentInputTextView.m \
            FLEX/DYYYFLEXArgumentInputView.m \
            FLEX/DYYYFLEXArgumentInputViewFactory.m \
            FLEX/DYYYFLEXBlockDescription.m \
            FLEX/DYYYFLEXBlockShortcuts.m \
            FLEX/DYYYFLEXBookmarkManager.m \
            FLEX/DYYYFLEXBookmarksViewController.m \
            FLEX/DYYYFLEXBundleShortcuts.m \
            FLEX/DYYYFLEXCarouselCell.m \
            FLEX/DYYYFLEXClassBuilder.m \
            FLEX/DYYYFLEXClassShortcuts.m \
            FLEX/DYYYFLEXClearCacheViewController.m \
            FLEX/DYYYFLEXCodeFontCell.m \
            FLEX/DYYYFLEXCollectionContentSection.m \
            FLEX/DYYYFLEXColor.m \
            FLEX/DYYYFLEXColorPickerTool.m \
            FLEX/DYYYFLEXColorPreviewSection.m \
            FLEX/DYYYFLEXCookiesViewController.m \
            FLEX/DYYYFLEXDBQueryRowCell.m \
            FLEX/DYYYFLEXDefaultEditorViewController.m \
            FLEX/DYYYFLEXDefaultsContentSection.m \
            FLEX/DYYYFLEXDetailViewController.m \
            FLEX/DYYYFLEXDoKitAppInfoViewController.m \
            FLEX/DYYYFLEXDoKitCPUViewController.m \
            FLEX/DYYYFLEXDoKitCleanViewController.m \
            FLEX/DYYYFLEXDoKitColorPickerViewController.m \
            FLEX/DYYYFLEXDoKitComponentViewController.m \
            FLEX/DYYYFLEXDoKitCrashMonitor.m \
            FLEX/DYYYFLEXDoKitCrashViewController.m \
            FLEX/DYYYFLEXDoKitDatabaseViewController.m \
            FLEX/DYYYFLEXDoKitFileBrowserViewController.m \
            FLEX/DYYYFLEXDoKitFloatingWindow.m \
            FLEX/DYYYFLEXDoKitH5ViewController.m \
            FLEX/DYYYFLEXDoKitLagViewController.m \
            FLEX/DYYYFLEXDoKitLogEntry.m \
            FLEX/DYYYFLEXDoKitLogExportViewController.m \
            FLEX/DYYYFLEXDoKitLogFilterViewController.m \
            FLEX/DYYYFLEXDoKitLogViewController.m \
            FLEX/DYYYFLEXDoKitLogViewer.m \
            FLEX/DYYYFLEXDoKitManager.m \
            FLEX/DYYYFLEXDoKitMemoryLeakDetector.m \
            FLEX/DYYYFLEXDoKitMockViewController.m \
            FLEX/DYYYFLEXDoKitNetworkHistoryViewController.m \
            FLEX/DYYYFLEXDoKitNetworkMonitor.m \
            FLEX/DYYYFLEXDoKitNetworkViewController.m \
            FLEX/DYYYFLEXDoKitPerformanceMonitor.m \
            FLEX/DYYYFLEXDoKitPerformanceViewController.m \
            FLEX/DYYYFLEXDoKitSystemInfoViewController.m \
            FLEX/DYYYFLEXDoKitUserDefaultsViewController.m \
            FLEX/DYYYFLEXDoKitVisualTools.m \
            FLEX/DYYYFLEXDoKitVisualToolsViewController.m \
            FLEX/DYYYFLEXDoKitWeakNetworkViewController.m \
            FLEX/DYYYFLEXExplorerToolbar.m \
            FLEX/DYYYFLEXExplorerToolbarItem.m \
            FLEX/DYYYFLEXExplorerViewController.m \
            FLEX/DYYYFLEXFPSMonitorViewController.m \
            FLEX/DYYYFLEXFieldEditorView.m \
            FLEX/DYYYFLEXFieldEditorViewController.m \
            FLEX/DYYYFLEXFileBrowserController+RuntimeBrowser.m \
            FLEX/DYYYFLEXFileBrowserController.m \
            FLEX/DYYYFLEXFileBrowserSearchOperation.m \
            FLEX/DYYYFLEXFilteringTableViewController.m \
            FLEX/DYYYFLEXGlobalsEntry.m \
            FLEX/DYYYFLEXGlobalsSection.m \
            FLEX/DYYYFLEXGlobalsViewController+RuntimeBrowser.m \
            FLEX/DYYYFLEXGlobalsViewController.m \
            FLEX/DYYYFLEXH5DoorViewController.m \
            FLEX/DYYYFLEXHTTPTransactionDetailController.m \
            FLEX/DYYYFLEXHeapEnumerator.m \
            FLEX/DYYYFLEXHierarchyTableViewCell.m \
            FLEX/DYYYFLEXHierarchyTableViewController.m \
            FLEX/DYYYFLEXHierarchyViewController.m \
            FLEX/DYYYFLEXHookDetector+RuntimeBrowser.m \
            FLEX/DYYYFLEXHookDetector.m \
            FLEX/DYYYFLEXImagePreviewViewController.m \
            FLEX/DYYYFLEXImageShortcuts.m \
            FLEX/DYYYFLEXIvar.m \
            FLEX/DYYYFLEXKBToolbarButton.m \
            FLEX/DYYYFLEXKeyPathSearchController.m \
            FLEX/DYYYFLEXKeyValueTableViewCell.m \
            FLEX/DYYYFLEXKeyboardHelpViewController.m \
            FLEX/DYYYFLEXKeyboardShortcutManager.m \
            FLEX/DYYYFLEXKeyboardToolbar.m \
            FLEX/DYYYFLEXKeychain.m \
            FLEX/DYYYFLEXKeychainQuery.m \
            FLEX/DYYYFLEXKeychainViewController.m \
            FLEX/DYYYFLEXLayerShortcuts.m \
            FLEX/DYYYFLEXLiveObjectsController.m \
            FLEX/DYYYFLEXLookinComparisonViewController.m \
            FLEX/DYYYFLEXLookinDisplayItem.m \
            FLEX/DYYYFLEXLookinHierarchyViewController.m \
            FLEX/DYYYFLEXLookinInspector.m \
            FLEX/DYYYFLEXLookinMeasureController.m \
            FLEX/DYYYFLEXLookinMeasureResultView.m \
            FLEX/DYYYFLEXLookinMeasureViewController.m \
            FLEX/DYYYFLEXLookinPreviewController.m \
            FLEX/DYYYFLEXMITMDataSource.m \
            FLEX/DYYYFLEXMachOClassBrowserViewController.m \
            FLEX/DYYYFLEXManager+DoKitExtensions.m \
            FLEX/DYYYFLEXManager+Extensibility.m \
            FLEX/DYYYFLEXManager+Networking.m \
            FLEX/DYYYFLEXManager+ThreeFingerTap.m \
            FLEX/DYYYFLEXManager.m \
            FLEX/DYYYFLEXMemoryAnalyzer+RuntimeBrowser.m \
            FLEX/DYYYFLEXMemoryAnalyzer.m \
            FLEX/DYYYFLEXMemoryAnalyzerViewController.m \
            FLEX/DYYYFLEXMemoryLeakDetectorViewController.m \
            FLEX/DYYYFLEXMemoryMonitorViewController.m \
            FLEX/DYYYFLEXMetadataSection.m \
            FLEX/DYYYFLEXMethod.m \
            FLEX/DYYYFLEXMethodBase.m \
            FLEX/DYYYFLEXMethodCallingViewController.m \
            FLEX/DYYYFLEXMirror.m \
            FLEX/DYYYFLEXMultiColumnTableView.m \
            FLEX/DYYYFLEXMultilineTableViewCell.m \
            FLEX/DYYYFLEXMutableListSection.m \
            FLEX/DYYYFLEXNSDataShortcuts.m \
            FLEX/DYYYFLEXNSStringShortcuts.m \
            FLEX/DYYYFLEXNavigationController.m \
            FLEX/DYYYFLEXNetworkCurlLogger.m \
            FLEX/DYYYFLEXNetworkMITMViewController.m \
            FLEX/DYYYFLEXNetworkMonitorViewController.m \
            FLEX/DYYYFLEXNetworkObserver.m \
            FLEX/DYYYFLEXNetworkRecorder.m \
            FLEX/DYYYFLEXNetworkSettingsController.m \
            FLEX/DYYYFLEXNetworkTransaction.m \
            FLEX/DYYYFLEXNetworkTransactionCell.m \
            FLEX/DYYYFLEXNetworkWeakTester.m \
            FLEX/DYYYFLEXNetworkWeakViewController.m \
            FLEX/DYYYFLEXOSLogController.m \
            FLEX/DYYYFLEXObjcRuntimeViewController.m \
            FLEX/DYYYFLEXObjectExplorer.m \
            FLEX/DYYYFLEXObjectExplorerFactory.m \
            FLEX/DYYYFLEXObjectExplorerViewController.m \
            FLEX/DYYYFLEXObjectListViewController.m \
            FLEX/DYYYFLEXObjectRef.m \
            FLEX/DYYYFLEXPerformanceMonitor.m \
            FLEX/DYYYFLEXPerformanceMonitorViewController.m \
            FLEX/DYYYFLEXPerformanceViewController.m \
            FLEX/DYYYFLEXProperty.m \
            FLEX/DYYYFLEXPropertyAttributes.m \
            FLEX/DYYYFLEXProtocol.m \
            FLEX/DYYYFLEXProtocolBuilder.m \
            FLEX/DYYYFLEXRealmDatabaseManager.m \
            FLEX/DYYYFLEXResources.m \
            FLEX/DYYYFLEXRevealInspectorViewController.m \
            FLEX/DYYYFLEXRevealLikeInspector.m \
            FLEX/DYYYFLEXRulerTool.m \
            FLEX/DYYYFLEXRuntime+Compare.m \
            FLEX/DYYYFLEXRuntime+UIKitHelpers.m \
            FLEX/DYYYFLEXRuntimeBrowserToolbar.m \
            FLEX/DYYYFLEXRuntimeClient+Optimization.m \
            FLEX/DYYYFLEXRuntimeClient+RuntimeBrowser.m \
            FLEX/DYYYFLEXRuntimeClient.m \
            FLEX/DYYYFLEXRuntimeController.m \
            FLEX/DYYYFLEXRuntimeExporter.m \
            FLEX/DYYYFLEXRuntimeHeaderViewController.m \
            FLEX/DYYYFLEXRuntimeKeyPath.m \
            FLEX/DYYYFLEXRuntimeKeyPathTokenizer.m \
            FLEX/DYYYFLEXRuntimeUtility.m \
            FLEX/DYYYFLEXSQLResult.m \
            FLEX/DYYYFLEXSQLiteDatabaseManager.m \
            FLEX/DYYYFLEXScopeCarousel.m \
            FLEX/DYYYFLEXSearchToken.m \
            FLEX/DYYYFLEXShortcut.m \
            FLEX/DYYYFLEXShortcutsFactory+Defaults.m \
            FLEX/DYYYFLEXShortcutsSection.m \
            FLEX/DYYYFLEXSingleRowSection.m \
            FLEX/DYYYFLEXSubtitleTableViewCell.m \
            FLEX/DYYYFLEXSystemAnalyzerViewController+RuntimeBrowser.m \
            FLEX/DYYYFLEXSystemAnalyzerViewController.m \
            FLEX/DYYYFLEXSystemLogCell.m \
            FLEX/DYYYFLEXSystemLogMessage.m \
            FLEX/DYYYFLEXSystemLogViewController.m \
            FLEX/DYYYFLEXTabList.m \
            FLEX/DYYYFLEXTableColumnHeader.m \
            FLEX/DYYYFLEXTableContentViewController.m \
            FLEX/DYYYFLEXTableLeftCell.m \
            FLEX/DYYYFLEXTableListViewController.m \
            FLEX/DYYYFLEXTableRowDataViewController.m \
            FLEX/DYYYFLEXTableView.m \
            FLEX/DYYYFLEXTableViewCell.m \
            FLEX/DYYYFLEXTableViewController.m \
            FLEX/DYYYFLEXTableViewSection.m \
            FLEX/DYYYFLEXTabsViewController.m \
            FLEX/DYYYFLEXTypeEncodingParser.m \
            FLEX/DYYYFLEXUIAppShortcuts.m \
            FLEX/DYYYFLEXUtility.m \
            FLEX/DYYYFLEXVariableEditorViewController.m \
            FLEX/DYYYFLEXViewBorderViewController.m \
            FLEX/DYYYFLEXViewControllerShortcuts.m \
            FLEX/DYYYFLEXViewControllersViewController.m \
            FLEX/DYYYFLEXViewShortcuts.m \
            FLEX/DYYYFLEXVisualToolsViewController.m \
            FLEX/DYYYFLEXWebViewController.m \
            FLEX/DYYYFLEXWindow.m \
            FLEX/DYYYFLEXWindowManagerController.m \
            FLEX/DYYYFLEXWindowShortcuts.m \
            FLEX/DYYYOSCache.m \
            FLEX/DYYYRTBHookDetector.m \
            FLEX/DYYYRTBRuntimeController.m \
            FLEX/DYYYRTBSearchToken.m \
            FLEX/FLEXMetadataExtras.m \
            FLEX/FLEXRuntimeConstants.m \
            FLEX/FLEXRuntimeSafety.m \
            FLEX/NSArray+FLEX.m \
            FLEX/NSDateFormatter+FLEX.m \
            FLEX/NSDictionary+ObjcRuntime.m \
            FLEX/NSMapTable+FLEX_Subscripting.m \
            FLEX/NSObject+FLEX_Reflection.m \
            FLEX/NSString+FLEX.m \
            FLEX/NSString+ObjcRuntime.m \
            FLEX/NSTimer+FLEX.m \
            FLEX/NSUserDefaults+FLEX.m \
            FLEX/SceneKit+Snapshot.m \
            FLEX/UIBarButtonItem+FLEX.m \
            FLEX/UIFont+FLEX.m \
            FLEX/UIGestureRecognizer+Blocks.m \
            FLEX/UIMenu+FLEX.m \
            FLEX/UIPasteboard+FLEX.m \
            FLEX/UITextField+Range.m \
            FLEX/UIView+FLEX_Layout.m \
            FLEX/x/AppProtection/DYYYUCAppProtectionTool.m \
            FLEX/x/ClassDump/DYYYCDHeaderDumper.m \
            FLEX/x/ClassDump/DYYYCDZipWriter.m \
            FLEX/x/ClassDump/DYYYUCClassDumpTool.m \
            FLEX/x/ClassDump/DYYYUCClassHeaderDetailViewController.m \
            FLEX/x/ClassDump/DYYYUCClassSearchViewController.m \
            FLEX/x/ClassDump/DYYYUCMethodListViewController.m \
            FLEX/x/Decrypt/CapturePanel.m \
            FLEX/x/Decrypt/CryptoCapture.m \
            FLEX/x/Decrypt/DYYYDatabaseManager.m \
            FLEX/x/Decrypt/DYYYUCDecryptTool.m \
            FLEX/x/Decrypt/OpenSSLHooks.m \
            FLEX/x/Decrypt/SSLHooks.m \
            FLEX/x/Decrypt/ScriptDecode.m \
            FLEX/x/Decrypt/StreamingHashHooks.m \
            FLEX/x/Decrypt/URLCapture.m \
            FLEX/x/Decrypt/URLIntercept.m \
            FLEX/x/Disassembler/DYYYUCDisasmViewController.m \
            FLEX/x/Disassembler/DYYYUCDisassembler.m \
            FLEX/x/Disassembler/DYYYUCPseudocodeViewController.m \
            FLEX/x/filza/DYYYUCFilzaTool.m \
            FLEX/x/Shared/DYYYUCAppGroupHelper.m
$(TWEAK_NAME)_FILES +=             FLEX/flex_fishhook.c
$(TWEAK_NAME)_FILES +=             FLEX/x/capstone/MCInst.c \
            FLEX/x/capstone/MCInstPrinter.c \
            FLEX/x/capstone/MCInstrDesc.c \
            FLEX/x/capstone/MCRegisterInfo.c \
            FLEX/x/capstone/Mapping.c \
            FLEX/x/capstone/SStream.c \
            FLEX/x/capstone/cs.c \
            FLEX/x/capstone/utils.c \
            FLEX/x/capstone/arch/AArch64/AArch64BaseInfo.c \
            FLEX/x/capstone/arch/AArch64/AArch64Disassembler.c \
            FLEX/x/capstone/arch/AArch64/AArch64DisassemblerExtension.c \
            FLEX/x/capstone/arch/AArch64/AArch64InstPrinter.c \
            FLEX/x/capstone/arch/AArch64/AArch64Mapping.c \
            FLEX/x/capstone/arch/AArch64/AArch64Module.c \
            FLEX/x/capstone/arch/ARM/ARMBaseInfo.c \
            FLEX/x/capstone/arch/ARM/ARMDisassembler.c \
            FLEX/x/capstone/arch/ARM/ARMDisassemblerExtension.c \
            FLEX/x/capstone/arch/ARM/ARMInstPrinter.c \
            FLEX/x/capstone/arch/ARM/ARMMapping.c \
            FLEX/x/capstone/arch/ARM/ARMModule.c

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -w
$(TWEAK_NAME)_CFLAGS += -Wno-deprecated-declarations -Wno-sign-compare -Wno-pointer-sign
$(TWEAK_NAME)_CFLAGS += -fobjc-runtime=ios-15.0
$(TWEAK_NAME)_CFLAGS += -DCAPSTONE_HAS_ARM -DCAPSTONE_HAS_AARCH64 -DCAPSTONE_USE_SYS_DYN_MEM
$(TWEAK_NAME)_LOGOS_DEFAULT_GENERATOR = internal

$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security Metal MetalKit CoreImage SwiftUI Combine
$(TWEAK_NAME)_LDFLAGS += -Xlinker -no_adhoc_codesign -Xlinker -objc_abi_version -Xlinker 2
$(TWEAK_NAME)_LDFLAGS += -Xlinker -no_warn_duplicate_libraries
$(TWEAK_NAME)_LDFLAGS += -Wl,-w

$(TWEAK_NAME)_CFLAGS += -I$(THEOS_PROJECT_DIR)
$(TWEAK_NAME)_CFLAGS += -I$(THEOS)/include
$(TWEAK_NAME)_CFLAGS += -I$(THEOS_PROJECT_DIR)/FLEX
$(TWEAK_NAME)_CFLAGS += -I$(THEOS_PROJECT_DIR)/FLEX/x/capstone/include
$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -fno-modules
$(TWEAK_NAME)_CCFLAGS += -I$(THEOS_PROJECT_DIR)/FLEX/x/capstone/include

$(TWEAK_NAME)_CFLAGS += -Wno-everything
$(TWEAK_NAME)_CFLAGS += -Wno-incomplete-implementation
$(TWEAK_NAME)_CFLAGS += -Wno-protocol

$(TWEAK_NAME)_CFLAGS += -DDOKIT_FULL_BUILD=1
$(TWEAK_NAME)_CFLAGS += -DDORAEMON_FULL_BUILD=1

include $(THEOS_MAKE_PATH)/tweak.mk
