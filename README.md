# NUcleus Mobile

Student research repository app for National University - Dasmarinas.

NUcleus Mobile helps students discover published research, submit capstone and research outputs, and track personal research performance from mobile devices.

## Scope

- Student-facing mobile experience only.
- Browse and search approved research papers.
- Submit research papers with PDF upload.
- View own papers and analytics.

## Features

- Authentication flow: splash, get started, login, and registration.
- Explore Research screen with search and filters.
- Research detail with in-app PDF viewing.
- Submit Research with category selection, adviser selection, and co-author search.
- My Papers management.
- Analytics for views, downloads, and status distribution.

## Tech Stack

- Flutter and Dart
- Supabase backend and storage
- flutter_riverpod, shared_preferences, file_picker
- syncfusion_flutter_pdfviewer, flutter_animate, shimmer, lottie

## Installation

1. Clone the repository:

   git clone https://github.com/malfoydevera/capstone-nucleus-mobile.git
   cd capstone-nucleus-mobile

2. Install dependencies:

   flutter pub get

3. Create a .env file in the project root:

   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key

4. Run the app:

   flutter run

## Documentation

- docs/01-cld-mobile.md
- docs/02-dfd-level-1-mobile.md
- docs/03-dfd-level-2-mobile.md
- docs/04-hipo-mobile.md
- docs/05-erd-mobile.md

## Team

| Role | Name | Contribution |
| :--- | :--- | :--- |
| Project Manager and Documentation | Jade Francine Bartolazo | Planning, requirements, and system documentation |
| Web System Developer | Malfoy de Vera | Web portal development and backend collaboration |
| Mobile App Developer | Christian Meude | Flutter architecture and implementation |

---
Developed for National University - Dasmarinas, BS Information Technology