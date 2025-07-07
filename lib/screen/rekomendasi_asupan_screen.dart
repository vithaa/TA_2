import 'package:flutter/material.dart';

class RekomendasiAsupanScreen extends StatelessWidget {
  const RekomendasiAsupanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF), // Warna latar belakang yang lembut
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          'Panduan Gizi Anak',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 4, // Sedikit bayangan pada AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Pendahuluan
            _buildSectionCard(
              context,
              title: 'Selamat Datang!',
              icon: Icons.info_outline,
              color: Colors.blue,
              children: [
                Text(
                  'Selamat datang di halaman panduan gizi untuk anak usia 3-5 tahun! Memenuhi kebutuhan gizi anak pada usia ini sangat krusial untuk tumbuh kembang optimal, terutama karena otak mereka sedang berkembang pesat.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Penting: Informasi di halaman ini adalah panduan umum dan tidak menggantikan konsultasi dengan ahli gizi atau dokter anak. Untuk rencana diet yang personal dan sesuai kondisi anak Anda, harap berkonsultasi dengan profesional kesehatan.',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bagian Kebutuhan Gizi Harian
            _buildSectionCard(
              context,
              title: 'Kebutuhan Gizi Harian Anak Usia 3-5 Tahun',
              subtitle: '(Berdasarkan Angka Kecukupan Gizi - AKG Kementerian Kesehatan Indonesia)',
              icon: Icons.local_dining,
              color: Colors.green,
              children: [
                _buildGiziItem(context, 'Usia 3 Tahun', 'Energi: 1125 kkal', 'Protein: 20 gram', 'Vitamin & Mineral Penting: Vitamin A, C, D, E, K, B kompleks, Kalsium, Zat Besi, Zink, Yodium, dll.'),
                _buildGiziItem(context, 'Usia 4 Tahun', 'Energi: 1250 kkal', 'Protein: 25 gram', 'Vitamin & Mineral Penting: Kebutuhan terus meningkat seiring pertumbuhan.'),
                _buildGiziItem(context, 'Usia 5 Tahun', 'Energi: 1375 kkal', 'Protein: 30 gram', 'Vitamin & Mineral Penting: Kebutuhan tetap penting untuk mendukung aktivitas dan perkembangan.'),
              ],
            ),
            const SizedBox(height: 20),

            // Bagian Sumber Makanan Penting
            _buildSectionCard(
              context,
              title: 'Sumber Makanan Penting',
              subtitle: 'Pastikan anak Anda mendapatkan asupan dari berbagai kelompok makanan berikut untuk memenuhi kebutuhan gizinya:',
              icon: Icons.restaurant_menu,
              color: Colors.orange,
              children: [
                _buildFoodGroup(
                  context,
                  '1. Karbohidrat',
                  'Sumber Energi Utama',
                  'Memberikan energi untuk aktivitas sehari-hari dan fungsi otak.',
                  'Nasi, roti, kentang, ubi, jagung, sereal, pasta.',
                  'Sesuaikan dengan kebutuhan energi harian anak.',
                ),
                _buildFoodGroup(
                  context,
                  '2. Protein',
                  'Pembangun dan Perbaikan Sel',
                  'Penting untuk pertumbuhan otot, tulang, kulit, rambut, serta pembentukan enzim dan hormon.',
                  'Hewani: Daging merah (sapi, ayam), ikan (salmon, tuna, lele, gabus), telur, susu dan produk olahannya (keju, yogurt).\nNabati: Tahu, tempe, kacang-kacangan (kacang hijau, kacang merah, kedelai).',
                  'Penting untuk setiap kali makan utama dan camilan.',
                ),
                _buildFoodGroup(
                  context,
                  '3. Lemak',
                  'Energi Cadangan dan Penyerapan Vitamin',
                  'Sumber energi terkonsentrasi, membantu penyerapan vitamin larut lemak (A, D, E, K), dan penting untuk perkembangan otak.',
                  'Alpukat, minyak zaitun, minyak ikan, kacang-kacangan, biji-bijian, ikan berlemak.',
                  'Berikan dalam jumlah cukup, pilih lemak sehat.',
                ),
                _buildFoodGroup(
                  context,
                  '4. Vitamin dan Mineral',
                  'Pengatur Fungsi Tubuh',
                  'Mendukung sistem kekebalan tubuh, perkembangan tulang, penglihatan, dan berbagai fungsi vital lainnya.',
                  'Vitamin A: Wortel, ubi jalar, bayam, hati ayam, telur.\nVitamin C: Jeruk, stroberi, brokoli, paprika.\nVitamin D: Sinar matahari, ikan berlemak, susu terfortifikasi.\nKalsium: Susu, yogurt, keju, sayuran hijau gelap.\nZat Besi: Daging merah, hati, bayam, kacang merah.\nZink: Daging, kacang-kacangan, biji-bijian.',
                  '', // Tidak ada porsi spesifik di sini
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bagian Tips Penting
            _buildSectionCard(
              context,
              title: 'Tips Penting dalam Memberikan Makanan pada Anak',
              icon: Icons.lightbulb_outline,
              color: Colors.purple,
              children: [
                _buildTipItem(context, 'Variasi Makanan', 'Sajikan berbagai jenis makanan untuk memastikan anak mendapatkan semua nutrisi yang dibutuhkan.'),
                _buildTipItem(context, 'Jadwal Makan Teratur', 'Tetapkan jadwal makan utama dan camilan yang konsisten.'),
                _buildTipItem(context, 'Libatkan Anak', 'Biarkan anak membantu memilih atau menyiapkan makanan untuk meningkatkan minat mereka.'),
                _buildTipItem(context, 'Contoh yang Baik', 'Orang tua adalah contoh terbaik dalam kebiasaan makan sehat.'),
                _buildTipItem(context, 'Hindari Makanan Olahan dan Manis Berlebihan', 'Batasi asupan gula, garam, dan lemak tidak sehat.'),
                _buildTipItem(context, 'Cukupi Cairan', 'Pastikan anak minum air putih yang cukup sepanjang hari.'),
              ],
            ),
            const SizedBox(height: 20),

            // Penutup
            Center(
              child: Text(
                'Dengan memahami panduan gizi ini, Anda dapat membantu memastikan anak Anda mendapatkan asupan nutrisi yang memadai untuk tumbuh kembang yang optimal dan mencegah stunting.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembangun untuk setiap bagian utama
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget pembangun untuk item gizi harian
  Widget _buildGiziItem(
    BuildContext context,
    String ageGroup,
    String energy,
    String protein,
    String vitamins,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ageGroup,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text('- $energy'),
          Text('- $protein'),
          Text('- $vitamins'),
        ],
      ),
    );
  }

  // Widget pembangun untuk kelompok makanan
  Widget _buildFoodGroup(
    BuildContext context,
    String title,
    String subtitle,
    String function,
    String examples,
    String portion,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.orange[800],
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          Text('Fungsi: $function'),
          const SizedBox(height: 4),
          Text('Contoh Makanan: $examples'),
          if (portion.isNotEmpty) Text('Porsi: $portion'),
        ],
      ),
    );
  }

  // Widget pembangun untuk item tips
  Widget _buildTipItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.purple[600], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
