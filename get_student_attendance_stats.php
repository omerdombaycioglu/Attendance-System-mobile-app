<?php
header('Content-Type: application/json');
require_once 'db_connection.php';

// Loglama başlat
$logFile = 'api_log.txt';
$logMessage = "[" . date('Y-m-d H:i:s') . "] Request received: " . json_encode($_GET) . "\n";
file_put_contents($logFile, $logMessage, FILE_APPEND);

try {
    // `course_id` parametresinin olup olmadığını kontrol et
    if (!isset($_GET['course_id']) || empty($_GET['course_id'])) {
        echo json_encode([
            'success' => false,
            'error' => 'Eksik parametre: course_id'
        ]);
        exit;
    }

    $courseId = intval($_GET['course_id']); // Güvenlik için integer'a çeviriyoruz.

    // Toplam yoklama sayısını bul (ilgili ders için)
    $totalQuery = "
        SELECT COUNT(*) as total_sessions
        FROM active_attendance
        WHERE course_id = :course_id
    ";

    $totalStmt = $conn->prepare($totalQuery);
    $totalStmt->bindParam(':course_id', $courseId, PDO::PARAM_INT);
    $totalStmt->execute();
    $totalSessions = $totalStmt->fetch(PDO::FETCH_ASSOC)['total_sessions'];

    // Öğrenci listesini ve devamlılık istatistiklerini getir
    $query = "
        SELECT 
            s.student_id, 
            s.first_name, 
            s.last_name, 
            COUNT(ar.record_id) AS total_attendance,
            ROUND((COUNT(ar.record_id) / NULLIF(:total_sessions, 0)) * 100, 2) AS attendance_rate
        FROM 
            students s
        LEFT JOIN 
            attendance_records ar ON s.student_id = ar.student_id
        LEFT JOIN 
            active_attendance aa ON ar.attendance_id = aa.attendance_id AND aa.course_id = :course_id
        WHERE 
            aa.course_id = :course_id
        GROUP BY 
            s.student_id, s.first_name, s.last_name
    ";

    $stmt = $conn->prepare($query);
    $stmt->bindParam(':course_id', $courseId, PDO::PARAM_INT);
    $stmt->bindParam(':total_sessions', $totalSessions, PDO::PARAM_INT);
    $stmt->execute();

    $students = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Başarılı yanıtı logla
    $logMessage = "[" . date('Y-m-d H:i:s') . "] Response sent: " . json_encode(['success' => true, 'students' => $students]) . "\n";
    file_put_contents($logFile, $logMessage, FILE_APPEND);

    echo json_encode([
        'success' => true,
        'students' => $students,
    ]);
} catch (PDOException $e) {
    // Hata durumunu logla
    $logMessage = "[" . date('Y-m-d H:i:s') . "] Error: " . $e->getMessage() . "\n";
    file_put_contents($logFile, $logMessage, FILE_APPEND);

    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage(),
    ]);
}
?>