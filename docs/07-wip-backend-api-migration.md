# WIP Backend API Migration Handoff

This document is the restart point for the mobile backend migration work. It captures what changed, why it changed, what is still unresolved, and what to check first when you come back.

## Quick Resume

- Checkpoint commit: `5c31bfc` (`WIP: backend API migration cleanup`)
- Current blocker still visible in the browser: `Client failed to fetch, uri=http://localhost:5001/api/auth/login`
- Fastest next place to look: backend CORS/origin allowlist, then `lib/data/services/backend_api_service.dart` if you are validating the mobile client path

## Current checkpoint

- Branch/state: `feat/mobile-submit-parity`
- Latest WIP commit: `5c31bfc`
- Commit message: `WIP: backend API migration cleanup`
- Status at checkpoint: mobile repo was clean after the migration and cleanup pass

## What was changed

### 1) The mobile app moved from direct Supabase access to the shared backend API

The main architectural change is that the mobile client no longer talks to Supabase directly for app behavior. It now calls the backend API, and the backend continues to own the actual Supabase access.

That includes:

- authentication
- session refresh
- authorization and role checks
- research retrieval and tracking
- department and program lookups
- notifications
- analytics and admin operations
- file access and signed/public URL resolution

The mobile client side now uses a single API base URL sourced from `API_URL`.

### 2) Auth/session handling was rebuilt around backend tokens

The mobile app now persists backend-issued access and refresh tokens in SharedPreferences.

Key behavior changes:

- login goes through the backend `/auth/login` endpoint
- registration goes through the backend `/auth/register` endpoint
- `getCurrentUser` goes through `/auth/me`
- refresh tokens are used when the API returns `401`
- session detection treats either stored token as a valid session signal
- logout clears both access and refresh tokens plus stored user metadata

The app also now rejects non-student accounts in the mobile flow. The mobile experience is intentionally student-only, while faculty, dean, staff, and admin continue in the shared backend/web workflow.

### 3) Domain models were widened to match backend payloads

Several models were updated so the mobile app can consume the backend response shapes without breaking on naming differences.

Updated models:

- `user_model.dart`
- `research_model.dart`
- `department_model.dart`
- `faculty_member_model.dart`
- `student_model.dart`
- new `program_model.dart`

These changes added support for:

- camelCase and snake_case fields
- department and program IDs
- nested department programs
- nested author data on research papers
- view/download counters
- defaulting `allowDownload` and `allowHighlight` to `false`
- safer integer parsing for counters and sizes

### 4) UI flows were updated to use backend data sources

The following screens were wired to the new backend-driven behavior:

- `get_started_screen.dart`
- `register_screen.dart`
- `research_detail_screen.dart`
- `pdf_viewer_screen.dart`

Important UI behavior changes:

- the onboarding/session gate now checks stored tokens, not just a user ID
- student registration now loads departments and programs from the backend
- registration requires both department and program selection when data is available
- research detail now tracks views through the backend
- PDF viewing/download tracking is handled through the backend API layer

### 5) The repo cleanup removed old Supabase-only artifacts

Cleanup work included:

- deleting `lib/config/supabase_config.dart`
- removing `supabase_flutter` from the dependency graph
- refreshing `pubspec.lock`
- replacing old Supabase service logic with the new backend API service while keeping the old service import path as a compatibility layer
- updating `README.md`
- updating `docs/00-project-context-mobile.md`
- adding a Windows web launcher script for an allowed backend origin
- refreshing generated plugin registrants for desktop platforms

## Errors addressed in this checkpoint

These were the concrete issues we addressed during the migration pass:

- `supabase_flutter` was removed from the mobile dependency graph, so the app no longer depends on the direct client package.
- `lib/config/supabase_config.dart` was deleted because the mobile runtime no longer needs direct Supabase URL/key bootstrapping.
- The mobile auth flow was moved to backend endpoints, which removed the old direct Supabase login/register/session path from the app layer.
- Session persistence was fixed to store and refresh backend-issued access/refresh tokens, instead of relying on a bare `user_id` check.
- The student-only gate was enforced in the mobile repo, so non-student roles are rejected early instead of drifting into unsupported screens.
- Research payload parsing was hardened to handle both camelCase and snake_case fields, nested author data, integer coercion, and default flags.
- Student registration was updated to load departments and programs from the backend, which fixed the old mismatch between form selection and backend IDs.
- Research view and download tracking were moved into the backend API flow so the mobile app no longer tries to own those counters directly.
- Platform plugin registrants were regenerated after dependency cleanup so the desktop builds stay aligned with the current package graph.

