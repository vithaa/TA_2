import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'rekomendasi_asupan_screen.dart'; // Tetap diimpor
import 'riwayat_screen.dart'; // Tetap diimpor

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const RiwayatScreen(), // RiwayatScreen sekarang di posisi kedua (indeks 1)
    const RekomendasiAsupanScreen(), // RekomendasiAsupanScreen sekarang di posisi terakhir (indeks 2)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color.fromARGB(255, 255, 253, 255),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), // Ikon dan label untuk Riwayat
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining), // Ikon dan label untuk Rekomendasi
            label: 'Rekomendasi',
          ),
        ],
      ),
    );
  }
}
