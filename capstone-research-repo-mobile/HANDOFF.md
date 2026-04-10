# UI Handoff Notes

Date: 2026-04-10
Commit: `4674340` (`chore(ui): refine app shell and explore filters`)

## Purpose

This note captures the UI direction, the exact changes made, the design decisions we intentionally preserved, and the remaining repo state so the next session can continue smoothly without re-discovering the same context.

## High-Level Outcome

The app was visually refined to feel sleeker while preserving the existing blue/navy and gold identity, and the current bottom navbar styling was intentionally kept. The work focused on three main areas:

1. A cleaner, flatter home header.
2. A more compact and controllable explore/search/filter experience.
3. A consistent theme baseline so the updated screens feel like part of one system.

## What Changed

### 1) Global Theme Alignment

File: `lib/core/constants/app_theme.dart`

The app-wide typography was aligned with the existing app text styles by switching the theme font family to `Plus Jakarta Sans` instead of `Poppins`.

Why this mattered:
- The app already used `Plus Jakarta Sans` in `lib/core/constants/app_text_styles.dart`.
- Before this change, the theme and the custom text styles were not fully consistent.
- Aligning them makes the UI feel more intentional and less like separate styling systems were layered together.

Behavioral impact:
- No user-facing flow changed.
- This only affected the visual consistency of text rendering throughout the app.

### 2) Home Screen Shell Polish

File: `lib/presentation/screens/home/home_screen.dart`

The home screen header and bottom navigation were refined. The bottom navbar itself was preserved structurally, because it was explicitly something you liked.

What changed in the header:
- The header was kept flat and straight, with no rounded bottom corners.
- The top section became a little tighter vertically.
- The logo and greeting area were slightly refined so the header reads cleaner.
- The notification icon was corrected so it sits centered inside its button.
- The badge for notifications was layered separately so the icon no longer looks skewed.

What changed in the bottom navbar:
- The navbar remains the same in terms of items and behavior.
- The visual treatment was softened slightly to feel more premium.
- The active item still expands to show the label, preserving the style you liked.
- The navbar was intentionally not replaced with a standard Material navigation widget.

Why this mattered:
- The home shell is one of the first things users see after landing in the app.
- A flatter header and cleaner icon alignment make the app feel more polished without changing the overall identity.
- Preserving the bottom navbar kept the app recognizable and avoided unnecessary design churn.

### 3) Explore / Browse Screen Header and Filters

File: `lib/presentation/screens/research/browse_research_screen.dart`

This was the main area of iteration. The goal was to reduce how much vertical space the explore header consumed and to make the filter experience feel more deliberate.

Final state of the explore header:
- The header is flat and not rounded.
- The search bar sits in the header as a distinct element.
- The filter icon is outside the search box, on the right side of the search row.
- The filter button is plain, borderless, and slightly larger than before.
- The filter panel is collapsed by default.
- Clicking the filter icon reveals the filter chips underneath the search bar.
- The filter panel contains all filter groups in the compact combined style that felt closest to the earlier version you preferred.

Important interaction details:
- The search bar and filter button are visually separate, which matches your latest preference.
- The filter icon uses the dial/tuning style rather than a funnel, per your preference.
- The main header container is square and flat, not rounded.
- Search text changes update the results badge and clear state correctly.

State and filtering details:
- Search scope filters remain available.
- Category filters remain available.
- The filters are hidden until opened, reducing the default vertical footprint.
- Search and category filtering behavior was preserved rather than rewritten into a completely different model.

Why this mattered:
- The original explore header was using too much vertical space.
- The two-row version was rejected because it looked too busy and not aligned with the desired visual language.
- The final version keeps the controls available without forcing them to occupy screen height all the time.

## Design Decisions That Were Deliberately Preserved

- The app color scheme remained the same.
- The bottom navbar styling remained the same in principle and was not replaced.
- The Explore / My Papers / Analytics navbar items were preserved.
- The app was not converted to a standard Material navigation pattern.
- The research browsing experience still supports both search scope filtering and category filtering.

## Files Changed in the Commit

The committed UI changes were limited to:

- `lib/core/constants/app_theme.dart`
- `lib/presentation/screens/home/home_screen.dart`
- `lib/presentation/screens/research/browse_research_screen.dart`

## Current Repo State

After the commit, these unrelated generated plugin files are still modified in the working tree and were intentionally left alone:

- `linux/flutter/generated_plugin_registrant.cc`
- `linux/flutter/generated_plugin_registrant.h`
- `linux/flutter/generated_plugins.cmake`
- `macos/Flutter/GeneratedPluginRegistrant.swift`
- `windows/flutter/generated_plugin_registrant.cc`
- `windows/flutter/generated_plugin_registrant.h`
- `windows/flutter/generated_plugins.cmake`

They are not part of the UI work above.

## What Was Tried Along the Way

The explore screen went through a few intermediate layouts before landing on the current one:

- A taller sticky header version.
- A two-row visible filter layout.
- An in-search-bar filter icon version.
- An outside-the-search-bar filter icon version.
- A bordered standalone filter button version.
- The current plain button version.

This history matters because the current version is the result of narrowing the UI to what you actually wanted, not the first generic improvement idea.

## Handoff Notes For the Next Session

If the next session continues UI refinement, the safest follow-up areas are:

1. Polish the research cards and list surfaces so they match the sleeker shell.
2. Tighten any spacing inconsistencies on other screens that reuse the same color and type system.
3. Check the explore screen on smaller devices to confirm the collapsed filter panel still feels compact and usable.
4. Decide whether the collapsed filter panel should stay as-is or be styled more like a floating sheet.

## Useful Context For Discussion

If someone asks why the current design looks the way it does, the answer is:

- Keep the app recognizable.
- Keep the existing color scheme.
- Preserve the bottom navbar style.
- Reduce wasted vertical space in the explore area.
- Make the home shell flatter and cleaner.
- Keep the filter experience available, but not constantly consuming screen real estate.

## Short Summary

The app was visually streamlined without changing its identity. The main wins were a flatter top header, a centered notification icon, a preserved bottom navbar, and a collapsed explore filter system that can be expanded on demand.
