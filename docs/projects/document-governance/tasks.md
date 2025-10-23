## Tasks — Document Governance Policy

**Status**: ACTIVE | Phase: 1 | 0% Complete

---

## Phase 1: Policy Definition (2-3 hours)

- [ ] 1.0 Define approved document categories
  - [ ] 1.1 List approved documents for simple projects (3-5 files)
  - [ ] 1.2 List approved documents for investigation projects (15+ files)
  - [ ] 1.3 List approved documents for specialized projects (if any)
  - [ ] 1.4 Document rationale for each category
- [ ] 1.5 Create decision tree for document type selection
  - [ ] 1.6 Map common needs → approved document types
  - [ ] 1.7 Add examples of when to use each type
  - [ ] 1.8 Add examples of when NOT to create documents
- [ ] 1.9 Define approval criteria for new document types
  - [ ] 1.10 What information must be provided to request approval?
  - [ ] 1.11 When should assistant suggest alternatives first?
  - [ ] 1.12 Is approval session-scoped or permanent?

## Phase 2: Rule Implementation (2-3 hours)

- [ ] 2.0 Create `.cursor/rules/document-governance.mdc`
  - [ ] 2.1 Document approved categories from Phase 1
  - [ ] 2.2 Add consent gate behavior (check before file creation)
  - [ ] 2.3 Add prompt templates for approval requests
  - [ ] 2.4 Add decision tree for assistant to follow
  - [ ] 2.5 Add examples of good/bad document structures
- [ ] 2.6 Integrate with pre-send gate
  - [ ] 2.7 Add "Document governance: checked?" to pre-send checklist
  - [ ] 2.8 Test gate triggers correctly on file creation
- [ ] 2.9 Update related rules
  - [ ] 2.10 Update `project-lifecycle.mdc` with governance reference
  - [ ] 2.11 Update `investigation-structure.mdc` with governance reference
  - [ ] 2.12 Update `/project` command with governance reference

## Phase 3: Validation Tooling (Optional, 1-2 hours)

- [ ] 3.0 Create audit script
  - [ ] 3.1 Script reads approved categories from rule or config
  - [ ] 3.2 Script scans project directories for documents
  - [ ] 3.3 Script flags unapproved documents
  - [ ] 3.4 Script outputs report (JSON + text)
- [ ] 3.5 Test against existing projects
  - [ ] 3.6 Run on 3-5 active projects
  - [ ] 3.7 Run on 3-5 archived projects
  - [ ] 3.8 Validate findings (true positives vs. false positives)
- [ ] 3.9 Document findings and recommendations
  - [ ] 3.10 Create migration guidance for common violations
  - [ ] 3.11 Propose policy refinements based on audit results

## Carryovers

(Tasks moved from future phases or discovered during execution)

---

## Relevant Files

- `.cursor/rules/document-governance.mdc` — Policy rule (to be created)
- `.cursor/rules/assistant-behavior.mdc` — Pre-send gate integration
- `.cursor/rules/project-lifecycle.mdc` — Project structure guidance
- `.cursor/rules/investigation-structure.mdc` — Investigation structure guidance
- `docs/projects/_examples/` — Example project structures
- `.cursor/scripts/validate-document-governance.sh` — Audit script (to be created, Phase 3)
