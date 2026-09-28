import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'mahasiswa.dart';
import 'lagu.dart';

void main() {
  runApp(const FataHaidarAly());
}

class FataHaidarAly extends StatelessWidget {
  const FataHaidarAly({super.key});

  @override
  Widget build(BuildContext context) {
    final mahasiswa = Mahasiswa(
      nama: 'Fata Haidar Aly',
      umur: 21,
      kelas: 'TI-3C',
    );

    final lagu = Lagu(
      judul: 'Moon',
      singer: 'Baby Monster',

      // IMAGE
      foto: 'img/moon.jpeg',

      // AUDIO
      // FILE ASLINYA:
      // assets/mp3/moon_fixed.mp3
      musik: 'mp3/moon_fixed.mp3',

      // LIRIK
      lirik: '''
I'm the moon, 보름달 뜨는 밤, on the loose
Zalabim, zalabam, zalaboom
I shine so bright in the gloom
I'm the moon, I'm the moon, I'm the moon

Fog thickens, night vision
Where we gonna end up is unwritten
Grave digger, go figure
But if you're killin' my mood, good riddance

Ice in my veins, you're gonna need to keep up
With the pace, 더 빨리 더 높이
When you, when you, when you at the crack of dawn
You keep on ravin' on, you keep on ravin' on, uh

까만 밤 빛이나 진짜가 나타나
세상을 불태워라 (baby, do you see me now?)
거울아, 거울아 말해봐, 알잖아
In your heart, leave a mark

I'm the moon, 보름달 뜨는 밤, on the loose
Zalabim, zalabam, zalaboom
I'm the queen of the tide and the youth
I'm the moon, I'm the moon, I'm the moon

I'm the moon, 보름달 뜨는 밤 on the loose (moon, moon)
Zalabim, zalabam, zalaboom (moon, moon)
I'm the queen of the tide and the youth (moon, moon)
I'm the moon, I'm the moon, I'm the moon (moon, moon)

Charismatic, energetic
It's a habit, oh, she stuntin', she stuntin'

I'm in a spaceship coupe, we 'bout to take off (ooh)
Leave 'em in the dust, yeah, see you later (yeah)
Outta this world, I'm off the radar (radar)
You wish on a star (star) that you had these bars

I, whoosh (uh), gettin' that, ah, when we go strut in like, whoa (mm)
Settin' on hot, that's what we got, that's how we bakin' that dough (yeah)
Lock and we load, shoot for the stars (whoo), we in the sky, raisin' the bar
Eyes on the prize, shinin' my light, ready, get, set, SOS when I flex

까만 밤 빛이나 진짜가 나타나
세상을 불태워라 (baby, do you see me now?)
거울아, 거울아 말해봐, 알잖아
In your heart, leave a mark

I'm the moon, 보름달 뜨는 밤, on the loose
Zalabim, zalabam, zalaboom
I'm the queen of the tide and the youth
I'm the moon, I'm the moon, I'm the moon

I'm the moon, 보름달 뜨는 밤 on the loose (moon, moon)
Zalabim, zalabam, zalaboom (moon, moon)
I'm the queen of the tide and the youth (moon, moon)
I'm the moon, I'm the moon, I'm the moon (moon, moon)

하늘을 봐, we gonna shine bright
내 길을 가, baby, it's our time
If you wanna ride, if you wanna ride
If you wanna ride, if you wanna ride, let's ride

Give 'em all in, give 'em all out, give 'em all a show (ride, let's ride)
Give 'em all in, give 'em all out, give 'em all that, whoa
Baby, I'ma glow, it's about to blow
They don't even know

Outta this world, we be takin' off, get in (moon, moon)
Look at me, I'ma need your attention (moon, moon)
Hut, one, two, hut, one, two, three (moon, moon)
All eyes, all eyes on me (moon, moon)

Outta this world, we be takin' off, get in (moon, moon)
Look at me, I'ma need your attention (moon, moon)
Hut, one, two, hut, one, two, three (moon, moon)
All eyes, all eyes on me (moon, moon, moon)
    ''',
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
        lagu: lagu,
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  final Mahasiswa mahasiswa;
  final Lagu lagu;

  const HomePage({
    super.key,
    required this.mahasiswa,
    required this.lagu,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

// ============================================================
// STATE WIDGET
// ============================================================

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // ==========================================================
  // AUDIO PLAYER
  // ==========================================================

  final AudioPlayer audioPlayer = AudioPlayer();

  // ==========================================================
  // STATE
  // ==========================================================

  bool isPlaying = false;
  bool sudahDiputar = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // ==========================================================
  // SEARCH
  // ==========================================================

  final TextEditingController searchController =
      TextEditingController();

  // ==========================================================
  // ANIMATION
  // ==========================================================

  late AnimationController animationController;

  // ==========================================================
  // ASYNC
  // ==========================================================

  late Future<String> statusAudio;

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
    // ASYNC
    // ========================================================

    statusAudio = loadAudio();

    // ========================================================
    // DURATION AUDIO
    // ========================================================

    audioPlayer.onDurationChanged.listen((newDuration) {
      if (!mounted) return;

      setState(() {
        duration = newDuration;
      });
    });

    // ========================================================
    // POSITION AUDIO
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
        isPlaying = false;
        sudahDiputar = false;
        position = Duration.zero;
      });

      animationController.stop();
      animationController.reset();
    });
  }

  // ==========================================================
  // ASYNC FUNCTION
  // ==========================================================

  Future<String> loadAudio() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );

    return 'Audio siap diputar';
  }

  // ==========================================================
  // PLAY MUSIC
  // ==========================================================

  Future<void> playMusic() async {
    try {
      if (sudahDiputar) {
        // LANJUTKAN AUDIO
        await audioPlayer.resume();
      } else {
        // PLAY DARI ASSET
        await audioPlayer.play(
          AssetSource(
            widget.lagu.musik,
            mimeType: 'audio/mpeg',
          ),
        );

        sudahDiputar = true;
      }

      if (!mounted) return;

      setState(() {
        isPlaying = true;
      });

      // MULAI ANIMASI
      animationController.repeat();

      showPesan(
        'Memutar ${widget.lagu.judul}',
      );
    } catch (e) {
      debugPrint('ERROR AUDIO: $e');

      if (!mounted) return;

      showPesan(
        'Musik gagal diputar',
      );
    }
  }

  // ==========================================================
  // PAUSE MUSIC
  // ==========================================================

  Future<void> pauseMusic() async {
    await audioPlayer.pause();

    if (!mounted) return;

    setState(() {
      isPlaying = false;
    });

    // STOP ANIMASI
    animationController.stop();

    showPesan(
      'Musik dijeda',
    );
  }

  // ==========================================================
  // SEARCH ACTION
  // ==========================================================

  void searchLagu(String keyword) {
    String input = keyword.trim().toLowerCase();

    if (input.isEmpty) {
      showPesan(
        'Masukkan nama lagu terlebih dahulu',
      );

      return;
    }

    String judul = widget.lagu.judul.toLowerCase();
    String singer = widget.lagu.singer.toLowerCase();

    if (judul.contains(input) || singer.contains(input)) {
      showPesan(
        '${widget.lagu.judul} - ${widget.lagu.singer} ditemukan',
      );
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
  // DIALOG / FEEDBACK WIDGET
  // ==========================================================

  void showFeedbackDialog() {
    int rating = 0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Feedback',
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bagaimana aplikasi musik ini?',
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // RATING BINTANG
                  // =================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) {
                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              rating = index + 1;
                            });
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

  String formatDuration(Duration value) {
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

    if (currentPosition > maxDuration) {
      currentPosition = maxDuration;
    }

    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(
          255,
          155,
          19,
          28,
        ),

        foregroundColor: Colors.white,

        centerTitle: true,

        title: Text(
          '${widget.lagu.judul} - ${widget.lagu.singer}',
        ),

        // ======================================================
        // APPBAR ACTIONS
        // ======================================================

        actions: [
          // ====================================================
          // SEARCH BOX
          // ====================================================

          SizedBox(
            width: 200,

            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 8,
              ),

              child: TextField(
                controller: searchController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: InputDecoration(
                  hintText: 'Cari lagu...',

                  hintStyle:
                      const TextStyle(
                    color: Colors.white70,
                  ),

                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),

                  // =============================================
                  // FILLED SEARCH BOX
                  // =============================================

                  filled: true,

                  fillColor: Colors.white
                      .withOpacity(0.15),

                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),

                    borderSide:
                        const BorderSide(
                      color: Colors.white,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),

                    borderSide:
                        const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),

                // =================================================
                // ACTION SEARCH
                // ENTER
                // =================================================

                onSubmitted: searchLagu,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ====================================================
          // FEEDBACK BUTTON
          // ====================================================

          IconButton(
            tooltip: 'Feedback',

            onPressed:
                showFeedbackDialog,

            icon: const Icon(
              Icons.rate_review,
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),

      // ========================================================
      // DRAWER
      // ========================================================

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,

          children: [
            // ==================================================
            // DRAWER HEADER
            // ==================================================

            DrawerHeader(
              decoration:
                  const BoxDecoration(
                color: Color.fromARGB(
                  255,
                  155,
                  19,
                  28,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                mainAxisAlignment:
                    MainAxisAlignment.end,

                children: [
                  Text(
                    widget.mahasiswa.nama,

                    style:
                        const TextStyle(
                      color: Colors.white,

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    widget.mahasiswa.kelas,

                    style:
                        const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // HOME
            // ==================================================

            ListTile(
              leading:
                  const Icon(
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

            // ==================================================
            // PLAYLIST
            // ACTION + ROUTE
            // ==================================================

            ListTile(
              leading:
                  const Icon(
                Icons.music_note,
              ),

              title:
                  const Text(
                'Playlist',
              ),

              onTap: () {
                // TUTUP DRAWER
                Navigator.pop(
                  context,
                );

                // ===============================================
                // ROUTE / NAVIGATION
                // ===============================================

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) {
                      return PlaylistPage(
                        lagu:
                            widget.lagu,
                      );
                    },
                  ),
                );
              },
            ),

            // ==================================================
            // FEEDBACK
            // ==================================================

            ListTile(
              leading:
                  const Icon(
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

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // ASYNC WIDGET
            // FUTURE BUILDER
            // ==================================================

            FutureBuilder<String>(
              future: statusAudio,

              builder: (
                context,
                snapshot,
              ) {
                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child: Padding(
                      padding:
                          EdgeInsets.all(
                        20,
                      ),

                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                }

                return Center(
                  child: Chip(
                    avatar: const Icon(
                      Icons.check_circle,

                      color:
                          Colors.green,
                    ),

                    label: Text(
                      snapshot.data ??
                          'Audio siap',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // ANIMATION WIDGET
            // COVER BERPUTAR
            // ==================================================

            Center(
              child: RotationTransition(
                turns:
                    animationController,

                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),

                  child: Image.asset(
                    widget.lagu.foto,

                    width: 300,

                    height: 300,

                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // JUDUL LAGU
            // ==================================================

            Row(
              children: [
                const Icon(
                  Icons.music_note,

                  color: Colors.red,

                  size: 30,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    '${widget.lagu.judul} - '
                    '${widget.lagu.singer}',

                    style:
                        const TextStyle(
                      fontSize: 24,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // STATE WIDGET
            // SLIDER AUDIO
            // ==================================================

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

                await audioPlayer.seek(
                  posisiBaru,
                );
              },
            ),

            // ==================================================
            // DURASI
            // ==================================================

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

            // ==================================================
            // LYRICS CARD
            // ==================================================

            Card(
              elevation: 5,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
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
                      widget.lagu.lirik,

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

      // ========================================================
      // BOTTOM MUSIC PLAYER
      // ========================================================

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
              // =================================================
              // DATA MAHASISWA
              // =================================================

              Expanded(
                flex: 2,

                child: Padding(
                  padding:
                      const EdgeInsets.only(
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

              // =================================================
              // PLAYER BUTTONS
              // =================================================

              Expanded(
                flex: 2,

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [
                    // =============================================
                    // PREVIOUS
                    // =============================================

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

                      onPressed: () {
                        showPesan(
                          'Tidak ada lagu sebelumnya',
                        );
                      },
                    ),

                    // =============================================
                    // PLAY / PAUSE
                    // STATE ACTION
                    // =============================================

                    IconButton(
                      tooltip:
                          isPlaying
                              ? 'Pause'
                              : 'Play',

                      icon: Icon(
                        isPlaying
                            ? Icons
                                .pause_circle
                            : Icons
                                .play_circle,

                        color:
                            Colors.white,

                        size: 45,
                      ),

                      onPressed:
                          isPlaying
                              ? pauseMusic
                              : playMusic,
                    ),

                    // =============================================
                    // NEXT
                    // =============================================

                    IconButton(
                      tooltip: 'Next',

                      icon:
                          const Icon(
                        Icons.skip_next,

                        color:
                            Colors.white,

                        size: 32,
                      ),

                      onPressed: () {
                        showPesan(
                          'Tidak ada lagu berikutnya',
                        );
                      },
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
// PLAYLIST PAGE
// ROUTE PAGE
// ============================================================

class PlaylistPage extends StatelessWidget {
  final Lagu lagu;

  const PlaylistPage({
    super.key,
    required this.lagu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================
      // APPBAR
      // ========================================================

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

      // ========================================================
      // BODY
      // ========================================================

      body: ListView(
        padding:
            const EdgeInsets.all(
          20,
        ),

        children: [
          Card(
            child: ListTile(
              // =================================================
              // GAMBAR
              // =================================================

              leading: ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  8,
                ),

                child: Image.asset(
                  lagu.foto,

                  width: 60,

                  height: 60,

                  fit: BoxFit.cover,
                ),
              ),

              // =================================================
              // JUDUL
              // =================================================

              title:
                  Text(
                lagu.judul,
              ),

              // =================================================
              // PENYANYI
              // =================================================

              subtitle:
                  Text(
                lagu.singer,
              ),

              trailing:
                  const Icon(
                Icons.play_arrow,
              ),

              // =================================================
              // ACTION
              // =================================================

              onTap: () {
                ScaffoldMessenger
                        .of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '${lagu.judul} dipilih',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}