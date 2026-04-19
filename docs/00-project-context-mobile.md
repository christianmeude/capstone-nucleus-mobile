# NUcleus Mobile Project Context

This document is the canonical reference for the Flutter mobile app in this repository.
It is meant to be read before starting future sessions so the mobile scope, data model,
and relationship to the broader web platform stay consistent.

## Relationship To The Web Platform

NUcleus Mobile is the student-facing modular version of the broader NUcleus web platform
in https://github.com/malfoydevera/capstone-nucleus.

The web app is the full multi-role system. It serves:

- student
- faculty
- program chair
- dean
- staff
- admin

The mobile app is not a separate product. It is the mobile slice of the same research
domain, shared backend, and workflow vocabulary. The mobile UI focuses on the student
experience, while the web app contains the full review and administration surface.

### Web/Mobile Parity Rule

When a workflow exists in both apps, the web app should be treated as the reference for:

- field names
- workflow status values
- submission ordering
- review semantics
- permission behavior
- file and metadata handling

If the mobile app diverges, the first question should always be whether the divergence is
intentional or just an unfinished parity gap.

## Product Identity

- App name: NUcleus Mobile
- Product type: student research repository app
- Platform: Flutter mobile application
- Backend: Supabase for auth, database, and storage
- Primary audience: students of National University - Dasmarinas

The app lets students browse approved research, submit new research outputs, open paper
details, and track their own submissions and performance metrics.

## Scope Boundary

### In Scope

- Student onboarding and authentication
- Browse and search published research
- Submit research papers with PDF upload
- View paper details and preview PDFs
- Track personal submissions and analytics
- See profile, notifications, settings, and student guide screens

### Out Of Scope For Mobile UI

- Faculty adviser dashboard and queue management
- Dean and program chair review tools
- Staff/editor review queues and metadata correction tools
- Admin user management and system health dashboards
- Workflow administration and audit tooling

The data layer still knows about broader roles and workflow actions because it stays
aligned with the shared backend contract, but those screens are not exposed in the mobile
navigation.

## Role Model

The codebase defines multiple roles in the shared constants and backend contract, but the
mobile login flow only accepts students into the app shell.

- `student` is the only supported active mobile role.
- `faculty`, `staff`, `admin`, `dean`, and `program_chair` exist in the shared model and
  backend workflow, but they are not allowed through the mobile home flow.

The login screen explicitly rejects non-student accounts after authentication.

## App Flow

The visible mobile flow is:

1. Splash screen
2. Landing screen
3. Get started screen
4. Login or register
5. Student home shell
6. Browse research, My Research, and Analytics tabs
7. Research detail or submission flows when opened from the home shell

### Route Map

The current route set includes:

- splash
- get-started
- landing
- login
- register
- home
- submit-research
- research-detail
- profile
- settings
- notifications
- guide

The home screen uses an `IndexedStack` with three core tabs:

- Browse Research
- My Research
- Analytics

The submission screen is opened separately from the home shell, and the research detail
screen is opened from browse or personal paper views.

## Core Student Workflow

### 1. Browse Published Research

Students can search published papers, switch between list and tile views, and filter by
search scope and sort category.

Current behavior:

- loads approved or published papers from the backend
- supports filtering by title, author, keywords, or all fields
- sorts by recent or popular when requested
- refreshes the list after returning from a paper detail view so updated counters are
  visible

### 2. Submit Research

The submission flow is the most important parity target for the student mobile app.

Students provide:

- title
- abstract
- keywords
- category
- department
- optional faculty adviser
- optional co-authors
- PDF file
- access flags for download and text highlighting

Submission behavior:

- PDF files are validated before upload
- the file is uploaded to Supabase storage in the `research-papers` bucket
- a `research_papers` record is inserted after upload
- the initial workflow status is chosen from the submission context
  - `pending_faculty` when a faculty adviser is selected
  - `pending_editor` when the paper goes directly to editorial review

The app treats the submit flow as a structured workflow, not just a file upload form.
The same field semantics should remain stable whenever the mobile and web forms are
changed together.

### 3. View Research Details

The detail screen shows:

- title and author metadata
- department and category context
- keywords
- abstract
- document preview
- paper statistics
- workflow history where available

Behavioral rules:

- opening a paper detail fetches the latest record from the backend
- view counts are incremented when the paper is opened
- the detail screen enforces the paper-level access flags
- download/full-screen access is blocked when `allowDownload` is false
- text selection/highlighting is controlled by `allowHighlight`

### 4. Track My Research And Analytics

Students can review their own papers in `My Research` and see aggregate metrics in
`Analytics`.

`My Research` currently supports:

- status filters for published, pending, rejected, and all
- search over title, author, department, and keywords
- newest-first ordering

`Analytics` currently summarizes:

- total views
- total downloads
- paper status distribution
- top-performing papers by view count

## Data Model And Backend Contract

The mobile app relies on a shared Supabase-backed contract that mirrors the web platform.

### Core Models

- `UserModel` for authenticated users
- `StudentModel` for co-author selection
- `ResearchModel` for research papers and workflow metadata
- `CategoryModel` for research categories
- `DepartmentModel` for department filtering and adviser selection
- `FacultyMemberModel` for adviser lookup

