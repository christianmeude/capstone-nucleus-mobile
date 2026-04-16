-- Adds paper-view permission columns used by the mobile submit/view workflow.
-- New submissions default to restricted access unless the author enables options.

alter table public.research_papers
  add column if not exists allow_download boolean;

alter table public.research_papers
  add column if not exists allow_highlight boolean;

alter table public.research_papers
  alter column allow_download set default false;

alter table public.research_papers
  alter column allow_highlight set default false;
