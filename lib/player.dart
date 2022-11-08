import 'dart:async';
import 'dart:io' as files;
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Player extends StatefulWidget {
  const Player(
      {Key? key,
      required this.sourceUrl,
      required this.isSeries,
      required this.nextEpisodes,
      required this.name})
      : super(key: key);
  final String sourceUrl;
  final String name;
  final bool isSeries;
  final List nextEpisodes;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  bool failed = false;

  bool controlsNotVisible = false;

  late VlcPlayerController _videoPlayerController;

// "AIzaSyD-_6rtBFFc0FrFenom8DTAgjAnc7eJDok"

  Timer? _hideTimer;
  get() async {
    _videoPlayerController = VlcPlayerController.network(
      // "https://imdb-video.media-imdb.com/vi2696135961/hls-preview-bb8a0d3b-98ac-487b-893a-0170ef2bbd3b.m3u8",
      'https://dl.dropboxusercontent.com/s/${widget.sourceUrl}',
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
        ]),
        subtitle: VlcSubtitleOptions([
          VlcSubtitleOptions.boldStyle(false),
          VlcSubtitleOptions.fontSize(25.sp.toInt()),
          VlcSubtitleOptions.outlineColor(VlcSubtitleColor.white),
          VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
          // works only on externally added subtitles
          // VlcSubtitleOptions.color(VlcSubtitleColor.navy),
        ]),
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
    );
    // await _videoPlayerController.initialize().then((value) => print('done'));
    _videoPlayerController.addListener(listener);

    focusListeners();
  }

  @override
  void dispose() async {
    super.dispose();
    await _videoPlayerController.stopRendererScanning();
    await _videoPlayerController.dispose();
  }

