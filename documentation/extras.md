# 🚀 **ASCEND – EXECUTION PACK**

***

# 1. ✅ Validation & Constraints Specification

***

## 1.1 User

```plaintext
email:
- required
- valid email format

department:
- required
- max 50 chars

semester:
- required (for students)
- range: 1–8

passoutYear:
- required (for alumni)
- valid year
```

***

## 1.2 Question

```plaintext
title:
- required
- min: 10 chars
- max: 150 chars

description:
- required
- min: 20 chars
- max: 2000 chars

tags:
- required
- min: 1
- max: 5

isAnonymous:
- boolean
```

***

## 1.3 Answer

```plaintext
content:
- required
- min: 20 chars
- max: 5000 chars
```

***

## 1.4 Reply

```plaintext
content:
- required
- min: 5 chars
- max: 1000 chars
```

***

## 1.5 Post

```plaintext
title:
- required
- min: 5 chars
- max: 120 chars

content:
- required
- min: 100 chars
- max: 5000 chars

tags:
- required
- max: 5
```

***

## 1.6 Resource

```plaintext
title:
- required
- min: 5 chars

description:
- required
- min: 20 chars

url:
- required
- valid URL

tags:
- required
- max: 5
```

***

## 1.7 Connection Request

```plaintext
message:
- required
- min: 20 chars
- max: 300 chars
```

***

## 1.8 Message

```plaintext
content:
- required
- min: 1 char
- max: 1000 chars
```

***

***

# 2. ⚠️ Error Code Catalog

***

```plaintext
AUTH_REQUIRED
INVALID_OTP
USER_NOT_FOUND
ALREADY_EXISTS

FORBIDDEN
NOT_ALLOWED_TO_ANSWER
NOT_ALLOWED_TO_ACCEPT

VALIDATION_ERROR
INVALID_INPUT

NOT_FOUND
CONTENT_NOT_FOUND

ALREADY_VOTED
INVALID_VOTE_TYPE

CONNECTION_LIMIT_REACHED
ALREADY_CONNECTED

REPORT_ALREADY_SUBMITTED

SERVER_ERROR
```

***

## Standard Error Format

```JSON
{
  "error": {
    "code": "FORBIDDEN",
    "message": "Only seniors, alumni, and faculty can answer"
  }
}
```

***

# 3. 📦 API Response Standard

***

## Success Response

```JSON
{
  "success": true,
  "data": {},
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 100
  }
}
```

***

## Single Resource

```JSON
{
  "success": true,
  "data": { ... }
}
```

***

## List Response

```JSON
{
  "success": true,
  "data": [],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 50
  }
}
```

***

# 4. 🔁 Pagination Rules

***

```plaintext
Default limit: 10
Max limit: 50
```

***

## Query Format

```plaintext
?page=1&limit=10
```

***

## Frontend Behavior

* Infinite scroll for:

  * Feed
  * Questions
  * Resources

* Stop fetching when:

```plaintext
data.length < limit
```

***

***

# 5. ⚡ Socket Event Contract

***

## 5.1 send\_message

```JSON
{
  "receiverId": "...",
  "content": "Hello"
}
```

***

## 5.2 receive\_message

```JSON
{
  "id": "...",
  "senderId": "...",
  "receiverId": "...",
  "content": "...",
  "createdAt": "..."
}
```

***

## 5.3 connection\_update

```JSON
{
  "type": "ACCEPTED",
  "userId": "..."
}
```

***

## 5.4 new\_notification

```JSON
{
  "id": "...",
  "type": "ANSWER",
  "message": "Your question got a new answer",
  "createdAt": "..."
}
```

***

***

# 6. 🔔 Notification Rules

***

| Event               | Stored | Toast | Type      |
| ------------------- | ------ | ----- | --------- |
| New answer          | ✅      | ❌     | panel     |
| Reply to answer     | ✅      | ❌     | panel     |
| Upvote              | ❌      | ❌     | none      |
| New message         | ✅      | ✅     | real-time |
| Connection accepted | ✅      | ❌     | panel     |
| Admin action        | ✅      | ✅     | important |

***

***

# 7. 📡 Data Fetching Strategy

***

## Q\&A

```plaintext
Question List:
- fetch on page load
- refetch after creating question

Question Detail:
- fetch on page load
- refetch after:
  - answer
  - reply
```

***

## Feed

```plaintext
- fetch on page load
- refetch after post creation
```

***

## Resources

```plaintext
- fetch on page load
- refetch after add
```

***

## Messages

```plaintext
- fetch chats on page load
- fetch chat on user select
- update via socket
```

***

## Notifications

```plaintext
- fetch on app load
- update via socket
```

***

***

# 8. 🌱 Seed Data Plan

***

## Users

* 5 Students (different semesters)
* 3 Alumni
* 2 Faculty
* 1 Admin

***

## Content

```plaintext
Questions: 15–20
Answers: 10–15
Posts: 8–10
Resources: 5–8
Connections: 5–10
```

***

***

# 9. 🧭 Build Order (CRITICAL)

***

## Phase 1: Foundation

1. Auth (OTP + JWT)
2. User system
3. Layout + routing

***

## Phase 2: Core Engine

1. Q\&A system

   * ask question
   * answer
   * reply
   * senior logic

***

## Phase 3: Engagement

1. Voting
2. Feed (posts)
3. Resources

***

## Phase 4: Social Layer

1. Connections
2. Messaging (Socket.io)

***

## Phase 5: System Layer

1. Notifications
2. Reports
3. Admin panel

***

## Phase 6: Polish

1. UI refinements
2. Performance
3. Bug fixing

***

***

# 10. 🧠 Final Execution Rules

***

## DO

* Enforce rules in backend (not frontend)
* Keep API consistent
* Refetch after mutations
* Use skeleton loaders

***

## DON'T

* Don’t duplicate state unnecessarily
* Don’t embed large nested data
* Don’t overuse real-time events

***

***

# 🚀 Final Status

You now have:

✅ Product definition
✅ UX + Design
✅ Architecture
✅ Database
✅ API
✅ Frontend services
✅ State management
✅ Execution pack
