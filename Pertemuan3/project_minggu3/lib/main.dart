import 'package:flutter/material.dart';
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
      foto: 'img/moon.jpeg',
      musik: 'mp3/moon2.mp3',
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
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 155, 19, 28),
          centerTitle: true,
          title: Text(
            '${lagu.judul} - ${lagu.singer}',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari lagu...',
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  hintStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),

                    borderSide: const BorderSide(color: Colors.white),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),

                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),

                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(width: 10),
          ],
        ),

        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 155, 19, 28),
                ),
                child: Text(
                  mahasiswa.nama,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text('Playlist'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        body: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // GAMBAR MOON
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),

                    child: Image.asset(
                      lagu.foto,

                      width: 300,

                      height: 350,

                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // JUDUL LAGU
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.red, size: 30),

                    const SizedBox(width: 10),

                    Text(
                      '${lagu.judul} - ${lagu.singer}',

                      style: const TextStyle(
                        fontSize: 24,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // LYRICS CARD
                Card(
                  elevation: 5,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lyrics, color: Colors.red),

                            SizedBox(width: 10),

                            Text(
                              "Lyrics",

                              style: TextStyle(
                                fontSize: 22,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const Divider(),

                        Text(
                          lagu.lirik,

                          style: const TextStyle(fontSize: 18, height: 1.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        bottomNavigationBar: BottomAppBar(
          color: const Color.fromARGB(255, 155, 19, 28),

          child: SizedBox(
            height: 80,

            child: Row(
              children: [
                // NAMA & KELAS
                Expanded(
                  flex: 2,

                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),

                    child: Text(
                      'Nama: ${mahasiswa.nama}\n'
                      'Kelas: ${mahasiswa.kelas}',

                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),

                // BUTTON MUSIC CENTER
                Expanded(
                  flex: 1,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous,

                          color: Colors.white,

                          size: 32,
                        ),

                        onPressed: () {},
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.play_arrow,

                          color: Colors.white,

                          size: 32,
                        ),

                        onPressed: () {},
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.pause,

                          color: Colors.white,

                          size: 32,
                        ),

                        onPressed: () {},
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.skip_next,

                          color: Colors.white,

                          size: 32,
                        ),

                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