String name = '';
List nextEpisodes= [];
  @override
  void initState() {
    get();
 name = widget.name;
 nextEpisodes= widget.nextEpisodes;
    super.initState();
  }

  void _getSubtitleTracks() async {
    if (!_videoPlayerController.value.isPlaying) return;

    var subtitleTracks = await _videoPlayerController.getSpuTracks();
    //
    if (subtitleTracks != null && subtitleTracks.isNotEmpty) {
      var selectedSubId = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Subtitle'),
            content: Container(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: subtitleTracks.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < subtitleTracks.keys.length
                          ? subtitleTracks.values.elementAt(index).toString()
                          : 'Disable',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < subtitleTracks.keys.length
                            ? subtitleTracks.keys.elementAt(index)
                            : -1,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
      if (selectedSubId != null)
        await _videoPlayerController.setSpuTrack(selectedSubId);
    }
  }

  cancelAndRestartTimer() {
    print("timec caellled");
    _hideTimer?.cancel();

    _startHideTimer();
  }

  void _startHideTimer() {
    if (controlsNotVisible) {
      return;
    }
    _hideTimer = Timer(const Duration(seconds: 5), () {
      controlsNotVisible = true;
    });
  }

  focusListeners() {
    audioTrackNodes.addListener(() {
      setState(() {
        (audioTrackNodes.hasFocus)
            ? audioTrackColor = Colors.black
            : audioTrackColor = Colors.white;
        if (audioTrackNodes.hasFocus) lastFocus = audioTrackNodes;
      });
      cancelAndRestartTimer();
    });
    playNode.addListener(() {
      setState(() {
        (playNode.hasFocus)
            ? playColor = Colors.black
            : playColor = Colors.white;
        if (playNode.hasFocus) lastFocus = playNode;
      });
      cancelAndRestartTimer();
    });
    subtitleNode.addListener(() {
      setState(() {
        (subtitleNode.hasFocus)
            ? subtitleColor = Colors.black
            : subtitleColor = Colors.white;
        if (subtitleNode.hasFocus) {
          lastFocus = subtitleNode;
        }
      });
      cancelAndRestartTimer();
    });
    speedNode.addListener(() {
      setState(() {
        (speedNode.hasFocus)
            ? speedColor = Colors.black
            : speedColor = Colors.white;
        if (speedNode.hasFocus) lastFocus = speedNode;
      });

      cancelAndRestartTimer();
    });
    qualityNode.addListener(() {
      setState(() {
        (qualityNode.hasFocus)
            ? qualityColor = Colors.black
            : qualityColor = Colors.white;
      });
      cancelAndRestartTimer();
    });
    zoomNode.addListener(() {
      setState(() {
        (zoomNode.hasFocus)
            ? zoomColor = Colors.black
            : zoomColor = Colors.white;
        if (zoomNode.hasFocus) lastFocus = zoomNode;
      });
      cancelAndRestartTimer();
    });
    skipNextNode.addListener(() {
      setState(() {
        (skipNextNode.hasFocus)
            ? skipNextColor = Colors.black
            : skipNextColor = Colors.white;
        if (skipNextNode.hasFocus) lastFocus = skipNextNode;
      });
      cancelAndRestartTimer();
    });
    restartNode.addListener(() {
      setState(() {
        (restartNode.hasFocus)
            ? restartColor = Colors.black
            : restartColor = Colors.white;
        if (restartNode.hasFocus) lastFocus = restartNode;
      });
      cancelAndRestartTimer();
    });

    progressNode.addListener(() {
      if (progressNode.hasFocus) lastFocus = progressNode;
    });
  }

  Color audioTrackColor = Colors.white;
  Color subtitleColor = Colors.white;
  Color speedColor = Colors.white;
  Color playColor = Colors.white;
  Color fullScreenColor = Colors.white;
  Color progressColor = Colors.white;
  Color qualityColor = Colors.white;
  Color zoomColor = Colors.white;
  Color skipNextColor = Colors.white;
  Color restartColor = Colors.white;

  List<double> playbackSpeeds = [0.5, 1.0, 2.0];
  int playbackSpeedIndex = 1;

  double sliderValue = 0.0;
  double volumeValue = 50;
  String position = '';
  String duration = '';
  int numberOfCaptions = 0;
  int numberOfAudioTracks = 0;
  bool validPosition = false;
  void _getAudioTracks() async {
    if (!_videoPlayerController.value.isPlaying) return;

    var audioTracks = await _videoPlayerController.getAudioTracks();
    //
    if (audioTracks != null && audioTracks.isNotEmpty) {
      var selectedAudioTrackId = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Audio'),
            content: Container(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: audioTracks.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < audioTracks.keys.length
                          ? audioTracks.values.elementAt(index).toString()
                          : 'Disable',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < audioTracks.keys.length
                            ? audioTracks.keys.elementAt(index)
                            : -1,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
      if (selectedAudioTrackId != null) {
        await _videoPlayerController.setAudioTrack(selectedAudioTrackId);
      }
    }
  }

  void _cyclePlaybackSpeed() async {
    playbackSpeedIndex++;
    if (playbackSpeedIndex >= playbackSpeeds.length) {
      playbackSpeedIndex = 0;
    }
    return await _videoPlayerController
        .setPlaybackSpeed(playbackSpeeds.elementAt(playbackSpeedIndex));
  }

  void listener() async {
    if (!mounted) return;
    //
    if (_videoPlayerController.value.isInitialized) {
      var oPosition = _videoPlayerController.value.position;
      var oDuration = _videoPlayerController.value.duration;
      if (oPosition != null && oDuration != null) {
        if (oDuration.inHours == 0) {
          var strPosition = oPosition.toString().split('.')[0];
          var strDuration = oDuration.toString().split('.')[0];
          position =
              "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
          duration =
              "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
        } else {
          position = oPosition.toString().split('.')[0];
          duration = oDuration.toString().split('.')[0];
        }
        validPosition = oDuration.compareTo(oPosition) >= 0;
        sliderValue = validPosition ? oPosition.inSeconds.toDouble() : 0;
      }
      numberOfCaptions = _videoPlayerController.value.spuTracksCount;
      numberOfAudioTracks = _videoPlayerController.value.audioTracksCount;
      // update recording blink widget
      // if (_videoPlayerController.value.isRecording && _videoPlayerController.value.isPlaying) {
      //   if (DateTime.now().difference(lastRecordingShowTime).inSeconds >= 1) {
      //     lastRecordingShowTime = DateTime.now();
      //     recordingTextOpacity = 1 - recordingTextOpacity;
      //   }
      // } else {
      //   recordingTextOpacity = 0;
      // }
      // check for change in recording state
      // if (isRecording != _controller.value.isRecording) {
      //   isRecording = _controller.value.isRecording;
      //   if (!isRecording) {
      //     if (widget.onStopRecording != null) {
      //       widget.onStopRecording(_controller.value.recordPath);
      //     }
      //   }
      // }
      setState(() {});
    }
  }

  void _getRendererDevices() async {
    var castDevices = await _videoPlayerController.getRendererDevices();
    //
    if (castDevices != null && castDevices.isNotEmpty) {
      var selectedCastDeviceName = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Display Devices'),
            content: Container(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: castDevices.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < castDevices.keys.length
                          ? castDevices.values.elementAt(index).toString()
                          : 'Disconnect',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < castDevices.keys.length
                            ? castDevices.keys.elementAt(index)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
      await _videoPlayerController.castToRenderer(selectedCastDeviceName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Display Device Found!')));
    }
  }

  void _onSliderPositionChanged(double progress) {
    setState(() {
      sliderValue = progress.floor().toDouble();
    });
    //convert to Milliseconds since VLC requires MS to set time
    _videoPlayerController.setTime(sliderValue.toInt() * 1000);
  }

  // void _createCameraImage() async {
  //   var snapshot = await _controller.takeSnapshot();
  //   _overlayEntry.remove();
  //   _overlayEntry = _createSnapshotThumbnail(snapshot);
  //   Overlay.of(context)?.insert(_overlayEntry);
  // }
  final FocusNode speedNode = FocusNode();
  final FocusNode playNode = FocusNode();
  final FocusNode progressNode = FocusNode();
  final FocusNode audioTrackNodes = FocusNode();
  final FocusNode subtitleNode = FocusNode();
  final FocusNode qualityNode = FocusNode();
  final FocusNode zoomNode = FocusNode();
  final FocusNode skipNextNode = FocusNode();
  final FocusNode restartNode = FocusNode();
  FocusNode lastFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: qualityNode,
      onKey: (s) {
        print(s);
        setState(() {
          controlsNotVisible = false;
        });
        if (!_hideTimer!.isActive) {
          zoomNode.unfocus();
          lastFocus.requestFocus();
        }

        cancelAndRestartTimer();
      },
      child: Scaffold(
          backgroundColor: Colors.transparent,
          bottomSheet: Visibility(
            visible: !controlsNotVisible,
            child: _videoPlayerController.value.playingState
                        .toString()
                        .split('.')[1] ==
                    "buffering"
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : SizedBox(
                    height: 100.h,
                    width: 100.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(name),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 60.w,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    // alignment: WrapAlignment.spaceAround,
                                    children: [
                                      _videoPlayerController.value.isBuffering
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: playColor == Colors.white
                                                    ? Colors.white.withOpacity(
                                                        controlsNotVisible
                                                            ? 0.0
                                                            : 0.2)
                                                    : Colors.white.withOpacity(
                                                        controlsNotVisible
                                                            ? 0.0
                                                            : 1),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: IconButton(
                                                  splashRadius: 1,
                                                  focusNode: playNode,
                                                  autofocus: true,
                                                  onPressed: () {
                                                    cancelAndRestartTimer();
                                                    print("play/paise");
                                                    setState(() {
                                                      if (_videoPlayerController
                                                          .value.isPlaying) {
                                                        _videoPlayerController
                                                            .pause();
                                                        // if(timer != null && timer!.isActive){
                                                        //   timer!.cancel();
                                                        // }
                                                      } else {
                                                        _videoPlayerController
                                                            .play();
                                                        // get();
                                                      }
                                                    });
                                                    cancelAndRestartTimer();
                                                  },
                                                  icon: Icon(
                                                    _videoPlayerController.value
                                                                .playingState
                                                                .toString()
                                                                .split(
                                                                    '.')[1] ==
                                                            "playing"
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    size: 30,
                                                    color:
                                                        playColor.withOpacity(
                                                            controlsNotVisible
                                                                ? 0.0
                                                                : 1),
                                                  )),
                                            ),
                                      widget.isSeries ?
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: skipNextColor == Colors.white
                                              ? Colors.white.withOpacity(
                                              controlsNotVisible
                                                  ? 0.0
                                                  : 0.2)
                                              : Colors.white.withOpacity(
                                              controlsNotVisible
                                                  ? 0.0
                                                  : 1),
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ),
                                        child: IconButton(
                                            splashRadius: 1,
                                            focusNode: skipNextNode,
                                            autofocus: true,
                                            onPressed: () async{
                                              print(nextEpisodes.first);
                                               setState(() {
                                                 name = nextEpisodes.first['name'];
                                               });
                                             await   _videoPlayerController.setMediaFromNetwork("https://dl.dropboxusercontent.com/s/${nextEpisodes.first['sourceUrl']}",hwAcc: HwAcc.full);
                                                    nextEpisodes.removeAt(0);
                                              cancelAndRestartTimer();
                                              setState(() {
                                              });
                                            },
                                            icon: Icon(
                                               Icons.skip_next,
                                              size: 30,
                                              color:
                                              skipNextColor.withOpacity(
                                                  controlsNotVisible
                                                      ? 0.0
                                                      : 1),
                                            )),
                                      ) :
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: restartColor == Colors.white
                                              ? Colors.white.withOpacity(
                                              controlsNotVisible
                                                  ? 0.0
                                                  : 0.2)
                                              : Colors.white.withOpacity(
                                              controlsNotVisible
                                                  ? 0.0
                                                  : 1),
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ),
                                        child: IconButton(
                                            splashRadius: 1,
                                            focusNode: restartNode,
                                            autofocus: true,
                                            onPressed: () {

                                              cancelAndRestartTimer();
                                            },
                                            icon: Icon(
                                               Icons.restart_alt_sharp,
                                              size: 30,
                                              color:
                                              restartColor.withOpacity(
                                                  controlsNotVisible
                                                      ? 0.0
                                                      : 1),
                                            )),
                                      ),
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: subtitleColor == Colors.white
                                              ? Colors.white.withOpacity(
                                                  controlsNotVisible
                                                      ? 0.0
                                                      : 0.2)
                                              : Colors.white.withOpacity(
                                                  controlsNotVisible ? 0.0 : 1),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Stack(
                                          children: [
                                            IconButton(
                                              focusNode: subtitleNode,
                                              autofocus: true,
                                              splashRadius: 1,
                                              // focusColor: Colors.white,
                                              // splashColor: Colors.white,
                                              tooltip: 'Get Subtitle Tracks',
                                              icon: const Icon(
                                                  Icons.closed_caption),
                                              color: subtitleColor.withOpacity(
                                                  controlsNotVisible ? 0.0 : 1),
                                              onPressed: _getSubtitleTracks,
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: IgnorePointer(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 1,
                                                    horizontal: 2,
                                                  ),
                                                  child: Text(
                                                    '$numberOfCaptions',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: audioTrackColor == Colors.white
                                              ? Colors.white.withOpacity(
                                                  controlsNotVisible
                                                      ? 0.0
                                                      : 0.2)
                                              : Colors.white.withOpacity(
                                                  controlsNotVisible ? 0.0 : 1),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Stack(
                                          children: [
                                            IconButton(
                                              splashRadius: 1,
                                              focusNode: audioTrackNodes,
                                              autofocus: true,
                                              tooltip: 'Get Audio Tracks',
                                              icon:
                                                  const Icon(Icons.audiotrack),
                                              color:
                                                  audioTrackColor.withOpacity(
                                                      controlsNotVisible
                                                          ? 0.0
                                                          : 1),
                                              onPressed: _getAudioTracks,
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: IgnorePointer(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 1,
                                                    horizontal: 2,
                                                  ),
                                                  child: Text(
                                                    '$numberOfAudioTracks',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: zoomColor == Colors.white
                                              ? Colors.white.withOpacity(
                                                  controlsNotVisible
                                                      ? 0.0
                                                      : 0.2)
                                              : Colors.white.withOpacity(
                                                  controlsNotVisible ? 0.0 : 1),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: IconButton(
                                            splashRadius: 1,
                                            focusNode: zoomNode,
                                            autofocus: true,
                                            onPressed: () {
                                              // _videoPlayerController.options.subtitle.options;

                                              // _videoPlayerController.setVideoAspectRatio("14:8");
                                              cancelAndRestartTimer();
                                            },
                                            icon: Icon(
                                              Icons.fullscreen,
                                              size: 30,
                                              color: zoomColor.withOpacity(
                                                  controlsNotVisible ? 0.0 : 1),
                                            )),
                                      ),

                                      const SizedBox(
                                        height: 50,
                                        width: 50,
                                      )
                                      // Container(
                                      //   width: 50,
                                      //   height: 50,
                                      //   decoration: BoxDecoration(
                                      //     color: speedColor == Colors.white
                                      //         ? Colors.white.withOpacity(controlsNotVisible ? 0.0 : 0.2)
                                      //         : Colors.white.withOpacity(controlsNotVisible ? 0.0 : 1),
                                      //     borderRadius: BorderRadius.circular(15),
                                      //   ),
                                      //   child: Stack(
                                      //     children: [
                                      //       IconButton(
                                      //         focusNode: speedNode,
                                      //         autofocus: true,
                                      //         splashRadius: 1,
                                      //         icon: const Icon(Icons.timer),
                                      //         color: speedColor.withOpacity(controlsNotVisible ? 0.0 : 1),
                                      //         onPressed: _cyclePlaybackSpeed,
                                      //       ),
                                      //       Positioned(
                                      //         bottom: 7,
                                      //         right: 3,
                                      //         child: IgnorePointer(
                                      //           child: Container(
                                      //             decoration: BoxDecoration(
                                      //               color: Colors.orange,
                                      //               borderRadius: BorderRadius.circular(1),
                                      //             ),
                                      //             padding: const EdgeInsets.symmetric(
                                      //               vertical: 1,
                                      //               horizontal: 2,
                                      //             ),
                                      //             child: Text(
                                      //               '${playbackSpeeds.elementAt(playbackSpeedIndex)}x',
                                      //               style: const TextStyle(
                                      //                 color: Colors.black,
                                      //                 fontSize: 8,
                                      //                 fontWeight: FontWeight.bold,
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // IconButton(
                                      //   tooltip: 'Get Snapshot',
                                      //   icon: const Icon(Icons.camera),
                                      //   color: Colors.white,
                                      //   onPressed: _createCameraImage,
                                      // ),
                                      // IconButton(
                                      //   color: Colors.white,
                                      //   icon: _videoPlayerController.value.isRecording
                                      //       ? const Icon(Icons.videocam_off_outlined)
                                      //       : const Icon(Icons.videocam_outlined),
                                      //   onPressed: _toggleRecording,
                                      // ),
                                      // IconButton(
                                      //   icon: const Icon(Icons.cast),
                                      //   color: Colors.white,
                                      //   onPressed: _getRendererDevices,
                                      // ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Size: ${_videoPlayerController.value.size.width.toInt()}x${_videoPlayerController.value.size.height.toInt()}',
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Status: ${_videoPlayerController.value.playingState.toString().split('.')[1]}',
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  // color: Colors.purple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Focus(
                                  // focusNode: progressNode,
                                  onFocusChange: (hasFocus) {
                                    setState(() {
                                      (hasFocus)
                                          ? progressColor = Colors.red
                                          : progressColor = Colors.white;
                                    });
                                    cancelAndRestartTimer();
                                  },
                                  child: RawKeyboardListener(
                                    focusNode: progressNode,
                                    onKey: (k) async {
                                      print(k.data.physicalKey.debugName);
                                      print('keuboard ${k.character}');
                                      if (k.runtimeType == RawKeyDownEvent &&
                                          k.isKeyPressed(
                                              LogicalKeyboardKey.arrowRight)) {
                                        print("next");
                                        // Duration? videoDuration = await widget
                                        //     .controller!.videoPlayerController!.position;
                                        setState(() {
                                          if (_videoPlayerController
                                              .value.isPlaying) {
                                            Duration forwardDuration = Duration(
                                                seconds: (_videoPlayerController
                                                        .value
                                                        .position
                                                        .inSeconds +
                                                    10));
                                            if (forwardDuration >
                                                _videoPlayerController
                                                    .value.duration) {
                                              _videoPlayerController.seekTo(
                                                  const Duration(seconds: 0));
                                              _videoPlayerController.pause();
                                            } else {
                                              _videoPlayerController
                                                  .seekTo(forwardDuration);
                                            }
                                          }
                                        });
                                        cancelAndRestartTimer();
                                      } else if (k.runtimeType ==
                                              RawKeyDownEvent &&
                                          k.isKeyPressed(
                                              LogicalKeyboardKey.arrowLeft)) {
                                        print("prev");
                                        // Duration? videoDuration = await widget
                                        //     .controller!.videoPlayerController!.position;
                                        setState(() {
                                          if (_videoPlayerController
                                              .value.isPlaying) {
                                            Duration rewindDuration = Duration(
                                                seconds: (_videoPlayerController
                                                        .value
                                                        .position
                                                        .inSeconds -
                                                    10));
                                            if (rewindDuration <
                                                const Duration(seconds: 10)) {
                                              _videoPlayerController.seekTo(
                                                  const Duration(seconds: 0));
                                            } else {
                                              _videoPlayerController
                                                  .seekTo(rewindDuration);
                                            }
                                          }
                                        });
                                        cancelAndRestartTimer();
                                      }
                                      cancelAndRestartTimer();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Container(
                                        height: 50,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: progressColor == Colors.red
                                                ? Colors.white.withOpacity(
                                                    controlsNotVisible
                                                        ? 0.0
                                                        : 1)
                                                : Colors.white.withOpacity(
                                                    controlsNotVisible
                                                        ? 0.0
                                                        : 0.2),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: ProgressBar(
                                          progress: _videoPlayerController
                                              .value.position,
                                          buffered: _videoPlayerController
                                              .value.duration,
                                          total: _videoPlayerController
                                              .value.duration,
                                          timeLabelType:
                                              TimeLabelType.remainingTime,
                                          timeLabelLocation:
                                              TimeLabelLocation.sides,
                                          progressBarColor:
                                              progressColor.withOpacity(
                                                  controlsNotVisible ? 0 : 1),
                                          timeLabelTextStyle: TextStyle(
                                            color: progressColor == Colors.red
                                                ? Colors.black.withOpacity(
                                                    controlsNotVisible ? 0 : 1)
                                                : Colors.white.withOpacity(
                                                    controlsNotVisible ? 0 : 1),
                                          ),
                                          baseBarColor: progressColor ==
                                                  Colors.red
                                              ? Colors.black.withOpacity(
                                                  controlsNotVisible ? 0 : 1)
                                              : Colors.white.withOpacity(
                                                  controlsNotVisible
                                                      ? 0
                                                      : 0.24),
                                          bufferedBarColor: Colors.white
                                              .withOpacity(
                                                  controlsNotVisible ? 0 : 0.8),
                                          thumbColor: progressColor ==
                                                  Colors.red
                                              ? Colors.red.withOpacity(
                                                  controlsNotVisible ? 0 : 1)
                                              : Colors.white.withOpacity(
                                                  controlsNotVisible ? 0 : 1),
                                          barHeight: 15.0,
                                          thumbRadius: 5.0,
                                          onSeek: (duration) async {
                                            await _videoPlayerController
                                                .seekTo(duration);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Visibility(
                        //   visible: !controlsNotVisible,
                        //   child: Container(
                        //     color: Colors.black.withOpacity(0.2),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.start,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: [
                        //
                        //         Expanded(
                        //           child: Row(
                        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //             mainAxisSize: MainAxisSize.max,
                        //             children: [
                        //               Text(
                        //                 position,
                        //                 style: const TextStyle(color: Colors.white),
                        //               ),
                        //               RawKeyboardListener(
                        //                 focusNode: progressNode,
                        //                 onKey: (k) async {
                        //                   print(k.data.physicalKey.debugName);
                        //                   print('keuboard ${k.character}');
                        //                   if (k.runtimeType == RawKeyDownEvent && k.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                        //                     print("next");
                        //
                        //                     setState(() {
                        //                       if (_videoPlayerController.value.isPlaying) {
                        //                         _videoPlayerController.value.bufferPercent;
                        //                         Duration forwardDuration =
                        //                         Duration(seconds: (videoDuration!.inSeconds + 10));
                        //                         if (forwardDuration >
                        //                             widget.controller!.videoPlayerController!.value
                        //                                 .duration!) {
                        //                           widget.controller!.seekTo(const Duration(seconds: 0));
                        //                           widget.controller!.pause();
                        //                         } else {
                        //                           widget.controller!.seekTo(forwardDuration);
                        //                         }
                        //                       }
                        //                     });
                        //                     cancelAndRestartTimer();
                        //                   } else if (k.runtimeType == RawKeyDownEvent && k.isKeyPressed(LogicalKeyboardKey.arrowLeft )) {
                        //                     print("prev");
                        //                     Duration? videoDuration = await widget
                        //                         .controller!.videoPlayerController!.position;
                        //                     setState(() {
                        //                       if (widget.controller!.isPlaying()!) {
                        //                         Duration rewindDuration =
                        //                         Duration(seconds: (videoDuration!.inSeconds - 10));
                        //                         if (rewindDuration >
                        //                             widget.controller!.videoPlayerController!.value
                        //                                 .duration!) {
                        //                           widget.controller!.seekTo(const Duration(seconds: 0));
                        //                         } else {
                        //                           widget.controller!.seekTo(rewindDuration);
                        //                         }
                        //                       }
                        //                     });
                        //                     cancelAndRestartTimer();
                        //                   }
                        //                   cancelAndRestartTimer();
                        //                 },
                        //                 child: Expanded(
                        //                   child: Slider(
                        //                     activeColor: Colors.redAccent,
                        //                     inactiveColor: Colors.white70,
                        //                     value: sliderValue,
                        //                     min: 0.0,
                        //                     max: (!validPosition &&
                        //                         _videoPlayerController.value.duration == null)
                        //                         ? 1.0
                        //                         : _videoPlayerController.value.duration.inSeconds.toDouble(),
                        //                     onChanged:
                        //                     validPosition ? _onSliderPositionChanged : null,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Text(
                        //                 duration,
                        //                 style: const TextStyle(color: Colors.white),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
          ),
          // floatingActionButton: FloatingActionButton(
          //     onPressed: ()async{
          //       // controlsNotVisible = !controlsNotVisible;
          //      // await  _videoPlayerController.setVideoAspectRatio("16:9");
          //       playNode.requestFocus();
          //       setState(() {
          //       });
          //       print(playNode.hasFocus);
          // }),
          // appBar: AppBar(title: const Text('momo'),),
          body: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // _betterPlayerController.videoPlayerController!.value.hasError ? _buildErrorWidget() :
                // BetterPlayer(controller: _betterPlayerController),
                // SizedBox(
                //   height: 100.h,
                //   width: 100.w,
                //   child: VlcPlayerWithControls(
                //     key: _key,
                //     controller: _videoPlayerController,
                //     onStopRecording: (recordPath) {
                //
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         SnackBar(
                //           content: Text(
                //               'The recorded video file has been added to the end of list.'),
                //         ),
                //       );
                //     },
                //   ),
                // ),
                VlcPlayer(
                  controller: _videoPlayerController,
                  aspectRatio: 16 / 9,
                  placeholder: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          )),
    );
  }

  // Widget _buildErrorWidget() {
  //   final errorBuilder =
  //       _betterPlayerController.betterPlayerConfiguration.errorBuilder;
  //   if (errorBuilder != null) {
  //     return errorBuilder(
  //         context,
  //         _betterPlayerController
  //             .videoPlayerController!.value.errorDescription);
  //   } else {
  //     const textStyle = TextStyle(color: Colors.white);
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Icon(
  //             Icons.warning,
  //             color:  Colors.white,
  //             size: 42,
  //           ),
  //           Text(
  //             _betterPlayerController.translations.generalDefaultError,
  //             style: textStyle,
  //           ),
  //           if (_betterPlayerController.betterPlayerControlsConfiguration.enableRetry)
  //             TextButton(
  //               onPressed: () {
  //                 _betterPlayerController.retryDataSource();
  //               },
  //               child: Text(
  //                 _betterPlayerController.translations.generalRetry,
  //                 style: textStyle.copyWith(fontWeight: FontWeight.bold),
  //               ),
  //             )
  //         ],
  //       ),
  //     );
  //   }
  //
  //
  // }

}
