# NUcleus Mobile

Student research repository app for National University - Dasmarinas.

NUcleus Mobile helps students discover published research, submit capstone and research outputs, and track personal research performance from mobile devices.

---

## Project Overview

NUcleus Mobile is a student-focused research platform that combines discovery, submission, and analytics into a single mobile workflow.

Core goals:
- Make published research easier to explore through search and metadata-rich cards.
- Support structured paper submission with PDF upload and workflow-ready metadata.
- Provide transparent tracking for engagement metrics such as views and downloads.
- Enable paper-level access controls for download and highlighting permissions.

---

## Scope

- Student-facing mobile experience.
- Browse and search approved research papers.
- Submit research papers with PDF upload.
- View own papers and personal analytics.

---

## Feature Breakdown

### Authentication and Onboarding
- Splash, get-started, login, and registration flow.

### Explore Research
- Search and filter published papers.
- List/tile view modes.
- Metadata-rich paper cards (author, department, dates, keywords, metrics).

### Research Detail and Document Viewing
- Detailed paper metadata and abstract.
- In-app PDF viewing.
- View/download metrics display.

### Submission Workflow
- Research submission with category and department.
- Co-author lookup and selection.
- PDF upload and metadata persistence.
- Author-controlled paper access flags:
  - allow download/full-screen access
  - allow text highlight/selection

### My Papers and Analytics
- Personal paper management.
- Status tracking and metric summaries.

---

## Tech Stack

| Layer | Technology |
| :--- | :--- |
| Framework | Flutter, Dart |
| Backend | Supabase (database, auth, storage) |
| State and Local Storage | flutter_riverpod, shared_preferences |
| File and Document Handling | file_picker, syncfusion_flutter_pdfviewer |
| UI and Motion | flutter_animate, shimmer, lottie |

---

## Getting Started

### 1) Clone the Repository

```bash
git clone https://github.com/christianmeude/capstone-nucleus-mobile.git
```

### 2) Install Dependencies

```bash
flutter pub get
```

### 3) Configure Environment Variables

Create a `.env` file in the project root:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 4) Run the App

```bash
flutter run
```

---

## Documentation

System design and analysis docs are available under the `docs/` directory:

- `docs/01-cld-mobile.md` - Context-Level Diagram
- `docs/02-dfd-level-1-mobile.md` - DFD Level 1
- `docs/03-dfd-level-2-mobile.md` - DFD Level 2
- `docs/04-hipo-mobile.md` - HIPO
- `docs/05-erd-mobile.md` - ERD
- `docs/06-research-permissions-migration.sql` - Permission columns migration script

---

## Team

| Role | Name | Contribution |
| :--- | :--- | :--- |
| Project Manager and Documentation | Jade Francine Bartolazo | Planning, requirements, and system documentation |
| Web System Developer | Malfoy de Vera | Web portal development and backend collaboration |
| Mobile App Developer | Christian Meude | Flutter architecture and implementation |

---

*Developed for National University - Dasmarinas, BS Information Technology.*