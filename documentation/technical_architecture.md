# **Technical Architecture & Database Schema Document**

## **Ascend: Elevate Each Other**

***

# 1. System Overview

Ascend is a **college-scoped, role-based knowledge and mentorship platform** built using the MERN stack. It enables structured Q\&A, experience sharing, resource curation, and controlled networking.

***

# 2. Technology Stack

### Frontend

* React + TypeScript
* State: Zustand / Redux Toolkit
* Styling: Tailwind CSS

### Backend

* Node.js + Express
* Mongoose (ODM)

### Database

* MongoDB

### Real-time

* Socket.io

### Authentication

* JWT (Access + Refresh Tokens)
* Email OTP (Nodemailer)

***

# 3. Architecture Style

> **Modular Monolith**

### Rationale

* Faster development
* Easier debugging
* Clear module boundaries
* Scalable into microservices later

***

# 4. High-Level Architecture

```
Client (React)
   ↓
API Layer (Express Controllers)
   ↓
Service Layer (Business Logic)
   ↓
Data Access Layer (Mongoose Models)
   ↓
MongoDB
```

***

# 5. Backend Module Structure

```
src/
 ├── modules/
 │    ├── auth/
 │    ├── user/
 │    ├── qa/
 │    ├── post/
 │    ├── resource/
 │    ├── tag/
 │    ├── vote/
 │    ├── connection/
 │    ├── message/
 │    ├── report/
 │    └── notification/
 │
 ├── models/
 ├── controllers/
 ├── services/
 ├── routes/
 ├── middlewares/
 ├── sockets/
 ├── utils/
 └── config/
```

***

# 6. Core Architectural Decisions

***

## 6.1 Authentication

* JWT-based authentication
* Access token (short-lived)
* Refresh token (long-lived)
* OTP stored in DB with expiry

***

## 6.2 Role-Based Access Control

Roles:

* STUDENT
* ALUMNI
* FACULTY
* ADMIN

Enforced at:

* Service layer
* Middleware

***

## 6.3 Anonymity

* `isAnonymous = true`
* `userId` always stored
* Identity hidden from public, visible to admin

***

## 6.4 Soft Delete Strategy

* All major entities include:

  * `deletedAt`
* Default queries exclude soft-deleted content
* Hard delete used only by admin/system cleanup

***

## 6.5 Tag System

* Global tag collection
* Referenced across:

  * Questions
  * Resources

***

## 6.6 Voting System

* Unified vote collection
* Supports:

  * Answers
  * Posts
  * Resources
  * (optional extension: questions)

***

## 6.7 Messaging

* Mutual connection model
* Chat enabled only after acceptance
* Socket.io for real-time

***

## 6.8 Reporting System

* Single polymorphic report collection
* Covers all content types

***

## 6.9 Search

* MongoDB text index (initial)
* Supports:

  * Questions
  * Posts (optional)

***

# 7. Database Design Strategy

***

## Approach

* Use **referencing over embedding** for scalability
* Keep documents **small and modular**
* Use **indexes for performance**

***

# 8. Database Schema (Mongoose)

***

## 8.1 User

```JavaScript
{
  _id: ObjectId,
  email: String (unique),
  password: String,

  role: "STUDENT" | "ALUMNI" | "FACULTY" | "ADMIN",

  department: String,
  semester: Number,
  passoutYear: Number,
  linkedinUrl: String,

  isVerified: Boolean,
  isBanned: Boolean,

  createdAt: Date,
  deletedAt: Date
}
```

***

## 8.2 OTP

```JavaScript
{
  _id: ObjectId,
  email: String,
  code: String,
  expiresAt: Date,
  createdAt: Date
}
```

***

## 8.3 Question

```JavaScript
{
  _id: ObjectId,
  title: String,
  description: String,

  userId: ObjectId,
  isAnonymous: Boolean,

  tags: [ObjectId],

  createdAt: Date,
  updatedAt: Date,
  deletedAt: Date
}
```

***

## 8.4 Answer

