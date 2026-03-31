# 🧭 GLOBAL LAYOUT (APPLIES TO ALL MAIN SCREENS)

```
┌──────────────────────────────────────────────────────────────┐
│ Sidebar (240px) │     Main Content      │   Right Panel      │
│                 │                       │                    │
│  + Create       │                       │  Trending Tags     │
│  Feed           │                       │  Featured Content  │
│  Q&A            │                       │  Suggestions       │
│  Resources      │                       │                    │
│  Connections    │                       │                    │
│  Notifications  │                       │                    │
│  Admin          │                       │                    │
│                 │                       │                    │
│  Profile        │                       │                    │
└──────────────────────────────────────────────────────────────┘
```

***

# 1. 🏠 FEED PAGE

```
CENTER COLUMN

[ Search Bar ]

[ Filters: Latest | Trending | Tags ]

[ + Create Post Button ]

-------------------------------------

[ Post Card ]
Title
Author • Time
Tags

Content preview (collapsed)

[ Upvote ] [ Comment ] [ Connect ]

-------------------------------------

[ Post Card ]
...
```

***

## Post Card Structure

```
┌───────────────────────────────┐
│ Title                         │
│ Student – CSE • 2h ago        │
│ [tag] [tag]                   │
│                               │
│ Content preview...            │
│ [Read more]                   │
│                               │
│ ↑ 12   💬 4                   │
└───────────────────────────────┘
```

***

# 2. ❓ Q\&A LIST PAGE

```
CENTER COLUMN

[ Search Bar ]

[ Filters: Latest | Unanswered | Tags ]

-------------------------------------

[ Question Card ]
Title
Tags
Student – CSE • Time

Short description preview

Answers: 3 | Upvotes: 10

-------------------------------------
```

***

## Question Card

```
┌───────────────────────────────┐
│ How to prepare for placements │
│                               │
│ Student – CSE • 3h ago        │
│ [placement] [DSA]             │
│                               │
│ Short preview of question...  │
│                               │
│ 💬 5 answers   ↑ 12           │
└───────────────────────────────┘
```

***

# 3. 📄 QUESTION DETAIL PAGE

```
CENTER COLUMN

[ Question Title ]

Student – CSE • Time
[tags]

Full description

-------------------------------------

[ Answer Button ]

-------------------------------------

[ Accepted Answer ]
(Highlighted with badge)

Answer content

[ Reply thread ]
   ↳ Reply
   ↳ Reply

-------------------------------------

[ Other Answers ]
Answer content

[ Reply thread ]
```

***

## Answer Block

```
┌───────────────────────────────┐
│ 🏅 Accepted Answer            │
│ Alumni – 2022 Batch          │
│                               │
│ Answer content...             │
│                               │
│ ↑ 20   💬 Replies             │
│                               │
│ ↳ Reply                       │
└───────────────────────────────┘
```

***

# 4. ✍️ ANSWER MODAL

```
┌───────────────────────────────┐
│ Question Title                │
│                               │
│ Question preview              │
│                               │
│ ----------------------------- │
│                               │
│ [ Answer Input Field ]        │
│                               │
│ ----------------------------- │
│                               │
│ [ Submit Answer ]             │
└───────────────────────────────┘
```

***

# 5. 📚 RESOURCES PAGE

```
CENTER COLUMN

[ Search Bar ]

[ Tag Filters ]

-------------------------------------

[ Resource Card ]

Title
Description

[tags]

[ Visit Link ]   ↑ Upvote

-------------------------------------
```

***

## Resource Card

```
┌───────────────────────────────┐
│ Striver DSA Sheet             │
│                               │
│ Best resource for DSA prep... │
│                               │
│ [DSA] [Placement]             │
│                               │
│ 🔗 Visit   ↑ 45               │
└───────────────────────────────┘
```

***

# 6. 🤝 CONNECTIONS PAGE

```
CENTER COLUMN

[ Tabs: Incoming | Sent | Connected ]

-------------------------------------

[ Connection Request Card ]

User info
Message (note)

[ Accept ] [ Reject ]

-------------------------------------
```

***

## Request Card

```
┌───────────────────────────────┐
│ Alumni – 2022 Batch          │
│                               │
│ “Hi, I saw your answer...”    │
│                               │
│ [ Accept ] [ Reject ]         │
└───────────────────────────────┘
```

***

# 7. 💬 MESSAGING PAGE

```
| Chat List        | Active Chat               |
|------------------|---------------------------|
| User 1           | Header (User Info)        |
| User 2           |                           |
| User 3           | Message bubble            |
|                  |                           |
|                  | Message bubble            |
|                  |                           |
|                  | [ Input box ]             |
```

***

## Chat Bubble

```
[ You ]: Message (right aligned)

[ Them ]: Message (left aligned)
```

***

# 8. 👤 PROFILE PAGE

```
CENTER COLUMN

[ User Info ]

Name
Role
Department

-------------------------------------

[ Tabs: Answers | Posts | Resources ]

-------------------------------------

[ Content List ]
```

***

# 9. 🛠 ADMIN DASHBOARD

```
CENTER COLUMN

[ Metrics Cards ]
- Total Users
- Questions
- Active Users

-------------------------------------

[ Pending Alumni ]

User info
[ Approve ] [ Reject ]

-------------------------------------

[ Reports ]

Content preview
[ Take Action ]
```

***

# 10. 🚨 REPORT MODAL

```
┌───────────────────────────────┐
│ Report Content                │
│                               │
│ Reason:                       │
│ [ Input Field ]               │
│                               │
│ [ Submit ]                    │
└───────────────────────────────┘
```

***

# 11. 🔔 NOTIFICATION PANEL

```
Sidebar → Click Notifications

-------------------------------------

[ Notification Item ]

“Your question got an answer”

-------------------------------------

[ Notification Item ]
```

***

# 12. ✨ RIGHT PANEL (ALL SCREENS)

```
[ Trending Tags ]
#placement
#react

-------------------------------------

[ Featured Content ]
Top answer / post

-------------------------------------

[ Suggested Connections ]
User card + connect button
```

***

# 🧠 Final Notes

These wireframes define:

* Layout hierarchy
* Component placement
* Interaction points

They are intentionally:

* **Low fidelity (no styling yet)**
* **Implementation-ready**

