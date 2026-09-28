import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'mahasiswa.dart';
import 'lagu.dart';

void main() {
  runApp(const FataHaidarAly());
}

// ============================================================
// APLIKASI UTAMA - STATELESS WIDGET
// ============================================================

class FataHaidarAly extends StatelessWidget {
  const FataHaidarAly({super.key});

  @override
  Widget build(BuildContext context) {
    final mahasiswa = Mahasiswa(
      nama: 'Fata Haidar Aly',
      umur: 21,
      kelas: 'TI-3C',
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(
          255,
          155,
          19,
          28,
        ),
      ),

      home: HomePage(
        mahasiswa: mahasiswa,
      ),
    );
  }
}

// ============================================================
// HOME PAGE - STATEFUL WIDGET
// ============================================================

class HomePage extends StatefulWidget {
  final Mahasiswa mahasiswa;

  const HomePage({
    super.key,
    required this.mahasiswa,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // ==========================================================
  // AUDIO PLAYER
  // ==========================================================

  final AudioPlayer audioPlayer = AudioPlayer();

  // ==========================================================
  // SEARCH
  // ==========================================================

  final TextEditingController searchController =
      TextEditingController();

  // ==========================================================
  // INDEX LAGU
  // ==========================================================

  int currentIndex = 0;

  // ==========================================================
  // STATE AUDIO
  // ==========================================================

  bool sudahDiputar = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  bool audioError = false;
  String errorMessage = '';

  // ==========================================================
  // ANIMATION
  // ==========================================================

  late AnimationController animationController;

  // ==========================================================
  // LAGU YANG SEDANG AKTIF
  // ==========================================================

  Lagu get laguAktif => daftarLagu[currentIndex];

  @override
  void initState() {
    super.initState();

    // ========================================================
    // ANIMATION CONTROLLER
    // ========================================================

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    // ========================================================
    // DURASI AUDIO
    // ========================================================

    audioPlayer.onDurationChanged.listen((newDuration) {
      if (!mounted) return;

      setState(() {
        duration = newDuration;
      });
    });

    // ========================================================
    // POSISI AUDIO
    // ========================================================

    audioPlayer.onPositionChanged.listen((newPosition) {
      if (!mounted) return;

      setState(() {
        position = newPosition;
      });
    });

    // ========================================================
    // AUDIO SELESAI
    // ========================================================

    audioPlayer.onPlayerComplete.listen((event) {
      if (!mounted) return;

      setState(() {
        sudahDiputar = false;
        position = Duration.zero;
      });

      animationController.stop();
      animationController.reset();
    });
  }

  // ==========================================================
  // PLAY MUSIC
  // ==========================================================

  Future<void> playMusic() async {
    try {
      if (sudahDiputar) {
        await audioPlayer.resume();
      } else {
        await audioPlayer.play(
          AssetSource(
            laguAktif.musik,
            mimeType: 'audio/mpeg',
          ),
        );

        sudahDiputar = true;
      }

      if (!mounted) return;

      setState(() {
        audioError = false;
        errorMessage = '';
      });

      // COVER BERPUTAR
      animationController.repeat();

      showPesan(
        'Memutar ${laguAktif.judul}',
      );
    } catch (e) {
      debugPrint('ERROR AUDIO: $e');

      if (!mounted) return;

      setState(() {
        audioError = true;
        errorMessage = 'Audio gagal diputar';
        sudahDiputar = false;
      });

      animationController.stop();

      showPesan(
        'Audio gagal diputar',
      );
    }
  }

  // ==========================================================
  // PAUSE MUSIC
  // ==========================================================

  Future<void> pauseMusic() async {
    await audioPlayer.pause();

    animationController.stop();

    showPesan(
      'Musik dijeda',
    );
  }

  // ==========================================================
  // GANTI LAGU
  // ==========================================================

  Future<void> gantiLagu(int index) async {
    await audioPlayer.stop();

    if (!mounted) return;

    animationController.stop();
    animationController.reset();

    setState(() {
      currentIndex = index;

      sudahDiputar = false;

      duration = Duration.zero;
      position = Duration.zero;

      audioError = false;
      errorMessage = '';
    });

    // LANGSUNG PLAY LAGU BARU
    await playMusic();
  }

  // ==========================================================
  // NEXT SONG
  // ==========================================================

  Future<void> nextSong() async {
    int indexBaru;

    if (currentIndex < daftarLagu.length - 1) {
      indexBaru = currentIndex + 1;
    } else {
      // KALAU SUDAH LAGU TERAKHIR,
      // BALIK KE LAGU PERTAMA
      indexBaru = 0;
    }

    await gantiLagu(indexBaru);
  }

  // ==========================================================
  // PREVIOUS SONG
  // ==========================================================

  Future<void> previousSong() async {
    int indexBaru;

    if (currentIndex > 0) {
      indexBaru = currentIndex - 1;
    } else {
      // KALAU DI LAGU PERTAMA,
      // PINDAH KE LAGU TERAKHIR
      indexBaru = daftarLagu.length - 1;
    }

    await gantiLagu(indexBaru);
  }

  // ==========================================================
  // SEARCH LAGU
  // ==========================================================

  Future<void> searchLagu(String keyword) async {
    String input = keyword.trim().toLowerCase();

    if (input.isEmpty) {
      showPesan(
        'Masukkan nama lagu terlebih dahulu',
      );

      return;
    }

    int indexDitemukan = daftarLagu.indexWhere(
      (lagu) {
        return lagu.judul
                .toLowerCase()
                .contains(input) ||
            lagu.singer
                .toLowerCase()
                .contains(input);
      },
    );

    if (indexDitemukan != -1) {
      showPesan(
        '${daftarLagu[indexDitemukan].judul} ditemukan',
      );

      await gantiLagu(
        indexDitemukan,
      );

      searchController.clear();
    } else {
      showPesan(
        'Lagu "$keyword" tidak ditemukan',
      );
    }
  }

  // ==========================================================
  // SNACKBAR / FEEDBACK
  // ==========================================================

  void showPesan(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(pesan),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ==========================================================
  // DIALOG FEEDBACK
  // ==========================================================

  void showFeedbackDialog() {
    int rating = 0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Feedback',
              ),

              content: Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  const Text(
                    'Bagaimana aplikasi musik ini?',
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: List.generate(
                      5,
                      (index) {
                        return IconButton(
                          onPressed: () {
                            setDialogState(
                              () {
                                rating =
                                    index + 1;
                              },
                            );
                          },

                          icon: Icon(
                            index < rating
                                ? Icons.star
                                : Icons.star_border,

                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },

                  child: const Text(
                    'Batal',
                  ),
                ),

                ElevatedButton(
                  onPressed: rating == 0
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );

                          showPesan(
                            'Terima kasih! Rating $rating/5',
                          );
                        },

                  child: const Text(
                    'Kirim',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // FORMAT DURASI
  // ==========================================================

  String formatDuration(
    Duration value,
  ) {
    String menit = value.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    String detik = value.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$menit:$detik';
  }

  // ==========================================================
  // BUKA PLAYLIST DENGAN ROUTE
  // ==========================================================

  Future<void> bukaPlaylist() async {
    Navigator.pop(context);

    final int? indexPilihan =
        await Navigator.push<int>(
      context,

      MaterialPageRoute(
        builder: (context) {
          return PlaylistPage(
            currentIndex:
                currentIndex,
          );
        },
      ),
    );

    if (indexPilihan != null) {
      await gantiLagu(
        indexPilihan,
      );
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();

    animationController.dispose();

    searchController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    // ========================================================
    // SLIDER
    // ========================================================

    double maxDuration =
        duration.inMilliseconds.toDouble();

    if (maxDuration <= 0) {
      maxDuration = 1;
    }

    double currentPosition =
        position.inMilliseconds.toDouble();

    if (currentPosition >
        maxDuration) {
      currentPosition =
          maxDuration;
    }

    return Scaffold(
      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(
          255,
          155,
          19,
          28,
        ),

        foregroundColor:
            Colors.white,

        centerTitle: true,

        title: Text(
          '${laguAktif.judul} - ${laguAktif.singer}',

          overflow:
              TextOverflow.ellipsis,
        ),

        actions: [
          // ==================================================
          // SEARCH BOX
          // ==================================================

          SizedBox(
            width: 200,

            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 8,
              ),

              child: TextField(
                controller:
                    searchController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    InputDecoration(
                  hintText:
                      'Cari lagu...',

                  hintStyle:
                      const TextStyle(
                    color:
                        Colors.white70,
                  ),

                  prefixIcon:
                      const Icon(
                    Icons.search,
                    color:
                        Colors.white,
                  ),

                  filled: true,

                  fillColor: Colors.white
                      .withOpacity(
                    0.15,
                  ),

                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),

                    borderSide:
                        const BorderSide(
                      color:
                          Colors.white,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),

                    borderSide:
                        const BorderSide(
                      color:
                          Colors.white,
                      width: 2,
                    ),
                  ),
                ),

                onSubmitted:
                    searchLagu,
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          // FEEDBACK
          IconButton(
            tooltip: 'Feedback',

            onPressed:
                showFeedbackDialog,

            icon: const Icon(
              Icons.rate_review,
            ),
          ),

          const SizedBox(
            width: 10,
          ),
        ],
      ),

      // ======================================================
      // DRAWER
      // ======================================================

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,

          children: [
            DrawerHeader(
              decoration:
                  const BoxDecoration(
                color:
                    Color.fromARGB(
                  255,
                  155,
                  19,
                  28,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                mainAxisAlignment:
                    MainAxisAlignment
                        .end,

                children: [
                  Text(
                    widget
                        .mahasiswa.nama,

                    style:
                        const TextStyle(
                      color:
                          Colors.white,

                      fontSize: 20,

                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    widget
                        .mahasiswa.kelas,

                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // HOME
            ListTile(
              leading: const Icon(
                Icons.home,
              ),

              title:
                  const Text(
                'Home',
              ),

              onTap: () {
                Navigator.pop(
                  context,
                );
              },
            ),

            // PLAYLIST
            ListTile(
              leading: const Icon(
                Icons.music_note,
              ),

              title:
                  const Text(
                'Playlist',
              ),

              onTap:
                  bukaPlaylist,
            ),

            // FEEDBACK
            ListTile(
              leading: const Icon(
                Icons.feedback,
              ),

              title:
                  const Text(
                'Feedback',
              ),

              onTap: () {
                Navigator.pop(
                  context,
                );

                showFeedbackDialog();
              },
            ),
          ],
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [
            // =================================================
            // ERROR SIGN
            // =================================================

            if (audioError)
              Center(
                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.red,

                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                  ),

                  child: Row(
                    mainAxisSize:
                        MainAxisSize
                            .min,

                    children: [
                      const Icon(
                        Icons.error,

                        color:
                            Colors.white,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        errorMessage,

                        style:
                            const TextStyle(
                          color: Colors
                              .white,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (audioError)
              const SizedBox(
                height: 20,
              ),

            // =================================================
            // GAMBAR + ANIMATION
            // =================================================

            Center(
              child:
                  RotationTransition(
                turns:
                    animationController,

                child: ClipRRect(
                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),

                  child:
                      Image.asset(
                    laguAktif.foto,

                    width: 300,
                    height: 300,

                    fit:
                        BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // =================================================
            // JUDUL
            // =================================================

            Row(
              children: [
                const Icon(
                  Icons.music_note,

                  color:
                      Colors.red,

                  size: 30,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    '${laguAktif.judul} - ${laguAktif.singer}',

                    style:
                        const TextStyle(
                      fontSize: 24,

                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // =================================================
            // SLIDER
            // =================================================

            Slider(
              min: 0,

              max: maxDuration,

              value:
                  currentPosition,

              onChanged:
                  (value) async {
                Duration posisiBaru =
                    Duration(
                  milliseconds:
                      value.toInt(),
                );

                await audioPlayer
                    .seek(
                  posisiBaru,
                );
              },
            ),

            // =================================================
            // DURASI
            // =================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [
                Text(
                  formatDuration(
                    position,
                  ),
                ),

                Text(
                  formatDuration(
                    duration,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 25,
            ),

            // =================================================
            // LIRIK
            // OTOMATIS GANTI SESUAI LAGU
            // =================================================

            Card(
              elevation: 5,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  20,
                ),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(
                  20,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lyrics,

                          color:
                              Colors.red,
                        ),

                        SizedBox(
                          width: 10,
                        ),

                        Text(
                          'Lyrics',

                          style:
                              TextStyle(
                            fontSize:
                                22,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(),

                    Text(
                      laguAktif.lirik,

                      style:
                          const TextStyle(
                        fontSize: 18,

                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ======================================================
      // BOTTOM MUSIC PLAYER
      // ======================================================

      bottomNavigationBar:
          BottomAppBar(
        color:
            const Color.fromARGB(
          255,
          155,
          19,
          28,
        ),

        child: SizedBox(
          height: 80,

          child: Row(
            children: [
              // DATA MAHASISWA
              Expanded(
                flex: 2,

                child: Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    left: 20,
                  ),

                  child: Text(
                    'Nama: ${widget.mahasiswa.nama}\n'
                    'Kelas: ${widget.mahasiswa.kelas}',

                    style:
                        const TextStyle(
                      color:
                          Colors.white,

                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // ===============================================
              // PLAYER BUTTONS
              // ===============================================

              Expanded(
                flex: 2,

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [
                    // =========================================
                    // PREVIOUS
                    // =========================================

                    IconButton(
                      tooltip:
                          'Previous',

                      icon:
                          const Icon(
                        Icons
                            .skip_previous,

                        color:
                            Colors.white,

                        size: 32,
                      ),

                      onPressed:
                          previousSong,
                    ),

                    // =========================================
                    // PLAY / PAUSE
                    //
                    // STREAMBUILDER = ASYNC WIDGET
                    // =========================================

                    StreamBuilder<
                        PlayerState>(
                      stream: audioPlayer
                          .onPlayerStateChanged,

                      builder: (
                        context,
                        snapshot,
                      ) {
                        bool playing =
                            snapshot.data ==
                                PlayerState
                                    .playing;

                        return IconButton(
                          tooltip:
                              playing
                                  ? 'Pause'
                                  : 'Play',

                          icon: Icon(
                            playing
                                ? Icons
                                    .pause_circle
                                : Icons
                                    .play_circle,

                            color:
                                Colors.white,

                            size: 45,
                          ),

                          onPressed:
                              playing
                                  ? pauseMusic
                                  : playMusic,
                        );
                      },
                    ),

                    // =========================================
                    // NEXT
                    // =========================================

                    IconButton(
                      tooltip: 'Next',

                      icon:
                          const Icon(
                        Icons
                            .skip_next,

                        color:
                            Colors.white,

                        size: 32,
                      ),

                      onPressed:
                          nextSong,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PLAYLIST PAGE - STATELESS WIDGET
// ============================================================

class PlaylistPage
    extends StatelessWidget {
  final int currentIndex;

  const PlaylistPage({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(
          255,
          155,
          19,
          28,
        ),

        foregroundColor:
            Colors.white,

        title:
            const Text(
          'Playlist',
        ),
      ),

      // ======================================================
      // LIST 2 LAGU
      // ======================================================

      body: ListView.builder(
        padding:
            const EdgeInsets.all(
          20,
        ),

        itemCount:
            daftarLagu.length,

        itemBuilder: (
          context,
          index,
        ) {
          final lagu =
              daftarLagu[index];

          bool aktif =
              index ==
                  currentIndex;

          return Card(
            child: ListTile(
              // GAMBAR
              leading: ClipRRect(
                borderRadius:
                    BorderRadius
                        .circular(
                  8,
                ),

                child:
                    Image.asset(
                  lagu.foto,

                  width: 60,
                  height: 60,

                  fit:
                      BoxFit.cover,
                ),
              ),

              // JUDUL
              title: Text(
                lagu.judul,

                style: TextStyle(
                  fontWeight:
                      aktif
                          ? FontWeight
                              .bold
                          : FontWeight
                              .normal,
                ),
              ),

              // SINGER
              subtitle: Text(
                lagu.singer,
              ),

              // ICON
              trailing: Icon(
                aktif
                    ? Icons
                        .volume_up
                    : Icons
                        .play_arrow,
              ),

              // PILIH LAGU
              onTap: () {
                Navigator.pop(
                  context,
                  index,
                );
              },
            ),
          );
        },
      ),
    );
  }
}