Report API Documentation

1. Report an Incident
Endpoint: POST /api/report
Description: Allows users to report an incident with optional evidence and tags.
Authentication: Token required in the header.

Request Body:
{
  "description": "Incident description",
  "anonymous": true,
  "tags": "tag",
  "image":the actual image
  "location": {
    "type": "Point",
    "coordinates": [38.80895765457167, 8.891288891174664]
  }
}

description (string): Description of the incident (required).
anonymous (boolean): Whether the report is anonymous (optional).
tags (string): single tag(optional).
location (object): GeoJSON object with type and coordinates (required).


Response:
Success (200):

{
  "success": true,
  "message": "Incident reported successfully",
  "data": {
    "_id": "645c0e1234567890abcdef12",
    "description": "Incident description",
    "anonymous": true,
    "tags": "tag1",
    "location": {
      "type": "Point",
      "coordinates": [38.80895765457167, 8.891288891174664]
    },
    "evidenceImage": "https://cloudinary.com/image.jpg",
    "reporterId": "645b9f1234567890abcdef34"
  }
}

Error (400):

{
  "success": false,
  "message": "Incomplete form",
  "error": "Please fill in all required fields"
}


2. Get All Reports
Endpoint: GET /api/reports
Description: Retrieves all reports with optional pagination and filtering.
Authentication: Token required in the header.

Query Parameters:
page (number): Page number for pagination (optional, default: 1).
limit (number): Number of reports per page (optional, default: 15).
status (string): Filter by report status (pending, resolved, rejected) (optional).
reporterId (string): Filter by reporter ID (optional).
tags (string): Filter by tags (comma-separated) (optional).

Response:
Success (200):

{
  "success": true,
  "message": "Reports retrieved successfully",
  "data": {
    "reports": [
      {
        "_id": "645c0e1234567890abcdef12",
        "description": "Incident description",
        "anonymous": true,
        "tags": "tags",
        "location": {
          "type": "Point",
          "coordinates": [38.80895765457167, 8.891288891174664]
        },
        "evidenceImage": "https://cloudinary.com/image.jpg",
        "reporterId": "645b9f1234567890abcdef34"
      }
    ],
    "analysis": {
      "totalReports": 100,
      "totalPages": 10,
      "currentPage": 1,
      "hasNextPage": true,
      "hasPreviousPage": false
    }
  }
}

Error (500):
{
  "success": false,
  "message": "Error getting reports"
}

3. Get Nearby Incidents
Endpoint: GET /api/reports/near
Description: Retrieves incidents near a specific location within a 1km radius.
Authentication: Token required in the header.

Query Parameters:
near (string): Comma-separated latitude and longitude (e.g., 8.891288891174664,38.80895765457167) (required).
timePeriod (number): Time period in milliseconds to filter incidents (optional, default: last 48 hours).

Response:
Success (200):

{
  "success": true,
  "message": "Found incidents in 1km radius",
  "data": [
    {
      "_id": "645c0e1234567890abcdef12",
      "description": "Incident description",
      "location": {
        "type": "Point",
        "coordinates": [38.80895765457167, 8.891288891174664]
      },
      "tags": ["tag1", "tag2"]
    }
  ]
}

Error (404):
{
  "success": false,
  "message": "No recent incidents in 1km radius"
}

4. Get Report by ID
Endpoint: GET /api/reports/:id
Description: Retrieves a specific report by its ID.
Authentication: Token required in the header.
Authorization: Admin or campus security roles required.

Request Parameters:
id (string): The ID of the report to retrieve (required).


Response:
Success (200):
{
  "success": true,
  "message": "Report retrieved successfully",
  "data": {
    "_id": "645c0e1234567890abcdef12",
    "description": "Incident description",
    "anonymous": true,
    "tags": "tag",
    "location": {
      "type": "Point",
      "coordinates": [38.80895765457167, 8.891288891174664]
    },
    "evidenceImage": "https://cloudinary.com/image.jpg",
    "reporterId": "645b9f1234567890abcdef34"
  }
}

Error (404):
{
  "success": false,
  "message": "Report not found"
}

5. Delete a Report
Endpoint: DELETE /api/reports/:id
Description: Deletes a specific report by its ID.
Authentication: Token required in the header.
Authorization: Admin or campus security roles required.

Request Parameters:
id (string): The ID of the report to delete (required).
Response:
Success (200):
{
  "success": true,
  "message": "Report deleted successfully"
}
Error (404):
{
  "success": false,
  "message": "Report not found"
}
6. Update Report Status
Endpoint: PATCH /api/reports/:id/status
Description: Updates the status of a specific report.
Authentication: Token required in the header.
Authorization: Admin or campus security roles required.

Request Parameters:
id (string): The ID of the report to update (required).
Request Body:


{
  "status": "resolved"
}

status (string): The new status of the report. Must be one of ["resolved", "pending", "rejected"].

Response:
Success (200):
{
  "success": true,
  "message": "Report status updated successfully",
  "data": {
    "_id": "645c0e1234567890abcdef12",
    "status": "resolved"
  }
}

Error (400):

{
  "success": false,
  "message": "Invalid status"
}