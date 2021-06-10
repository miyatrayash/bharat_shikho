import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bharat_shikho/audio/audio_player.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bharat_shikho/user_repository.dart';

class MiniMediaPlayer extends StatefulWidget {
  final MediaItem? item;

  MiniMediaPlayer({required this.item});

  @override
  _MiniMediaPlayerState createState() => _MiniMediaPlayerState();
}

class _MiniMediaPlayerState extends State<MiniMediaPlayer> {
  double screenWidth = 0;
  double screenHeight = 0;

  init() async {
    List<dynamic> list = [];

    var m = widget.item?.toJson();
    list.add(m);

    var params = {"data": list};
    if (AudioService.connected &&
        AudioService.currentMediaItem != widget.item) {
      await AudioService.stop();
      await AudioService.disconnect();
    }
    await AudioService.connect();
    await AudioService.start(
      backgroundTaskEntrypoint: audioTaskEntryPoint,
      androidNotificationChannelName: 'Audio Service Demo',
      androidNotificationColor: 0xFF2222f5,
      params: params,
    );
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  final BehaviorSubject<double?> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  Widget audioImage(MediaItem item) {
    return Container(
      height: screenWidth * 0.1,
      width: screenWidth * 0.1,
      child: Material(
        elevation: 18.0,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(item.artUri.toString(), fit: BoxFit.fill),
        ),
      ),
    );
  }

  Widget titleBar(MediaItem item) {
    return Container(
      width: screenWidth *.5,
      child: AutoSizeText(
        item.title,
        style: TextStyle(
            fontSize: 15, color: Colors.black, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget slider(MediaItem item, PlaybackState state) {
    double? seekPos;
    return Container(
      height: screenHeight * 0.01,
      width: screenWidth,
      child: StreamBuilder(
        stream: Rx.combineLatest2<double?, double?, double?>(
            _dragPositionSubject.stream,
            Stream.periodic(Duration(milliseconds: 200)),
            (dragPosition, _) => dragPosition),
        builder: (context, snapshot) {
          double position = snapshot.data as double? ??
              state.currentPosition.inMilliseconds.toDouble();
          double? duration = item.duration?.inMilliseconds.toDouble();
          return SliderTheme(
            data: SliderThemeData(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0,disabledThumbRadius: 0),),
            child: Slider(
              min: 0.0,
              max: duration!,
              value: seekPos ?? max(0.0, min(position, duration)),
              activeColor: Colors.red,
              inactiveColor: Colors.black,
              onChanged: (value) {
                _dragPositionSubject.add(value);
              },
              onChangeEnd: (value) {
                AudioService.seekTo(Duration(milliseconds: value.toInt()));
                seekPos = value;
                _dragPositionSubject.add(null);
              },
            ),
          );
        },
      ),
    );
  }

  Widget playButton(PlaybackState state) {
    return IconButton(
      icon: Icon(state.playing
          ? Icons.pause_outlined
          : Icons.play_arrow),
      onPressed: state.playing ? AudioService.pause : AudioService.play,
      iconSize: screenHeight * 0.05,
      color: Colors.black,
      splashColor: Colors.blue[50],
      highlightColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return  Container(
      height: screenHeight * .3,
      width: screenWidth,
      child: Card(
        child: StreamBuilder<AudioState>(
            stream: audioStateStream,
            builder: (context, snapshot) {
              final audioState = snapshot.data;
              print(snapshot.connectionState);
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return CircularProgressIndicator();
              }
              final mediaItem = audioState?.mediaItem;
              final playbackState = audioState?.playbackState;
              if (mediaItem == null) {
                return Center(child: CircularProgressIndicator());
              }
              final processingState =
                  playbackState?.processingState ?? AudioProcessingState.none;
              print(processingState);

              return Column(
                mainAxisAlignment:  MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                    audioImage(mediaItem),
                    titleBar(mediaItem),
                    playButton(playbackState!),
                  ]),
                  slider(mediaItem, playbackState),
                ],
              );
            }),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  /// Removes side padding of slider
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double? trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
