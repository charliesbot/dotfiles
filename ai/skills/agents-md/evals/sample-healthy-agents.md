# Kōji

CLI tool for structured log parsing and analysis, written in Rust.

## Hard Rules

- NEVER use `unwrap()` or `expect()` in library code. Use `thiserror` for typed errors, propagate with `?`.
- NEVER add dependencies without checking if an existing crate already covers the use case.

## Priorities

correctness > simplicity > performance > readability

## Architecture

- `src/main.rs` — CLI entry point, argument parsing via `clap`
- `src/parser/` — log format parsers (JSON, logfmt, CLF)
- `src/filter/` — query engine for filtering parsed logs
- `src/output/` — formatters (table, JSON, CSV)

New parsers implement the `LogParser` trait in `src/parser/mod.rs`.

## Coding Standards

- Use `clippy` with `pedantic` lint group enabled.
- Prefer iterators over manual loops.
- Public functions require doc comments with an `# Examples` section.

## Common Commands

- `cargo build` — build
- `cargo test` — run all tests
- `cargo clippy -- -D warnings` — lint (must pass before committing)
- `cargo fmt --check` — verify formatting

## Workflow

- Create a feature branch from `main`.
- Run `cargo clippy && cargo test` before pushing.
- PRs require one approval before merging.
