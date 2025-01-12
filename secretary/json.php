
<?php
session_start();

include 'db_connect.php';

// Validate session and user role
if (!isset($_SESSION['user_id']) || !isset($_SESSION['role'])) {
    header("Location: ../login.php");
    exit();
}

// Check if the session cookie exists and is valid
if (!isset($_COOKIE['user_session']) || $_COOKIE['user_session'] !== session_id()) {
    header("Location: ../login.php");
    exit();
}

if ($_SESSION['role'] !== 'secretary') {
    echo "Access denied. This page is for the secretary only.";
    exit();
}

$user_id = $_SESSION['user_id'];
?>




<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload and Display Data</title>
    <link rel="stylesheet" href="secretary.css">
</head>
<body>

    <nav>
        <button onclick="location.href='secretary.php'">Home</button>
        <button onclick="location.href='json.php'">Students/Professors Datasheet Upload</button>
        <button onclick="location.href='anouncements.php'">Thesis Anouncements</button>
    </nav>
    
    <form action='../logout.php' method='POST'>
        <button type='submit' class='logout-button'>Logout</button>
    </form>

    <div class="upload-container">
        <h1>Students/Professors Datasheet Upload</h1>
        <form id="json-upload-form">
            <input type="file" id="json-file" name="json-file" accept="application/json">
            <button type="button" id="upload-button">Upload</button>
        </form>
        <p id="upload-message"></p>

        <div id="data-display">
            <h2>Professors</h2>
            <table id="professors-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Surname</th>
                        <th>Email</th>
                        <th>Topic</th>
                        <th>Landline</th>
                        <th>Mobile</th>
                        <th>Department</th>
                        <th>University</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>

            <h2>Students</h2>
            <table id="students-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Surname</th>
                        <th>Email</th>
                        <th>Landline</th>
                        <th>Mobile</th>
                        <th>Department</th>
                        <th>University</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>

    <script src="json_upload.js"></script>
</body>
</html>
