# 🧠 State Management Strategy

---

## Principles

1. **Server = source of truth**

   * Don’t over-store data
   * Fetch when needed

2. **Global state only for shared data**

   * auth
   * user
   * notifications

3. **Page-level state stays local or in scoped store**

---

# 📁 Folder Structure

```plaintext
src/
 ├── store/
 │    ├── auth.store.ts
 │    ├── user.store.ts
 │    ├── question.store.ts
 │    ├── post.store.ts
 │    ├── resource.store.ts
 │    ├── connection.store.ts
 │    ├── message.store.ts
 │    ├── notification.store.ts
```

---

# 🔐 1. Auth Store (Global)

## Responsibilities

* user session
* login/logout
* token sync

---

## `auth.store.ts`

```ts
import { create } from "zustand";
import { authService } from "@/services/auth.service";

interface AuthState {
  user: any | null;
  isAuthenticated: boolean;
  loading: boolean;

  setUser: (user: any) => void;
  login: (data: any) => Promise<void>;
  logout: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  loading: false,

  setUser: (user) =>
    set({ user, isAuthenticated: !!user }),

  login: async (data) => {
    set({ loading: true });
    const res = await authService.verifyOtp(data);

    if (res.accessToken) {
      set({
        user: res.user,
        isAuthenticated: true,
        loading: false,
      });
    }
  },

  logout: async () => {
    await authService.logout();
    localStorage.removeItem("accessToken");

    set({
      user: null,
      isAuthenticated: false,
    });
  },
}));
```

---

# 👤 2. User Store

```ts
import { create } from "zustand";
import { userService } from "@/services/user.service";

export const useUserStore = create((set) => ({
  profile: null,
  activity: null,

  fetchProfile: async (id: string) => {
    const res = await userService.getProfile(id);
    set({ profile: res.data });
  },

  fetchActivity: async (id: string) => {
    const res = await userService.getActivity(id);
    set({ activity: res.data });
  },
}));
```

---

# ❓ 3. Question Store (Core)

---

## Responsibilities

* question list
* question detail
* answers

---

```ts
import { create } from "zustand";
import { questionService } from "@/services/question.service";
import { answerService } from "@/services/answer.service";

export const useQuestionStore = create((set) => ({
  questions: [],
  questionDetail: null,
  loading: false,

  fetchQuestions: async (params: any) => {
    set({ loading: true });
    const res = await questionService.getQuestions(params);

    set({
      questions: res.data,
      loading: false,
    });
  },

  fetchQuestionById: async (id: string) => {
    set({ loading: true });
    const res = await questionService.getQuestionById(id);

    set({
      questionDetail: res.data,
      loading: false,
    });
  },

  createQuestion: async (data: any) => {
    await questionService.createQuestion(data);
  },

  answerQuestion: async (data: any) => {
    await answerService.answerQuestion(data);
  },
}));
```

---

# 📰 4. Post Store

```ts
import { create } from "zustand";
import { postService } from "@/services/post.service";

export const usePostStore = create((set) => ({
  posts: [],
  loading: false,

  fetchPosts: async (params: any) => {
    set({ loading: true });
    const res = await postService.getFeed(params);

    set({
      posts: res.data,
      loading: false,
    });
  },

  createPost: async (data: any) => {
    await postService.createPost(data);
  },
}));
```

---

# 📚 5. Resource Store

```ts
import { create } from "zustand";
import { resourceService } from "@/services/resource.service";

export const useResourceStore = create((set) => ({
  resources: [],

  fetchResources: async (params: any) => {
    const res = await resourceService.getAll(params);
    set({ resources: res.data });
  },
}));
```

---

# 🤝 6. Connection Store

```ts
import { create } from "zustand";
import { connectionService } from "@/services/connection.service";

export const useConnectionStore = create((set) => ({
  connections: null,

  fetchConnections: async () => {
    const res = await connectionService.getAll();
    set({ connections: res.data });
  },

  sendRequest: async (data: any) => {
    await connectionService.sendRequest(data);
  },
}));
```

---

# 💬 7. Message Store (Real-Time Ready)

```ts
import { create } from "zustand";
import { messageService } from "@/services/message.service";

export const useMessageStore = create((set) => ({
  chats: [],
  activeChat: [],
  activeUserId: null,

  fetchChats: async () => {
    const res = await messageService.getChats();
    set({ chats: res.data });
  },

  fetchChat: async (userId: string) => {
    const res = await messageService.getChat(userId);
    set({
      activeChat: res.data,
      activeUserId: userId,
    });
  },

  sendMessage: async (data: any) => {
    await messageService.send(data);
  },
}));
```

---

# 🔔 8. Notification Store

```ts
import { create } from "zustand";
import { notificationService } from "@/services/notification.service";

export const useNotificationStore = create((set) => ({
  notifications: [],

  fetchNotifications: async () => {
    const res = await notificationService.getAll();
    set({ notifications: res.data });
  },

  markRead: async (id: string) => {
    await notificationService.markRead(id);
  },
}));
```

---

# 🔄 Real-Time Integration (Important)

When using Socket.io:

```ts
socket.on("receive_message", (msg) => {
  useMessageStore.setState((state) => ({
    activeChat: [...state.activeChat, msg],
  }));
});
```

---

# 🧠 Key Patterns You Must Follow

---

## 1. Don’t Overstore Data

* Avoid duplicating:

  * question list
  * question detail

---

## 2. Always Refetch After Mutation

Example:

```ts
await createQuestion(data);
fetchQuestions();
```

---

## 3. Keep Stores Feature-Based

Not:

* one giant store

But:

* modular stores (what we did)

---

## 4. Avoid Deep Nesting

Keep state flat:

```ts
questions: []
questionDetail: {}
```

---

# 🚀 What You Now Have

You now have:

✅ Clean API layer
✅ Structured state management
✅ Modular architecture
✅ Real-time ready stores
