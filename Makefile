PACKAGE_IDENTIFIER = com.huami.dyyy
PACKAGE_NAME = DYYYPP
PACKAGE_VERSION = 2.1-7PP
PACKAGE_ARCHITECTURE = iphoneos-arm64e
PACKAGE_REVISION = 1
PACKAGE_SECTION = Tweaks
PACKAGE_DEPENDS = firmware (>= 14.0), mobilesubstrate
PACKAGE_DESCRIPTION = DYYY (Original: huami1314; Mod: pxx917144686)

define Package/$(PACKAGE_IDENTIFIER)
  Package: com.huami.dyyy
  Name: DYYYPP
  Version: 2.1-7PP
  Architecture: iphoneos-arm64e
  Author: pxx917144686
  Section: Tweaks
  Depends: firmware (>= 14.0), mobilesubstrate
endef

ARCHS = arm64 arm64e
TARGET = iphone:clang:15.0:15.0
USE_SWIFT = 1

export DEBUG = 1
export THEOS_STRICT_LOGOS = 0
export ERROR_ON_WARNINGS = 0
export LOGOS_DEFAULT_GENERATOR = internal

INSTALL_TARGET_PROCESSES = Aweme

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DYYYPP

$(TWEAK_NAME)_FILES = DYYY.xm \
	DYYYFloatSpeedButton.xm \
	DYYYFloatClearButton.xm \
	AWEPlayInteractionViewController.xm \
	AWEModernLongPressPanelTableViewController.xm \
	DYYYCityManager.m \
	DYYYManager.m \
	DYYYSettingViewController.m \
	DYYYSwitchManager.m \
	DYYYToast.m \
	DYYYBottomAlertView.m \
	DYYYUtils.m
$(TWEAK_NAME)_FILES += DYYYABTestHook.xm DYYYScreenshot.m DYYYSocialStats.xm AWEPlayerPlayControlHandler.xm AFDPrivacyHalfScreenViewController.xm UITextField.xm AWEElementStackView.xm AWELeftSideBarViewController.xm AWEFeedProgressSlider.xm AWEPOIDetailUGCPhotosPreviewViewController.xm
$(TWEAK_NAME)_FILES += DYYYConfirmCloseView.m DYYYCustomInputView.m DYYYFilterSettingsView.m DYYYKeywordListView.m DYYYPipPlayer.m
$(TWEAK_NAME)_FILES += DYYYSystemVersionSpoof.xm
$(TWEAK_NAME)_FILES += DYYYSDKPatch.m

FLEX_FILES := $(shell find FLEX -name '*.m' -o -name '*.mm' | grep -v 'FLEX/x/retdec' | grep -v 'FLEX/x/capstone' | grep -v 'UCDecompiler')
$(TWEAK_NAME)_FILES += $(FLEX_FILES) FLEX/flex_fishhook.c

CAPSTONE_CORE := $(shell find FLEX/x/capstone -maxdepth 1 -name "*.c")
CAPSTONE_ARM := $(shell find FLEX/x/capstone/arch/ARM -name "*.c")
CAPSTONE_ARM64 := $(shell find FLEX/x/capstone/arch/AArch64 -name "*.c")
$(TWEAK_NAME)_FILES += $(CAPSTONE_CORE) $(CAPSTONE_ARM) $(CAPSTONE_ARM64)

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -w
$(TWEAK_NAME)_CFLAGS += -Wno-deprecated-declarations -Wno-sign-compare -Wno-pointer-sign
$(TWEAK_NAME)_CFLAGS += -fobjc-runtime=ios-15.0
$(TWEAK_NAME)_CFLAGS += -DCAPSTONE_HAS_ARM -DCAPSTONE_HAS_AARCH64 -DCAPSTONE_USE_SYS_DYN_MEM
$(TWEAK_NAME)_CFLAGS += -I$(THEOS_PROJECT_DIR)
$(TWEAK_NAME)_CFLAGS += -I$(THEOS)/include
$(TWEAK_NAME)_CFLAGS += -I$(THEOS_PROJECT_DIR)/FLEX
$(TWEAK_NAME)_CFLAGS += -I$(THEOS_PROJECT_DIR)/FLEX/x/capstone/include
$(TWEAK_NAME)_CFLAGS += -Wno-everything
$(TWEAK_NAME)_CFLAGS += -Wno-incomplete-implementation
$(TWEAK_NAME)_CFLAGS += -Wno-protocol
$(TWEAK_NAME)_CFLAGS += -DDOKIT_FULL_BUILD=1
$(TWEAK_NAME)_CFLAGS += -DDORAEMON_FULL_BUILD=1

$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -fno-modules
$(TWEAK_NAME)_CCFLAGS += -I$(THEOS_PROJECT_DIR)/FLEX/x/capstone/include

$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security Metal MetalKit CoreImage SwiftUI Combine

$(TWEAK_NAME)_LDFLAGS += -Xlinker -no_adhoc_codesign -Xlinker -objc_abi_version -Xlinker 2
$(TWEAK_NAME)_LDFLAGS += -Xlinker -no_warn_duplicate_libraries
$(TWEAK_NAME)_LDFLAGS += -Wl,-w

NO_PACKAGE = 1

include $(THEOS_MAKE_PATH)/tweak.mk
# v2.1-7PP

