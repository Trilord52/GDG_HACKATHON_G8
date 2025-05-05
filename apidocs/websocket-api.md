## 📡 WebSocket Functionality

### Overview

This module establishes real-time, bi-directional communication using Socket.IO. It handles secure client connections, room-based messaging for "routes", and supports location updates, route sharing, and status management in real-time.

---

### 🔌 Initialization

**File:** `config/socket.config.js`

- Initializes a Socket.IO server with CORS and timeout configurations.
- Applies authentication middleware and socket event handling via `initSocketEvents`.
- Manages connections and namespace-level configurations.
- Gracefully handles client reconnections, disconnections, and errors.

```js
const { initSocket, getIO } = require('./config/socket.config');
```

#### Environments
- **Allowed origins:** Controlled by `process.env.ALLOWEDORIGINS`.
- **JWT secret:** `process.env.JWT_SECRET`

---

### 🔐 Socket Authentication

**File:** `sockets/middleware/socket.auth.js`

- Authenticates socket connections using JWT from either `auth.token` or `query.token`.
- Adds the decoded user ID and role to the `socket.user` object.
- Emits errors on token absence, expiration, or invalidity.

```js
socket.use(socketAuth);
```

---

### 🧠 Socket Events Initialization

**File:** `sockets/index.js`

- Applies error and authentication middleware to all connections.
- Initializes namespaced socket events (`/routes`).
- Logs disconnection events with connection duration.

```js
initSocketEvents(io);
```

---

### 🧭 Route Namespace

**File:** `sockets/route.socket.js`  
**Namespace:** `/routes`

Handles all real-time interactions for route-based operations.

#### Events

| Event Name                 | Payload                                      | Description                                                  |
|---------------------------|----------------------------------------------|--------------------------------------------------------------|
| `route:join`              | `routeId: String`                            | Joins a user to a route room after validation.              |
| `route:leave`             | `routeId: String`                            | Leaves the specified route room.                            |
| `route:location-update`   | `{ routeId, location: { coordinates } }`     | Pushes location points to the route with rate limiting.     |
| `route:share`             | `{ routeId, sharedWith: UserId }`            | Shares the route with another user.                         |
| `route:status-change`     | `{ routeId, status }`                        | Updates the route status and notifies all connected users.  |

#### Broadcasts

| Event Name                 | Triggered When...                                | Payload                                |
|---------------------------|--------------------------------------------------|----------------------------------------|
| `route:joined`            | On successful room join                          | `{ routeId }`                          |
| `route:left`              | On successful room leave                         | `{ routeId }`                          |
| `route:location-updated`  | After successful location update                 | `{ routeId, location }`                |
| `route:shared`            | When a route is shared with another user         | `{ routeId, sharedBy }`                |
| `route:shared-success`    | After route is successfully shared               | `{ routeId, sharedWith }`              |
| `route:status-changed`    | After route status is changed                    | `{ routeId, status }`                  |
| `route:status-changed-success` | Acknowledgment for status change success   | `{ routeId, status }`                  |

---

### 📊 Rate Limiting

- Applies to `route:location-update` event.
- Allows **60 updates per minute per user**.
- Prevents location spamming using `updateCounts` map.

---

### ⚠️ Error Handling

- All namespaces and sockets emit `error` events with descriptive messages on:
  - Invalid input
  - Unauthorized actions
  - Not found errors
  - Server exceptions