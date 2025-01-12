<?php
include 'db_connect.php';
header('Content-Type: application/json'); 

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $thesis_id = intval($_POST['thesis_id']);
    $arithmos_protokolou = intval($_POST['arithmos_protokolou']); 

    if ($thesis_id > 0 && $arithmos_protokolou > 0) {

        $conn->begin_transaction();

        try {
            $conn->query("SET @bypass_trigger = 1;");

            $updateQuery = "UPDATE thesis SET state = 'cancelled', ap = ? WHERE thesis_id = ?;";
            $stmt = $conn->prepare($updateQuery);

            if ($stmt) {
                $stmt->bind_param("ii", $arithmos_protokolou, $thesis_id);

                if ($stmt->execute()) {
                    $response = ["success" => true, "message" => "Thesis state updated to 'cancelled' and AP updated successfully."];
                } else {
                    $response = ["success" => false, "message" => "Error: " . $stmt->error];
                }
                
                $stmt->close();
            } else {
                throw new Exception("Failed to prepare the update statement.");
            }

            $conn->query("SET @bypass_trigger = 0;");

            $conn->commit();
        } catch (Exception $e) {
            $conn->rollback();
            $response = ["success" => false, "message" => $e->getMessage()];
        }
    } else {
        $response = ["success" => false, "message" => "Invalid thesis ID or AP."];
    }

    echo json_encode($response);
    $conn->close();
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method."]);
}
?>
