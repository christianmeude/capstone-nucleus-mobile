# DFD Level 2 - Submit Research Paper

```mermaid
flowchart LR
    E1[Student]
    D1[(D1 Users)]
    D2[(D2 Research Papers)]
    D3[(D3 Research Categories)]
    D5[(D5 Research Paper Files)]

    subgraph S[3.0 Submit Research Paper - Level 2]
        P32((3.2 Load Submission Options))
        P31((3.1 Validate Submission Data))
        P33((3.3 Upload PDF File))
        P34((3.4 Create Submission Record))
        P35((3.5 Return Submission Result))
    end

    E1 -->|request submission form options| P32
    P32 -->|read categories| D3
    P32 -->|read co-author and advisor options| D1
    P32 -->|available options| E1

    E1 -->|completed form and selected PDF| P31
    P31 -->|valid metadata| P34
    P31 -->|valid PDF| P33
    P31 -->|validation errors| E1

    P33 -->|store PDF| D5
    D5 -->|file URL or path| P34

    P34 -->|insert paper with initial status| D2
    P34 -->|submission id and status| P35
    P35 -->|confirmation message| E1
```

## Description

This Level 2 DFD details Process 3.0 (Submit Research Paper) by breaking it into five sub-processes.

- 3.2 Load Submission Options reads categories plus user lists for advisor and co-author selection.
- 3.1 Validate Submission Data checks metadata completeness and PDF constraints.
- 3.3 Upload PDF File stores the selected PDF and returns a file path or URL.
- 3.4 Create Submission Record inserts the research paper row with workflow status.
- 3.5 Return Submission Result sends success feedback to the student.

The diagram emphasizes a gated flow: invalid data returns to the student immediately, while valid data continues to upload and persistence.

## Code Alignment (Student Submit Flow)

- Options loading:
    - lib/presentation/screens/research/submit_research_screen.dart
    - lib/data/repositories/research_repository.dart
    - lib/data/services/supabase_service.dart
- Validation checks in UI:
    - required category
    - title minimum length
    - abstract minimum length
    - PDF-only and max file size checks
    - lib/presentation/screens/research/submit_research_screen.dart
- File upload plus record insert:
    - lib/data/services/supabase_service.dart
- Workflow status assignment:
    - faculty selected -> pending_faculty
    - no faculty -> pending_editor
    - lib/data/services/supabase_service.dart

## Accuracy Notes

- The diagram is aligned with the implemented submit lifecycle.
- In code, upload and insert are executed sequentially inside one service call, while the diagram presents them as separate logical sub-processes.
- The process numbering order is presentation-oriented; in runtime, options are loaded on screen init, then validation occurs on submit.
