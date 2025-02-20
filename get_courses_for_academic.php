<?php
include 'db_connection.php';

header("Content-Type: application/json");

$academic_id = $_GET['academic_id']; // Akademisyen ID'si

try {
    $sql = "SELECT c.course_id, c.course_name, c.course_code 
            FROM courses c
            JOIN academic_courses ac ON c.course_id = ac.course_id
            WHERE ac.academic_id = :academic_id";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':academic_id' => $academic_id]);
    $courses = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["success" => true, "courses" => $courses]);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>