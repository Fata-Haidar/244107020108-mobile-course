import 'package:flutter/material.dart';
import 'package:camera/camera.dart';



class Kamera1 extends StatefulWidget {


  final CameraDescription camera;



  const Kamera1({

    super.key,

    required this.camera,

  });



  @override

  State<Kamera1> createState()=> _Kamera1State();


}




class _Kamera1State extends State<Kamera1>{


  late CameraController controller;

  late Future<void> initializeControllerFuture;




  @override

  void initState(){

    super.initState();



    controller = CameraController(

      widget.camera,

      ResolutionPreset.medium,

    );



    initializeControllerFuture = controller.initialize();


  }




  @override

  void dispose(){

    controller.dispose();

    super.dispose();

  }




  Future<void> takePhoto() async{


    await initializeControllerFuture;


    final image = await controller.takePicture();



    print("Foto kamera depan : ${image.path}");


  }




  @override

  Widget build(BuildContext context){


    return Scaffold(


      appBar: AppBar(

        title: const Text("Kamera Depan"),

      ),



      body: FutureBuilder(


        future: initializeControllerFuture,


        builder:(context,snapshot){


          if(snapshot.connectionState == ConnectionState.done){


            return CameraPreview(controller);


          }



          return const Center(

            child:CircularProgressIndicator(),

          );


        },


      ),



      floatingActionButton: FloatingActionButton(


        onPressed: takePhoto,


        child: const Icon(Icons.camera),


      ),


    );

  }


}