### Important Research Fields

The mobile app currently treats these fields as core to the research record:

- author_id
- title
- abstract
- keywords
- category
- co_authors
- file_url
- file_name
- file_size
- status
- faculty_id
- department
- department_id
- revision_notes
- rejection_reason
- view_count
- download_count
- allow_download
- allow_highlight

### Shared Workflow Status Vocabulary

The student app uses the same workflow status family as the broader system:

- `pending_faculty`
- `pending_dean`
- `pending_program_chair`
- `pending_editor`
- `pending_admin`
- `approved`
- `rejected`
- `revision_required`

Not every status is surfaced in the mobile UI, but the values are part of the shared
domain and should remain consistent across client and backend changes.

### Service Layer Responsibilities

`SupabaseService` is the main integration point and covers:

- login and registration
- local session persistence
- fetching published papers
- fetching personal papers
- fetching paper details
- submitting new research
- tracking downloads and views
- loading categories, departments, faculty members, and students
- broader workflow operations retained for backend parity

## Navigation And Screen Map

### Authentication Screens

- Splash screen: app entry animation and startup handoff
- Landing screen: marketing and entry point to login/register
- Get started screen: onboarding step before authentication
- Login screen: student sign-in and role gate
- Register screen: student account creation

### Student Home And Shared Screens

- Home screen: shell with browse, my research, and analytics tabs
- Profile dashboard: student profile area
- Notifications: in-app updates and workflow-related notices
- Settings: student app preferences
- Student guide: user guidance and workflow help

### Research Screens

- Browse research: published paper discovery and search
- Submit research: structured submission form and file upload
- Research detail: paper metadata, PDF preview, and permissions
- PDF viewer: expanded document viewing on supported platforms

## UI And Design Language

The app uses a restrained university-branded visual system:

- primary blue and gold accent colors
- light surfaces and soft shadows
- rounded cards and pill filters
- animated loading states and micro-interactions
- informative metadata-heavy paper cards

The visual language should stay academic and readable rather than decorative.

## Key Technical Building Blocks

### Startup And Shell

- `main.dart` loads `.env` and initializes Supabase before the app starts
- `app.dart` builds the `MaterialApp` shell and route system
- `app_routes.dart` owns named navigation and research detail argument handling

### State And Storage

- `SharedPreferences` stores local session values such as user ID, email, role, and name
- `StorageKeys` keeps those local storage keys centralized
- app constants define supported roles, statuses, and file limits

### Backend And Network Dependencies

- `http`
- `file_picker`
- `open_filex`
- `syncfusion_flutter_pdfviewer`
- `url_launcher`
- `flutter_dotenv`
- `flutter_riverpod`
- `shared_preferences`
- `bcrypt`

### Design System Files

- `lib/core/constants/app_colors.dart`
- `lib/core/constants/app_text_styles.dart`
- `lib/core/constants/app_theme.dart`
- `lib/core/constants/app_constants.dart`

## Where To Read First In Future Sessions

If you need to understand the app quickly, start with:

- [lib/main.dart](../lib/main.dart)
- [lib/app.dart](../lib/app.dart)
- [lib/routes/app_routes.dart](../lib/routes/app_routes.dart)
- [lib/data/services/supabase_service.dart](../lib/data/services/supabase_service.dart)
- [lib/data/repositories/auth_repository.dart](../lib/data/repositories/auth_repository.dart)
- [lib/data/repositories/research_repository.dart](../lib/data/repositories/research_repository.dart)
- [lib/data/models/research_model.dart](../lib/data/models/research_model.dart)
- [lib/presentation/screens/auth/login_screen.dart](../lib/presentation/screens/auth/login_screen.dart)
- [lib/presentation/screens/research/submit_research_screen.dart](../lib/presentation/screens/research/submit_research_screen.dart)
- [lib/presentation/screens/research/browse_research_screen.dart](../lib/presentation/screens/research/browse_research_screen.dart)
- [lib/presentation/screens/research/research_detail_screen.dart](../lib/presentation/screens/research/research_detail_screen.dart)
- [lib/presentation/screens/research/my_research_screen.dart](../lib/presentation/screens/research/my_research_screen.dart)
- [lib/presentation/screens/research/analytics_screen.dart](../lib/presentation/screens/research/analytics_screen.dart)

## Existing Docs In This Repo

The following docs already provide supporting analysis for the mobile app:

- `docs/01-cld-mobile.md`
- `docs/02-dfd-level-1-mobile.md`
- `docs/03-dfd-level-2-mobile.md`
- `docs/04-hipo-mobile.md`
- `docs/05-erd-mobile.md`
- `docs/06-research-permissions-migration.sql`

## Short Summary

NUcleus Mobile is the student-only mobile module of the wider NUcleus platform. It
shares the same research domain and backend contract as the web app, but only exposes
the student experience: sign in, browse published papers, submit research, open paper
details, and monitor personal progress. For future work, the web app should be treated
as the reference point for workflow parity whenever mobile submission or research
review behavior needs to match exactly.