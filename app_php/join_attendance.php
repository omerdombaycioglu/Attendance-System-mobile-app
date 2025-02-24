<?php
include 'db_connection.php';

header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["success" => false, "error" => "Geçersiz veri."]);
    exit();
}

$attendanceId = $data['attendance_id'];
$studentId = $data['student_id'];
$attendanceCode = $data['attendance_code'];

try {
    // Yoklama kodunu kontrol et
    $sql = "SELECT * FROM active_attendance WHERE attendance_id = :attendance_id AND attendance_code = :attendance_code";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':attendance_id' => $attendanceId, ':attendance_code' => $attendanceCode]);
    $attendance = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($attendance) {
        // Yoklama kaydını ekle
        $sql = "INSERT INTO attendance_records (attendance_id, student_id, status) VALUES (:attendance_id, :student_id, 'present')";
        $stmt = $conn->prepare($sql);
        $stmt->execute([':attendance_id' => $attendanceId, ':student_id' => $studentId]);

        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "error" => "Geçersiz yoklama kodu."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>