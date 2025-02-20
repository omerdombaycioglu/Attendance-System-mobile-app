<?php
include 'db_connection.php';

header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["success" => false, "error" => "Geçersiz veri."]);
    exit();
}

$email = $data['email'];
$password = $data['password'];
$type = $data['type']; // Öğrenci veya akademisyen girişi için

try {
    if ($type === 'student') {
        // Öğrenci girişi kontrolü
        $sql = "SELECT * FROM students WHERE email = :email AND password = :password";
    } else if ($type === 'academic') {
        // Akademisyen girişi kontrolü
        $sql = "SELECT * FROM academics WHERE email = :email AND password = :password";
    } else {
        echo json_encode(["success" => false, "error" => "Geçersiz kullanıcı türü."]);
        exit();
    }

    $stmt = $conn->prepare($sql);
    $stmt->execute([':email' => $email, ':password' => $password]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        echo json_encode(["success" => true, "type" => $type, "data" => $user]);
    } else {
        echo json_encode(["success" => false, "error" => "Geçersiz email veya şifre."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>