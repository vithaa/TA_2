    import 'package:flutter/material.dart';
    import 'package:firebase_auth/firebase_auth.dart';
    import 'package:cloud_firestore/cloud_firestore.dart';

    class RegisterScreen extends StatefulWidget {
      const RegisterScreen({super.key});

      @override
      State<RegisterScreen> createState() => _RegisterScreenState();
    }

    class _RegisterScreenState extends State<RegisterScreen> {
      final _formKey = GlobalKey<FormState>();
      final _emailController = TextEditingController();
      final _passwordController = TextEditingController();
      final _rewritePasswordController = TextEditingController();
      final _namaOrtuController = TextEditingController();
      final _idController = TextEditingController(); // Untuk NIK/No. KTP
      final _alamatController = TextEditingController();
      final _telponController = TextEditingController();
      bool _isLoading = false;

      @override
      void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        _rewritePasswordController.dispose();
        _namaOrtuController.dispose();
        _idController.dispose();
        _alamatController.dispose();
        _telponController.dispose();
        super.dispose();
      }

      Future<void> _handleRegister() async {
        if (!_formKey.currentState!.validate()) return;

        setState(() {
          _isLoading = true;
        });

        try {
          // 1. Buat pengguna dengan Firebase Authentication
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          // Pastikan user tidak null setelah pendaftaran
          if (userCredential.user == null) {
            throw FirebaseAuthException(
              code: 'user-not-created',
              message: 'Gagal membuat pengguna Firebase.',
            );
          }

          // 2. Simpan data orang tua ke Firestore
          // Sesuai dengan struktur database yang Anda tunjukkan di tangkapan layar:
          // users/{UID_pengguna}/data_ortu/{UID_pengguna}
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid) // Dokumen utama untuk UID pengguna
              .collection('data_ortu') // Sub-koleksi 'data_ortu'
              .doc(userCredential.user!.uid) // Dokumen dengan UID yang sama di dalam sub-koleksi
              .set({
            'namaOrtu': _namaOrtuController.text.trim(),
            'emailOrtu': _emailController.text.trim(),
            'id': _idController.text.trim(), // NIK/No. KTP
            'alamat': _alamatController.text.trim(),
            'noTelp': _telponController.text.trim(),
            'role': 'orangtua', // Penting untuk identifikasi peran
            'uid': userCredential.user!.uid, // Menyimpan UID Firebase
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pendaftaran berhasil! Silakan login.'),
                backgroundColor: Colors.green,
              ),
            );
            // Kembali ke halaman login setelah pendaftaran berhasil
            Navigator.pop(context);
          }
        } on FirebaseAuthException catch (e) {
          String errorMessage;
          switch (e.code) {
            case 'weak-password':
              errorMessage = 'Password terlalu lemah.';
              break;
            case 'email-already-in-use':
              errorMessage = 'Email sudah terdaftar. Silakan gunakan email lain atau login.';
              break;
            case 'invalid-email':
              errorMessage = 'Format email tidak valid.';
              break;
            default:
              errorMessage = 'Terjadi kesalahan autentikasi: ${e.message}';
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error during registration: $e'); // Untuk debugging
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Terjadi kesalahan tak terduga: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Daftar Akun Orang Tua'),
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email harus diisi';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password harus diisi';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _rewritePasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password harus diisi';
                      }
                      if (value != _passwordController.text) {
                        return 'Password tidak sama';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Ulangi Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_reset),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 20), // Spasi sebelum informasi pribadi
                  
                  const Text(
                    'Informasi Pribadi Orang Tua',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const Divider(height: 20, thickness: 1),
                  
                  TextFormField(
                    controller: _namaOrtuController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama orang tua harus diisi';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap Orang Tua',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _idController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ID (NIK/No. KTP) harus diisi';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'ID hanya boleh berisi angka';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'ID (NIK/No. KTP)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.credit_card),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _alamatController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat harus diisi';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Alamat Lengkap',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.home_outlined),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _telponController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'No. Telpon harus diisi';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'No. Telpon hanya boleh berisi angka';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'No. Telpon',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone_outlined),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 5, // Tambahkan sedikit bayangan
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Daftar',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke halaman login
                    },
                    child: Text(
                      'Sudah punya akun? Login di sini',
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    