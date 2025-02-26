import 'package:flutter/material.dart';
import 'package:kostify/service/apiService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String profileImage = "assets/img/dummy_profile.jpg";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ambil data dari SharedPreferences
    String? savedProfileImage = prefs.getString('foto');
    String? savedName = prefs.getString('name');
    String? savedPhone = prefs.getString('no_wa');

    print("Data dari SharedPreferences:");
    print("Foto: $savedProfileImage");
    print("Nama: $savedName");
    print("No WA: $savedPhone");

    setState(() {
      profileImage = savedProfileImage ?? profileImage;
      _nameController.text = savedName ?? "";
      _phoneController.text = savedPhone ?? "";
    });
  }

  Future<void> _updateProfile() async {
    ApiService apiService = ApiService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 0;

    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User tidak ditemukan")),
      );
      return;
    }

    // Data sebelum update
    String oldName = prefs.getString('name') ?? "";
    String oldNoWa = prefs.getString('no_wa') ?? "";

    // Data baru
    String newName = _nameController.text;
    String newNoWa = _phoneController.text;

    // Cek perubahan data
    bool isNameChanged = newName != oldName;
    bool isNoWaChanged = newNoWa != oldNoWa;

    List<String> successMessages = [];
    List<String> errorMessages = [];

    if (isNameChanged) {
      var response = await apiService.updateName(userId, newName);
      if (response['success']) {
        await prefs.setString('name', newName);
        successMessages.add("Nama berhasil diperbarui");
        _updateName();
      } else {
        errorMessages.add(response['message']);
      }
    }

    if (isNoWaChanged) {
      var response = await apiService.updateNoWa(userId, newNoWa);
      if (response['success']) {
        await prefs.setString('no_wa', newNoWa);
        successMessages.add("Nomor WhatsApp berhasil diperbarui");
        _updateNoWa();
      } else {
        errorMessages.add(response['message']);
      }
    }

    // Tampilkan notifikasi hasil update
    if (successMessages.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessages.join(" & "))),
      );
    } else if (errorMessages.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessages.join(" & "))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tidak ada perubahan yang dilakukan")),
      );
    }
  }

  Future<void> _updateName() async {
    ApiService apiService = ApiService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId =
        prefs.getInt('id') ?? 0; // Sesuaikan dengan ID user yang tersimpan

    if (userId == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("User tidak ditemukan")));
      return;
    }

    var response = await apiService.updateName(userId, _nameController.text);

    if (response['success']) {
      await prefs.setString('name', _nameController.text);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Nama berhasil diperbarui")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response['message'])));
    }
  }

  Future<void> _updateNoWa() async {
    ApiService apiService = ApiService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 0;

    if (userId == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("User tidak ditemukan")));
      return;
    }

    var response = await apiService.updateNoWa(userId, _phoneController.text);

    if (response['success']) {
      await prefs.setString('no_wa', _phoneController.text);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nomor WhatsApp berhasil diperbarui")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response['message'])));
    }
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Konfirmasi password tidak cocok")),
      );
      return;
    }

    ApiService apiService = ApiService();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Pastikan user_id yang disimpan dalam SharedPreferences adalah int
    int userId = prefs.getInt('id') ?? 0;

    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User tidak ditemukan")),
      );
      return;
    }

    var response = await apiService.updatePassword(
      userId,
      _oldPasswordController.text,
      _newPasswordController.text,
    );

    print("Update Password Response: $response"); // Debugging

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(response['message'].toString())), // Pastikan toString()
    );

    if (response['success']) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      ApiService apiService = ApiService();
      String? imageUrl = await apiService.uploadProfilePicture(imageFile);

      if (imageUrl != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_url', imageUrl);

        setState(() {
          profileImage = imageUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profil"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nama",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Nomor HP",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showChangePasswordDialog(context),
              child: Text("Ganti Password"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ganti Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPasswordController, // Tambahkan controller
              obscureText: true,
              decoration: InputDecoration(labelText: "Password Lama"),
            ),
            TextField(
              controller: _newPasswordController, // Tambahkan controller
              obscureText: true,
              decoration: InputDecoration(labelText: "Password Baru"),
            ),
            TextField(
              controller: _confirmPasswordController, // Tambahkan controller
              obscureText: true,
              decoration: InputDecoration(labelText: "Konfirmasi Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog dulu
              _updatePassword();
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
