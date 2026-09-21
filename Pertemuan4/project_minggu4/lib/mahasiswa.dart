class Mahasiswa {
  String nama;
  int umur;
  String kelas;

  Mahasiswa({required this.nama, required this.umur, required this.kelas});
  void tampilkanData() {
    print('Nama: $nama');
    print('Umur: $umur');
    print('Kelas: $kelas');
  }
}