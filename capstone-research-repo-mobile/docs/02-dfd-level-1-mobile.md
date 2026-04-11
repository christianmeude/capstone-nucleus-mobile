# DFD Level 1 - Student Mobile

```mermaid
flowchart LR
    E1[Student]

    subgraph P[NUcleus Student Mobile App Processes]
        P1((1.0 Authenticate Student))
        P2((2.0 Browse Published Research))
        P3((3.0 Submit Research Paper))
        P4((4.0 View My Papers and Analytics))
        P5((5.0 Open and Download PDF))
    end

    subgraph D[Supabase Student-Facing Data Stores]
        D1[(D1 Users)]
        D2[(D2 Research Papers)]
        D3[(D3 Research Categories)]
        D4[(D4 Paper Downloads)]
        D5[(D5 Research Paper Files)]
    end

    E1 -->|credentials and registration data| P1
    P1 -->|read or create student account| D1
    P1 -->|login result and session| E1

    E1 -->|search text and filters| P2
    P2 -->|fetch approved or published papers| D2
    P2 -->|paper list and details preview| E1

    E1 -->|title, abstract, category, optional co-authors, optional advisor, PDF| P3
    P3 -->|load categories| D3
    P3 -->|lookup co-authors and advisor options| D1
    P3 -->|upload PDF| D5
    P3 -->|create submission and initial status| D2
    P3 -->|submission confirmation| E1

    E1 -->|my papers and analytics request| P4
    P4 -->|read own submissions and metrics| D2
    P4 -->|status summary and analytics view| E1

    E1 -->|open paper or download request| P5
    P5 -->|fetch PDF file| D5
    P5 -->|read or update view and download counters| D2
    P5 -->|insert download log| D4
    P5 -->|PDF preview or download response| E1
```

## Description

This Level 1 DFD decomposes the mobile app into five student-facing processes and shows how each process exchanges data with Supabase data stores.

- Process 1.0 authenticates students and manages session-related account reads and writes.
- Process 2.0 retrieves approved or published papers for exploration.
- Process 3.0 orchestrates submission: reference data loading, file upload, and paper record creation.
- Process 4.0 returns student-owned papers and analytics summaries.
- Process 5.0 handles PDF opening and download-related updates.

The key structural idea is process-to-store mapping: each app process touches only the stores needed for that student use case.

## Data Store Mapping To Code

- D1 Users
    - Authentication and profile lookups.
    - Co-author and faculty lookup sources.
    - lib/data/services/supabase_service.dart
- D2 Research Papers
    - Browse reads, my papers reads, submission inserts, status and counters.
    - lib/data/services/supabase_service.dart
- D3 Research Categories
    - Submit form category options.
    - lib/data/services/supabase_service.dart
- D4 Paper Downloads
    - Download log inserts.
    - lib/data/services/supabase_service.dart
- D5 Research Paper Files
    - PDF storage upload and file URL usage.
    - lib/data/services/supabase_service.dart

## Accuracy Notes

- The decomposition is accurate for the student app flow in:
    - lib/presentation/screens/home/home_screen.dart
- Process 4.0 is shown as one process in the diagram, but is implemented as two tabs:
    - lib/presentation/screens/research/my_research_screen.dart
    - lib/presentation/screens/research/analytics_screen.dart
- Process 5.0 is architecturally correct, but download tracking methods are currently defined in repository and service layers and are not directly invoked by the current research detail screen interaction path.
    - lib/data/repositories/research_repository.dart
    - lib/data/services/supabase_service.dart
    - lib/presentation/screens/research/research_detail_screen.dart
