import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'clickable.dart';
import 'cupertino.dart';

class CustomControlsWidget extends StatefulWidget {
  final BetterPlayerController? controller;
  final Function(bool visbility)? onControlsVisibilityChanged;

  const CustomControlsWidget({
    Key? key,
    this.controller,
    this.onControlsVisibilityChanged,
  }) : super(key: key);

  @override
  _CustomControlsWidgetState createState() => _CustomControlsWidgetState();
}

Timer? timer;
Duration buffered = const Duration(seconds: 0);
Duration current = const Duration(seconds: 0);
Duration total = const Duration(seconds: 0);

class MyTimeNotifier extends ChangeNotifier {
  void timeTracker(BetterPlayerController controller) {
    if (controller.videoPlayerController!.value.isPlaying) {
      current = controller.videoPlayerController!.value.position;
      buffered = controller.videoPlayerController!.value.buffered.last.end;
      total = controller.videoPlayerController!.value.duration!;
    } else {
      timer!.cancel();
    }
    notifyListeners();
  }
}

class _CustomControlsWidgetState extends State<CustomControlsWidget> {
  Color vertColor = Colors.white;
  Color subtitleColor = Colors.white;
  Color speedColor = Colors.white;
  Color playColor = Colors.white;
  Color fullScreenColor = Colors.white;
  Color progressColor = Colors.white;
  Color qualityColor = Colors.white;
  Color zoomColor = Colors.white;

// change(){
//   print('print('');');
//   currentColor = Colors.blue;
//   setState(() {
//
//   });
// }
  final _timeNotifier = MyTimeNotifier();
  Timer? _hideTimer;
  bool controlsNotVisible = false;
  @override
  void cancelAndRestartTimer() {
    print("timec caellled");
    _hideTimer?.cancel();
    changePlayerControlsNotVisible(false);
    _startHideTimer();
  }

  void _startHideTimer() {
    if (widget.controller!.controlsAlwaysVisible) {
      return;
    }
    _hideTimer = Timer(const Duration(seconds: 5), () {
      changePlayerControlsNotVisible(true);
    });
  }

  void changePlayerControlsNotVisible(bool notVisible) {
    setState(() {
      if (notVisible) {
        widget.controller?.postEvent(
            BetterPlayerEvent(BetterPlayerEventType.controlsHiddenStart));
      }
      controlsNotVisible = notVisible;
    });
  }

