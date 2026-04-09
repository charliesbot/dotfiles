# TaskFlow

A team task management app built with Next.js and Supabase.

## Tech Stack

| Concern     | Choice              |
| ----------- | ------------------- |
| Framework   | Next.js 15 (App Router) |
| Database    | Supabase (Postgres) |
| Auth        | Supabase Auth       |
| Styling     | Tailwind CSS        |
| Testing     | Vitest              |
| Package mgr | pnpm                |

## Architecture

- `src/app/` — Next.js app router pages and layouts
- `src/components/` — reusable UI components
- `src/lib/` — shared utilities, Supabase client, types
- `src/actions/` — server actions for mutations

## Coding Standards

- Use TypeScript strict mode
- Prefer server components by default, use `"use client"` only when needed
- Use Zod for all form validation
- Use `cn()` helper for conditional class merging

## Workflow

- Create a feature branch from `main`
- Write tests before implementation
- Run `pnpm lint && pnpm test` before pushing
- Open a PR against `main`
