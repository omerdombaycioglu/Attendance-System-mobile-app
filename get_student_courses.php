<?php
include 'db_connection.php';

header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["success" => false, "error" => "Geçersiz veri."]);
    exit();
}

$student_id = $data['student_id'];

try {
    $sql = "SELECT c.course_id, c.course_name, c.course_code 
            FROM courses c
            JOIN student_courses sc ON c.course_id = sc.course_id
            WHERE sc.student_id = :student_id";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':student_id' => $student_id]);
    $courses = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["success" => true, "courses" => $courses]);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>