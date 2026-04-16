# UI Handoff Notes

Date: 2026-04-16
Commits:
- `242fc11` (`feat: add paper permissions and enforce access across app`)
- `1d77909` (`feat(ui): refine explore card layout and interactions`)

## Purpose

This note captures the full session breakdown for research submission/view permissions, dynamic paper metrics, and Explore card redesign decisions so the next session can continue without re-discovery or rework.

## High-Level Outcome

The session delivered two major outcomes in one coherent workflow:

1. A permission-aware paper lifecycle from submission to viewing (download/highlight controls).
2. Dynamic, data-correct paper engagement tracking (views increment on detail open and refresh in Explore).
3. A more informative and interaction-rich Explore card system with stronger visual hierarchy.
4. Documentation and migration readiness for database alignment and onboarding continuity.

## What Changed

### 1) Paper Permission Model and Data Plumbing

Files:
- `lib/data/models/research_model.dart`
- `lib/data/repositories/research_repository.dart`
- `lib/data/services/supabase_service.dart`

What changed:
- Added paper-level flags to `ResearchModel`:
	- `allowDownload`
	- `allowHighlight`
- Added backward-safe bool parsing in the model for resilient deserialization (`bool`, numeric, and string-ish values).
- Extended repository submit API to carry both permission flags.
- Extended Supabase submit payload to persist:
	- `allow_download`
	- `allow_highlight`

Why this mattered:
- The app now supports explicit author controls for access behavior.
- Old records remain readable due safe parsing defaults.
- The permission contract is now consistent from model to backend payload.

Behavioral impact:
- New submissions can carry permission intent.
- Existing records remain stable and non-breaking.

### 2) Database Migration Readiness

File:
- `docs/06-research-permissions-migration.sql`

What changed:
- Added migration script to add permission columns if they do not yet exist:
	- `allow_download`
	- `allow_highlight`
- Set defaults to `false` for restricted-by-default behavior.

Why this mattered:
- Database and app model are now aligned.
- Enables immediate rollout in Supabase without schema guessing.

### 3) Dynamic View Count Activation and Route Flow Fix

Files:
- `lib/data/services/supabase_service.dart`
- `lib/routes/app_routes.dart`
- `lib/presentation/screens/research/browse_research_screen.dart`
- `lib/presentation/screens/research/research_detail_screen.dart`

What changed:
- Fixed stale view count behavior by ensuring detail opens are ID-based and fetch fresh paper state.
- `getResearchById` now:
	1. fetches the paper,
	2. increments view count via RPC,
	3. refetches the row and returns updated data.
- Explore list now refreshes after returning from detail so updated counters are visible.
- Route generator now supports both argument forms for compatibility:
	- new path: `String paperId`
	- fallback path: `ResearchModel`

Why this mattered:
- View counts are no longer static in UX flow.
- Prevents dead-code metrics behavior.
- Preserves backward compatibility while transitioning to ID-driven detail loading.

### 4) Submit Research Workflow Permissions UI

File:
- `lib/presentation/screens/research/submit_research_screen.dart`

What changed:
- Added two author-facing toggles in submit flow:
	- Allow full-screen/download access
	- Allow highlighting/selecting text
- Both toggles default to OFF for privacy-first submissions.
- Added explanatory helper copy for each permission.
- Wired values through submit pipeline into repository/service.

Why this mattered:
- Access behavior is now author-controlled at submission time.
- UX makes permission implications explicit before publishing.

### 5) Detail Screen Permission Enforcement

File:
- `lib/presentation/screens/research/research_detail_screen.dart`

What changed:
- Refactored detail screen constructor to use `paperId` with optional `initialPaper` fallback.
- Added async loading/error state for robust detail fetch behavior.
- Enforced `allowDownload` in PDF open action:
	- blocks full-screen/external open when disabled,
	- shows restriction feedback.
- Applied `allowHighlight` to PDF viewer text selection behavior where supported.
- Added metadata rows in detail to show current permission states.

Why this mattered:
- Permissions now affect runtime behavior, not just stored data.
- Users get transparent access-state feedback in detail screen.

### 6) Explore Card Information Architecture and Visual Iteration

File:
- `lib/presentation/screens/research/browse_research_screen.dart`

