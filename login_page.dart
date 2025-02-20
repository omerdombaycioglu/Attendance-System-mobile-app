import 'package:flutter/material.dart';
import 'student_login.dart';
import 'academic_login.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade100],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school,
                  size: 100,
                  color: Colors.blueGrey.shade700,
                ),
                SizedBox(height: 20),
                Text(
                  'ZBEÜ Yoklama Sistemi',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 40),
                _buildLoginButton(
                  context,
                  title: 'Öğrenci Girişi',
                  icon: Icons.school,
                  color: Colors.blueGrey.shade700,
                  route: StudentLogin(),
                ),
                SizedBox(height: 20),
                _buildLoginButton(
                  context,
                  title: 'Akademisyen Girişi',
                  icon: Icons.person,
                  color: Colors.teal.shade700,
                  route: AcademicLogin(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required Widget route,
      }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => route),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}