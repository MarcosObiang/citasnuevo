import 'dart:async';


import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorVideollamadas.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../main.dart';

class CallPage extends StatefulWidget {
  static FirebaseFirestore basedatos = FirebaseFirestore.instance;
  static bool canalIniciado = false;
  final Map<String, dynamic> datosLLamada;
  final String usuario;
  static bool seMuestra;


  /// non-modifiable channel name of the page
  final String channelName;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  CallPage(
      {Key key,
      @required this.channelName,
      @required this.role,
      @required this.datosLLamada,
      @required this.usuario});

  @override
  CallPageState createState() => CallPageState();
}

class CallPageState extends State<CallPage> with RouteAware{
  static final _users = <int>[];
  final _infoStrings = <String>[];
  int segundosVideo=Usuario.esteUsuario.minutosRestantesVideoChat*60;
  bool muted = false;
  var formatoTiempo=new DateFormat("HH:mm:ss");
  Timer cronometroVideoPantalla;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    routeObserver.unsubscribe(this);
    if(cronometroVideoPantalla.isActive){
      cronometroVideoPantalla.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }
 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }



    @override
  void didPush() {
   CallPage.seMuestra=true;
    // Route was pushed onto navigator and is now topmost route.
  }

  @override
  void didPopNext() {
    CallPage.seMuestra=false;
    // Covering route was popped off the navigator.
  }




  void iniciarCuentaAtrasVideo(){
    int contadorSegundos=0;


     cronometroVideoPantalla=new Timer.periodic(Duration(seconds:1), (timer) {
      setState(() {

      });
      contadorSegundos+=1;
      segundosVideo-=1;
      if(contadorSegundos==60){
        contadorSegundos=0;
        Usuario.esteUsuario.minutosRestantesVideoChat-=1;
       // FirebaseFirestore.instance.collection("usuarios").doc(Usuario.esteUsuario.idUsuario).update({"minutosVideo":FieldValue.increment(-1)});
      }

    });
  }



  Future<void> initialize() async {
    if (VideoLlamada.idAplicacion.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = Size(640, 320);
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(VideoLlamada.idAplicacion);
    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await AgoraRtcEngine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
        VideoLlamada.ponerStatusConectado();
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        VideoLlamada.ponerStatusOcupado();
        final info = 'onJoinChannel: $channel, uid: $uid';
        CallPage.canalIniciado = true;
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        Navigator.pop(context);
        VideoLlamada.ponerStatusConectado();
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      iniciarCuentaAtrasVideo();
      setState(() {
        final info = 'userJoined: $uid';
        print("Usuario en el canal^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        VideoLlamada.ponerStatusConectado();
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        Navigator.pop(context);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(AgoraRenderWidget(0, local: true, preview: true));
    }
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
             
              onCallEnd(context);
              VideoLlamada.colgarLLamadaVideo(
                  widget.usuario, widget.datosLLamada);

              print(widget.datosLLamada);
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static void onCallEnd(BuildContext context) {
    Navigator.pop(context);
    CallPage.canalIniciado = false;
    print("LLamada colgada y rechazasda que triste");



    VideoLlamada.ponerStatusConectado();
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: <Widget>[

              _viewRows(),
            //  Text(formatoTiempo.format(DateTime(0,0,0,0,0,segundosVideo)),style: GoogleFonts.lato(fontSize:90.sp,color: Colors.red),),
              _panel(),
              Container(
                color: Colors.transparent,
                child: !CallPage.canalIniciado
                    ? Center(
                        child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.white),
                        height: ScreenUtil().setHeight(300),
                        width: ScreenUtil().setWidth(600),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            Text("Cargando llamada"),
                          ],
                        ),
                      ))
                    : null,
              ),
              _toolbar(),
            ],
          ),
        ),
      ),
    );
  }
}