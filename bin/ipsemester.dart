import 'dart:io';

// Satu baris data mata kuliah, ditulis sebagai record bernama.
typedef MataKuliah = ({String nama, int sks, String nilai});

/// Membaca satu baris input dengan label, lalu merapikannya dengan trim().
String baca(String label) {
  stdout.write('$label : ');
  return (stdin.readLineSync() ?? '').trim(); // readLineSync bisa null -> ''
}

/// Validasi SKS. Melempar FormatException bila bukan angka 1-6.
/// Exception dilempar di sini, ditangkap di main() (satu tempat saja).
int validasiSks(String teks) {
  final sks = int.tryParse(teks);
  if (sks == null || sks < 1 || sks > 6) {
    throw FormatException('SKS harus berupa angka 1-6, bukan "$teks".');
  }
  return sks;
}

/// Validasi nilai huruf. Menerima a-e (huruf kecil) dan mengubahnya ke A-E.
String validasiNilai(String teks) {
  final huruf = teks.toUpperCase();
  // length dicek dulu karena 'ABCDE'.contains('') bernilai true.
  if (huruf.length != 1 || !'ABCDE'.contains(huruf)) {
    throw FormatException('Nilai harus salah satu dari A, B, C, D, E, '
        'bukan "$teks".');
  }
  return huruf;
}

/// Mengubah nilai huruf menjadi bobot (skala contoh; sesuaikan dengan
/// pedoman akademik bila perlu).
int bobot(String huruf) => switch (huruf) {
      'A' => 4,
      'B' => 3,
      'C' => 2,
      'D' => 1,
      'E' => 0,
      _ => throw ArgumentError('Nilai tidak dikenal: $huruf'),
    };

/// IP = jumlah(SKS x bobot) / jumlah(SKS), dihitung dengan fold.
double hitungIp(List<MataKuliah> data) {
  final totalSks = data.fold<int>(0, (jumlah, m) => jumlah + m.sks);
  if (totalSks == 0) return 0; // hindari pembagian dengan nol
  final totalMutu =
      data.fold<int>(0, (jumlah, m) => jumlah + m.sks * bobot(m.nilai));
  return totalMutu / totalSks;
}

/// Predikat berdasarkan IP (skala contoh).
String predikat(double ip) => switch (ip) {
      >= 3.5 => 'Sangat Memuaskan',
      >= 3.0 => 'Memuaskan',
      >= 2.0 => 'Cukup',
      _ => 'Kurang',
    };

/// Mencetak KHS. Parameter bernama [urutkan]: true = nilai tertinggi dulu.
void cetakKhs(List<MataKuliah> data, {bool urutkan = false}) {
  // Salin list supaya urutan input asli tidak berubah.
  final tampil = [...data];
  if (urutkan) {
    // Fungsi pembanding: bobot b dibanding bobot a -> urutan menurun.
    tampil.sort((a, b) => bobot(b.nilai).compareTo(bobot(a.nilai)));
  }

  print('');
  print('${'Mata Kuliah'.padRight(26)}${'SKS'.padLeft(4)}${'Nilai'.padLeft(7)}');
  print('-' * 37);
  for (final m in tampil) {
    print('${m.nama.padRight(26)}${m.sks.toString().padLeft(4)}'
        '${m.nilai.padLeft(7)}');
  }
  print('-' * 37);

  final totalSks = data.fold<int>(0, (jumlah, m) => jumlah + m.sks);
  final ip = hitungIp(data);
  print('Total SKS : $totalSks');
  print('IP        : ${ip.toStringAsFixed(2)} (${predikat(ip)})');

  // where: saring mata kuliah dengan bobot < 2 (nilai D dan E).
  final perluDiperbaiki =
      data.where((m) => bobot(m.nilai) < 2).map((m) => m.nama).toList();
  if (perluDiperbaiki.isNotEmpty) {
    print('Perlu diperbaiki: ${perluDiperbaiki.join(', ')}');
  }
}

void main() {
  final List<MataKuliah> data = [];
  print('Masukkan data mata kuliah. Kosongkan nama untuk selesai.');

  while (true) {
    final nama = baca('Nama MK');
    if (nama.isEmpty) break; // nama kosong = selesai input

    try {
      final sks = validasiSks(baca('SKS'));
      final nilai = validasiNilai(baca('Nilai (A-E)'));
      data.add((nama: nama, sks: sks, nilai: nilai));
    } on FormatException catch (e) {
      // Data yang salah diabaikan, program tetap lanjut.
      print('Data diabaikan: ${e.message}');
    }
  }

  if (data.isEmpty) {
    print('Tidak ada data mata kuliah yang valid.');
    return;
  }

  final urutkan =
      baca('Urutkan dari nilai tertinggi? (y/n)').toLowerCase() == 'y';
  cetakKhs(data, urutkan: urutkan);
}