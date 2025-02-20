import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'student_login.dart'; // Giriş sayfasına geri dönmek için

class StudentRegister extends StatefulWidget {
  @override
  _StudentRegisterState createState() => _StudentRegisterState();
}

class _StudentRegisterState extends State<StudentRegister> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final email = _emailController.text;
    final studentNumber = _studentNumberController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Şifre doğrulama kontrolü
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şifreler eşleşmiyor. Lütfen tekrar deneyin.')),
      );
      return;
    }

    final success = await ApiService().registerStudent(
      firstName,
      lastName,
      email,
      studentNumber,
      password,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başarılı. Giriş yapabilirsiniz.')),
      );
      Navigator.pop(context); // Kayıt başarılıysa giriş sayfasına dön
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başarısız. Lütfen tekrar deneyin.')),
      );
    }
  }

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
        child: SingleChildScrollView(
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
                    'Öğrenci Kayıt',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Ad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Soyad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _studentNumberController,
                    decoration: InputDecoration(
                      labelText: 'Öğrenci No',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Şifre Doğrulama',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 40),
                  _buildRegisterButton(
                    context,
                    title: 'Kayıt Ol',
                    icon: Icons.app_registration,
                    color: Colors.blueGrey.shade700,
                    onPressed: () => _register(context),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => StudentLogin()),
                      );
                    },
                    child: Text(
                      'Zaten hesabınız var mı? Giriş Yap',
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return InkWell(
      onTap: onPressed,
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