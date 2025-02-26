import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kostify/pages/loginPage.dart';
import 'package:kostify/service/apiService.dart';

class RegisterCard extends StatefulWidget {
  const RegisterCard({super.key});

  @override
  _RegisterCardState createState() => _RegisterCardState();
}

class _RegisterCardState extends State<RegisterCard> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String selectedRole = 'Pencari'; // Default role langsung "Pencari"
  bool isLoading = false; // Untuk indikator loading

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void registerUser() async {
    if (passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password harus memiliki minimal 8 karakter!')),
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Password dan konfirmasi password tidak cocok!')),
      );
      return;
    }

    setState(() => isLoading = true); // Aktifkan loading

    final apiService = ApiService();
    final response = await apiService.registerUser(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      role: selectedRole, // Tetap kirim role sebagai "Pencari"
      phone: phoneController.text,
    );

    setState(() => isLoading = false); // Matikan loading

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'])),
    );

    if (response['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/bgRegister.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.lightBlueAccent.withOpacity(0.2),
            ),
          ),
          Center(
            child: Card(
              margin: EdgeInsets.all(20.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 30),
                      Image.asset(
                        "assets/img/logobgkostify.png",
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 50),

                      // Input Nama
                      TextField(
                        controller: nameController,
                        decoration: inputDecoration('Nama'),
                      ),
                      SizedBox(height: 10),

                      // Input Email
                      TextField(
                        controller: emailController,
                        decoration: inputDecoration('Email'),
                      ),
                      SizedBox(height: 10),

                      // Input Password
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: inputDecoration('Password'),
                      ),
                      SizedBox(height: 10),

                      // Input Konfirmasi Password
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: inputDecoration('Konfirmasi Password'),
                      ),
                      SizedBox(height: 10),

                      // Input No WA
                      TextField(
                        controller: phoneController,
                        decoration: inputDecoration('No Wa'),
                      ),
                      SizedBox(height: 10),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Sudah punya akun?",
                            style: TextStyle(fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: Text(
                              "Masuk",
                              style: TextStyle(
                                color: Colors.lightBlue,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Tombol Register
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : registerUser,
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Register',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi dekorasi input
  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    );
  }
}
