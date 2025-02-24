<?php
// db_connection.php

$host = "localhost"; // Veritabanı sunucusu
$dbname = "student_attendance_db"; // Veritabanı adı
$username = "root"; // Veritabanı kullanıcı adı
$password = ""; // Veritabanı şifresi

try {
    // PDO ile MySQL bağlantısı oluştur
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    
    // Hata modunu ayarla (Exception fırlatır)
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Karakter setini UTF-8 olarak ayarla
    $conn->exec("SET NAMES 'utf8'");
} catch (PDOException $e) {
    // Bağlantı hatası durumunda hata mesajını göster
    die("Bağlantı hatası: " . $e->getMessage());
}
?>