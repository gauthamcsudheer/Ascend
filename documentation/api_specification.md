# **Ascend – API Specification**

## Base URL

```
/api
```

---

# 1. 🔐 Authentication

---

## 1.1 Send OTP

**POST** `/auth/send-otp`

### Request

```json
{
  "email": "user@rajagiri.edu.in"
}
```

### Response

```json
{
  "message": "OTP sent successfully"
}
```

---

## 1.2 Verify OTP (Login/Register)

**POST** `/auth/verify-otp`

### Request (Student/Faculty)

```json
{
  "email": "user@rajagiri.edu.in",
  "otp": "123456",
  "role": "STUDENT",
  "department": "CSE",
  "semester": 4
}
```

### Request (Alumni)

```json
{
  "email": "user@gmail.com",
  "otp": "123456",
  "role": "ALUMNI",
  "department": "CSE",
  "passoutYear": 2022,
  "linkedinUrl": "https://linkedin.com/..."
}
```

---

### Responses

#### ✅ Success (Student/Faculty)

```json
{
  "user": { ... },
  "accessToken": "jwt"
}
```

#### ⏳ Alumni Pending

```json
{
  "message": "Pending admin approval"
}
```

👉 Refresh token is set via **HTTP-only cookie**

---

## 1.3 Refresh Token

**POST** `/auth/refresh`

```json
{
  "accessToken": "new-token"
}
```

---

## 1.4 Logout

**POST** `/auth/logout`

* Clears refresh cookie

---

# 2. 👤 Users

---

## 2.1 Get Current User

**GET** `/users/me`

---

## 2.2 Get User Profile

**GET** `/users/:id`

---

## 2.3 Get User Activity

**GET** `/users/:id/activity`

```json
{
  "answers": [],
  "posts": [],
  "resources": []
}
```

---

# 3. ❓ Q&A

---

## 3.1 Create Question

**POST** `/questions`

### Request

```json
{
  "title": "How to prepare for placements?",
  "description": "...",
  "tags": ["placement", "dsa"],
  "isAnonymous": true
}
```

---

## 3.2 Get Questions

**GET** `/questions`

### Query

```
?page=1&limit=10&filter=latest|unanswered&tag=placement
```

---

## 3.3 Get Question Detail

**GET** `/questions/:id`

### Response

```json
{
  "question": {
    "id": "...",
    "title": "...",
    "description": "...",
    "author": {
      "displayName": "Student - CSE"
    },
    "tags": [],
    "createdAt": "..."
  },
  "answers": [],
  "canCurrentUserAnswer": true,
  "reason": null
}
```

---

## 3.4 Answer Question

**POST** `/answers`

### Request

```json
{
  "questionId": "...",
  "content": "..."
}
```

---

### Validation Logic

A user can answer if:

```plaintext
- Alumni OR Faculty OR Admin
- OR Student where user.semester > questionAuthor.semester
```

---

### Error Response

```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "Only seniors, alumni, and faculty can answer this question"
  }
}
```

---

## 3.5 Reply to Answer

**POST** `/answers/:id/reply`

```json
{
  "content": "..."
}
```

---

## 3.6 Accept Answer

**POST** `/answers/:id/accept`

* Only question owner

---

## 3.7 Delete Question

**DELETE** `/questions/:id`

* Soft delete

---

# 4. 📰 Posts (Feed)

---

## 4.1 Create Post

**POST** `/posts`

```json
{
  "title": "...",
  "content": "...",
  "tags": ["placement"]
}
```

---

## 4.2 Get Feed

**GET** `/posts`

```
?page=1&limit=10
```

---

## 4.3 Get Post Detail

**GET** `/posts/:id`

---

## 4.4 Comment on Post

**POST** `/posts/:id/comments`

```json
{
  "content": "..."
}
```

---

## 4.5 Delete Post

**DELETE** `/posts/:id`

---

# 5. 📚 Resources

---

## 5.1 Add Resource

**POST** `/resources`

```json
{
  "title": "...",
  "description": "...",
  "url": "...",
  "tags": ["dsa"]
}
```

---

## 5.2 Get Resources

**GET** `/resources`

```
?page=1&limit=10&tag=dsa
```

---

## 5.3 Delete Resource

**DELETE** `/resources/:id`

---

# 6. 🏷 Tags

---

## 6.1 Get Tags

**GET** `/tags`

---

# 7. 👍 Voting

---

## 7.1 Vote / Toggle

**POST** `/votes`

```json
{
  "contentType": "ANSWER",
  "contentId": "...",
  "type": "UP" // or "DOWN"
}
```

### Behavior

* Toggle:

  * same vote → remove
  * different vote → switch

---

# 8. 🤝 Connections

---

## 8.1 Send Request

**POST** `/connections`

```json
{
  "receiverId": "...",
  "message": "Short note..."
}
```

---

## 8.2 Accept Request

**POST** `/connections/:id/accept`

---

## 8.3 Reject Request

**POST** `/connections/:id/reject`

---

## 8.4 Get Connections

**GET** `/connections`

```json
{
  "incoming": [],
  "sent": [],
  "accepted": []
}
```

---

# 9. 💬 Messaging

---

## 9.1 Get Conversations

**GET** `/messages`

---

## 9.2 Get Chat

**GET** `/messages/:userId`

---

## 9.3 Send Message (REST fallback)

**POST** `/messages`

```json
{
  "receiverId": "...",
  "content": "..."
}
```

---

# 10. 🔔 Notifications

---

## 10.1 Get Notifications

**GET** `/notifications`

---

## 10.2 Mark Read

**POST** `/notifications/:id/read`

---

# 11. 🚨 Reports

---

## 11.1 Report Content

**POST** `/reports`

```json
{
  "contentType": "POST",
  "contentId": "...",
  "reason": "Spam"
}
```

---

# 12. 🛠 Admin

---

## 12.1 Get Pending Alumni

**GET** `/admin/alumni`

---

## 12.2 Approve Alumni

**POST** `/admin/alumni/:id/approve`

---

## 12.3 Reject Alumni

**POST** `/admin/alumni/:id/reject`

---

## 12.4 Get Reports

**GET** `/admin/reports`

---

## 12.5 Take Action

**POST** `/admin/reports/:id/action`

```json
{
  "action": "DELETE_CONTENT" // WARN / BAN
}
```

---

# 13. 🔍 Search

---

## 13.1 Global Search

**GET** `/search?q=react`

```json
{
  "questions": [],
  "posts": [],
  "resources": [],
  "users": []
}
```

---

# 14. ⚠️ Error Format (Global)

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message"
  }
}
```

---

# 15. 🔐 Permissions Summary

| Action       | Student | Senior (dynamic) | Alumni | Faculty | Admin |
| ------------ | ------- | ---------------- | ------ | ------- | ----- |
| Ask question | ✅       | ✅                | ❌      | ❌       | ❌     |
| Answer       | ❌       | ✅                | ✅      | ✅       | ✅     |
| Reply        | ✅       | ✅                | ✅      | ✅       | ✅     |
| Moderate     | ❌       | ❌                | ❌      | ❌       | ✅     |

---

# 16. ⚡ Socket Events

---

## Client → Server

```
send_message
```

---

## Server → Client

```
receive_message
new_notification
connection_update
```

---

# 🚀 Final State

This API spec is now:

* Consistent with UX
* Aligned with DB schema
* Enforces business rules (especially senior logic)
* Ready for backend + frontend development
