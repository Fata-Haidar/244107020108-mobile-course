import 'package:flutter/material.dart';



class MyMainPage extends StatelessWidget {


  const MyMainPage({

    super.key,

    required this.title,

  });



  final String title;




  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar: AppBar(

        title: Text(title),

      ),



      body: Center(


        child: ElevatedButton(


          onPressed: (){


            Navigator.pushNamed(

              context,

              '/camera',

            );


          },



          child: const Text(

            'Open Camera',

          ),


        ),


      ),



    );


  }



}