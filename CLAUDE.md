# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ascend is a college-specific knowledge and mentorship platform for Rajagiri School of Engineering and Technology. It connects students with seniors, alumni, and faculty through Q&A, experience sharing, resource curation, and networking. Built on the MERN stack (MongoDB, Express, React/TypeScript, Node.js) with Socket.io for real-time features.

**Status**: Documentation complete, implementation in progress. All specs are in `documentation/`.

## Architecture

**Modular monolith** — the backend is organized into feature modules, each with its own controller, service, model, and routes. The frontend uses React with Zustand stores per feature domain.

### Backend Structure (`backend/`)
```
modules/<feature>/
  ├── <feature>.controller.ts   # HTTP handling, input validation, response formatting
  ├── <feature>.service.ts      # Business logic, DB operations, permission checks
  ├── <feature>.model.ts        # Mongoose schema/model
  └── <feature>.route.ts        # Express routes
middleware/                      # auth, role-check, error-handler, validate
```

Modules: auth, user, qa (questions + answers + replies), post, resource, tag, vote, connection, message, report, notification.

### Frontend Structure (`frontend/`)
```
services/           # API call functions (one per domain)
store/              # Zustand stores (one per domain)
components/         # Reusable UI components
pages/              # Route-level page components
types/              # Shared TypeScript interfaces
```

### Key Patterns
- **Controllers** only handle HTTP concerns; all logic lives in services
- **Components never call APIs directly** — they call store actions, which call services
- **Soft deletes** on all content (questions, answers, posts, resources) via `deletedAt` field
- **Polymorphic Vote/Report models** — single collection handles votes/reports for all content types using `contentType` + `contentId`
- **References over embedding** in MongoDB — use ObjectId refs, not nested documents

## Critical Business Rules

- **Senior answer eligibility**: Students can only answer questions from users in a lower semester. Alumni and faculty can answer any question.
- **Anonymity**: Questions can be posted anonymously (display "Student – \<dept\>"), but `userId` is always stored and visible to admins.
- **One accepted answer** per question, only the question owner can accept.
- **Connections required for chat**: Messaging is only available between users with an accepted connection.
- **Alumni verification**: Alumni accounts require manual admin approval before they gain alumni privileges.

## API Conventions

- Base path: `/api`
- Standard response: `{ success: true, data: {...} }` or `{ error: { code: "ERROR_CODE", message: "..." } }`
- All list endpoints require pagination (default limit: 10, max: 50)
- Auth via Bearer JWT token in Authorization header; refresh tokens in httpOnly cookies
- Authentication: Email OTP flow (send-otp → verify-otp), no passwords

## Validation Constraints

| Entity | Field | Constraint |
|--------|-------|-----------|
| Question | title | 10–150 chars |
| Question | description | 20–2000 chars |
| Question/Post/Resource | tags | 1–5 required |
| Answer | content | 20–5000 chars |
| Post | content | 100–5000 chars |
| Connection request | message | 20–300 chars |

## Design System

- **Colors**: Primary `#5C1220` (maroon), Accent `#C9894A` (gold), Background `#FAF7F2` (cream), Text `#1A1410`
- **Fonts**: Headings — Cormorant Garamond, Body — DM Sans, Code/Tags — JetBrains Mono
- **Styling**: Tailwind CSS only — no inline styles, no CSS modules

## Build Order

Implementation follows this sequence (each phase builds on the previous):
1. Auth + User system + App layout/routing
2. Q&A (questions, answers, replies, senior eligibility logic)
3. Voting + Feed (posts/comments) + Resources
4. Connections + Messaging (Socket.io)
5. Notifications + Reports + Admin panel
6. Polish, performance, bug fixes

## User Roles

Four roles with hierarchical permissions: `STUDENT`, `ALUMNI`, `FACULTY`, `ADMIN`. Role checks are enforced in backend middleware and service layer. Admin has full access including moderation and alumni verification.
