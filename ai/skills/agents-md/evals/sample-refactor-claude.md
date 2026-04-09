# My Project

This is a full-stack web application that we've been building since 2023. It started as a hackathon project and has grown into our main product. The frontend is built with React and the backend uses Express with a PostgreSQL database.

## About the Team

We have 4 developers working on this project. Alice focuses on the frontend, Bob handles the backend, Charlie does DevOps, and Diana is our designer who also writes some CSS. We do weekly sprints and have standups every morning at 9am.

## Technologies

We use React 18 with TypeScript for the frontend. We tried Vue before but switched back to React because more people knew it. The backend is Express.js running on Node 20. We use PostgreSQL 16 for the database with Prisma as the ORM. For styling we use styled-components but we've been thinking about switching to Tailwind. Tests are written with Jest and React Testing Library. We deploy on AWS using ECS.

## Code Style

Write clean code. Make sure your code is readable. Use meaningful variable names. Don't write overly complex code. Keep functions small and focused. Follow the DRY principle. ALWAYS use TypeScript, NEVER use `any` type. ALWAYS write tests. NEVER skip code review. ALWAYS use proper error handling. Make sure to use ESLint and Prettier. Code should be well-documented. Use JSDoc comments on all public functions. Make sure imports are organized.

## How We Handle State

We use Redux Toolkit for global state management. We used to use plain Redux but it was too verbose so we switched to Redux Toolkit in Q2 2024. For server state we use React Query (TanStack Query). Local component state uses useState and useReducer. We tried Zustand briefly but went back to Redux because the team was more familiar with it. Context is used for theme and auth state only.

## File Structure

The frontend code is in src/. Components go in src/components/. Pages go in src/pages/. Hooks go in src/hooks/. Utils go in src/utils/. Types go in src/types/. The API layer is in src/api/. Redux slices are in src/store/slices/. Layouts are in src/layouts/. The backend code is in server/. Routes go in server/routes/. Controllers go in server/controllers/. Models go in server/models/. Middleware goes in server/middleware/. Database migrations are in server/migrations/.

## Backend Conventions

Express routes follow RESTful conventions. Use async/await, not callbacks. Error handling middleware catches all unhandled errors. Use Prisma for all database queries, don't write raw SQL unless absolutely necessary. Validate all request bodies with Zod. Response format is always { data, error, message }. Use HTTP status codes correctly. Log errors with Winston.

## Frontend Conventions

Components use PascalCase for filenames. Hooks use camelCase with use prefix. Use functional components, no class components. Prefer composition over inheritance. Use React.memo sparingly. Lazy load routes. Use Suspense boundaries. Form handling uses react-hook-form with Zod resolvers.

## Testing

Write unit tests for all utility functions. Write integration tests for API routes. Write component tests for complex UI. Use test IDs for element selection, not CSS classes. Mock external services in tests. Test files live next to the code they test. Use describe blocks to organize tests. Aim for 80% coverage but don't obsess over it.

## Environment Setup

You need Node 20, PostgreSQL 16, and Redis 7 running locally. Copy .env.example to .env and fill in the values. Run npm install (we're thinking of switching to pnpm). Run npm run db:migrate to set up the database. Run npm run db:seed to get test data. Start the dev server with npm run dev. The frontend runs on port 3000 and the backend on port 4000.

## Deployment

We deploy to AWS ECS. The CI/CD pipeline runs on GitHub Actions. Pushes to main trigger a staging deploy. Production deploys require manual approval. Docker images are built in CI. Environment variables are managed through AWS Parameter Store. We used to use Heroku but migrated to AWS last year.

## Common Gotchas

- The auth middleware must be applied before any route that needs authentication
- Prisma generates types that sometimes conflict with our manual types, always use generated types
- The WebSocket connection for real-time features uses a different port (4001)
- Redis sessions expire after 24 hours, make sure to handle that gracefully
- The image upload service has a 5MB limit that's configured on the Nginx side, not in our code
- CORS is configured in server/middleware/cors.ts, not in the main server file
- Hot reload sometimes breaks when editing Prisma schema, restart the dev server if types look stale

## Git Conventions

Use conventional commits (feat:, fix:, chore:, docs:, refactor:, test:). Branch names follow feature/description, bugfix/description, or hotfix/description. Squash merge to main. Delete branches after merging. Don't push directly to main. Don't force push to shared branches.

## API Documentation

We use Swagger for API documentation. The Swagger UI is available at /api-docs in development. Keep the Swagger annotations up to date when modifying endpoints. Use @swagger JSDoc comments in route files. The API follows OpenAPI 3.0 specification. Document all request/response schemas. Include example values in the documentation.

## Performance

Use React.lazy for code splitting. Optimize images before committing. Use pagination for list endpoints. Cache frequently accessed data in Redis. Use database indexes for commonly queried fields. Monitor performance with Lighthouse. Keep bundle size under 500KB. Use compression middleware in Express.

## Security

Never store secrets in code. Use environment variables for all sensitive data. Sanitize all user input. Use parameterized queries (Prisma handles this). Set security headers with Helmet. Rate limit API endpoints. Use HTTPS in production. Validate JWT tokens on every request. Don't expose stack traces in production error responses. Keep dependencies updated. Run npm audit regularly.

## Accessibility

Follow WCAG 2.1 AA standards. Use semantic HTML elements. Provide alt text for images. Ensure keyboard navigation works. Use ARIA attributes when needed. Test with screen readers periodically. Maintain color contrast ratios. Use focus indicators on interactive elements.

## Misc

Alice prefers dark mode in VS Code. Bob uses Vim. Charlie says the deployment scripts are "self-documenting" but they're really not. Diana's Figma designs are in the shared workspace. The office WiFi password is on the fridge. Team lunch is on Fridays.
