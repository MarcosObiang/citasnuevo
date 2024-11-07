import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../../../main.dart';

class CameraWidget extends StatefulWidget {
  String faceFileName;
  String gestureName;

  CameraWidget({
    required this.faceFileName,
    required this.gestureName,
  });

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController cameraController;
  bool showPreviewPicture = false;
  Uint8List? verificationImage;
  bool faceIsVisible = false;
  bool handIsVisible = false;
  late bool showInstructions;
  PageController instructioinsPageController = PageController();
  @override
  void initState() {
    super.initState();
    showInstructions = true;
    cameraController = CameraController(cameras[0], ResolutionPreset.max);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  void initializeCamera({required CameraDescription cameraDescription}) {
    CameraDescription description =
        cameras.firstWhere((element) => element.name == cameraDescription.name);

    cameraController = CameraController(description, ResolutionPreset.max);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  void disposeCameraResources() {
    // cameraController.dispose();

    cameraController.stopImageStream();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController controller = cameraController;

    // App state changed before we got the chance to initialize.
    if (!controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // onNewCameraSelected(controller.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              capturePictureScreen(context),
              showInstructions ? instructionsScreen() : Container(),
              showPreviewPicture ? previewPictureScreen() : Container(),
            ],
          ),
        ));
  }

  Widget capturePictureScreen(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              CameraPreview(cameraController),
              Container(
                height: 300.h,
                width: 300.h,
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Container(
                        height: 250.h,
                        width: 250.h,
                        child: SvgPicture.asset(widget.gestureName),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            child: Column(
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      captureImage();
                    },
                    icon: Icon(LineAwesomeIcons.camera),
                    label: Text("Capturar")),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                        onPressed: () {
                          showInstructions = true;
                          setState(() {});
                        },
                        icon: Icon(Icons.help),
                        label: Text("Instrucciones")),
                    TextButton.icon(
                        onPressed: () {
                          showCameraOptions();
                        },
                        icon: Icon(Icons.change_circle),
                        label: Text("Cambiar camara")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget previewPictureScreen() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Container(
                    child: Image.memory(verificationImage!),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Color.fromARGB(101, 0, 0, 0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              "Comprueba que salga claramente tu cara",
                              style: GoogleFonts.lato(
                                  color: Colors.white, fontSize: 50.sp),
                            ),
                          ),
                          Divider(
                            color: Colors.transparent,
                            height: 50.h,
                          ),
                          Container(
                            child: Text(
                              "Comprueba que salga tu mano imitando el gesto que muestran las flechas",
                              style: GoogleFonts.lato(
                                  color: Colors.white, fontSize: 50.sp),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        color: Colors.white,
                                      ),
                                      Container(
                                        height: 200.h,
                                        width: 200.h,
                                        child: SvgPicture.asset(
                                          widget.gestureName,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                            onPressed: () {
                              showInstructions = true;
                              setState(() {});
                            },
                            icon: Icon(Icons.help),
                            label: Text("Instrucciones")),
                        TextButton.icon(
                            onPressed: () {
                              showPreviewPicture = false;
                              handIsVisible = false;
                              faceIsVisible = false;
                              setState(() {});
                            },
                            icon: Icon(LineAwesomeIcons.retro_camera),
                            label: Text("Nueva foto")),
                      ],
                    ),
                    TextButton.icon(
                        onPressed: () {
                          Navigator.pop(
                              startKey.currentContext as BuildContext);

                          if (verificationImage != null) {
                            Dependencies.verificationPresentation
                                .setUserVerificationPicture(
                                    byteData: verificationImage as Uint8List);
                          }
                        },
                        icon: Icon(LineAwesomeIcons.arrow_right),
                        label: Text("Continuar")),
                  ],
                ),
              )
            ],
          ),
          faceIsVisible == false && handIsVisible == false
              ? faceConfirmationScreen()
              : Container(),
          handIsVisible == false && faceIsVisible == true
              ? handConfirmationScreen()
              : Container(),
        ],
      ),
    );
  }

  Container faceConfirmationScreen() {
    return Container(
      width: ScreenUtil.defaultSize.width,
      color: Color.fromARGB(167, 0, 0, 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.transparent),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "¿Tu cara es perfectamente visible?",
                    style:
                        GoogleFonts.lato(color: Colors.white, fontSize: 60.sp),
                  ),
                )),
            Divider(
              height: 200.h,
              color: Colors.transparent,
            ),
            TextButton.icon(
                onPressed: () {
                  faceIsVisible = true;
                  setState(() {});
                },
                icon: Icon(Icons.help),
                label: Text(
                  "Si, es visible",
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
                )),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
            TextButton.icon(
                onPressed: () {
                  showPreviewPicture = false;
                  handIsVisible = false;
                  faceIsVisible = false;
                  setState(() {});
                },
                icon: Icon(LineAwesomeIcons.retro_camera),
                label: Text(
                  "No lo es",
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
                )),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Container handConfirmationScreen() {
    return Container(
      width: ScreenUtil.defaultSize.width,
      color: Color.fromARGB(167, 0, 0, 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.transparent),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "¿Tu mano sale imitando el gesto?",
                    style:
                        GoogleFonts.lato(color: Colors.white, fontSize: 60.sp),
                  ),
                )),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Gesto:",
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 60.sp),
                ),
                Container(
                  height: 200.h,
                  width: 200.h,
                  child: SvgPicture.asset(widget.gestureName),
                ),
              ],
            ),
            Divider(
              height: 200.h,
              color: Colors.transparent,
            ),
            TextButton.icon(
                onPressed: () {
                  handIsVisible = true;
                  setState(() {});
                },
                icon: Icon(Icons.help),
                label: Text(
                  "Si, es visible",
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
                )),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
            TextButton.icon(
                onPressed: () {
                  showPreviewPicture = false;
                  handIsVisible = false;
                  faceIsVisible = false;
                  setState(() {});
                },
                icon: Icon(LineAwesomeIcons.retro_camera),
                label: Text(
                  "No ",
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
                )),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Container instructionsScreen() {
    return Container(
      color: Color.fromARGB(212, 0, 0, 0),
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: EdgeInsets.all(100.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Text(
                "Instrucciones",
                style: GoogleFonts.lato(color: Colors.white, fontSize: 70.sp),
              ),
            ),
            Flexible(
              flex: 8,
              fit: FlexFit.tight,
              child: PageView(
                controller: instructioinsPageController,
                children: [
                  zeroInstruction(),
                  firstInstruction(),
                  secondInstructionPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column secondInstructionPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Text(
            "Alguna de tus manos debe salir imitanto el gesto que te indicamos con las flechas",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 60.sp),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
            Column(
              children: [
                Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                ),
                Container(
                  height: 200.h,
                  width: 200.h,
                  child: SvgPicture.asset(
                    widget.gestureName,
                  ),
                ),
                Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
              ],
            ),
            Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () {
                  instructioinsPageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                },
                child: Text("Atras")),
            ElevatedButton(
                onPressed: () {
                  showInstructions = false;
                  setState(() {});
                },
                child: Text("Entendido")),
          ],
        ),
      ],
    );
  }

  Widget firstInstruction() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 200.h,
          width: 200.h,
          child: SvgPicture.asset(
            widget.faceFileName,
          ),
        ),
        Container(
          child: Text(
            "- Tu cara debe ser la unica en la imagen, y claramente visible",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 60.sp),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () {
                  instructioinsPageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                },
                child: Text("Atras")),
            ElevatedButton(
                onPressed: () {
                  instructioinsPageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                },
                child: Text("Siguiente")),
          ],
        ),
      ],
    );
  }

  Column zeroInstruction() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Text(
            "- Debes tomarte una foto ahora para que sepamos que eres quien dices ser",
            style: GoogleFonts.lato(color: Colors.white, fontSize: 60.sp),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              instructioinsPageController.nextPage(
                  duration: Duration(milliseconds: 300), curve: Curves.easeIn);
            },
            child: Text("Siguiente")),
      ],
    );
  }

  void captureImage() async {
    XFile file = await cameraController.takePicture();
    //   Uint8List byte =
    //     await FlutterImageCompress.compressWithList(await file.readAsBytes());

    //   verificationImage = byte;
    showPreviewPicture = true;
    setState(() {});
  }

  void showCameraOptions() {
    List<Widget> simpleDialogOptionList = [];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          for (int i = 0; i < cameras.length; i++) {
            late String cameraDirection;

            if (cameras[i].lensDirection.name == "front") {
              cameraDirection = "Frontal";
            } else {
              cameraDirection = "Trasera";
            }
            simpleDialogOptionList.add(SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);

                // disposeCameraResources();
                initializeCamera(cameraDescription: cameras[i]);
              },
              child: Text("Camara ${i + 1} ($cameraDirection)"),
            ));
          }

          return SimpleDialog(
            title: Text("Selecciona una camara"),
            children: simpleDialogOptionList,
          );
        });
  }
}
