import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'http://192.168.1.40';

  Future<Map<String, dynamic>?> studentLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'type': 'student', // Öğrenci girişi olduğunu belirt
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Giriş başarısız.');
    }
  }

  Future<Map<String, dynamic>?> academicLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'type': 'academic', // Akademisyen girişi olduğunu belirt
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Giriş başarısız.');
    }
  }

  Future<bool> registerStudent(
      String firstName,
      String lastName,
      String email,
      String studentNumber,
      String password,
      ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register_student.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'student_number': studentNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'];
    } else {
      throw Exception('Kayıt başarısız.');
    }
  }

  Future<List<dynamic>> getStudentCourses(int studentId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/get_student_courses.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'student_id': studentId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['courses'];
      } else {
        throw Exception(data['error']);
      }
    } else {
      throw Exception('Veri yüklenemedi');
    }
  }
  Future<List<dynamic>> getAnnouncementsForStudent(int studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/get_announcements_for_student.php?student_id=$studentId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['announcements'];
      } else {
        throw Exception(data['error']);
      }
    } else {
      throw Exception('Veri yüklenemedi');
    }
  }
  Future<List<dynamic>> getCoursesForAcademic(int academicId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/get_courses_for_academic.php?academic_id=$academicId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['courses'];
      } else {
        throw Exception(data['error']);
      }
    } else {
      throw Exception('Veri yüklenemedi');
    }
  }
  Future<bool> createAnnouncement(int academicId, int courseId, String title, String content) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/create_announcement.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'academic_id': academicId,
        'course_id': courseId,
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'];
    } else {
      throw Exception('Duyuru oluşturulamadı');
    }
  }
  Future<Map<String, dynamic>> startAttendance(int courseId, int academicId, String attendanceDate, String startTime, String endTime) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/start_attendance.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'course_id': courseId,
        'academic_id': academicId,
        'attendance_date': attendanceDate,
        'start_time': startTime,
        'end_time': endTime,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data;
      } else {
        throw Exception(data['error']);
      }
    } else {
      throw Exception('Yoklama başlatılamadı.');
    }
  }
  Future<List<dynamic>> getActiveAttendances(int studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/get_active_attendances.php?student_id=$studentId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['attendances'];
      } else {
        throw Exception(data['error']);
      }
    } else {
      throw Exception('Veri yüklenemedi');
    }
  }

  Future<bool> joinAttendance(int attendanceId, int studentId, String attendanceCode) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/join_attendance.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'attendance_id': attendanceId,
        'student_id': studentId,
        'attendance_code': attendanceCode,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'];
    } else {
      throw Exception('Yoklamaya katılınamadı.');
    }
  }
  Future<Map<String, dynamic>> checkAttendanceStatus(int attendanceId, int studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/check_attendance_status.php?attendance_id=$attendanceId&student_id=$studentId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Yoklama durumu kontrol edilemedi.');
    }
  }
  Future<Map<String, double>> getAttendanceRates(int studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/get_attendance_rates.php?student_id=$studentId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("API Yanıtı: $data"); // API yanıtını konsola yazdır
      if (data['success']) {
        // int değerleri double'a dönüştür
        final Map<String, dynamic> rates = data['attendance_rates'];
        return rates.map((key, value) => MapEntry(key, value.toDouble()));
      } else {
        throw Exception(data['error']);
      }
    } else {
      throw Exception('Devamlılık oranları yüklenemedi.');
    }
  }
}