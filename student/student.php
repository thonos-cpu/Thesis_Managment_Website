
<?php
include("head_student.html");
include("project_base.php");
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <link rel="stylesheet" href="style.css?v=<?php echo time(); ?>">
</head>
<body>
    <form action="../logout.php" method="post">
        <input class="but" type="submit" name="logout" value="LOGOUT">
    </form>
</body>
</html>


<?php
 if(isset($_POST["logout"])){
    session_destroy();
    header("location: login_page.php");
}
?>