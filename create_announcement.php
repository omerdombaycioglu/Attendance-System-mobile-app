<?php
include 'db_connection.php';

header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["success" => false, "error" => "Geçersiz veri."]);
    exit();
}

$academicId = $data['academic_id'];
$courseId = $data['course_id'];
$title = $data['title'];
$content = $data['content'];

try {
    $sql = "INSERT INTO announcements (academic_id, course_id, title, content) VALUES (:academic_id, :course_id, :title, :content)";
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':academic_id' => $academicId,
        ':course_id' => $courseId,
        ':title' => $title,
        ':content' => $content,
    ]);

    echo json_encode(["success" => true]);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>