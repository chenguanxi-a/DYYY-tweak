# Atria Reverse-Engineered Architecture

## Core runtime
- `Atria.dylib` is injected into `com.apple.springboard`.
- The original package exposes a `MobileSubstrate` dynamic library and a separate `Atria.plist`.

## Key internal classes
- `ARITweakManager`: top-level coordinator for SpringBoard tweaks.
- `ARIEditManager`: drives the settings UI / collection view.
- `ARIEditingMainView`: hosts the main editor controls.
- `ARIEditingControlsView`: renders individual control rows.
- `ARISettingCell`: settings list rows.
- `ARISettingCollectionViewHost`: hosts settings collection layout.
- `ARIOption`: option metadata / default state.
- `ARIDynamicBackgroundView`: animated background for editor screens.
- `ARIDynamicWelcomeLabel`: welcome text element.
- `ARISplashViewController`: onboarding / splash controller.
- `ARIFadeEffectView`: fade transition layer.

## Observed SpringBoard hooks
- `SBIconListView`
- `SBIconListFlowExtendedLayout`
- `SBIconListFlowLayout`
- `SBDockView`
- `SBPageManagementIcon`
- `SBIconBadgeView`
- `SBIconView`
- `SBFolderIconImageView`
- `SBHLibraryViewController`
- `SBSApplicationShortcutCustomImageIcon`

## Observed preference namespaces
- `me.lau.Atria`
- `me.lau.AtriaPrefs`
- `me.ren7995.atria.edit.*`

## Observed settings keys
- `layoutEnabled`
- `enableAppLibrary`
- `hideBadges`
- `hideLabels`
- `hideLabelsAppLibrary`
- `hideLabelsFolders`
- `hidePageDots`
- `hideFolderIconBG`
- `resizeWidgets`
- `scaleInsideFolders`
- `hide3DTouchActions`
- `disableTapGesture`
- `dropShadow`
- `showBackground`
- `blurTintEnabled`
- `showAlphaSlider`
- `showWelcome`
- `showTooltips`
- `disabledDock`
- `saveIconState`
- `exportSettingsString`
- `importSettingsString`
- `welcomeText`
- `welcomeTextColor`
- `pagedot_offsetX`
- `pagedot_offsetY`
- `welcome_inset_left`
- `welcome_inset_top`
- `welcome_textSize`

## Dock / general layout keys
- `dock`, `dock_bg`, `dock_columns`, `dock_rows`, `dock_iconScale`, `dock_spacing_x`, `dock_spacing_y`
- `dock_inset_top`, `dock_inset_bottom`, `dock_inset_left`, `dock_inset_right`
- `hs_columns`, `hs_rows`, `hs_iconScale`, `hs_spacing_x`, `hs_spacing_y`
- `hs_inset_top`, `hs_inset_bottom`, `hs_inset_left`, `hs_inset_right`
- `hs_widgetIconScale`, `hs_widgetXOffset`, `hs_widgetYOffset`

## External dependency observed
- `/var/jb/Library/MobileSubstrate/DynamicLibraries/ShyLabels.dylib`
- Runtime references suggest optional integration with ShyLabels.

## Second-development split in this repository
- `ARIAtriaOptions`: central option registry
- `ARIAtriaHooks`: SpringBoard hook installation and layout application
- `ARITweakManager`: runtime state + user defaults binding
- `ARIEditingMainView` / `ARISplashViewController` / related UI classes: secondary visual editor scaffolding
- `AtriaTweak`: load/unload entry point
