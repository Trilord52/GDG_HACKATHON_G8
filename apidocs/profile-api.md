safeCampus API Documentation 📚

# Profile Routes

## 1. Get User Profile
**Endpoint**: `GET /api/profile`  
**Description**: Retrieves the profile details of the authenticated user.  
**Authentication**: Token required in the header.  

### Response Body:
- **Success (200)**:
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "studentId": "123456",
    "fullName": "John Doe",
    "email": "johndoe@example.com",
    "role": "student",
    "trustedContacts": [
      {
        "name": "Jane Doe",
        "phone": "1234567890",
        "email": "janedoe@example.com",
        "relationShip": "friend"
      }
    ],
    "location": {
      "type": "Point",
      "coordinates": [38.80895765457167, 8.891288891174664]
    },
    "addressDescription": "Dorm 2, Room 303, AASTU Main Campus"
  }
}
Unauthorized (401):
{
  "success": false,
  "message": "Unauthorized"
}
Not Found (404):
{
  "success": false,
  "message": "User not found"
}
2. Update User Profile
Endpoint: PUT /api/profile
Description: Updates the profile details of the authenticated user.
Authentication: Token required in the header.
Request Body:
{
  "fullName": "John Doe Updated",
  "email": "johnupdated@example.com",
  "location": {
    "type": "Point",
    "coordinates": [38.80895765457167, 8.891288891174664]
  },
  "addressDescription": "Dorm 3, Room 101, AASTU Main Campus"
}
Response Body:
Success (200):
{
  "success": true,
  "message": "User profile updated successfully",
  "data": {
    "studentId": "123456",
    "fullName": "John Doe Updated",
    "email": "johnupdated@example.com",
    "role": "student",
    "trustedContacts": [
      {
        "name": "Jane Doe",
        "phone": "1234567890",
        "email": "janedoe@example.com",
        "relationShip": "friend"
      }
    ],
    "location": {
      "type": "Point",
      "coordinates": [38.80895765457167, 8.891288891174664]
    },
    "addressDescription": "Dorm 3, Room 101, AASTU Main Campus"
  }
}

Validation Error (400):
{
  "success": false,
  "message": "Validation error message"
}
Unauthorized (401):
{
  "success": false,
  "message": "Unauthorized"
}

Not Found (404):
{
  "success": false,
  "message": "User not found"
}
3. Delete User Profile
Endpoint: DELETE /api/profile
Description: Deletes the profile of the authenticated user.
Authentication: Token required in the header.

Response Body:
Success (200):
{
  "success": true,
  "message": "User profile deleted successfully",
  "data": {
    "studentId": "123456",
    "fullName": "John Doe",
    "email": "johndoe@example.com",
    "role": "student"
  }
}
Unauthorized (401):
{
  "success": false,
  "message": "Unauthorized"
}
Not Found (404):
{
  "success": false,
  "message": "User not found"
}
