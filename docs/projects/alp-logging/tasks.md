## Tasks — ERD: ALP Logging Consistency

## Relevant Files

- `.cursor/rules/assistant-behavior.mdc`
- `.cursor/rules/assistant-learning.mdc`
- `.cursor/scripts/alp-logger.sh`
- `docs/assistant-learning-logs/README.md`

## Todo

- [ ] 1.0 Update `assistant-behavior.mdc`: consent exception precedence + end-of-turn ALP-needed? check (send gate)
- [ ] 2.0 Update `assistant-learning.mdc`: explicit triggers, concise schema, duplicate guard, destination semantics
- [ ] 3.0 Update `docs/assistant-learning-logs/README.md`: cheat sheet + examples + heredoc templates
- [ ] 4.0 Add usage examples to `README.md`: minimal commands for logger and template tool
- [ ] 5.0 Emit ALP entries when completing 1.0–4.0 (Task Completed logs)
