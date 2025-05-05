# 📍 Route Tracking API

This API allows authenticated users to start, update, stop, pause, and share route tracking sessions with friends. Routes are tracked using geolocation data in real time.

> All endpoints require JWT authentication via `Authorization: Bearer <token>`

---

## 📦 Base URL

```
/routes
```

---

## 🔐 Authentication

All routes require the `verifyToken` middleware. Ensure users are logged in before accessing these endpoints.

---

## 📘 Endpoints

### ▶️ Start a Route

**POST** `/routes/start`

Starts a new route session for the authenticated user.

#### Request Body

```json
{
  "startLocation": {
    "coordinates": [longitude, latitude]
  },
  "description": "Optional route description"
}
```

#### Success Response

- **201 Created**

```json
{
  "success": true,
  "message": "Route started successfully",
  "data": { ... }
}
```

---

### ⛔ Stop a Route

**POST** `/routes/:routeId/stop`

Stops an ongoing route session and optionally sets the end location.

#### Request Body

```json
{
  "endLocation": {
    "coordinates": [longitude, latitude]
  }
}
```

#### Success Response

- **200 OK**

---

### ⏸ Pause a Route

**POST** `/routes/:routeId/pause`

Pauses an active route session.

#### Success Response

- **200 OK**

---

### 📍 Update Route Location

**POST** `/routes/:routeId/location`

Updates the route with a new geolocation point.

#### Request Body

```json
{
  "coordinates": [longitude, latitude]
}
```

#### Success Response

- **200 OK**

---

### ℹ️ Get Route Status

**GET** `/routes/:routeId/status`

Fetches the current route status, including the most recent location point.

#### Success Response

```json
{
  "success": true,
  "message": "Route status retrieved successfully",
  "data": {
    "status": "started",
    "startTime": "2025-04-30T12:34:56Z",
    "endTime": null,
    "currentLocation": {
      "location": {
        "type": "Point",
        "coordinates": [longitude, latitude]
      },
      "timestamp": "..."
    }
  }
}
```

---

### 👥 Share Route

**POST** `/routes/:routeId/share`

Shares the route with one or more friends.

#### Request Body

```json
{
  "friendIds": ["userId1", "userId2"]
}
```

#### Success Response

- **200 OK**

---

### 📥 Get Shared Route

**GET** `/routes/:routeId/shared`

Retrieves a route shared with the currently logged-in user.

---

### 📜 Get All Routes for a User

**GET** `/routes?status=<optionalStatus>`

Lists all routes for the current user. Optionally filter by status (`started`, `paused`, `ended`, etc.).

#### Success Response

- **200 OK**

```json
{
  "data": [
    {
      "_id": "...",
      "description": "...",
      "status": "...",
      "startTime": "...",
      ...
    }
  ]
}
```

---

### ✏️ Update Route Details

**PATCH** `/routes/:routeId`

Update the description of a route.

#### Request Body

```json
{
  "description": "Updated route description"
}
```

---

## 🧱 Data Model: Route

```json
{
  "_id": "ObjectId",
  "userId": "ObjectId",
  "startLocation": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "endLocation": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "status": "started | paused | ended | emergency",
  "locationPoints": [
    {
      "location": {
        "type": "Point",
        "coordinates": [longitude, latitude]
      },
      "timestamp": "ISODate"
    }
  ],
  "sharedWith": [
    {
      "userId": "ObjectId",
      "sharedAt": "ISODate"
    }
  ],
  "startTime": "ISODate",
  "endTime": "ISODate",
  "description": "string",
  "createdAt": "ISODate",
  "updatedAt": "ISODate"
}
```

---

## ⚠️ Errors

- `401 Unauthorized`: User not authenticated
- `404 Not Found`: Route not found or not shared
- `400 Bad Request`: Invalid input (missing fields, invalid coordinates)
- `500 Server Error`: Internal server issues

---

## 📌 Notes

- All coordinates must follow `[longitude, latitude]` format.

---
