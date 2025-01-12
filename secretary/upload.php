<?php
$host = 'localhost';
$username = 'root';
$password = '';
$database = 'project24';

$conn = new mysqli($host, $username, $password, $database);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$jsonData = json_decode($_POST['jsonData'], true);

if ($jsonData) {
    if (isset($jsonData['professors']) && is_array($jsonData['professors'])) {
        foreach ($jsonData['professors'] as $professor) {
            $stmt = $conn->prepare("INSERT INTO professor (professor_id, name, surname, email, topic, landline, mobile, department, university, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("isssssssss", $professor['id'], $professor['name'], $professor['surname'], $professor['email'], $professor['topic'], $professor['landline'], $professor['mobile'], $professor['department'], $professor['university'], $professor['email']);
            $stmt->execute();
        }
    }

    if (isset($jsonData['students']) && is_array($jsonData['students'])) {
        foreach ($jsonData['students'] as $student) {
            $stmt = $conn->prepare("INSERT INTO student (student_id, name, surname, email, landline, mobile, department, university, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("issssssss", $student['id'], $student['name'], $student['surname'], $student['email'], $student['landline'], $student['mobile'], $student['department'], $student['university'], $student['email']);
            $stmt->execute();
        }
    }

    echo "Data inserted successfully!";
} else {
    echo "Invalid JSON data!";
}

$conn->close();
?>
