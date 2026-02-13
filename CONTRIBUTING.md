# Contributing to Construct Themes Showcase

Thank you for helping improve this project.

This repository is a **showcase/reference project** for Crestron Construct themes. Contributions should keep the project focused, reproducible, and easy to validate.

## Code of Conduct

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Ways to Contribute

- Report bugs or incorrect behavior
- Suggest improvements to existing showcase pages/widgets
- Add or refine theme examples for supported widget types
- Improve documentation and usage guidance
- Improve generation/utility scripts under `Creation Scripts/`

## Before You Start

1. Open an issue describing the problem or proposed change (especially for large additions).
2. Keep changes scoped and focused on one topic.
3. Prefer minimal, clear updates over large redesigns.

## Development Notes

This project is primarily composed of Construct/SIMPL artifacts and generated UI assets.

- Main theme showcase assets are under folders like `LightDark/` and `SIMPL/`.
- Utility scripts and source data live in `Creation Scripts/`.
- Screenshots and documentation assets are in `Images/`.


## Pull Request Process

1. Fork the repository and create a branch from `main`.
2. Make your changes with clear, focused commits.
3. Update related documentation (for example, `README.md`) when behavior or usage changes.
4. Open a pull request with:
   - A concise summary
   - Why the change is needed
   - What was modified
   - Any limitations or known side effects
   - Screenshots (if UI output changed)

## Validation Checklist

Before opening a PR, verify as applicable:

- The project still loads and navigates correctly in Construct.
- Updated CH5z/LPZ artifacts (if included) correspond to the documented change.
- Theme switching behavior is not unintentionally broken.
- Added/updated scripts run without errors in PowerShell.
- Documentation reflects the current behavior.

## Scope and Performance

This repository is intentionally large and can be performance-heavy. Keep this in mind when contributing:

- Avoid unnecessary page/widget duplication.
- Prefer targeted changes over broad restructures.
- Do not remove existing showcase coverage unless discussed in an issue first.

## Commit Message Guidance

Use short, descriptive messages, for example:

- `docs: clarify CH5z loading instructions`
- `scripts: fix keypad generation CSV mapping`
- `lightdark: update slider advanced ticks example`

## Questions

If you are unsure whether a contribution fits the project goals, open an issue first to discuss approach and scope.
