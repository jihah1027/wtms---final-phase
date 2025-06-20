<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");

if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

$name = $_POST['name'];
$email = $_POST['email'];
$password = sha1($_POST['password']);
$phone = $_POST['phone'];
$address = $_POST['address'];
$image = base64_decode($_POST['image']); // Decode base64 image

$sqlinsert = "INSERT INTO `tbl_users`(`full_name`, `email`, `password`, `phone`, `address`) 
              VALUES ('$name', '$email', '$password', '$phone', '$address')";

try {
    if ($conn->query($sqlinsert) === TRUE) {
        $last_id = $conn->insert_id; // get last inserted ID
        $path = "../assets/images/profiles/" . $last_id . ".png"; // path to save image
        file_put_contents($path, $image); // save image file

        $response = array('status' => 'success', 'data' => null);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }
} catch (Exception $e) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
