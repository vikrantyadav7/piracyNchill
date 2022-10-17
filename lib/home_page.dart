import 'dart:io' as files;
import 'package:mttv/playout.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as user;
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'authentication.dart';
import 'package:better_player/better_player.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.sourceUrl, required this.subtitleUrl}) : super(key: key);
final String sourceUrl;
final String subtitleUrl;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  drive.FileList? list;
  FileList? some;
  List<File>? somess;
 String? fileId ;
  DriveApi? driveApi;
 drive.File? file;

  bool failed = false;

  // Future<void> _incrementCounter() async {
  //
  //
  //   final googleSignIn =
  //   signIn.GoogleSignIn.standard(scopes: [DriveApi.driveFileScope,DriveApi.driveScope,DriveApi.driveAppdataScope,DriveApi.driveScriptsScope]);
  //   final signIn.GoogleSignInAccount? accounts = await googleSignIn.signOut();
  //   final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
  //
  //   print("User account $account");
  //   final authHeaders = await account!.authHeaders;
  //   final authenticateClient = GoogleAuthClient(authHeaders);
  //    driveApi = drive.DriveApi(authenticateClient);
  //
  //   // final Stream<List<int>> mediaStream = Future.value([104, 105]).asStream();
  //   // var media = new drive.Media(mediaStream, 2);
  //   // var driveFile = new drive.File();
  //   // driveFile.name = "hello_world.txt";
  //   // final result = await driveApi!.files.create(driveFile, uploadMedia: media);
  //   // print("Upload result: $result ${result.exportLinks?.isNotEmpty}  ${result.webViewLink}  ${result.size}  ${result.name}  ${result.iconLink}  ${result.driveId}");
  //   final somes = await driveApi!.files.list();
  //    somess = somes.files as List<File>;
  //    setState(() {
  //
  //    });
  //   for(var i in somess!){
  //     print(i.exportLinks);
  //   }
  // }
 late BetterPlayerController _betterPlayerController ;

 initialize()async{
   BetterPlayerConfiguration betterPlayerConfiguration =
   BetterPlayerConfiguration(
     autoPlay: true,
     aspectRatio: 16 / 9,
     fit: BoxFit.fitWidth,
     subtitlesConfiguration: const BetterPlayerSubtitlesConfiguration(
       fontSize: 20,
       fontColor: Colors.white,
     ),
     autoDetectFullscreenAspectRatio: true,
     allowedScreenSleep: false,
     controlsConfiguration :
     BetterPlayerControlsConfiguration(
         enableFullscreen: true,
         playerTheme: BetterPlayerTheme.custom,
         // backgroundColor: Colors.white,
         customControlsBuilder:
             (controller, onControlsVisibilityChanged){
           return
             CustomControlsWidget(
               controller: controller,
               onControlsVisibilityChanged:
               onControlsVisibilityChanged,
             );}
     ),

   );
   print("THIS IS ${widget.sourceUrl}");
   BetterPlayerDataSource dataSource = BetterPlayerDataSource(
     BetterPlayerDataSourceType.network,
     // "https://dai.google.com/linear/hls/pb/event/Sid4xiTQTkCT1SLu6rjUSQ/stream/34753d11-cb6c-41b0-bbf4-e30e1d2310ce:SIN2/variant/ea524505d39e73f6a2da30bf0adce261/bandwidth/3073312.m3u8",
     'https://dl.dropboxusercontent.com/s/${widget.sourceUrl}',
     useAsmsSubtitles: true,
     // liveStream: true,
     // 'https://dl.dropboxusercontent.com/s/16q5f9e0vzochcw/%5B60FPS%5D.Fantastic.Beasts.The.Secrets.of.Dumbledore.2022.1080p.HMAX.WEBRip.HLG.H.265.%5BEng%2BHin%5D.Esub.Homelander.mkv?dl=0',
     // subtitles: BetterPlayerSubtitlesSource.single(
     //   name: "English",
     //     type: BetterPlayerSubtitlesSourceType.network,
     //   selectedByDefault: true,
     //   url: widget.subtitleUrl
     //   // url: "https://www.opensubtitles.com/download/DBA9D04D65A62F6D80579D4587079C89135C664A0EB882513B98B77392EEABDAB62F18E9E2F0C8DC55EC87B402B31029D889668F89EE73749B5ECB293B798DEA056FBB1331B3C9F1F71E27779A2A4E4A1A1956AAA5471EFCDC0BD906C74C6D59AC5A3C918CBE72FAB70BCADFCBA4262A64B0832CD32053966BF894CCC2B4711CFE4E9D86B936759A55B17C832D114B9FF58CE9FA5C459C9FB3A31D9AE8CE5E09FF381DA69279116A8749D09FF6B14344B6FB9D3570B6134D73CF8C0D06C9AF2B59BC0C96306E45ED82CDA4367CE318B3045478BE073E2EA8893CED4B1BBA4F21EDF95764C7ED9034DFE55986A97A98AA7F2F739B37F8729F4F27EAA50FA6B2C7E4D4B4E33771D9E14393236F1F135D5EF38A00111015781102AE59FE5E9C6BB8658F44DB8DA89FAF1118D08113963C5B/subfile/Fantastic.Beasts.The.Secrets.of.Dumbledore.2022.1080p.HMAX.WEB-DL.DDP5.1.Atmos.x264-EVO.srt",
     //
     // ),
   );
   _betterPlayerController.setupDataSource(dataSource).then((w) {
     print('VEdio loeded ');
   }).catchError((onError){
     print(onError.toString());
     setState(() {
       failed = true;
     });
   });
 }


  @override
  void initState() {

    BetterPlayerConfiguration betterPlayerConfiguration =
      BetterPlayerConfiguration(
        autoPlay: true,
      aspectRatio: 16 / 9,
      fit: BoxFit.fitWidth,
        subtitlesConfiguration: const BetterPlayerSubtitlesConfiguration(
          fontSize: 20,
          fontColor: Colors.white,
        ),
      autoDetectFullscreenAspectRatio: true,
      allowedScreenSleep: false,
      controlsConfiguration :
      BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          playerTheme: BetterPlayerTheme.custom,
          // backgroundColor: Colors.white,
          customControlsBuilder:
              (controller, onControlsVisibilityChanged){
            return
              CustomControlsWidget(
                controller: controller,
                onControlsVisibilityChanged:
                onControlsVisibilityChanged,
              );}
      ),

    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      // "https://dai.google.com/linear/hls/pb/event/Sid4xiTQTkCT1SLu6rjUSQ/stream/34753d11-cb6c-41b0-bbf4-e30e1d2310ce:SIN2/variant/ea524505d39e73f6a2da30bf0adce261/bandwidth/3073312.m3u8",
      'https://dl.dropboxusercontent.com/s/${widget.sourceUrl}',
      useAsmsSubtitles: true,
      // liveStream: true,
      // 'https://dl.dropboxusercontent.com/s/16q5f9e0vzochcw/%5B60FPS%5D.Fantastic.Beasts.The.Secrets.of.Dumbledore.2022.1080p.HMAX.WEBRip.HLG.H.265.%5BEng%2BHin%5D.Esub.Homelander.mkv?dl=0',
      // subtitles: BetterPlayerSubtitlesSource.single(
      //   name: "English",
      //     type: BetterPlayerSubtitlesSourceType.network,
      //   selectedByDefault: true,
      //   url: widget.subtitleUrl
      //   // url: "https://www.opensubtitles.com/download/DBA9D04D65A62F6D80579D4587079C89135C664A0EB882513B98B77392EEABDAB62F18E9E2F0C8DC55EC87B402B31029D889668F89EE73749B5ECB293B798DEA056FBB1331B3C9F1F71E27779A2A4E4A1A1956AAA5471EFCDC0BD906C74C6D59AC5A3C918CBE72FAB70BCADFCBA4262A64B0832CD32053966BF894CCC2B4711CFE4E9D86B936759A55B17C832D114B9FF58CE9FA5C459C9FB3A31D9AE8CE5E09FF381DA69279116A8749D09FF6B14344B6FB9D3570B6134D73CF8C0D06C9AF2B59BC0C96306E45ED82CDA4367CE318B3045478BE073E2EA8893CED4B1BBA4F21EDF95764C7ED9034DFE55986A97A98AA7F2F739B37F8729F4F27EAA50FA6B2C7E4D4B4E33771D9E14393236F1F135D5EF38A00111015781102AE59FE5E9C6BB8658F44DB8DA89FAF1118D08113963C5B/subfile/Fantastic.Beasts.The.Secrets.of.Dumbledore.2022.1080p.HMAX.WEB-DL.DDP5.1.Atmos.x264-EVO.srt",
      //
      // ),
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource).then((w) {
      print('VEdio loeded ');
    }).catchError((onError){
       print(onError.toString());
       setState(() {
         failed = true;
       });
    });
    super.initState();
    // _videoPlayerController.initialize();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('momo'),),
      body: Column( mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _betterPlayerController.videoPlayerController!.value.hasError ? _buildErrorWidget() :
          BetterPlayer(controller: _betterPlayerController)
        ],


      )
    );
  }





  Widget _buildErrorWidget() {
    final errorBuilder =
        _betterPlayerController.betterPlayerConfiguration.errorBuilder;
    if (errorBuilder != null) {
      return errorBuilder(
          context,
          _betterPlayerController
              .videoPlayerController!.value.errorDescription);
    } else {
      const textStyle = TextStyle(color: Colors.white);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning,
              color:  Colors.white,
              size: 42,
            ),
            Text(
              _betterPlayerController.translations.generalDefaultError,
              style: textStyle,
            ),
            if (_betterPlayerController.betterPlayerControlsConfiguration.enableRetry)
              TextButton(
                onPressed: () {
                  _betterPlayerController.retryDataSource();
                },
                child: Text(
                  _betterPlayerController.translations.generalRetry,
                  style: textStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              )
          ],
        ),
      );
    }


  }

}
