# Panic Alert API Documentation

## Base URL
```
/api/panic-alert
```

## Authentication
All endpoints require authentication using a valid JWT token in the Authorization header.
Format: `Bearer <token>`

## Endpoints

### Trigger Panic Event
Trigger a new panic event.

**Endpoint:** `POST /trigger`

**Authentication:** Required

**Request Body:**
```json
{
  "location": {
    "coordinates": [number, number] // [longitude, latitude]
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "success",
  "data": {
    "message": "Panic event triggered successfully.",
    "data": {
      "_id": "string",
      "userId": "string",
      "location": {
        "type": "Point",
        "coordinates": [number, number]
      },
      "timeStamp": "string",
      "resolved": false,
      "notifications": [],
      "acknowledgedBy": []
    }
  }
}
```

**Error Responses:**
- `401 Unauthorized`: 
  - Invalid or missing token
  - Invalid request format
  - Missing location coordinates
- `500 Internal Server Error`: Server error

### Get All Panic Events
Get all panic events (Admin and Campus Security only).

**Endpoint:** `GET /get-all`

**Authentication:** Required (Admin/Campus Security)

**Query Parameters:**
- `page` (optional): Page number for pagination (default: 1)
- `limit` (optional): Number of items per page (default: 20)

**Response:**
```json
{
  "success": true,
  "message": "success",
  "data": {
    "message": "Panic events retrieved successfully.",
    "data": [
      {
        "_id": "string",
        "userId": {
          "name": "string",
          "email": "string"
        },
        "location": {
          "type": "Point",
          "coordinates": [number, number]
        },
        "timeStamp": "string",
        "resolved": boolean,
        "resolvedBy": {
          "name": "string",
          "email": "string"
        },
        "resolvedAt": "string",
        "notifications": [
          {
            "type": "contact" | "guard",
            "userId": "string",
            "name": "string",
            "email": "string",
            "notifiedAt": "string"
          }
        ],
        "acknowledgedBy": [
          {
            "userId": "string",
            "name": "string",
            "email": "string",
            "notifiedAt": "string",
            "response": "yes" | "no"
          }
        ]
      }
    ],
    "analysis": {
      "totalPanicEvents": number,
      "totalPages": number,
      "currentPage": number,
      "hasNextPage": boolean,
      "hasPreviousPage": boolean
    }
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid or missing token
- `403 Forbidden`: Insufficient permissions
- `500 Internal Server Error`: Server error

### Get User's Panic Events
Get all panic events for the authenticated user.

**Endpoint:** `GET /user`

**Authentication:** Required

**Query Parameters:**
- `page` (optional): Page number for pagination (default: 1)
- `limit` (optional): Number of items per page (default: 20)

**Response:**
```json
{
  "success": true,
  "message": "success",
  "data": {
    "message": "Panic events retrieved successfully.",
    "data": [
      {
        "_id": "string",
        "userId": {
          "name": "string",
          "email": "string"
        },
        "location": {
          "type": "Point",
          "coordinates": [number, number]
        },
        "timeStamp": "string",
        "resolved": boolean,
        "resolvedBy": {
          "name": "string",
          "email": "string"
        },
        "resolvedAt": "string",
        "notifications": [
          {
            "type": "contact" | "guard",
            "userId": "string",
            "name": "string",
            "email": "string",
            "notifiedAt": "string"
          }
        ],
        "acknowledgedBy": [
          {
            "userId": "string",
            "name": "string",
            "email": "string",
            "notifiedAt": "string",
            "response": "yes" | "no"
          }
        ]
      }
    ],
    "analysis": {
      "totalPanicEvents": number,
      "totalPages": number,
      "currentPage": number,
      "hasNextPage": boolean,
      "hasPreviousPage": boolean
    }
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid or missing token
- `500 Internal Server Error`: Server error

### Update Panic Event Status
Update the status of a panic event (Admin and Campus Security only).

**Endpoint:** `PUT /update/:eventId`

**Authentication:** Required (Admin/Campus Security)

**Response:**
```json
{
  "success": true,
  "message": "success",
  "data": {
    "_id": "string",
    "userId": {
      "name": "string",
      "email": "string"
    },
    "location": {
      "type": "Point",
      "coordinates": [number, number]
    },
    "timeStamp": "string",
    "resolved": boolean,
    "resolvedBy": {
      "name": "string",
      "email": "string"
    },
    "resolvedAt": "string"
  }
}
```

**Error Responses:**
- `401 Unauthorized`: 
  - Invalid or missing token
  - Invalid event ID
  - Panic event not found
- `403 Forbidden`: Insufficient permissions
- `500 Internal Server Error`: Server error

### Update Notified Contacts
Update the list of notified contacts for a panic event.

**Endpoint:** `PUT /update-notified/:eventId`

**Authentication:** Required

**Request Body:**
```json
{
  "notifications": [
    {
      "type": "contact" | "guard",
      "userId": "string", // Optional, for guards
      "name": "string",
      "email": "string"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "success",
  "data": {
    "_id": "string",
    "notifications": [
      {
        "type": "contact" | "guard",
        "userId": "string",
        "name": "string",
        "email": "string",
        "notifiedAt": "string"
      }
    ]
  }
}
```

**Error Responses:**
- `401 Unauthorized`: 
  - Invalid or missing token
  - Invalid event ID
  - Panic event not found
- `500 Internal Server Error`: Server error

### Update Acknowledged Contacts
Update the list of acknowledged contacts for a panic event.

**Endpoint:** `PUT /update-acknowledged/:eventId`

**Authentication:** Required

**Request Body:**
```json
{
  "acknowledgedBy": [
    {
      "userId": "string", // Optional, for registered users
      "name": "string",
      "email": "string",
      "response": "yes" | "no"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "success",
  "data": {
    "_id": "string",
    "acknowledgedBy": [
      {
        "userId": "string",
        "name": "string",
        "email": "string",
        "notifiedAt": "string",
        "response": "yes" | "no"
      }
    ]
  }
}
```

**Error Responses:**
- `401 Unauthorized`: 
  - Invalid or missing token
  - Invalid event ID
  - Panic event not found
- `500 Internal Server Error`: Server error

## Notes
- All requests should include `Content-Type: application/json` header
- The access token should be included in the `Authorization` header
- Token format: `Bearer <token>`
- Some endpoints require specific user roles (admin, campus_security)
- Location coordinates should be provided in [longitude, latitude] format
- Timestamps are in ISO 8601 format
- The system supports pagination for list endpoints
- Notifications can be of type "contact" or "guard"
- Acknowledged responses can be "yes" or "no"
- The system includes email tracking and response handling
- Google Maps URL is generated for location visualization 