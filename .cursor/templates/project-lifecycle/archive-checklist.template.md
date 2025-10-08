# Archive Checklist — <Project Name>

1. Closure Checklist (Definition of Done)

   - ERD front matter has `status: completed`, `completed: <YYYY-MM-DD>`, `owner: <handle>`
   - All items in `tasks.md` are checked off
   - ADRs updated/added (if any)
   - User-facing docs/examples updated
   - Ownership/handoff note present (next review date)

2. Final Summary (pre-move preferred)

   - Command:
     - Pre-move: `.cursor/scripts/final-summary-generate.sh --project <slug> --year <YYYY> --pre-move [--date YYYY-MM-DD] [--force]`

3. Single full-folder move (policy)

   - Command: `.cursor/scripts/project-archive.sh --project <slug> --year <YYYY>`
   - Destination: `docs/projects/_archived/<YYYY>/<slug>/`

4. Projects index update

   - Move entry from Active → Completed in `docs/projects/README.md`
   - Link: `../_archived/<YYYY>/<slug>/erd.md`

5. Validators
   - `.cursor/scripts/rules-validate.sh`
   - `.cursor/scripts/project-lifecycle-validate.sh` (dry-run is fine)
   - `.cursor/scripts/links-check.sh`
