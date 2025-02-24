<?php
include 'db_connection.php';

header("Content-Type: application/json");

$student_id = $_GET['student_id']; // Öğrenci ID'si

try {
    $sql = "SELECT a.announcement_id, a.title, a.content, a.created_at, ac.first_name, ac.last_name 
            FROM announcements a
            JOIN academics ac ON a.academic_id = ac.academic_id
            JOIN student_courses sc ON a.course_id = sc.course_id
            WHERE sc.student_id = :student_id
            ORDER BY a.created_at DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':student_id' => $student_id]);
    $announcements = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["success" => true, "announcements" => $announcements]);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>