```JavaScript
{
  _id: ObjectId,
  content: String,

  userId: ObjectId,
  questionId: ObjectId,

  isAccepted: Boolean,

  createdAt: Date,
  updatedAt: Date,
  deletedAt: Date
}
```

***

## 8.5 Reply

```JavaScript
{
  _id: ObjectId,
  content: String,

  userId: ObjectId,
  answerId: ObjectId,

  createdAt: Date
}
```

***

## 8.6 Post

```JavaScript
{
  _id: ObjectId,
  title: String,
  content: String,

  userId: ObjectId,

  createdAt: Date,
  updatedAt: Date,
  deletedAt: Date
}
```

***

## 8.7 Comment

```JavaScript
{
  _id: ObjectId,
  content: String,

  userId: ObjectId,
  postId: ObjectId,

  createdAt: Date
}
```

***

## 8.8 Resource

```JavaScript
{
  _id: ObjectId,
  title: String,
  description: String,
  url: String,

  userId: ObjectId,

  tags: [ObjectId],

  createdAt: Date,
  deletedAt: Date
}
```

***

## 8.9 Tag

```JavaScript
{
  _id: ObjectId,
  name: String (unique)
}
```

***

## 8.10 Vote (Polymorphic)

```JavaScript
{
  _id: ObjectId,
  userId: ObjectId,

  contentType: "QUESTION" | "ANSWER" | "POST" | "RESOURCE",
  contentId: ObjectId,

  createdAt: Date
}
```

### Constraint

* Unique index:

```JavaScript
(userId, contentType, contentId)
```

***

## 8.11 Connection

```JavaScript
{
  _id: ObjectId,
  senderId: ObjectId,
  receiverId: ObjectId,

  status: "PENDING" | "ACCEPTED" | "REJECTED",

  createdAt: Date
}
```

***

## 8.12 Message

```JavaScript
{
  _id: ObjectId,
  senderId: ObjectId,
  receiverId: ObjectId,

  content: String,

  createdAt: Date
}
```

***

## 8.13 Report

```JavaScript
{
  _id: ObjectId,
  userId: ObjectId,

  contentType: "QUESTION" | "ANSWER" | "POST" | "RESOURCE" | "COMMENT",
  contentId: ObjectId,

  reason: String,

  status: "OPEN" | "REVIEWED" | "ACTION_TAKEN",

  createdAt: Date
}
```

***

# 9. Indexing Strategy

***

## Required Indexes

```JavaScript
// Questions
{ createdAt: -1 }

// Answers
{ questionId: 1 }

// Posts
{ createdAt: -1 }

// Tags
{ name: 1 }

// Votes
{ userId: 1, contentType: 1, contentId: 1 } (unique)

// Reports
{ status: 1 }
```

***

## Full-Text Search

```JavaScript
{
  title: "text",
  description: "text"
}
```

***

# 10. Real-Time Architecture (Socket.io)

***

## Use Cases

* Messaging
* Connection updates
* Notifications (optional)

***

## Event Flow

### Client → Server

* `send_message`
* `connection_request`

### Server → Client

* `receive_message`
* `connection_accepted`
* `new_answer_notification`

***

# 11. Security Considerations

* JWT validation middleware
* Role-based route protection
* Input validation (Joi/Zod)
* Rate limiting (auth endpoints)
* Prevent spam via connection limits

***

# 12. Performance Considerations

* Avoid deep population
* Use `.lean()` queries
* Paginate all lists
* Index frequently queried fields

***

# 13. Scalability Considerations

Future upgrades:

* Redis (caching + sockets scaling)
* Elasticsearch (advanced search)
* Microservices (if multi-college expansion)

***

# 14. Known Trade-offs

| Decision             | Trade-off                    |
| -------------------- | ---------------------------- |
| MongoDB references   | More joins in app layer      |
| Unified vote model   | Slight query complexity      |
| Manual moderation    | Operational overhead         |
| Real-time from day 1 | Increased backend complexity |

***

# 15. Conclusion

This architecture is designed to:

* Be **simple enough to build quickly**
* Be **structured enough to scale**
* Enforce your **core product rules (roles, trust, moderation)**

