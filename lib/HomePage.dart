import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart'; // pacote para extrair texto de imagem
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tts/flutter_tts_web.dart';
import 'package:image_picker/image_picker.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String result = "olá, agora posso falar. fico muito feliz em poder concluir o objetivo deste aplicativo que fotografa, lê e fala.";
  File image;
  ImagePicker imagePicker = ImagePicker();
  FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  //******************************************
  //Método que recupera imagem de arquivo
  //******************************************

  captureFromGallery() async{
    PickedFile pickedFile = await imagePicker.getImage(source: ImageSource.gallery,
    maxWidth: 1800,
    maxHeight: 1800);
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    setState(() {
      image;
      textFromImage();   //Extraindo texto da imagem
    }
    );
  }

  //************************************************************
  // Método que captur a imagem pela câmera do Smartphone
  //************************************************************

  captureFromCamera() async{
    PickedFile pickedFile = await imagePicker.getImage(source: ImageSource.camera);
    image = File(pickedFile.path);
    result = "";
    setState(() {
      image;
      textFromImage();    //Extraindo texto da imagem
    }
    );
  }


  // Método que pega a imagem e captura a parte escrita

  textFromImage() async{
    final FirebaseVisionImage firebaseVisionImage = FirebaseVisionImage.fromFile(image);
    final TextRecognizer recognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await recognizer.processImage(firebaseVisionImage);
    result = "";
    setState(() {
      for(TextBlock block in visionText.blocks){
        final String txt = block.text;
        for(TextLine line in block.lines){
          for(TextElement element in line.elements){
            result += element.text + " ";
          }
        }
        result += "\n\n";  // Inclui mudança de linha no texto
      }
    }
    );
  }

  @override
  initState(){
    super.initState();
    initTts();
    imagePicker = ImagePicker();
  }
  //***************************
  // Coeçando a falar
  //***************************

  initTts(){
    flutterTts = FlutterTts();
    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((message) {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });
  }

  Future fala() async {
    await flutterTts.setVolume(0.5);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    if (result != null){
      if (result.isNotEmpty) {
        var controle = await flutterTts.speak(result);
        if (controle == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover),
        ),

        //***************************************************************
        // Painel onde será escrito o que foi capturado pela câmera
        //***************************************************************

        child: Column(
          children: [
            SizedBox(width: 100.0),

            Container(
              height: 330.0,
                width: 320.0,
              margin: EdgeInsets.only(top: 70.0),
              padding: EdgeInsets.only(left: 28.0,bottom: 5.0, right: 18.0),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    result,
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),

              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/note.jpg'), fit: BoxFit.cover,
                ),
              ),
            ),

            //***************************************
            // Botão para capturar a imgem
            //***************************************

            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top:20, left: 40),
                  height: 200,
                  width: 150,
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          Align(
                            child: Image.asset('assets/images/pin2.png',
                              height: 200.0,
                              width: 160.0,
                            ),
                          ),
                        ],
                      ),
                      Align(
                        child: TextButton(
                          onPressed: (){
                            captureFromCamera();
                          },
                          onLongPress: (){
                            captureFromGallery();
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 25.0, right: 5),
                            child: image != null
                                ? Image.file(image,
                                width: 140.0,height: 162.0,fit: BoxFit.fill)
                                : Container(
                              width: 110.0,
                              height: 200.0,
                            child: Icon(
                                Icons.camera_alt,
                                size: 110.0,
                                color: Colors.indigo.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                //***************************
                // Botão para falar
                //***************************

                Container(
                  margin: EdgeInsets.only(left: 30),
                  color: Colors.white.withOpacity(.2),

                  height: 150,
                  width: 110,

                  child: IconButton(
                    icon: new Icon(Icons.record_voice_over, size: 100, color: Colors.green,), onPressed: (){ fala();},
                    //size: 130,
                    //  color: Colors.green,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
