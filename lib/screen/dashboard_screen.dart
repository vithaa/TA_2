import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<BarChartGroupData> _barGroups = [];
  bool _isLoading = true;
  String? _namaOrtu;
  List<Map<String, dynamic>> _dataBalita = []; // List to store balita data for display
  List<String> _chartLabels = []; // List to store labels for the chart's x-axis

  @override
  void initState() {
    super.initState();
    _loadData();
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

  // Fungsi untuk menghitung umur balita dalam bulan (bulan penuh yang sudah dilalui)
  int _calculateAgeInMonths(Timestamp tanggalLahirTimestamp) {
    final birthDate = tanggalLahirTimestamp.toDate();
    final today = DateTime.now();

    int months = (today.year - birthDate.year) * 12 + (today.month - birthDate.month);

    // Jika hari ini lebih awal dari tanggal lahir di bulan ini, maka bulan tersebut belum genap
    if (today.day < birthDate.day) {
      months--;
    }
    return months < 0 ? 0 : months; // Pastikan umur tidak negatif
  }

  // Fungsi untuk mendapatkan string tampilan umur (contoh: "1 tahun 3 bulan" atau "20 hari")
  String _getAgeDisplayString(Timestamp tanggalLahirTimestamp) {
    final birthDate = tanggalLahirTimestamp.toDate();
    final today = DateTime.now();

    final int ageInMonths = _calculateAgeInMonths(tanggalLahirTimestamp);

    if (ageInMonths < 1) {
      // Jika umur kurang dari 1 bulan (belum genap 1 bulan), tampilkan dalam hari
      final Duration difference = today.difference(birthDate);
      return '${difference.inDays} hari';
    } else if (ageInMonths < 12) {
      return '$ageInMonths bulan';
    } else {
      // Jika umur 12 bulan atau lebih, tampilkan dalam tahun dan bulan
      int years = ageInMonths ~/ 12;
      int remainingMonths = ageInMonths % 12;
      if (remainingMonths == 0) {
        return '$years tahun';
      } else {
        return '$years tahun $remainingMonths bulan';
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _barGroups = []; // Clear previous data
      _dataBalita = [];
      _chartLabels = [];
      _namaOrtu = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Pengguna tidak login.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Ambil namaOrtu dari dokumen pengguna yang login di koleksi 'users'
      // Sesuai struktur database yang Anda tunjukkan: users/{uid_pengguna}/data_ortu/{uid_pengguna}
      debugPrint('Mencoba mengambil data orang tua untuk UID: ${user.uid}');
      final ortuDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('data_ortu') // Tambahkan sub-koleksi 'data_ortu'
          .doc(user.uid)           // Dokumen dengan UID yang sama di dalam sub-koleksi
          .get();

      if (!ortuDoc.exists) {
        debugPrint('Data orang tua tidak ditemukan di Firestore untuk UID: ${user.uid} di jalur users/${user.uid}/data_ortu/${user.uid}');
        setState(() {
          _isLoading = false;
        });
        // Tampilkan dialog error yang lebih informatif
        if (mounted) {
          _showErrorDialog('Data profil orang tua tidak ditemukan. Pastikan Anda sudah mendaftar dan profil Anda lengkap.');
        }
        return;
      }

      final namaOrtu = ortuDoc.data()?['namaOrtu'];
      if (namaOrtu == null || namaOrtu.isEmpty) {
        debugPrint('Nama orang tua kosong di profil pengguna UID: ${user.uid}');
        setState(() {
          _isLoading = false;
        });
        // Tampilkan dialog error yang lebih informatif
        if (mounted) {
          _showErrorDialog('Nama orang tua tidak ditemukan di profil Anda. Pastikan profil lengkap setelah mendaftar.');
        }
        return;
      }

      setState(() {
        _namaOrtu = namaOrtu;
      });

      debugPrint('Nama orang tua ditemukan: $_namaOrtu');

      // 2. Cari data balita berdasarkan namaOrtu yang ditemukan
      // Struktur: /data_balita/{documentId} dimana field namaOrtu = namaOrtu
      debugPrint('Mencari data balita dengan namaOrtu: $_namaOrtu');
      final dataBalitaSnapshot = await FirebaseFirestore.instance
          .collection('data_balita') // Menggunakan 'data_balita' sesuai struktur Anda
          .where('namaOrtu', isEqualTo: namaOrtu)
          .get();

      List<Map<String, dynamic>> tempBalitaList = [];
      List<double> tempTbList = [];
      List<double> tempBbList = [];
      List<String> tempLabelList = [];

      if (dataBalitaSnapshot.docs.isEmpty) {
        debugPrint('Tidak ada data balita ditemukan untuk $_namaOrtu');
      }

      for (var balitaDoc in dataBalitaSnapshot.docs) {
        final balitaData = balitaDoc.data();
        debugPrint('Ditemukan balita: ${balitaData['namaBalita']} (ID: ${balitaDoc.id})');
        
        final tanggalLahirTimestamp = balitaData['tanggalLahir'] as Timestamp?;
        String umurDisplay = _getAgeDisplayString(tanggalLahirTimestamp!); // Menghitung dan mendapatkan string umur

        tempBalitaList.add({
          'id': balitaDoc.id,
          'namaBalita': balitaData['namaBalita'] ?? 'Tidak diketahui',
          'tanggalLahir': tanggalLahirTimestamp, // Timestamp
          'jenisKelamin': balitaData['jenisKelamin'],
          'namaOrtu': balitaData['namaOrtu'],
          'umurDisplay': umurDisplay, // Tambahkan umur ke data balita
        });

        // 3. Ambil riwayat pemeriksaan untuk setiap balita
        // Struktur: data_balita/{balitaId}/riwayat_pengukuran/{documentId}
        debugPrint('Mencari riwayat pengukuran untuk balita ID: ${balitaDoc.id}');
        final riwayatSnapshot = await FirebaseFirestore.instance
            .collection('data_balita') // Menggunakan 'data_balita'
            .doc(balitaDoc.id)
            .collection('riwayat_pengukuran') // Menggunakan 'riwayat_pengukuran'
            .orderBy('tanggalPengukuran', descending: false) // Menggunakan 'tanggalPengukuran'
            .get();

        if (riwayatSnapshot.docs.isEmpty) {
          debugPrint('Tidak ada riwayat pengukuran ditemukan untuk balita ID: ${balitaDoc.id}');
        }

        for (var riwayatDoc in riwayatSnapshot.docs) {
          final riwayatData = riwayatDoc.data();
          debugPrint('Ditemukan riwayat: $riwayatData');
          final tb = _parseToDouble(riwayatData['tinggiBadan']); // Menggunakan helper dan field yang benar
          final bb = _parseToDouble(riwayatData['beratBadan']); // Menggunakan helper dan field yang benar
          
          if (tb > 0 && bb > 0) {
            tempTbList.add(tb);
            tempBbList.add(bb);
            
            // Format label dengan nama balita dan tanggal pengukuran
            final tanggalPengukuran = riwayatData['tanggalPengukuran'] as Timestamp?;
            final namaBalita = balitaData['namaBalita'] ?? 'Anak';
            final labelTanggal = tanggalPengukuran != null 
                ? DateFormat('dd/MM').format(tanggalPengukuran.toDate()) 
                : 'N/A';
            tempLabelList.add('$namaBalita\n($labelTanggal)');
          }
        }
      }

      // 4. Buat bar chart groups
      List<BarChartGroupData> groups = [];
      for (int i = 0; i < tempTbList.length; i++) {
        groups.add(
          BarChartGroupData(
            x: i,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: tempTbList[i],
                color: Colors.blue.shade800,
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
              BarChartRodData(
                toY: tempBbList[i],
                color: Colors.orange.shade600,
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        );
      }

      setState(() {
        _barGroups = groups;
        _dataBalita = tempBalitaList;
        _chartLabels = tempLabelList;
        _isLoading = false;
      });

    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        _showErrorDialog('Gagal memuat data: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              await FirebaseAuth.instance.signOut(); // Lakukan logout
              if (mounted) {
                // Pastikan untuk mengganti rute ke halaman login atau root
                Navigator.pushReplacementNamed(context, '/'); 
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          'Dashboard Orang Tua', // Mengubah judul AppBar
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat data...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Header Image
                      SizedBox(
                        height: 120,
                        child: Image.asset(
                          'assets/images/family.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.family_restroom,
                                size: 60,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Welcome Text
                      Text(
                        'Selamat Datang di\nLayanan Posyandu Jogodayuh',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      
                      // Nama Ortu Info
                      if (_namaOrtu != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            'Data untuk: $_namaOrtu',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Data Balita Summary
                      if (_dataBalita.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Balita (${_dataBalita.length} anak)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...(_dataBalita.map((balita) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  // Menampilkan umur balita
                                  '• ${balita['namaBalita']} (${balita['jenisKelamin']}, ${balita['umurDisplay']})',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              )).toList()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Chart Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Grafik Pertumbuhan Balita',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            if (_barGroups.isEmpty)
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bar_chart,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tidak ada data riwayat pemeriksaan',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              SizedBox(
                                height: 300,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: _chartLabels.length * 80.0 + 100, // Adjust width based on number of bars
                                    child: BarChart(
                                      BarChartData(
                                        maxY: _getMaxValue() * 1.2,
                                        barGroups: _barGroups,
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: _getInterval(),
                                              reservedSize: 40,
                                              getTitlesWidget: (value, _) => Text(
                                                '${value.toInt()}',
                                                style: const TextStyle(fontSize: 10),
                                              ),
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                // Ensure index is within bounds
                                                if (value.toInt() >= 0 && value.toInt() < _chartLabels.length) {
                                                  return SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    space: 8,
                                                    child: Text(
                                                      _chartLabels[value.toInt()],
                                                      style: const TextStyle(fontSize: 9),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                        ),
                                        gridData: const FlGridData(show: true),
                                        borderData: FlBorderData(show: true),
                                        barTouchData: BarTouchData(
                                          touchTooltipData: BarTouchTooltipData(
                                            tooltipBgColor: Colors.grey[800]!,
                                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                              String label = rodIndex == 0 ? 'TB' : 'BB';
                                              String unit = rodIndex == 0 ? 'cm' : 'kg';
                                              return BarTooltipItem(
                                                '$label: ${rod.toY.toStringAsFixed(1)} $unit',
                                                const TextStyle(color: Colors.white),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            
                            const SizedBox(height: 16),
                            
                            // Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[800],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('Tinggi Badan (cm)', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.orange[600],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('Berat Badan (kg)', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  double _getMaxValue() {
    if (_barGroups.isEmpty) return 100;
    double max = 0;
    for (var group in _barGroups) {
      for (var rod in group.barRods) {
        if (rod.toY > max) {
          max = rod.toY;
        }
      }
    }
    return max;
  }

  double _getInterval() {
    double maxValue = _getMaxValue();
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    if (maxValue <= 200) return 40;
    return 50;
  }
}
