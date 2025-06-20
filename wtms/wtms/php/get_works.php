<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
include_once("dbconnect.php");

$worker_id = isset($_POST['worker_id']) ? $_POST['worker_id'] : '';

if (empty($worker_id)) {
    echo json_encode(['status' => 'failed', 'data' => null, 'message' => 'worker_id missing']);
    exit();
}

$sql = "SELECT * FROM tbl_works WHERE assigned_to = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $worker_id);
$stmt->execute();
$result = $stmt->get_result();

$tasks = [];
while ($row = $result->fetch_assoc()) {
    $tasks[] = $row;
}

if (count($tasks) > 0) {
    echo json_encode(['status' => 'success', 'data' => $tasks]);
} else {
    echo json_encode(['status' => 'failed', 'data' => null, 'message' => 'No tasks found']);
}

$stmt->close();
$conn->close();
?>
