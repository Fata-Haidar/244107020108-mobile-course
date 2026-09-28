class Lagu {
  String judul;
  String singer;
  String lirik;
  String foto;
  String musik;

  Lagu({
    required this.judul,
    required this.singer,
    required this.lirik,
    required this.foto,
    required this.musik,
  });
}


// ===========================================
// DAFTAR LAGU / PLAYLIST
// ===========================================

final List<Lagu> daftarLagu = [
    Lagu(
    judul: 'Talking to the moon',
    singer: 'Bruno Mars',
    foto: 'img/TM.jpeg',
    musik: 'mp3/TM.mp3',
    lirik: '''
Masukkan lirik Drip di sini...
''',
  ),
  Lagu(
    judul: 'Moon',
    singer: 'Baby Monster',
    foto: 'img/moon.jpeg',
    musik: 'mp3/moon_fixed.mp3',
    lirik: '''
Masukkan lirik Moon di sini...
''',
  ),


];