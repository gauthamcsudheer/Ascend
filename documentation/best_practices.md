# **Ascend – Development Standards & Best Practices Guide**

***

# 1. 🎯 Purpose

This document defines:

* Coding standards
* Architectural rules
* Best practices per technology
* Do’s and Don’ts

***

## Goal

> Ensure the system is **consistent, scalable, and predictable**—especially for AI-driven development.

***

# 2. 🧠 General Engineering Principles

***

## 2.1 Single Responsibility Principle

* Each module/file should have **one clear responsibility**
* Avoid “god files”

***

## 2.2 Consistency Over Cleverness

* Prefer predictable patterns over optimization tricks
* Reuse existing patterns instead of inventing new ones

***

## 2.3 Backend is Source of Truth

* All validation, permissions, and rules:

  * MUST be enforced in backend
  * Frontend only reflects state

***

## 2.4 Explicit > Implicit

* Always define:

  * types
  * responses
  * validations

***

***

# 3. 🧱 Project Structure Standards

***

## Backend

```plaintext
modules/
  ├── controller
  ├── service
  ├── model
  ├── route
```

***

## Frontend

```plaintext
components/
pages/
services/
store/
types/
```

***

## Rules

* No business logic in controllers
* No API calls inside components directly
* No state duplication across stores

***

***

# 4. ⚙️ Backend (Node.js + Express)

***

## 4.1 Controller Rules

Controllers must:

* Handle request/response only
* Call service layer
* NOT contain business logic

***

### ✅ Good

```TypeScript
const createQuestion = async (req, res) => {
  const result = await questionService.create(req.user, req.body);
  res.json(result);
};
```

***

### ❌ Bad

* validation logic inside controller
* DB queries inside controller

***

***

## 4.2 Service Layer Rules

* All business logic lives here
* Enforce:

  * permissions
  * validation
  * rules

***

***

## 4.3 Database (Mongoose)

***

### Rules

* Always use schemas with validation
* Use references instead of deep embedding
* Use indexes for:

  * frequently queried fields

***

### Avoid

* large nested documents
* unbounded arrays

***

***

## 4.4 Error Handling

* Always throw structured errors

```TypeScript
throw {
  code: "FORBIDDEN",
  message: "Not allowed"
};
```

***

* Use centralized error middleware

***

***

## 4.5 Middleware

Use middleware for:

* auth validation
* role checks
* request validation

***

***

# 5. 🌐 REST API Standards

***

## 5.1 Naming

* Use plural nouns:

```plaintext
/questions
/posts
/resources
```

***

## 5.2 HTTP Methods

| Action | Method    |
| ------ | --------- |
| Create | POST      |
| Read   | GET       |
| Update | PUT/PATCH |
| Delete | DELETE    |

***

***

## 5.3 Response Format (Strict)

```JSON
{
  "success": true,
  "data": {},
  "meta": {}
}
```

***

***

## 5.4 Status Codes

| Code | Use              |
| ---- | ---------------- |
| 200  | Success          |
| 201  | Created          |
| 400  | Validation error |
| 401  | Unauthorized     |
| 403  | Forbidden        |
| 404  | Not found        |

***

***

## 5.5 Validation

* Validate at:

  * request level (middleware)
  * business logic level (service)

***

***

# 6. ⚛️ React Best Practices

***

## 6.1 Component Structure

* Small, reusable components
* Separate:

  * UI
  * logic

***

***

## 6.2 Folder Pattern

```plaintext
components/
  ├── PostCard/
  ├── QuestionCard/
```

***

## 6.3 Rules

* No API calls directly inside UI components
* Use services + stores

***

***

## 6.4 Hooks

* Use custom hooks for:

  * reusable logic
  * data fetching

***

***

## 6.5 Rendering

* Use conditional rendering cleanly
* Avoid deeply nested JSX

***

***

# 7. 🧠 Zustand State Management

***

## Rules

* One store per domain
* Keep state minimal

***

## Do

* Fetch data via actions
* Keep loading states

***

## Don’t

* Store derived data unnecessarily
* Mutate state directly

***

***

# 8. 🧾 TypeScript Standards

***

## 8.1 Strict Typing

* Avoid `any`
* Define interfaces for all data

***

***

## 8.2 Types Organization

```plaintext
types/
  ├── user.types.ts
  ├── question.types.ts
```

***

***

## 8.3 API Types

Define request/response types explicitly:

```TypeScript
interface CreateQuestionRequest {
  title: string;
  description: string;
}
```

***

***

# 9. 🎨 UI & Styling (Tailwind)

***

## Rules

* Use design tokens (no hardcoded colors)
* Maintain spacing consistency

***

***

## Avoid

* inline styles
* inconsistent spacing

***

***

# 10. 🔁 Data Fetching & Sync

***

## Rules

* Always refetch after mutations
* Avoid stale UI

***

***

## Pattern

```TypeScript
await createPost();
fetchPosts();
```

***

***

# 11. ⚡ Real-Time (Socket.io)

***

## Rules

* Use sockets only for:

  * messages
  * notifications

***

## Avoid

* syncing entire app via sockets

***

***

# 12. 🔐 Security Practices

***

* Never trust frontend
* Validate all inputs
* Use JWT properly
* Protect admin routes

***

***

# 13. 🧪 Testing (Basic Expectation)

***

## Minimum

* API testing (Postman / scripts)
* Manual UI testing

***

***

# 14. 🚫 Anti-Patterns to Avoid

***

* Fat controllers
* Business logic in frontend
* Duplicate state
* Deep nested components
* Hardcoded values

***

***

# 15. 🧭 Development Workflow

***

## Step-by-Step

1. Define types
2. Implement API
3. Build service layer
4. Connect frontend service
5. Add store logic
6. Build UI
7. Test

***

***

# 16. 🧠 AI Agent Guidelines

***

When generating code, ALWAYS:

* Follow existing structure
* Reuse patterns
* Keep functions small
* Use clear naming
* Avoid assumptions

***

***

# 17. 🚀 Final Principle

> Build simple → validate → iterate
> Not complex → refactor later

