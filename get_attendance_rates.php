<?php
require_once 'db_connection.php';

header("Content-Type: application/json");

$student_id = $_GET['student_id'];

try {
    $sql_courses = "SELECT c.course_id, c.course_name 
                    FROM student_courses sc 
                    JOIN courses c ON sc.course_id = c.course_id 
                    WHERE sc.student_id = :student_id";
    $stmt_courses = $conn->prepare($sql_courses);
    $stmt_courses->bindParam(':student_id', $student_id, PDO::PARAM_INT);
    $stmt_courses->execute();
    $courses = $stmt_courses->fetchAll(PDO::FETCH_ASSOC);

    $attendance_rates = [];
    foreach ($courses as $course) {
        $course_id = $course['course_id'];

        // Toplam yoklama sayısını bul
        $sql_total_attendances = "SELECT COUNT(*) AS total 
                                  FROM active_attendance 
                                  WHERE course_id = :course_id";
        $stmt_total = $conn->prepare($sql_total_attendances);
        $stmt_total->bindParam(':course_id', $course_id, PDO::PARAM_INT);
        $stmt_total->execute();
        $total_attendances = (int) $stmt_total->fetch(PDO::FETCH_ASSOC)['total'];

        // Öğrencinin katıldığı yoklama sayısını bul
        $sql_student_attendances = "SELECT COUNT(*) AS attended 
                                    FROM attendance_records ar 
                                    JOIN active_attendance aa ON ar.attendance_id = aa.attendance_id 
                                    WHERE ar.student_id = :student_id AND aa.course_id = :course_id";
        $stmt_attended = $conn->prepare($sql_student_attendances);
        $stmt_attended->bindParam(':student_id', $student_id, PDO::PARAM_INT);
        $stmt_attended->bindParam(':course_id', $course_id, PDO::PARAM_INT);
        $stmt_attended->execute();
        $attended_attendances = (int) $stmt_attended->fetch(PDO::FETCH_ASSOC)['attended'];

        // Devamlılık oranını hesapla (double olarak)
        $attendance_rate = ($total_attendances > 0) ? (double) ($attended_attendances / $total_attendances) : 0.0;

        // Ders adı ve devamlılık oranını kaydet
        $attendance_rates[$course_id] = $attendance_rate;
    }

    // JSON olarak cevap döndür
    echo json_encode([
        'success' => true,
        'attendance_rates' => $attendance_rates,
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage(),
    ]);
}
?>