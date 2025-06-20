<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
include_once("dbconnect.php");

$worker_id = isset($_POST['worker_id']) ? $_POST['worker_id'] : '';

if (empty($worker_id)) {
    echo json_encode(['status' => 'failed', 'data' => null, 'message' => 'worker_id missing']);
    exit();
}

$sql = "SELECT s.id as submission_id, s.submission_text, s.submitted_at, w.title 
        FROM tbl_submissions s
        JOIN tbl_works w ON s.work_id = w.work_id
        WHERE s.worker_id = ?
        ORDER BY s.submitted_at DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $worker_id);
$stmt->execute();
$result = $stmt->get_result();

$submissions = [];
while ($row = $result->fetch_assoc()) {
    $submissions[] = $row;
}

if (count($submissions) > 0) {
    echo json_encode(['status' => 'success', 'data' => $submissions]);
} else {
    echo json_encode(['status' => 'failed', 'data' => null, 'message' => 'No submissions found']);
}

$stmt->close();
$conn->close();
?>
