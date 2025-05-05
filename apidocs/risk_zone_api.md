The dangerArea API allows users to interact with dangerous zones on the map. It supports fetching dangerous areas, creating risk zones, and deleting risk zones.


1. Get All Dangerous Areas
Endpoint: GET /api/danger-area
Description: Retrieves a list of dangerous areas with optional filtering and pagination.
Authentication: Token required in the header.

Query Parameters:
page (number): Page number for pagination (optional, default: 1).
limit (number): Number of records per page (optional, default: 15).
status (string): Filter by status (active, under investigation, resolved) (optional).
types (string): Filter by types of incidents (comma-separated, e.g., theft,assault) (optional).
severity (string): Filter by severity (low, medium, high) (optional).
source (string): Filter by source of the report (user, admin, campus_security, anonymous, other) (optional).

Response:
Success (200):
{
  "success": true,
  "message": "successfully fetched dangerous area",
  "data": [
    {
      "_id": "645c0e1234567890abcdef12",
      "location": {
        "type": "Point",
        "coordinates": [38.80895765457167, 8.891288891174664]
      },
      "severity": "high",
      "reportCount": 5,
      "reports": ["645b9f1234567890abcdef34"],
      "source": ["user"],
      "status": "active",
      "types": ["theft", "assault"],
      "lastReportedAt": "2025-05-02T12:00:00.000Z"
    }
  ]
}
Error (400):
{
  "success": false,
  "message": "error in fetching dangerous area"
}


2. Create a Risk Zone
Endpoint: POST /api/danger-area
Description: Allows admins or campus security to create a new risk zone.
Authentication: Token required in the header.
Authorization: Only users with the roles admin or campus_security can access this endpoint.

Request Body:
{
  "location": {
    "type": "Point",
    "coordinates": [38.80895765457167, 8.891288891174664]
  },
  "severity": "high",
  "types": ["theft", "assault"]
}
location (object): GeoJSON object with type and coordinates (required).
type (string): Must be "Point".
coordinates (array): Array of two numbers [longitude, latitude].
severity (string): Severity of the risk zone (low, medium, high) (required).
types (array): Types of incidents associated with the risk zone (e.g., theft, assault) (required).

Response:
Success (200):
{
  "success": true,
  "message": "risk zone successfully saved",
  "data": {
    "_id": "645c0e1234567890abcdef12",
    "location": {
      "type": "Point",
      "coordinates": [38.80895765457167, 8.891288891174664]
    },
    "severity": "high",
    "reportCount": 1,
    "source": ["admin"],
    "status": "active",
    "types": ["theft", "assault"],
    "lastReportedAt": "2025-05-02T12:00:00.000Z"
  }
}

Error (400):
{
  "success": false,
  "message": "error in creating risk zone"
}
3. Delete a Risk Zone
Endpoint: DELETE /api/danger-area/:id
Description: Allows admins or campus security to delete a specific risk zone by its ID.
Authentication: Token required in the header.
Authorization: Only users with the roles admin or campus_security can access this endpoint.

Request Parameters:
id (string): The ID of the risk zone to delete (required).
Response:
Success (200):
{
  "success": true,
  "message": "deleted successfully",
  "data": {
    "_id": "645c0e1234567890abcdef12",
    "location": {
      "type": "Point",
      "coordinates": [38.80895765457167, 8.891288891174664]
    },
    "severity": "high",
    "reportCount": 1,
    "source": ["admin"],
    "status": "active",
    "types": ["theft", "assault"],
    "lastReportedAt": "2025-05-02T12:00:00.000Z"
  }
}

{
  "success": true,
  "message": "deleted successfully",
  "data": {
    "_id": "645c0e1234567890abcdef12",
    "location": {
      "type": "Point",
      "coordinates": [38.80895765457167, 8.891288891174664]
    },
    "severity": "high",
    "reportCount": 1,
    "source": ["admin"],
    "status": "active",
    "types": ["theft", "assault"],
    "lastReportedAt": "2025-05-02T12:00:00.000Z"
  }
}

Error (400):
{
  "success": false,
  "message": "error in deleting risk zone"
}

Danger Area Data Model
The DangerArea model defines the schema for dangerous zones in the database.

Schema Fields:
location (object): GeoJSON object with the following fields:
type (string): Must be "Point".
coordinates (array): Array of two numbers [longitude, latitude].
severity (string): Severity of the danger zone (low, medium, high).
reportCount (number): Number of reports associated with the danger zone (default: 1).
reports (array): Array of report IDs associated with the danger zone.
source (array): Array of sources for the danger zone (user, admin, campus_security, anonymous, other).
status (string): Status of the danger zone (active, under investigation, resolved).
types (array): Types of incidents associated with the danger zone (e.g., theft, assault).
lastReportedAt (date): Timestamp of the last report associated with the danger zone.
Indexes:
location: Indexed as a 2dsphere for geospatial queries.
tags: Indexed for faster filtering by tags.

