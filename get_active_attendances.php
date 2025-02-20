<?php
include 'db_connection.php';

header("Content-Type: application/json");

$student_id = $_GET['student_id']; // Öğrenci ID'si

try {
    $sql = "SELECT a.attendance_id, a.course_id, a.attendance_code, c.course_name 
            FROM active_attendance a
            JOIN courses c ON a.course_id = c.course_id
            JOIN student_courses sc ON a.course_id = sc.course_id
            WHERE sc.student_id = :student_id
              AND a.attendance_date = CURDATE()
              AND a.start_time <= CURTIME()
              AND a.end_time >= CURTIME()";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':student_id' => $student_id]);
    $attendances = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["success" => true, "attendances" => $attendances]);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>