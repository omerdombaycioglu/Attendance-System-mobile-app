<?php
include 'db_connection.php';

header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["success" => false, "error" => "Geçersiz veri."]);
    exit();
}

$first_name = $data['first_name'];
$last_name = $data['last_name'];
$email = $data['email'];
$student_number = $data['student_number'];
$password = $data['password'];

try {
    $sql = "INSERT INTO students (first_name, last_name, email, student_number, password) VALUES (:first_name, :last_name, :email, :student_number, :password)";
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':first_name' => $first_name,
        ':last_name' => $last_name,
        ':email' => $email,
        ':student_number' => $student_number,
        ':password' => $password,
    ]);

    echo json_encode(["success" => true]);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>