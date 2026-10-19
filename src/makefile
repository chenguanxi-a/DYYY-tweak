include $(THEOS_MAKE_PATH)/tweak.mk

TWEAK_NAME = Atria

Atria_FILES = Tweak.m Settings/Options.m Hooks/SpringboardHooks.m UI/EditorViews.m

Atria_CFLAGS += -fobjc-arc -fobjc-weak
Atria_CFLAGS += -I.. -I./Settings -I./Hooks -I./UI

Atria_FRAMEWORKS += UIKit Foundation CoreFoundation
Atria_EXTRA_FRAMEWORKS += MobileSubstrate

Atria_LDFLAGS += -F$(THEOS)/lib -L$(THEOS)/lib
Atria_LDFLAGS += -Wl,-rpath,/var/jb/usr/lib -Wl,-rpath,/usr/lib

AFTER_INCLUDES += $(THEOS_PROJECT_DIR)/makefile:resources.mk

Atria_IS_ROOTLESS = 1
Atria_ROOT = /var/jb
