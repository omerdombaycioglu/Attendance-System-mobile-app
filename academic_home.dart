import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // json kütüphanesi

class AcademicHome extends StatefulWidget {
  final Map<String, dynamic> academic;

  AcademicHome({required this.academic});

  @override
  _AcademicHomeState createState() => _AcademicHomeState();
}

class _AcademicHomeState extends State<AcademicHome> with SingleTickerProviderStateMixin {
  List<dynamic> _courses = [];
  bool _isLoading = true;
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<int, bool> _attendanceStarted = {}; // Yoklamanın başlatılıp başlatılmadığını saklar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tab
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final courses = await ApiService().getCoursesForAcademic(widget.academic['academic_id']);
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dersler yüklenirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: Text('Akademisyen Sayfası', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white, // Seçili sekme yazı rengi beyaz olacak
          unselectedLabelColor: Colors.grey.shade300, // Seçilmemiş sekmelerin rengi
          tabs: [
            Tab(text: 'Yoklamalar', icon: Icon(Icons.list, color: Colors.white)),
            Tab(text: 'Duyurular', icon: Icon(Icons.announcement, color: Colors.white)),
            Tab(text: 'Ders Bilgi', icon: Icon(Icons.info, color: Colors.white)),
          ],
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: _buildProfileDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade100],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAttendances(),
            _buildAnnouncements(),
            _buildCourseInfo(), // Yeni tab içeriği
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal.shade700,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${widget.academic['first_name']} ${widget.academic['last_name']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.teal.shade700),
            title: Text('Ayarlar', style: TextStyle(color: Colors.black87)),
            onTap: () {
              // Ayarlar sayfasına yönlendir
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.teal.shade700),
            title: Text('Çıkış Yap', style: TextStyle(color: Colors.black87)),
            onTap: () {
              // Çıkış yapma işlemi
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendances() {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.teal.shade700))
        : ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        final isAttendanceStarted = _attendanceStarted[course['course_id']] ?? false;

        return Card(
          margin: EdgeInsets.all(8.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(course['course_name'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(course['course_code']),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAttendanceStarted ? Colors.grey : Colors.teal.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isAttendanceStarted
                  ? null // Butonu devre dışı bırak
                  : () {
                _startAttendance(course['course_id']);
              },
              child: Text(
                isAttendanceStarted ? 'Yoklama Devam Ediyor...' : 'Yoklama Başlat',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnnouncements() {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.teal.shade700))
        : ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(course['course_name'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(course['course_code']),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _showAnnouncementDialog(course['course_id']);
              },
              child: Text('Duyuru Yap', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseInfo() {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.teal.shade700))
        : ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(course['course_name'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(course['course_code']),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _showStudentAttendanceStats(course['course_id']);
              },
              child: Text('Öğrenci Listesini Gör', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  void _showStudentAttendanceStats(int courseId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Öğrenci Devamlılık İstatistikleri', style: TextStyle(color: Colors.teal.shade700)),
          content: FutureBuilder<List<dynamic>>(
            future: _fetchStudentAttendanceStats(courseId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Colors.teal.shade700));
              } else if (snapshot.hasError) {
                return Text('Hata: ${snapshot.error}', style: TextStyle(color: Colors.red));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('Öğrenci bulunamadı.', style: TextStyle(color: Colors.black87));
              } else {
                final students = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    children: students.map((student) {
                      return ListTile(
                        title: Text('${student['first_name']} ${student['last_name']}', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Devamlılık: ${student['attendance_rate']}%', style: TextStyle(color: Colors.black87)),
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Kapat', style: TextStyle(color: Colors.teal.shade700)),
            ),
          ],
        );
      },
    );
  }

  Future<List<dynamic>> _fetchStudentAttendanceStats(int courseId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.40/get_student_attendance_stats.php?course_id=$courseId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['students'];
      } else {
        throw Exception(data['error']);
      }
    } else {
      throw Exception('Veri yüklenemedi');
    }
  }

  void _startAttendance(int courseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Yoklama Başlat', style: TextStyle(color: Colors.teal.shade700)),
          content: Text('Bu ders için yoklama başlatmak istediğinizden emin misiniz?', style: TextStyle(color: Colors.black87)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Hayır
              },
              child: Text('Hayır', style: TextStyle(color: Colors.teal.shade700)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
              ),
              onPressed: () {
                Navigator.pop(context, true); // Evet
              },
              child: Text('Evet', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final now = DateTime.now();
      final attendanceDate = "${now.year}-${now.month}-${now.day}";
      final startTime = "${now.hour}:${now.minute}:${now.second}";
      final endTime = "${now.hour}:${now.minute + 1}:${now.second}"; // 1 dakika sonra bitiyor

      try {
        final response = await ApiService().startAttendance(
          courseId,
          widget.academic['academic_id'],
          attendanceDate,
          startTime,
          endTime,
        );

        if (response['success']) {
          final attendanceCode = response['attendance_code'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Yoklama başlatıldı. Kod: $attendanceCode')),
          );

          // Yoklamanın başlatıldığını state'e kaydet
          setState(() {
            _attendanceStarted[courseId] = true;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yoklama başlatılırken hata oluştu: $e')),
        );
      }
    }
  }

  void _showAnnouncementDialog(int courseId) {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Duyuru Oluştur', style: TextStyle(color: Colors.teal.shade700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Başlık', labelStyle: TextStyle(color: Colors.teal.shade700)),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'İçerik', labelStyle: TextStyle(color: Colors.teal.shade700)),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog'u kapat
              },
              child: Text('İptal', style: TextStyle(color: Colors.teal.shade700)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
              ),
              onPressed: () async {
                final title = _titleController.text;
                final content = _contentController.text;

                if (title.isNotEmpty && content.isNotEmpty) {
                  final success = await ApiService().createAnnouncement(
                    widget.academic['academic_id'],
                    courseId,
                    title,
                    content,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Duyuru başarıyla oluşturuldu.')),
                    );
                    Navigator.pop(context); // Dialog'u kapat
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Duyuru oluşturulurken hata oluştu.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lütfen başlık ve içerik girin.')),
                  );
                }
              },
              child: Text('Gönder', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}