What changed across iterations:
- Replaced non-informative card string area with meaningful metadata.
- Final list-card hierarchy now emphasizes:
	1. Title
	2. Author (directly below title)
	3. Department (below author)
	4. Authored/Approved dates as secondary information
- Keywords were moved to the footer-left slot (where author had previously been).
- Removed overly attention-grabbing icons in final pass:
	- removed top-right arrow icon in list cards,
	- removed tag icon before keywords.
- Preserved yellow keyword bubble treatment while neutralizing department color.
- Added subtle interaction design:
	- hover/press swell animation,
	- focused border/shadow response,
	- long-press light haptic feedback.

Why this mattered:
- Card content now prioritizes what users scan first.
- Interaction feedback improves polish without visual noise.
- Visual hierarchy aligns with user-requested academic card conventions.

### 7) Validation and Tooling Notes

What was run:
- File-level diagnostics for edited Dart files (no blocking errors in changed files).
- `flutter analyze` for project-wide check.

Result:
- No new analyzer errors introduced by this session changeset.
- Existing repo-wide informational warnings remained unchanged.

## Design Decisions That Were Deliberately Preserved

- The app color identity (NU blue + gold accent) was preserved.
- Navigation structure was preserved; route compatibility retained during transition.
- Existing workflow semantics remained additive; no unrelated feature removal was done.
- Unrelated generated platform files were intentionally excluded from commits.
- Submit flow and detail flow now include permissions without breaking old records.

## Files Changed in the Session Commits

Commit `242fc11`:
- `docs/06-research-permissions-migration.sql`
- `lib/data/models/research_model.dart`
- `lib/data/repositories/research_repository.dart`
- `lib/data/services/supabase_service.dart`
- `lib/presentation/screens/research/browse_research_screen.dart`
- `lib/presentation/screens/research/research_detail_screen.dart`
- `lib/presentation/screens/research/submit_research_screen.dart`
- `lib/routes/app_routes.dart`

Commit `1d77909`:
- `lib/presentation/screens/research/browse_research_screen.dart`

## Current Repo State

After these commits, unrelated generated plugin files are still modified in the working tree and were intentionally left untouched:

- `linux/flutter/generated_plugin_registrant.cc`
- `linux/flutter/generated_plugin_registrant.h`
- `linux/flutter/generated_plugins.cmake`
- `macos/Flutter/GeneratedPluginRegistrant.swift`
- `windows/flutter/generated_plugin_registrant.cc`
- `windows/flutter/generated_plugin_registrant.h`
- `windows/flutter/generated_plugins.cmake`

They are not part of the session deliverables above.

## What Was Tried Along the Way

Explore card evolution in this session included several intentional iterations:

- Bubble-first metadata approach for department/authored/approved lines.
- Shift to plain text metadata under title for reduced visual clutter.
- Author placement moved to standard academic position directly below title.
- Department moved below author; keywords moved to footer-left area.
- Reintroduction of icons for readability and hierarchy guidance.
- Removal of icon noise (top-right arrow and keyword tag icon) after usability review.
- Final hierarchy tuning so Author/Department read stronger than dates.

This history matters because the final card is the result of targeted, user-driven refinement rather than a single-pass redesign.

## Handoff Notes For the Next Session

Recommended follow-up options:

1. Decide final long-term placement and style of Authored/Approved dates (currently secondary lines under department).
2. Consider optional per-role visibility for permission metadata in detail view.
3. If strict anti-download is required on web, migrate from public URLs to private storage + signed URLs.
4. Add focused tests for permission behavior and view counter increments.
5. Re-check card density and readability on smaller devices after larger paper datasets are loaded.

## Useful Context For Discussion

If someone asks why the current implementation looks the way it does, the answer is:

- Make paper cards informative without overloading attention.
- Keep hierarchy consistent with research-card reading habits (title -> author -> department).
- Keep permissions explicit, additive, and enforceable in runtime.
- Keep engagement metrics real (not static) in day-to-day navigation.
- Preserve compatibility while transitioning route/data flow behavior.

## Short Summary

This session completed a full permission-aware research flow and a substantial Explore card refinement cycle. The app now supports author-controlled paper access, increments and refreshes view counts correctly, and presents richer paper metadata with clearer hierarchy and improved interaction feedback.
