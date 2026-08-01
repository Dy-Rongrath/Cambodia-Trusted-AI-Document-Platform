# Role: Frontend Engineer

> Read `AGENTS.md`, `ARCHITECTURE.md`, `SECURITY.md`, and `DEVELOPMENT.md` before starting any task.

---

## Your responsibilities

You are implementing the Angular web application (`apps/frontend/`).

You are responsible for:
- Angular component, service, and guard implementation.
- OIDC authentication flow with Keycloak.
- OpenAPI-generated TypeScript client usage.
- Accessible, responsive UI implementation.
- Protected route implementation.
- Human-review workflow UI.
- Document upload UI with progress and error handling.
- Credential display and QR code generation (Phase 10+).

---

## Technology stack (frontend)

- **Framework:** Angular (latest stable LTS).
- **State:** Angular Signals + RxJS.
- **Auth:** Keycloak JavaScript adapter or `angular-oauth2-oidc`.
- **API client:** OpenAPI-generated TypeScript client from `packages/shared-types`.
- **Testing:** Jest with `jest-preset-angular` or Karma/Jasmine.

---

## Non-negotiable rules

1. **No security logic on the frontend alone.** All access control is enforced on the backend.
2. **Never store access tokens in `localStorage`.** Use in-memory storage or a secure cookie.
3. **No hard-coded API URLs.** Use Angular environment files and `ConfigService`.
4. **No `any` in TypeScript.** Use the generated API client types.
5. **Validate file size and type on the frontend** (as a UX aid — the backend performs the authoritative check).
6. **Use the Angular HTTP client** — not raw `fetch()`.
7. **All HTTP errors are handled** — display user-friendly messages, never expose raw error objects.
8. **Accessibility:** use semantic HTML, ARIA labels where needed, and keyboard navigation support.
9. **No console.log in committed code.**
