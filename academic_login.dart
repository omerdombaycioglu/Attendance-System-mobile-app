import 'package:flutter/material.dart';
import 'academic_home.dart';
import '../api/api_service.dart';

class AcademicLogin extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // API'ye gönderilen veriyi kontrol et
    print("Gönderilen Veri: ");
    print({
      'email': email,
      'password': password,
      'type': 'academic', // Akademisyen girişi olduğunu belirt
    });

    final response = await ApiService().academicLogin(email, password);

    // API'den gelen yanıtı kontrol et
    print("API Yanıtı: $response");

    if (response != null && response['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AcademicHome(academic: response['data']), // academic nesnesini aktar
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?['error'] ?? 'Giriş başarısız. Lütfen tekrar deneyin.')),
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
                    Icons.person, // Akademisyen için daha uygun bir ikon
                    size: 100,
                    color: Colors.teal.shade700,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Akademisyen Girişi',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 40),
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
                  SizedBox(height: 40),
                  _buildLoginButton(
                    context,
                    title: 'Giriş Yap',
                    icon: Icons.login,
                    color: Colors.teal.shade700,
                    onPressed: () => _login(context),
                  ),
                ],
              ),
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