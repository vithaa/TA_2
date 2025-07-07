import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Untuk initializeDateFormatting
import 'package:flutter_localizations/flutter_localizations.dart'; // Untuk localization
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ta_2/firebase_options.dart'; // Pastikan ini ada dan benar
import 'package:cloud_firestore/cloud_firestore.dart';

// Import hanya halaman-halaman yang merupakan titik masuk utama atau diakses langsung
import 'package:flutter_ta_2/screen/login_screen.dart';
import 'package:flutter_ta_2/screen/register_screen.dart';
import 'package:flutter_ta_2/screen/navigate_screen.dart'; // NavigateScreen mengelola Dashboard, Riwayat, Rekomendasi
import 'package:flutter_ta_2/screen/grafik_pertumbuhan_screen.dart'; // Diakses dari RiwayatScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  try {
    await initializeDateFormatting('id_ID', null);
    print("✅ Date formatting initialized");
  } catch (e) {
    print("❌ Date formatting init error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Posyandu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // visualDensity: VisualDensity.adaptivePlatformDensity, // Ini bisa dihapus jika tidak ada kebutuhan spesifik
      ),
      // Tambahkan localization jika diperlukan
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Bahasa Indonesia
        Locale('en', 'US'), // Bahasa Inggris
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), // Halaman login
        '/register': (context) => const RegisterScreen(), // Halaman register
        '/navigate': (context) => const NavigateScreen(), // Halaman dengan BottomNavigationBar
        // Rute '/main' dihapus karena redundan dengan '/navigate'
        // '/main': (context) => const NavigateScreen(), 

        // Rute-rute berikut dihapus karena mereka diakses melalui NavigateScreen
        // dan tidak perlu rute top-level terpisah, kecuali '/grafik'
        // '/dashboard': (context) => const DashboardScreen(), 
        // '/rekomendasi': (context) => const RekomendasiAsupanScreen(),
        // '/riwayat': (context) => const RiwayatScreen(),

        '/grafik': (context) => const GrafikPertumbuhanScreen(), // Tetap ada karena diakses dari RiwayatScreen
      },
    );
  }
}