  get() async {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeNotifier.timeTracker(widget.controller!);
      // print(current);
      // print(total);
      // print("seconds ${currentTrackTime}");
    });
  }

  final FocusNode speedNode = FocusNode();
  final FocusNode playNode = FocusNode();
  final FocusNode progressNode = FocusNode();
  final FocusNode vertNode = FocusNode();
  final FocusNode subtitleNode = FocusNode();
  final FocusNode qualityNode = FocusNode();
  final FocusNode zoomNode = FocusNode();
  static String formatBitrate(int bitrate) {
    if (bitrate < 1000) {
      return "$bitrate bit/s";
    }
    if (bitrate < 1000000) {
      final kbit = (bitrate / 1000).floor();
      return "~$kbit KBit/s";
    }
    final mbit = (bitrate / 1000000).floor();
    return "~$mbit MBit/s";
  }

  Widget _buildTrackRow(BetterPlayerAsmsTrack track, String? preferredName) {
    final int width = track.width ?? 0;
    final int height = track.height ?? 0;
    final int bitrate = track.bitrate ?? 0;
    final String mimeType = (track.mimeType ?? '').replaceAll('video/', '');
    final String trackName =
        preferredName ?? "${width}x$height ${formatBitrate(bitrate)} $mimeType";

    final BetterPlayerAsmsTrack? selectedTrack =
        widget.controller!.betterPlayerAsmsTrack;
    final bool isSelected = selectedTrack != null && selectedTrack == track;

    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        widget.controller!.setTrack(track);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: isSelected ? 8 : 16),
            Visibility(
                visible: isSelected,
                child: const Icon(
                  Icons.check_outlined,
                  color: Colors.black,
                )),
            const SizedBox(width: 16),
            Text(
              trackName,
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionSelectionRow(String name, String url) {
    final bool isSelected =
        url == widget.controller!.betterPlayerDataSource!.url;
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        widget.controller!.setResolution(url);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: isSelected ? 8 : 16),
            Visibility(
                visible: isSelected,
                child: const Icon(
                  Icons.check_outlined,
                  color: Colors.black,
                )),
            const SizedBox(width: 16),
            Text(
              name,
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
          ],
        ),
      ),
    );
  }

  void _showQualitiesSelectionWidget() {
    // HLS / DASH
    final List<String> asmsTrackNames =
        widget.controller!.betterPlayerDataSource!.asmsTrackNames ?? [];
    final List<BetterPlayerAsmsTrack> asmsTracks =
        widget.controller!.betterPlayerAsmsTracks;
    final List<Widget> children = [];
    for (var index = 0; index < asmsTracks.length; index++) {
      final track = asmsTracks[index];

      String? preferredName;
      if (track.height == 0 && track.width == 0 && track.bitrate == 0) {
        preferredName = widget.controller!.translations.qualityAuto;
      } else {
        preferredName =
            asmsTrackNames.length > index ? asmsTrackNames[index] : null;
      }
      children.add(_buildTrackRow(asmsTracks[index], preferredName));
    }

    // normal videos
    final resolutions = widget.controller!.betterPlayerDataSource!.resolutions;
    resolutions?.forEach((key, value) {
      children.add(_buildResolutionSelectionRow(key, value));
    });

    if (children.isEmpty) {
      children.add(
        _buildTrackRow(BetterPlayerAsmsTrack.defaultTrack(),
            widget.controller!.translations.qualityAuto),
      );
    }

    _showMaterialBottomSheet(children);
  }

  void _showMaterialBottomSheet(List<Widget> children) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      useRootNavigator:
          widget.controller?.betterPlayerConfiguration.useRootNavigator ??
              false,
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0)),
              ),
              child: Column(
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedRow(double value) {
    final bool isSelected =
        widget.controller!.videoPlayerController!.value.speed == value;

    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        widget.controller!.setSpeed(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: isSelected ? 8 : 16),
            Visibility(
                visible: isSelected,
                child: const Icon(
                  Icons.check_outlined,
                  color: Colors.black,
                )),
            const SizedBox(width: 16),
            Text(
              "$value x",
              style: _getOverflowMenuElementTextStyle(isSelected),
            )
          ],
        ),
      ),
    );
  }

  void _showSpeedChooserWidget() {
    _showMaterialBottomSheet([
      _buildSpeedRow(0.25),
      _buildSpeedRow(0.5),
      _buildSpeedRow(0.75),
      _buildSpeedRow(1.0),
      _buildSpeedRow(1.25),
      _buildSpeedRow(1.5),
      _buildSpeedRow(1.75),
      _buildSpeedRow(2.0),
    ]);
  }
  focusListeners(){
    vertNode.addListener(() {
      setState(() {
        (vertNode.hasFocus)
            ? vertColor = Colors.black
            : vertColor = Colors.white;
      });
      cancelAndRestartTimer();
    });
    playNode.addListener(() {
      setState(() {
        (playNode.hasFocus)
            ? playColor = Colors.black
            : playColor = Colors.white;
      });
      cancelAndRestartTimer();
    });
    subtitleNode.addListener(() {
      setState(() {
        (subtitleNode.hasFocus)
            ? subtitleColor = Colors.black
            : subtitleColor = Colors.white;
      });
      cancelAndRestartTimer();
    });
    speedNode.addListener(() {
      setState(() {
        (speedNode.hasFocus)
            ? speedColor = Colors.black
            : speedColor = Colors.white;
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
      });
      cancelAndRestartTimer();
    });
  }

  @override
  void initState() {

    // get();
    vertNode.addListener(() {
      setState(() {
        (vertNode.hasFocus)
            ? vertColor = Colors.black
            : vertColor = Colors.white;
      });
      cancelAndRestartTimer();
    });
    playNode.addListener(() {
      setState(() {
        (playNode.hasFocus)
            ? playColor = Colors.black
            : playColor = Colors.white;
      });
      cancelAndRestartTimer();
    });
    subtitleNode.addListener(() {
      setState(() {
        (subtitleNode.hasFocus)
            ? subtitleColor = Colors.black
            : subtitleColor = Colors.white;
      });
      cancelAndRestartTimer();
    });
    speedNode.addListener(() {
      setState(() {
        (speedNode.hasFocus)
            ? speedColor = Colors.black
            : speedColor = Colors.white;
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
      });
      cancelAndRestartTimer();
    });
    print("initstate ${widget.controller!.isVideoInitialized()}");
    // widget.controller.
    // TODO: implement initState
    super.initState();
  }

  void _showSubtitlesSelectionWidget() {
    final subtitles =
        List.of(widget.controller!.betterPlayerSubtitlesSourceList);
    print(subtitles.length);
    // final noneSubtitlesElementExists = subtitles.contains(
    //         (source) => (source.type == BetterPlayerSubtitlesSourceType.none )) ;
    // if (!noneSubtitlesElementExists) {
    //   subtitles.add(BetterPlayerSubtitlesSource(
    //       type: BetterPlayerSubtitlesSourceType.none));
    // }

    _showMaterialBottomSheet(
        subtitles.map((source) => _buildSubtitlesSourceRow(source)).toList());
  }

  Widget _buildSubtitlesSourceRow(BetterPlayerSubtitlesSource subtitlesSource) {
    final selectedSourceType = widget.controller!.betterPlayerSubtitlesSource;
    final bool isSelected = (subtitlesSource == selectedSourceType) ||
        (subtitlesSource.type == BetterPlayerSubtitlesSourceType.none &&
            subtitlesSource.type == selectedSourceType!.type);

    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        widget.controller!.setupSubtitleSource(subtitlesSource);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: isSelected ? 8 : 16),
            Visibility(
                visible: isSelected,
                child: const Icon(
                  Icons.check_outlined,
                  color: Colors.white,
                )),
            const SizedBox(width: 16),
            Text(
              subtitlesSource.type == BetterPlayerSubtitlesSourceType.none
                  ? widget.controller!.translations.generalNone
                  : subtitlesSource.name ??
                      widget.controller!.translations.generalDefault,
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getOverflowMenuElementTextStyle(bool isSelected) {
    return TextStyle(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      color: isSelected ? Colors.black : Colors.black.withOpacity(0.7),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    current = Duration.zero;
    total = Duration.zero;
    buffered = Duration.zero;
    timer!.cancel();
    _hideTimer!.cancel();
    widget.controller!.dispose();
    playNode.dispose();
    speedNode.dispose();
    subtitleNode.dispose();
    zoomNode.dispose();
    qualityNode.dispose();
    progressNode.dispose();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //focusNode:  FocusNode(),
    //         onKey: (k){
    //         print(k.data);
    //         print(k.data.physicalKey.debugName);
    //         print('keuboard22');
    //
    //         setState(() {
    //         if(controlsNotVisible){
    //           controlsNotVisible = false;}
    //         });
    //         },
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       const SizedBox(
         height: 90,
       ),
        Align(
          alignment: Alignment.center,
          child:  widget.controller!.videoPlayerController!.value.isBuffering
              ? const CircularProgressIndicator(
            color: Colors.white,
          )
              : Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: playColor == Colors.white
                  ? Colors.white.withOpacity(controlsNotVisible ? 0.0 : 0.2)
                  : Colors.white.withOpacity(controlsNotVisible ? 0.0 : 1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
                focusNode: playNode,
                autofocus: true,
                onPressed: () {
                  print("play/paise");
                  setState(() {
                    controlsNotVisible = false;
                    if (widget.controller!.isPlaying()!) {
                      widget.controller!.pause();
                      if(timer != null && timer!.isActive){
                        timer!.cancel();
                      }
                    } else {
                      widget.controller!.play();
                      get();
                    }
                  });
                  cancelAndRestartTimer();
                },
                icon: Icon(
                  widget.controller!.isPlaying()!
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 30,
                  color:
                  playColor.withOpacity(controlsNotVisible ? 0.0 : 1),
                )),
          ),
        ),

        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                 const SizedBox(width: 50,),
                  Container(
                    decoration: BoxDecoration(
                      color: subtitleColor == Colors.white
                          ? Colors.white
                              .withOpacity(controlsNotVisible ? 0.0 : 0.2)
                          : Colors.white
                              .withOpacity(controlsNotVisible ? 0.0 : 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                        focusNode: subtitleNode,
                        autofocus: true,
                        splashColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            _showSubtitlesSelectionWidget();

                            cancelAndRestartTimer();
                            print("subs");
                          });
                        },
                        // widget.controller!.isFullScreen
                        //     ? Icons.fullscreen_exit
                        icon: Icon(
                          Icons.closed_caption_outlined,
                          color: subtitleColor == Colors.white
                              ? Colors.white
                                  .withOpacity(controlsNotVisible ? 0.0 : 1)
                              : Colors.black
                                  .withOpacity(controlsNotVisible ? 0.0 : 1),
                          size: 28,
                        )),
                  ),
                  const SizedBox(width: 50,),
                  Container(
                    decoration: BoxDecoration(
                      color: speedColor == Colors.white
                          ? Colors.white
                              .withOpacity(controlsNotVisible ? 0.0 : 0.2)
                          : Colors.white
                              .withOpacity(controlsNotVisible ? 0.0 : 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                        focusNode: speedNode,
                        autofocus: true,
                        splashColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            _showSpeedChooserWidget();

                            cancelAndRestartTimer();
                            print("spped");
                          });
                        },
                        // widget.controller!.isFullScreen
                        //     ? Icons.fullscreen_exit
                        icon: Icon(
                          Icons.speed,
                          color: speedColor == Colors.white
                              ? Colors.white
                                  .withOpacity(controlsNotVisible ? 0.0 : 1)
                              : Colors.black
                                  .withOpacity(controlsNotVisible ? 0.0 : 1),
                          size: 28,
                        )),
                  ),
                  const SizedBox(width: 50,),
                  Container(
                    decoration: BoxDecoration(
                      color: qualityColor == Colors.white
                          ? Colors.white
                              .withOpacity(controlsNotVisible ? 0.0 : 0.2)
                          : Colors.white
                              .withOpacity(controlsNotVisible ? 0.0 : 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                        focusNode: qualityNode,
                        autofocus: true,
                        splashColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            _showQualitiesSelectionWidget();

                            cancelAndRestartTimer();
                            print("spped");
                          });
                        },
                        // widget.controller!.isFullScreen
                        //     ? Icons.fullscreen_exit
                        icon: Icon(
                          Icons.hd_outlined,
                          color: qualityColor == Colors.white
                              ? Colors.white
                                  .withOpacity(controlsNotVisible ? 0.0 : 1)
                              : Colors.black
                                  .withOpacity(controlsNotVisible ? 0.0 : 1),
                          size: 28,
                        )),
                  ),
                  const SizedBox(width: 50,),
                  Container(
                    decoration: BoxDecoration(
                      color: zoomColor == Colors.white
                          ? Colors.white
                              .withOpacity(controlsNotVisible ? 0.0 : 0.2)
                          : Colors.white
                              .withOpacity(controlsNotVisible ? 0.0 : 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                        focusNode: zoomNode,
                        autofocus: true,
                        splashColor: Colors.white,
                        onPressed: () {
                          widget.controller!.setOverriddenFit(BoxFit.fill);
                          widget.controller!.videoPlayerController!.refresh();
                          setState(() {

                            print(widget.controller!.betterPlayerConfiguration.fit);
                            cancelAndRestartTimer();
                            print("zoom");
                          });

                        },
                        // widget.controller!.isFullScreen
                        //     ? Icons.fullscreen_exit
                        icon: Icon(
                          Icons.fullscreen,
                          color: zoomColor == Colors.white
                              ? Colors.white
                                  .withOpacity(controlsNotVisible ? 0.0 : 1)
                              : Colors.black
                                  .withOpacity(controlsNotVisible ? 0.0 : 1),
                          size: 28,
                        )),
                  ),
                ],
              ),
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
                     widget.controller?.playNextVideo();
                      print(k.data.physicalKey.debugName);
                      print('keuboard ${k.character}');
                      if (k.runtimeType == RawKeyDownEvent && k.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                        print("next");
                        Duration? videoDuration = await widget
                            .controller!.videoPlayerController!.position;
                        setState(() {
                          if (widget.controller!.isPlaying()!) {
                            Duration forwardDuration =
                            Duration(seconds: (videoDuration!.inSeconds + 10));
                            if (forwardDuration >
                                widget.controller!.videoPlayerController!.value
                                    .duration!) {
                              widget.controller!.seekTo(const Duration(seconds: 0));
                              widget.controller!.pause();
                            } else {
                              widget.controller!.seekTo(forwardDuration);
                            }
                          }
                        });
                        cancelAndRestartTimer();
                      } else if (k.runtimeType == RawKeyDownEvent && k.isKeyPressed(LogicalKeyboardKey.arrowLeft )) {
                        print("prev");
                        Duration? videoDuration = await widget
                            .controller!.videoPlayerController!.position;
                        setState(() {
                          if (widget.controller!.isPlaying()!) {
                            Duration rewindDuration =
                            Duration(seconds: (videoDuration!.inSeconds - 10));
                            if (rewindDuration >
                                widget.controller!.videoPlayerController!.value
                                    .duration!) {
                              widget.controller!.seekTo(const Duration(seconds: 0));
                            } else {
                              widget.controller!.seekTo(rewindDuration);
                            }
                          }
                        });
                        cancelAndRestartTimer();
                      }
                      cancelAndRestartTimer();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: AnimatedBuilder(
                        animation: _timeNotifier,
                        builder: (_, __) => Container(
                          height: 50,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: progressColor == Colors.red
                                  ? Colors.white
                                  .withOpacity(controlsNotVisible ? 0.0 : 1)
                                  : Colors.white
                                  .withOpacity(controlsNotVisible ? 0.0 : 0.2),
                              borderRadius: BorderRadius.circular(5)),
                          child: ProgressBar(
                            progress: current,
                            buffered: buffered,
                            total: total,
                            timeLabelType: TimeLabelType.remainingTime,
                            timeLabelLocation: TimeLabelLocation.sides,
                            progressBarColor: progressColor
                                .withOpacity(controlsNotVisible ? 0 : 1),
                            timeLabelTextStyle: TextStyle(
                              color: progressColor == Colors.red
                                  ? Colors.black
                                  .withOpacity(controlsNotVisible ? 0 : 1)
                                  : Colors.white
                                  .withOpacity(controlsNotVisible ? 0 : 1),
                            ),
                            baseBarColor: progressColor == Colors.red
                                ? Colors.black
                                .withOpacity(controlsNotVisible ? 0 : 1)
                                : Colors.white
                                .withOpacity(controlsNotVisible ? 0 : 0.24),
                            bufferedBarColor: Colors.white
                                .withOpacity(controlsNotVisible ? 0 : 0.8),
                            thumbColor: progressColor == Colors.red
                                ? Colors.red.withOpacity(controlsNotVisible ? 0 : 1)
                                : Colors.white
                                .withOpacity(controlsNotVisible ? 0 : 1),
                            barHeight: 15.0,
                            thumbRadius: 5.0,
                            onSeek: (duration) {
                              // _player.seek(duration);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

      ],
    );
  }
}
