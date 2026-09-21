import 'package:flutter/material.dart';
import 'package:camera/camera.dart';



class Kamera extends StatefulWidget {


  final CameraDescription camera;


  const Kamera({

    super.key,

    required this.camera,

  });



  @override
  State<Kamera> createState()=> _KameraState();

}



class _KameraState extends State<Kamera>{


  late CameraController controller;

  late Future<void> initializeControllerFuture;



  @override

  void initState(){

    super.initState();


    controller = CameraController(

      widget.camera,

      ResolutionPreset.high,

    );


    initializeControllerFuture = controller.initialize();

  }




  @override

  void dispose(){

    controller.dispose();

    super.dispose();

  }





  Future<void> takePhoto() async{


    try{


      await initializeControllerFuture;


      final image = await controller.takePicture();



      print("Foto tersimpan : ${image.path}");



    }catch(e){

      print(e);

    }


  }





  @override

  Widget build(BuildContext context){


    return Scaffold(


      appBar: AppBar(

        title: const Text("Kamera Belakang"),

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


        child: const Icon(Icons.camera_alt),


      ),



    );


  }


}