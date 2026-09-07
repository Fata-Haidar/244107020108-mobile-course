import 'package:flutter/material.dart';
import 'mahasiswa.dart';
import 'lagu.dart';

void main() {
  runApp(const FataHaidarAly());
}

class FataHaidarAly extends StatelessWidget {
  const FataHaidarAly({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final mahasiswa = Mahasiswa(nama: 'Fata Haidar Aly', umur: 21, kelas: 'TI-3C');
    final lagu = Lagu(judul: 'Moon', Group: 'Baby Monster');
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple),),
      home: Scaffold(
        appBar: AppBar(backgroundColor: const Color.fromARGB(255, 155, 19, 28), centerTitle: true, title: Text('${lagu.judul} - ${lagu.Group}')),
        body: Stack(
          children: [
            const Positioned(
              top: 20,
              left: 20,
              child: Text('Im the moon, boreumdal tteuneun bam on the loose\nZa-la-bim,za-la-bam, za-la-boom\nI shine so bright in the gloom\n Im the moon, Im the moon, Im the moon', style: const TextStyle(fontSize: 24)),
            ),
           const Positioned(
              bottom: 20,
              right: 20,
              child: Text('Fog thickens, night vision\nWhere we gonna end up is unwritten\nGrave digger, go figure\nBut if youre killing my mood, good riddance\nIce in my veins\nYoure gonna need to keep up with the pace,\n deo ppalli deo nopi\nWhen you, when you, when you at the crack of dawn\nYou keep on raving on, you keep on raving on, uh', style: const TextStyle(fontSize: 24)),
            ), 
            const Positioned(
              bottom: 20,
              left: 20,
              child: Image(image: AssetImage('https://picsum.photos/200/300'), width: 200, height: 200),
            ),
          ]
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromARGB(255, 155, 19, 28),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nama: ${mahasiswa.nama} Kelas: ${mahasiswa.kelas} ', style: const TextStyle(color: Colors.white)),
               IconButton(
      icon: const Icon(Icons.skip_previous, color: Colors.white),
      onPressed: () {},
    ),
    IconButton(
      icon: const Icon(Icons.play_arrow, color: Colors.white),
      onPressed: () {},
    ),
    IconButton(
      icon: const Icon(Icons.pause, color: Colors.white),
      onPressed: () {},
    ),
    IconButton(
      icon: const Icon(Icons.skip_next, color: Colors.white),
      onPressed: () {},
    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

