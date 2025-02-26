import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kostify/utility/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: mainUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  // Register User
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    try {
      Response response = await _dio.post(
        'register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'no_wa': phone,
        },
      );

      return {
        'success': true,
        'message': response.data['message'],
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Registrasi gagal',
      };
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      Response response = await _dio.post(
        'login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data == null || response.data['user'] == null) {
        return {
          'success': false,
          'message': 'Data user tidak ditemukan',
        };
      }

      final userData = response.data['user'];
      print("User Data: $userData");

      // Simpan data user ke SharedPreferences secara otomatis (tanpa rememberMe)
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setInt('id', userData['id'] ?? 0);
        await prefs.setString('name', userData['name'] ?? '');
        await prefs.setString('email', userData['email'] ?? '');
        await prefs.setString('no_wa', userData['no_wa'] ?? '');
        await prefs.setString('foto', userData['foto'] ?? 'none');
        await prefs.setString('role', userData['role'] ?? '');
        await prefs.setString('credit', userData['credit'].toString());

        print("Data berhasil disimpan!");
      } catch (e) {
        print("Error SharedPreferences: $e");
        return {
          'success': false,
          'message': 'Gagal menyimpan data ke SharedPreferences',
        };
      }

      return {
        'success': true,
        'message': response.data['message'] ?? 'Login berhasil',
        'user': userData,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Login gagal',
      };
    }
  }

  // Mengecek apakah user sudah login
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('id'); // Cek apakah ada ID user yang tersimpan
  }

  // Logout User
  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data user dari SharedPreferences
  }

  // Get Gird View Home
  Future<List<dynamic>> fetchKamars() async {
    try {
      Response response =
          await _dio.get('kamars'); // Tidak perlu menulis full URL

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data']; // Mengembalikan daftar kamar
      } else {
        throw Exception("Gagal memuat data kamar");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Terjadi kesalahan");
    }
  }

  // Search Kost
  Future<List<dynamic>> searchKost(String nama) async {
    try {
      Response response = await _dio.get(
        'search-kamars',
        queryParameters: {'nama': nama},
      );

      if (response.data != null && response.data['success'] == true) {
        return List<dynamic>.from(
            response.data['data']); // Pastikan hasilnya berupa List
      } else {
        return []; // Kembalikan list kosong jika tidak ada data atau gagal
      }
    } catch (e) {
      print("Error searching kost: $e");
      return []; // Tangani error dengan mengembalikan list kosong
    }
  }

  // Fetch favorit berdasarkan ID dari SharedPreferences
  Future<List<dynamic>> fetchFavorit() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id'); // Ambil ID pengguna

      if (userId == null) {
        return []; // Jika tidak ada user_id, kembalikan list kosong
      }

      Response response = await _dio.get('favorit/$userId');

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data']; // Return data favorit
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching favorit: $e");
      return [];
    }
  }

  // Upload profile picture
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');

      if (userId == null) {
        print("User ID tidak ditemukan di SharedPreferences");
        return null;
      }

      String baseUrl = "https://kostify.nosveratu.com/";
      String uploadUrl = "${baseUrl}api/user/$userId/update-foto";

      FormData formData = FormData.fromMap({
        "foto": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      Response response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "multipart/form-data",
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        String filename = response.data['data']['foto']; // Nama file dari API
        String fullImageUrl = "${baseUrl}storage/images/foto_profile/$filename";

        // Simpan di SharedPreferences
        await prefs.setString('profile_image_name', filename);
        await prefs.setString('profile_image_url', fullImageUrl);

        print("Foto profil berhasil diperbarui: $fullImageUrl");

        return fullImageUrl;
      } else {
        print("Gagal mengunggah foto: ${response.data['message']}");
      }
    } catch (e) {
      print("Error uploading profile picture: $e");
    }
    return null;
  }

  // Update nama
  Future<Map<String, dynamic>> updateName(int userId, String newName) async {
    try {
      Response response = await _dio.post(
        'user/$userId/update-name',
        data: {'name': newName},
      );

      return {
        'success': true,
        'message': response.data['message'],
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal mengupdate nama',
      };
    }
  }

  // Update Nomor WA
  Future<Map<String, dynamic>> updateNoWa(int userId, String newNoWa) async {
    try {
      Response response = await _dio.post(
        'user/$userId/update-no-wa',
        data: {'no_wa': newNoWa},
      );

      return {
        'success': true,
        'message': response.data['message'],
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal mengupdate nomor WA',
      };
    }
  }

  // Update password
  Future<Map<String, dynamic>> updatePassword(
      int userId, String oldPassword, String newPassword) async {
    try {
      Response response = await _dio.post(
        'user/$userId/update-password',
        data: {
          'password_lama': oldPassword,
          'password_baru': newPassword,
        },
      );

      return {
        'success': true,
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      print("Error Response: ${e.response?.data}"); // Debugging

      return {
        'success': false,
        'message': e.response?.data is Map<String, dynamic>
            ? e.response?.data['message'] ?? 'Gagal mengupdate password'
            : 'Terjadi kesalahan pada server',
      };
    }
  }

  // Pemanggilan detail kost
  Future<Map<String, dynamic>> getDetailKost(int id) async {
    try {
      // Ambil user_id dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');

      if (userId == null) {
        return {'success': false, 'message': 'User ID tidak ditemukan'};
      }

      Response response = await _dio.get('kamars/$id', queryParameters: {
        'user_id': userId,
      });

      return {
        'success': true,
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal mendapatkan data',
      };
    }
  }

  Future<Map<String, dynamic>> toggleFavorite(int kamarId) async {
    try {
      // Ambil user_id dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');

      if (userId == null) {
        return {'success': false, 'message': 'User ID tidak ditemukan'};
      }

      // Kirim request ke API untuk toggle favorit
      Response response = await _dio.post('favorit/toggle', data: {
        'user_id': userId,
        'kamar_id': kamarId,
      });

      return {
        'success': true,
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Gagal mengubah status favorit',
      };
    }
  }

  Future<Map<String, dynamic>> fetchHistory() async {
    try {
      // Ambil user_id dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');

      if (userId == null) {
        return {
          'success': false,
          'message': 'User ID tidak ditemukan',
          'data': []
        };
      }

      // Kirim request ke API
      Response response = await _dio.get('/history/$userId');

      return {
        'success': response.data['success'],
        'message': response.data['message'],
        'data': response.data['data'] ?? [],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Gagal mengambil data history',
        'data': [],
      };
    }
  }

  Future<Map<String, dynamic>> submitReview({
    required int transaksiId,
    required int rating,
    required String ulasan,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');

      if (userId == null) {
        return {'success': false, 'message': 'User ID tidak ditemukan'};
      }

      Response response = await _dio.post(
        'history/review',
        data: {
          'user_id': userId,
          'transaksi_id': transaksiId,
          'rating': rating, // Pastikan rating dikirim sebagai integer
          'ulasan': ulasan,
        },
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Ulasan berhasil ditambahkan',
      };
    } on DioException catch (e) {
      String errorMessage = 'Gagal menambahkan ulasan';
      print("Errornya $e");
      return {'success': false, 'message': errorMessage};
    }
  }

  // Cek kode promo
  Future<Map<String, dynamic>> checkPromo(String kodePromo, int kamarId) async {
    try {
      Response response = await _dio.post(
        'check-promo',
        data: {
          'kode_promo': kodePromo,
          'kamar_id': kamarId, // Menambahkan kamar_id dalam request
        },
      );

      return {
        'success': response.data['success'],
        'message': response.data['message'],
        'harga_promo': response.data['harga_promo'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Gagal memverifikasi kode promo',
        'harga_promo': null,
      };
    }
  }

  // Refresh shared preferences user
  Future<Map<String, dynamic>> getUserById() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');

      if (userId == null) {
        return {
          'success': false,
          'message': 'ID user tidak ditemukan di SharedPreferences',
        };
      }

      Response response = await _dio.get('user/$userId');

      if (response.data == null || response.data['user'] == null) {
        return {
          'success': false,
          'message': 'Data user tidak ditemukan',
        };
      }

      final userData = response.data['user'];
      print("User Data (Updated): $userData");

      // Perbarui SharedPreferences dengan data terbaru dari server
      await prefs.setInt('id', userData['id'] ?? 0);
      await prefs.setString('name', userData['name'] ?? '');
      await prefs.setString('email', userData['email'] ?? '');
      await prefs.setString('no_wa', userData['no_wa'] ?? '');
      await prefs.setString('foto', userData['foto'] ?? 'none');
      await prefs.setString('role', userData['role'] ?? '');
      await prefs.setString('credit', userData['credit'].toString());

      print("Data berhasil diperbarui!");

      return {
        'success': true,
        'message': 'Data user berhasil diperbarui',
        'user': userData,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal memperbarui data user',
      };
    }
  }

  // buat transaksi
  Future<Map<String, dynamic>> createTransaction({
    required int kamarId,
    required int lamaSewa,
    required String tanggalSewa,
    String kodePromo = "",
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt("id");
      String? credit = prefs.getString("credit");

      if (userId == null) {
        return {
          'success': false,
          'message': 'User tidak ditemukan',
        };
      }

      Response response = await _dio.post(
        'transaksi',
        data: {
          'user_id': userId,
          'kamar_id': kamarId,
          'lama_sewa': lamaSewa,
          'tanggal_sewa': tanggalSewa,
          'kode_promo': kodePromo,
          'poin': (credit != null && credit.isNotEmpty)
              ? int.tryParse(credit) ?? 0
              : 0,
        },
      );

      return {
        'success': true,
        'message': response.data['message'],
        'snap_token': response.data['snap_token'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal membuat transaksi',
      };
    }
  }

  // Hapus transaksi
  Future<Map<String, dynamic>> deleteTransaction(int transactionId) async {
    try {
      Response response = await _dio.delete(
        'transaksi/delete/$transactionId',
      );

      return {
        'success': response.data['success'],
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal menghapus transaksi',
      };
    }
  }
}
