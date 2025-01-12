<?php
include("head_student.html");
include("project_base.php");

// Έλεγχος αν υπάρχει ήδη ενεργή συνεδρία
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

// Εξασφάλιση ότι ο χρήστης είναι συνδεδεμένος και είναι φοιτητής
if (!isset($_SESSION['role']) || $_SESSION['role'] != 'student') {
    header("Location: ../login.php");
    exit;
}

// Παίρνουμε το student_id από τη συνεδρία
$student_id = $_SESSION['user_id'];

// Φέρνουμε τα υπάρχοντα δεδομένα του φοιτητή
$sql = "SELECT * FROM student WHERE student_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $student_id);
$stmt->execute();
$result = $stmt->get_result();
$student = $result->fetch_assoc();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile</title>
    <link rel="stylesheet" href="style.css?v=<?php echo time(); ?>"><link rel="stylesheet" href="style.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
</head>
<body>
    <h1>Edit Your Details</h1>
    <form id="editForm">
        <label for="email">Email:</label><br>
        <input type="email" id="email" name="email" value="<?php echo htmlspecialchars($student['email']); ?>"><br><br>

        <label for="landline">Landline:</label><br>
        <input type="tel" id="landline" name="landline" value="<?php echo htmlspecialchars($student['landline']); ?>"><br><br>
        
        <label for="mobile">Mobile Number:</label><br>
        <input type="tel" id="mobile" name="mobile" value="<?php echo htmlspecialchars($student['mobile']); ?>"><br><br>
        
        <button type="button" id="saveButton">Save</button>
        <br>
        
    </form>
    <form action="../logout.php" method="post">
        <input class="but" type="submit" name="logout" value="LOGOUT">
    </form>
    
    <p id="message"></p>

    <script>
        $(document).ready(function() {
            $("#saveButton").on("click", function() {
                // Παίρνουμε τα δεδομένα από τη φόρμα
                const formData = {
                    email: $("#email").val(),
                    landline: $("#landline").val(),
                    mobile: $("#mobile").val(),
                    student_id: <?php echo $student_id; ?>
                };

                // Κλήση AJAX
                $.ajax({
                    url: "update_student.php",
                    method: "POST",
                    data: formData,
                    dataType: "json", // Αναμένουμε απάντηση JSON
                    success: function(response) {
                        // Εμφάνιση μηνύματος
                        $("#message").text(response.message).css("color", response.success ? "green" : "red");
                    },
                    error: function() {
                        $("#message").text("An error occurred. Please try again.").css("color", "red");
                    }
                });
            });
        });
    </script>
</body>
</html>
