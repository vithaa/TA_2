import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _namaOrtu;
  bool _isLoadingProfile = true; // Untuk melacak loading profil ortu

  @override
  void initState() {
    super.initState();
    _loadOrtuProfile(); // Memuat profil orang tua saat initState
  }

  // Fungsi helper untuk mengonversi nilai dari Firestore ke double
  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Ganti koma dengan titik untuk parsing yang benar
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  Future<void> _loadOrtuProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
      return;
    }

    try {
      // Ambil namaOrtu dari dokumen pengguna yang login
      // Sesuai dengan struktur database Anda: users/{UID_pengguna}/data_ortu/{UID_pengguna}
      final ortuDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data_ortu')
          .doc(user.uid)
          .get();

      if (ortuDoc.exists) {
        setState(() {
          _namaOrtu = ortuDoc.data()?['namaOrtu'];
        });
      } else {
        debugPrint('Profil orang tua tidak ditemukan untuk UID: ${user.uid}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data profil orang tua tidak ditemukan. Silakan lengkapi profil Anda.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error memuat profil orang tua: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat profil orang tua: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Riwayat Pemeriksaan",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.blue[800],
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text(
            'Anda harus login terlebih dahulu',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Tampilkan loading screen jika profil ortu masih dimuat
    if (_isLoadingProfile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Riwayat Pemeriksaan",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue[800],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat profil orang tua...'),
            ],
          ),
        ),
      );
    }

    // Tampilkan pesan jika namaOrtu tidak ditemukan setelah loading
    if (_namaOrtu == null || _namaOrtu!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Riwayat Pemeriksaan",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue[800],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Profil orang tua tidak lengkap.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pastikan nama orang tua terdaftar di profil Anda untuk melihat riwayat anak.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          'Riwayat Pemeriksaan',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Trigger rebuild to refresh StreamBuilder
              setState(() {
                _isLoadingProfile = true; // Set true to re-load profile and then stream
              });
              _loadOrtuProfile();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Data sedang diperbarui..."),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream untuk mendapatkan semua data balita yang namaOrtu-nya sama dengan namaOrtu user yang login
        // Ini memastikan hanya anak-anak dari orang tua yang sedang login yang ditampilkan.
        stream: _firestore
            .collection('data_balita')
            .where('namaOrtu', isEqualTo: _namaOrtu) // Filter berdasarkan namaOrtu user yang login
            .orderBy('updatedAt', descending: true) // Urutkan balita terbaru
            .snapshots(),
        builder: (context, balitaSnapshot) {
          if (balitaSnapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan: ${balitaSnapshot.error}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (balitaSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Memuat data balita...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final balitaDocs = balitaSnapshot.data?.docs ?? [];

          if (balitaDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.child_care,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data balita untuk $_namaOrtu.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Data anak Anda akan muncul di sini setelah ditambahkan oleh kader.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: balitaDocs.length,
            padding: const EdgeInsets.all(12),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final balitaDoc = balitaDocs[index];
              final balitaData = balitaDoc.data() as Map<String, dynamic>;
              final namaAnak = balitaData['namaBalita'] ?? 'Nama Anak Tidak Diketahui';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Icon(Icons.child_care, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            namaAnak,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1),
                    // StreamBuilder untuk menampilkan riwayat pengukuran dari anak ini
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('data_balita')
                          .doc(balitaDoc.id)
                          .collection('riwayat_pengukuran') // Mengubah ke 'riwayat_pengukuran'
                          .orderBy('tanggalPengukuran', descending: true) // Mengubah ke 'tanggalPengukuran'
                          .snapshots(), // Ambil semua riwayat untuk anak ini
                      builder: (context, riwayatSnapshot) {
                        if (riwayatSnapshot.hasError) {
                          return const Text('Error memuat riwayat', style: TextStyle(color: Colors.red));
                        }
                        if (riwayatSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
                        }

                        final riwayatDocs = riwayatSnapshot.data?.docs ?? [];

                        if (riwayatDocs.isEmpty) {
                          return const Text(
                            'Belum ada riwayat pemeriksaan untuk anak ini.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true, // Penting agar ListView bersarang tidak error
                          physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll pada ListView bersarang
                          itemCount: riwayatDocs.length,
                          itemBuilder: (context, riwayatIndex) {
                            final riwayatData = riwayatDocs[riwayatIndex].data() as Map<String, dynamic>;
                            final tanggalPengukuran = riwayatData['tanggalPengukuran'] as Timestamp?; // Mengubah ke 'tanggalPengukuran'
                            final beratBadan = _parseToDouble(riwayatData['beratBadan']);
                            final tinggiBadan = _parseToDouble(riwayatData['tinggiBadan']);
                            
                            // Ambil kategori Z-score individual
                            final categoryBbU = riwayatData['categoryBB_U'] ?? 'N/A';
                            final categoryTbU = riwayatData['categoryTB_U'] ?? 'N/A';
                            final categoryImtU = riwayatData['categoryIMT_U'] ?? 'N/A';

                            final zScoreBbU = _parseToDouble(riwayatData['zScoreBB_U']);
                            final zScoreTbU = _parseToDouble(riwayatData['zScoreTB_U']);
                            final zScoreImtU = _parseToDouble(riwayatData['zScoreIMT_U']);
                            final imt = _parseToDouble(riwayatData['imt']);


                            String tanggalFormatted = 'Tanggal tidak tersedia';
                            if (tanggalPengukuran != null) {
                              tanggalFormatted = DateFormat('dd MMMM yyyy – HH:mm').format(tanggalPengukuran.toDate());
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Card(
                                elevation: 1,
                                color: Colors.blue[50],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.blue[700],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            tanggalFormatted,
                                            style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.bold),
                                          ),
                                          const Spacer(),
                                          // Menampilkan status gizi BB/U
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(categoryBbU).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: _getStatusColor(categoryBbU)),
                                            ),
                                            child: Text(
                                              'BB/U: $categoryBbU',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: _getStatusColor(categoryBbU),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Berat Badan: ${beratBadan.toStringAsFixed(1)} kg',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Tinggi Badan: ${tinggiBadan.toStringAsFixed(1)} cm',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'IMT: ${imt.toStringAsFixed(1)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      // Menampilkan Z-score dan kategori lainnya
                                      Text(
                                        'Z-Score BB/U: ${zScoreBbU.toStringAsFixed(2)} ($categoryBbU)',
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                      Text(
                                        'Z-Score TB/U: ${zScoreTbU.toStringAsFixed(2)} ($categoryTbU)',
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                      Text(
                                        'Z-Score IMT/U: ${zScoreImtU.toStringAsFixed(2)} ($categoryImtU)',
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'gizi kurang':
      case 'pendek':
      case 'risiko gizi lebih': // Risiko Gizi Lebih juga bisa diberi warna oranye
        return Colors.orange;
      case 'gizi buruk':
      case 'sangat pendek':
      case 'obesitas': // Obesitas juga merah karena kondisi serius
        return Colors.red;
      case 'gizi lebih':
      case 'tinggi':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
