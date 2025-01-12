<?php
include 'db_connect.php';
header('Content-Type: application/json'); // Set response type to JSON

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $thesis_id = intval($_POST['thesis_id']);

    // Check if thesis_id is valid
    if ($thesis_id > 0) {
        $deleteQuery = "UPDATE thesis SET state = 'cancelled' WHERE thesis_id = ?";
        $stmt = $conn->prepare($deleteQuery);

        if ($stmt) {
            $stmt->bind_param("i", $thesis_id);

            if ($stmt->execute()) {
                echo json_encode(["success" => true, "message" => "Thesis deleted successfully."]);
            } else {
                echo json_encode(["success" => false, "message" => "Error: " . $stmt->error]);
            }

            $stmt->close();
        } else {
            echo json_encode(["success" => false, "message" => "Failed to prepare the delete statement."]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Invalid thesis ID."]);
    }

    $conn->close();
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method."]);
}
?>
