import 'package:flutter/material.dart';
import '../api/api_service.dart';

class StudentHome extends StatefulWidget {
  final Map<String, dynamic> student;

  StudentHome({required this.student});

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> with SingleTickerProviderStateMixin {
  List<dynamic> _courses = [];
  List<dynamic> _announcements = [];
  List<dynamic> _activeAttendances = [];
  bool _isLoading = true;
  late TabController _tabController;
  Map<int, bool> _attendedStatus = {}; // Her yoklama için katılım durumu
  Map<String, double> _attendanceRates = {}; // Her ders için devamlılık oranı

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 sekme
    _fetchStudentCourses();
    _fetchAnnouncements();
    _fetchActiveAttendances();
    _fetchAttendanceRates(); // Devamlılık oranlarını yükle
  }

  Future<void> _fetchStudentCourses() async {
    try {
      final courses = await ApiService().getStudentCourses(widget.student['student_id']);
      setState(() {
        _courses = courses;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dersler yüklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final announcements = await ApiService().getAnnouncementsForStudent(widget.student['student_id']);
      setState(() {
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Duyurular yüklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _fetchActiveAttendances() async {
    try {
      final attendances = await ApiService().getActiveAttendances(widget.student['student_id']);
      setState(() {
        _activeAttendances = attendances;
        // Her yoklama için katılım durumunu başlangıçta false olarak ayarla
        _attendedStatus = {for (var attendance in attendances) attendance['attendance_id']: false};
      });
      // Her yoklama için katılım durumunu kontrol et
      for (var attendance in attendances) {
        _checkAttendanceStatus(attendance['attendance_id']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aktif yoklamalar yüklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _fetchAttendanceRates() async {
    try {
      final rates = await ApiService().getAttendanceRates(widget.student['student_id']);
      print("Devamlılık Oranları: $rates"); // Devamlılık oranlarını konsola yazdır
      setState(() {
        _attendanceRates = rates;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Devamlılık oranları yüklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _checkAttendanceStatus(int attendanceId) async {
    try {
      final response = await ApiService().checkAttendanceStatus(
        attendanceId,
        widget.student['student_id'],
      );
      setState(() {
        _attendedStatus[attendanceId] = response['attended'];
      });
    } catch (e) {
      // Hata durumunda katılım durumunu false olarak ayarla
      setState(() {
        _attendedStatus[attendanceId] = false;
      });
    }
  }

  Future<void> _joinAttendance(int attendanceId) async {
    final attendanceCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Yoklamaya Katıl'),
          content: TextField(
            controller: attendanceCodeController,
            decoration: InputDecoration(labelText: 'Yoklama Kodu'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog'u kapat
              },
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final attendanceCode = attendanceCodeController.text;

                if (attendanceCode.isNotEmpty) {
                  final success = await ApiService().joinAttendance(
                    attendanceId,
                    widget.student['student_id'],
                    attendanceCode,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Yoklamaya başarıyla katıldınız.')),
                    );
                    Navigator.pop(context); // Dialog'u kapat
                    setState(() {
                      _attendedStatus[attendanceId] = true; // Katılım durumunu güncelle
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Geçersiz yoklama kodu.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lütfen yoklama kodunu girin.')),
                  );
                }
              },
              child: Text('Katıl'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade300, //Colors.transparent
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          'Öğrenci Sayfası',
          style: TextStyle(color: Colors.black87),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Drawer'ı aç
            },
          ),
        ),
        actions: [
          // Sağ üst köşeye öğrenci profil paneli ekle
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.3,
                    maxChildSize: 0.6,
                    minChildSize: 0.2,
                    builder: (context, scrollController) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(widget.student['profile_image_url'] ?? 'https://via.placeholder.com/150'),
                                ),
                              ),
                              SizedBox(height: 16),
                              Center(
                                child: Text(
                                  '${widget.student['first_name']} ${widget.student['last_name']}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Öğrenci No: ${widget.student['student_number']}',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ),
                              SizedBox(height: 16),
                              Divider(),
                              ListTile(
                                leading: Icon(Icons.email),
                                title: Text('Email'),
                                subtitle: Text(widget.student['email']),
                              ),
                              ListTile(
                                leading: Icon(Icons.calendar_today),
                                title: Text('Kayıt Tarihi'),
                                subtitle: Text(widget.student['created_at']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(fontSize: 13), // Seçili sekmenin yazı boyutu
          unselectedLabelStyle: TextStyle(fontSize: 12), // Seçili olmayan sekmenin yazı boyutu
          labelColor: Colors.black, // Seçili sekmenin yazı rengi
          unselectedLabelColor: Colors.black, // Seçili olmayan sekmenin yazı rengi
          indicatorColor: Colors.black, // Seçili sekmenin alt çizgi rengi
          tabs: [
            Tab(
              icon: Icon(Icons.assignment_turned_in), // Aktif Yoklamalar için ikon
              text: 'Aktif Yoklamalar',
            ),
            Tab(
              icon: Icon(Icons.announcement), // Duyurular için ikon
              text: 'Duyurular',
            ),
            Tab(
              icon: Icon(Icons.timeline), // Devamlılık Durumu için ikon
              text: 'Devam Durumu',
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade500],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school, // Okul ikonu ekledik
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8), // İkon ile metin arasına boşluk ekledik
                    Text(
                      'Derslerim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto', // Daha modern bir font
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return InkWell(
                    onTap: () {
                      // Burada herhangi bir işlem yapmıyoruz, sadece tıklanabilir hale getiriyoruz.
                    },
                    splashColor: Colors.blueGrey.shade200, // Tıklama efekti rengi
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          course['course_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                        subtitle: Text(
                          course['course_code'],
                          style: TextStyle(
                            color: Colors.blueGrey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

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
            // Aktif Yoklamalar Bölümü
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _activeAttendances.isEmpty
                ? Center(
              child: Text(
                'Aktif yoklama bulunamadı.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _activeAttendances.length,
              itemBuilder: (context, index) {
                final attendance = _activeAttendances[index];
                final attended = _attendedStatus[attendance['attendance_id']] ?? false;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(attendance['course_name']),
                    subtitle: Text('Yoklama Kodu: ${attendance['attendance_code']}'),
                    trailing: attended
                        ? Text(
                      'Katıldınız',
                      style: TextStyle(color: Colors.green),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        _joinAttendance(attendance['attendance_id']);
                      },
                      child: Text('Yoklamaya Katıl'),
                    ),
                  ),
                );
              },
            ),
            // Duyurular Bölümü
            _buildAnnouncements(),
            // Devamlılık Durumum Bölümü
            _buildAttendanceRates(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncements() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: _announcements.length,
      itemBuilder: (context, index) {
        final announcement = _announcements[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(announcement['title']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(announcement['content']),
                SizedBox(height: 10),
                Text(
                  '${announcement['first_name']} ${announcement['last_name']} - ${announcement['created_at']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceRates() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _attendanceRates.isEmpty
        ? Center(
      child: Text(
        'Devamlılık bilgisi bulunamadı.',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    )
        : ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        final attendanceRate = _attendanceRates[course['course_id'].toString()] ?? 0.0;

        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(course['course_name']),
            subtitle: Text('Devamlılık Oranı: ${(attendanceRate * 100).toStringAsFixed(2)}%'),
            trailing: CircularProgressIndicator(
              value: attendanceRate,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey.shade700),
            ),
          ),
        );
      },
    );
  }
}