## What still persists

These are the problems and technical follow-ups that still remain after the checkpoint:

- Browser login still fails with the fetch error against `http://localhost:5001/api/auth/login` because the backend CORS/origin allowlist does not currently accept the Chrome origin being used.
- That browser-only failure is not fixable purely inside the mobile repo; the origin allowlist must be corrected in the backend server configuration.
- The duplicate PDF viewer implementation still exists in both `research_detail_screen.dart` and `pdf_viewer_screen.dart`.
- Any backend payload changes in future sessions can still break the model normalization layer, so the parser/mapping code may need another pass.
- The mobile app still depends on the backend being reachable at the configured `API_URL`; if that host changes, the `.env` and launch workflow must be updated together.

## Why this migration happened

This was done for a unified backend architecture, not just to patch one mobile bug.

The backend repo already owns the real business rules and database access, so moving the mobile app onto the same backend means:

- one auth/session contract
- one place for permission logic
- one place for payload shaping and compatibility fixes
- one place for research/department/program workflows
- less drift between the mobile and web behavior

The web app is also using the backend API pattern. The mobile app was being brought into the same contract instead of keeping a separate direct-Supabase client path.

## What the backend still does with Supabase

The backend still uses Supabase internally for the actual data operations, including:

- auth user creation and lookup
- token/session refresh support
- users, research papers, notifications, departments, programs, workflow stages, and audit logs
- file upload and file URL generation
- signed URL generation for private files
- cleanup scripts and migration checks

So the migration is not “removing Supabase from the system.” It is “moving Supabase behind the backend so clients stop speaking to it directly.”

## What still needs to be done

### 1) Fix the browser CORS/origin issue in the backend repo

The Chrome login failure is still a backend origin/allowlist problem.

What to do there:

- open the backend repo
- inspect the CORS/origin allowlist middleware or server configuration
- add the dev origin you are actually using in Chrome
- keep the API host aligned with the frontend origin used in web mode

This cannot be solved fully from the mobile repo alone because the browser request is blocked before it reaches the API logic.

### 2) Decide whether the duplicate PDF viewer should be consolidated

There is duplicated PDF viewer logic between:

- `research_detail_screen.dart`
- `pdf_viewer_screen.dart`

Later cleanup could make the standalone viewer the single source of truth and remove the embedded duplicate implementation.

### 3) Re-check any backend payload changes if they happen again

The model normalization was made to handle the backend response shapes seen during this migration. If backend response fields change later, the mobile models may need another pass.

## What to reopen first when you come back

If you want the fastest re-entry path, open these files first:

- `lib/data/services/backend_api_service.dart`
- `lib/data/repositories/auth_repository.dart`
- `lib/data/repositories/research_repository.dart`
- `lib/presentation/screens/auth/register_screen.dart`
- `lib/presentation/screens/research/research_detail_screen.dart`
- `lib/presentation/screens/research/pdf_viewer_screen.dart`
- `scripts/run_flutter_web.ps1`
- `docs/00-project-context-mobile.md`

## How to continue from here

### If the goal is to finish the browser login fix

1. Switch to the backend repo.
2. Update the CORS/origin allowlist so the current Chrome origin is accepted.
3. Verify the API base URL and frontend origin are consistent.
4. Restart the backend and retest login in Chrome.

### If the goal is to keep working in the mobile repo

1. Confirm `API_URL` in the root `.env` file.
2. Use the allowed-origin web launcher script for browser testing.
3. Run a full app restart after env changes.
4. Re-test login and session refresh.
5. If needed, simplify the duplicate PDF viewer implementation.

### If the goal is just to resume the migration cleanly

1. Read this file.
2. Review commit `5c31bfc`.
3. Reopen the backend API service and the auth repository.
4. Check whether the app still needs any payload normalization updates.

## Important implementation details to remember

- Mobile auth is student-only by design.
- Access and refresh tokens are stored locally and used by the API interceptor.
- The backend is the source of truth for auth, permissions, and data access.
- The mobile app uses backend endpoints for departments, programs, categories, research, notifications, and admin/system data.
- The browser CORS issue is not fixable from the mobile client alone.

## Short summary

This checkpoint represents the mobile cutover from direct Supabase access to a backend-mediated architecture. The mobile repo was cleaned up, token/session handling was aligned with backend auth, and the project docs were updated. The next blocking item is the backend CORS/origin fix for browser login; everything else is follow-up cleanup or validation.