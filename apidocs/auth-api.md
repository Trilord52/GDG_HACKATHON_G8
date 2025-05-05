Authentication API Documentation
The auth API allows users to register and log in to the system. It supports student registration and login functionality.

1. Register a User
Endpoint: POST /api/auth/register
Description: Allows students to register for the system.
Authentication: No authentication required.

Request Body:
{
  "studentId": "123456",
  "fullName": "John Doe",
  "email": "johndoe@example.com",
  "password": "password123",
  "deviceToken": "device_token_123",
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
  "addressDescription": "Dorm 1"
}



Request Body Fields:
studentId (string): The student ID (required for students).
fullName (string): The full name of the user (optional).
email (string): The email address of the user (required).
password (string): The password for the user account (required).
deviceToken (string): The device token for push notifications (required).
role (string): The role of the user. Must be "student" (default: "student").
trustedContacts (array): An array of trusted contacts (optional).
name (string): Name of the trusted contact.
phone (string): Phone number of the trusted contact (required).
email (string): Email address of the trusted contact (required).
relationShip (string): Relationship with the user (friend, roommate, colleague, other).
location (object): GeoJSON object for the user's location (optional).
type (string): Must be "Point".
coordinates (array): Array of two numbers [longitude, latitude].
addressDescription (string): Description of the user's address (optional).
Response:
Success (201):

{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "_id": "645c0e1234567890abcdef12",
    "studentId": "123456",
    "email": "johndoe@example.com",
    "role": "student"
  }
}
Error (400):
{
  "success": false,
  "message": "User with this email or student id already exists."
}
Error (500):
{
  "success": false,
  "message": "Server error"
}

2. Log In a User
Endpoint: POST /api/auth/login
Description: Allows users to log in to the system.
Authentication: No authentication required.

Request Body:
{
  "email": "johndoe@example.com",
  "password": "password123"
}

Request Body Fields:
email (string): The email address of the user (required).
password (string): The password for the user account (required).
Response:
Success (200):
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "jwt_token_here",
    "user": {
      "_id": "645c0e1234567890abcdef12",
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
      "addressDescription": "Dorm 1"
    }
  }
}

Error (401):
{
  "success": false,
  "message": "please register first"
}
Error (403):

{
  "success": false,
  "message": "please provide email and password"
}
Error (500):
{
  "success": false,
  "message": "Server error"
}


post api/auth/update_token  => used to update the fireabase token when it gets refreshed