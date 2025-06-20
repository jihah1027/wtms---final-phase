<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
include_once("dbconnect.php");

$submission_id = isset($_POST['submission_id']) ? $_POST['submission_id'] : '';
$updated_text = isset($_POST['updated_text']) ? $_POST['updated_text'] : '';

if (empty($submission_id) || empty($updated_text)) {
    echo json_encode(['status' => 'failed', 'message' => 'Missing submission_id or updated_text']);
    exit();
}

$sql = "UPDATE tbl_submissions SET submission_text = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $updated_text, $submission_id);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Submission updated successfully']);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'Update failed']);
}

$stmt->close();
$conn->close();
?>
