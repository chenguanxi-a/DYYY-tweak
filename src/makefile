include \/tweak.mk

TWEAK_NAME = Atria

Atria_FILES = Tweak.m Settings/Options.m Hooks/SpringboardHooks.m UI/EditorViews.m

Atria_CFLAGS += -fobjc-arc -fobjc-weak
Atria_CFLAGS += -I.. -I./Settings -I./Hooks -I./UI

Atria_FRAMEWORKS += UIKit Foundation CoreFoundation
Atria_EXTRA_FRAMEWORKS += MobileSubstrate

Atria_LDFLAGS += -FTHEOS\/lib -LTHEOS\/lib
Atria_LDFLAGS += -Wl,-rpath,/var/jb/usr\/lib -Wl,-rpath,/usr\/lib

AFTER_INCLUDES += \/makefile:resources.mk

Atria_IS_ROOTLESS = 1
Atria_ROOT = /var/jb

