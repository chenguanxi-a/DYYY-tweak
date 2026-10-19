# Theos resources include: copy everything under resources/ into the .deb stage
# Rootless layout: /var/jb/Library/...

Atria_resource_files = $(shell find resources -type f 2>/dev/null)

AFTER_ALL += stage_resources

stage_resources:
	@echo "Staging resources into root/"
	@mkdir -p $(BUILD_ROOT)/var/jb/Library/MobileSubstrate/DynamicLibraries
	@mkdir -p $(BUILD_ROOT)/var/jb/Library/PreferenceBundles/AtriaPrefs.bundle
	@mkdir -p $(BUILD_ROOT)/var/jb/Library/PreferenceLoader/Preferences

	@cp -f resources/MobileSubstrate/DynamicLibraries/Atria.plist $(BUILD_ROOT)/var/jb/Library/MobileSubstrate/DynamicLibraries/ 2>/dev/null || true
	@cp -f resources/AtriaPrefs.bundle/Info.plist              $(BUILD_ROOT)/var/jb/Library/PreferenceBundles/AtriaPrefs.bundle/ 2>/dev/null || true
	@cp -f resources/AtriaPrefs.bundle/Root.plist              $(BUILD_ROOT)/var/jb/Library/PreferenceBundles/AtriaPrefs.bundle/ 2>/dev/null || true
	@cp -f resources/PreferenceLoader/Preferences/AtriaPrefs.plist $(BUILD_ROOT)/var/jb/Library/PreferenceLoader/Preferences/ 2>/dev/null || true

	@if [ -f $(BUILD_DIR)/Atria.dylib ]; then \
	  cp -f $(BUILD_DIR)/Atria.dylib $(BUILD_ROOT)/var/jb/Library/MobileSubstrate/DynamicLibraries/; \
	fi
