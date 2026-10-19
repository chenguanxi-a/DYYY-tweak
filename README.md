# Atria Rootless Desktop Layout - Second Development Base

This folder contains a clean, editable Theos-style codebase derived from the original `acreson.rootless.cj.atria` package.

## What is included
- Core tweak source:
  - `src/Atria.h`
  - `src/Atria.m`
  - `src/Hooks/SpringboardHooks.h`
  - `src/Hooks/SpringboardHooks.m`
  - `src/Settings/Options.h`
  - `src/Settings/Options.m`
  - `src/UI/EditorViews.h`
  - `src/UI/EditorViews.m`
  - `src/ARIArchitecture.md`
- Packaging files:
  - `Makefile`
  - `src/makefile`
  - `Control`
- Preference bundle layout under `var/jb/...`

## Important notes
- This is a re-implementation skeleton, not a bit-for-bit decompiled source of the original binary.
- Class names, hook targets, preference domains, and settings keys are aligned with the observed structure of the original dylib.
- The code is split into a runtime tweak layer, SpringBoard hook layer, options registry, and secondary UI editor scaffolding.

## Build notes
- The project expects Theos to be installed and `THEOS` exported.
- The goal is to keep this folder directly usable from `make package` after the local toolchain is ready.
