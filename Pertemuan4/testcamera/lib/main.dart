import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'kamera.dart';
import 'kamera1.dart';


List<CameraDescription> cameras = [];


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(const MyApp());

}


class MyApp extends StatelessWidget {

  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: "Multi Camera",

      home: HomePage(),

    );

  }

}



class HomePage extends StatelessWidget {

  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: const Text("Camera App"),

      ),


      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,


          children: [


            ElevatedButton(

              child: const Text("Kamera Belakang"),

              onPressed: (){


                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context)=> Kamera(

                      camera: cameras.firstWhere(

                        (camera)=>

                        camera.lensDirection == CameraLensDirection.back,

                      ),

                    ),

                  ),

                );


              },

            ),



            ElevatedButton(

              child: const Text("Kamera Depan"),


              onPressed: (){


                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context)=> Kamera1(

                      camera: cameras.firstWhere(

                        (camera)=>

                        camera.lensDirection == CameraLensDirection.front,

                      ),

                    ),

                  ),

                );


              },

            ),


          ],

        ),

      ),

    );

  }

}