# 🧱 1. Folder Structure (Frontend)

```plaintext
src/
 ├── api/
 │    ├── client.ts
 │    ├── endpoints.ts
 │
 ├── services/
 │    ├── auth.service.ts
 │    ├── user.service.ts
 │    ├── question.service.ts
 │    ├── post.service.ts
 │    ├── resource.service.ts
 │    ├── vote.service.ts
 │    ├── connection.service.ts
 │    ├── message.service.ts
 │    ├── notification.service.ts
 │    ├── admin.service.ts
 │
 ├── types/
 │    ├── user.types.ts
 │    ├── question.types.ts
 │    ├── post.types.ts
 │    ├── common.types.ts
```

***

# ⚙️ 2. Axios Client Setup

## `api/client.ts`

```TypeScript
import axios from "axios";

const api = axios.create({
  baseURL: "/api",
  withCredentials: true, // for refresh token cookie
});

// Attach access token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem("accessToken");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle token refresh
api.interceptors.response.use(
  (res) => res,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const res = await axios.post("/api/auth/refresh", {}, { withCredentials: true });
        const newToken = res.data.accessToken;

        localStorage.setItem("accessToken", newToken);
        originalRequest.headers.Authorization = `Bearer ${newToken}`;

        return api(originalRequest);
      } catch (err) {
        localStorage.removeItem("accessToken");
        window.location.href = "/login";
      }
    }

    return Promise.reject(error);
  }
);

export default api;
```

***

# 🌐 3. Endpoints Map

## `api/endpoints.ts`

```TypeScript
export const ENDPOINTS = {
  AUTH: {
    SEND_OTP: "/auth/send-otp",
    VERIFY_OTP: "/auth/verify-otp",
    REFRESH: "/auth/refresh",
    LOGOUT: "/auth/logout",
  },

  USERS: {
    ME: "/users/me",
    PROFILE: (id: string) => `/users/${id}`,
    ACTIVITY: (id: string) => `/users/${id}/activity`,
  },

  QUESTIONS: {
    BASE: "/questions",
    DETAIL: (id: string) => `/questions/${id}`,
  },

  ANSWERS: {
    BASE: "/answers",
    REPLY: (id: string) => `/answers/${id}/reply`,
    ACCEPT: (id: string) => `/answers/${id}/accept`,
  },

  POSTS: {
    BASE: "/posts",
    DETAIL: (id: string) => `/posts/${id}`,
    COMMENTS: (id: string) => `/posts/${id}/comments`,
  },

  RESOURCES: {
    BASE: "/resources",
  },

  VOTES: "/votes",

  CONNECTIONS: {
    BASE: "/connections",
    ACCEPT: (id: string) => `/connections/${id}/accept`,
    REJECT: (id: string) => `/connections/${id}/reject`,
  },

  MESSAGES: {
    BASE: "/messages",
    CHAT: (userId: string) => `/messages/${userId}`,
  },

  NOTIFICATIONS: {
    BASE: "/notifications",
    READ: (id: string) => `/notifications/${id}/read`,
  },

  ADMIN: {
    ALUMNI: "/admin/alumni",
    APPROVE: (id: string) => `/admin/alumni/${id}/approve`,
    REJECT: (id: string) => `/admin/alumni/${id}/reject`,
    REPORTS: "/admin/reports",
  },

  SEARCH: "/search",
};
```

***

# 🔐 4. Auth Service

```TypeScript
import api from "@/api/client";
import { ENDPOINTS } from "@/api/endpoints";

export const authService = {
  sendOtp: (email: string) =>
    api.post(ENDPOINTS.AUTH.SEND_OTP, { email }),

  verifyOtp: async (data: any) => {
    const res = await api.post(ENDPOINTS.AUTH.VERIFY_OTP, data);
    if (res.data.accessToken) {
      localStorage.setItem("accessToken", res.data.accessToken);
    }
    return res.data;
  },

  logout: () => api.post(ENDPOINTS.AUTH.LOGOUT),
};
```

***

# ❓ 5. Question Service

```TypeScript
import api from "@/api/client";
import { ENDPOINTS } from "@/api/endpoints";

export const questionService = {
  createQuestion: (data: {
    title: string;
    description: string;
    tags: string[];
    isAnonymous: boolean;
  }) => api.post(ENDPOINTS.QUESTIONS.BASE, data),

  getQuestions: (params: any) =>
    api.get(ENDPOINTS.QUESTIONS.BASE, { params }),

  getQuestionById: (id: string) =>
    api.get(ENDPOINTS.QUESTIONS.DETAIL(id)),
};
```

***

# 💬 6. Answer Service

```TypeScript
export const answerService = {
  answerQuestion: (data: { questionId: string; content: string }) =>
    api.post("/answers", data),

  replyToAnswer: (id: string, content: string) =>
    api.post(`/answers/${id}/reply`, { content }),

  acceptAnswer: (id: string) =>
    api.post(`/answers/${id}/accept`),
};
```

***

# 📰 7. Post Service

```TypeScript
export const postService = {
  createPost: (data: any) =>
    api.post("/posts", data),

  getFeed: (params: any) =>
    api.get("/posts", { params }),

  getPostById: (id: string) =>
    api.get(`/posts/${id}`),

  comment: (id: string, content: string) =>
    api.post(`/posts/${id}/comments`, { content }),
};
```

***

# 📚 8. Resource Service

```TypeScript
export const resourceService = {
  create: (data: any) =>
    api.post("/resources", data),

  getAll: (params: any) =>
    api.get("/resources", { params }),
};
```

***

# 👍 9. Vote Service

```TypeScript
export const voteService = {
  vote: (data: {
    contentType: string;
    contentId: string;
    type: "UP" | "DOWN";
  }) => api.post("/votes", data),
};
```

***

# 🤝 10. Connection Service

```TypeScript
export const connectionService = {
  sendRequest: (data: { receiverId: string; message: string }) =>
    api.post("/connections", data),

  accept: (id: string) =>
    api.post(`/connections/${id}/accept`),

  reject: (id: string) =>
    api.post(`/connections/${id}/reject`),

  getAll: () => api.get("/connections"),
};
```

***

# 💬 11. Message Service

```TypeScript
export const messageService = {
  getChats: () => api.get("/messages"),

  getChat: (userId: string) =>
    api.get(`/messages/${userId}`),

  send: (data: { receiverId: string; content: string }) =>
    api.post("/messages", data),
};
```

***

# 🔔 12. Notification Service

```TypeScript
export const notificationService = {
  getAll: () => api.get("/notifications"),

  markRead: (id: string) =>
    api.post(`/notifications/${id}/read`),
};
```

***

# 🛠 13. Admin Service

```TypeScript
export const adminService = {
  getPendingAlumni: () =>
    api.get("/admin/alumni"),

  approve: (id: string) =>
    api.post(`/admin/alumni/${id}/approve`),

  reject: (id: string) =>
    api.post(`/admin/alumni/${id}/reject`),

  getReports: () =>
    api.get("/admin/reports"),
};
```

***

# 🔍 14. Search Service

```TypeScript
export const searchService = {
  search: (query: string) =>
    api.get("/search", { params: { q: query } }),
};
```

***

# 🧠 15. Example Usage (React)

```TypeScript
const loadQuestions = async () => {
  try {
    const res = await questionService.getQuestions({ page: 1 });
    setQuestions(res.data);
  } catch (err) {
    console.error(err);
  }
};
```

***

# 🚀 What You Now Have

This layer gives you:

✅ Clean API abstraction
✅ Centralized error handling
✅ Token management (auto refresh)
✅ Scalable service structure
