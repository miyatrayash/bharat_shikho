import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bharat_shikho/audio/audio_player.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bharat_shikho/user_repository.dart';

class MediaPlayer extends StatefulWidget {
  final MediaItem item;

  MediaPlayer({required this.item});

  @override
  _MediaPlayerState createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  double screenWidth = 0;
  double screenHeight = 0;

  init() async {
    List<dynamic> list = [];

    var m = widget.item.toJson();
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
      height: screenWidth * 0.8,
      width: screenWidth * 0.8,
      child: Material(
        elevation: 18.0,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.network(item.artUri.toString(), fit: BoxFit.fill),
        ),
      ),
    );
  }

  Widget titleBar(MediaItem item) {
    return Container(
      height: screenHeight * 0.15,
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                item.title,
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.w800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
              child: Icon(Icons.favorite, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget artistText(MediaItem item) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: screenHeight * 0.05,
        child: SingleChildScrollView(
          child: AutoSizeText(
            item.artist!,
            style: TextStyle(color: Colors.redAccent, fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget slider(MediaItem item, PlaybackState state) {
    double? seekPos;
    return StreamBuilder(
      stream: Rx.combineLatest2<double?, double?, double?>(
          _dragPositionSubject.stream,
          Stream.periodic(Duration(milliseconds: 200)),
          (dragPosition, _) => dragPosition),
      builder: (context, snapshot) {
        double position = snapshot.data as double? ??
            state.currentPosition.inMilliseconds.toDouble();
        double? duration = item.duration?.inMilliseconds.toDouble();
        return Column(
          children: [
            if (duration != null)
              SliderTheme(
                data: SliderThemeData(
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                    trackShape: CustomTrackShape()),
                child: Slider(
                  min: 0.0,
                  max: duration,
                  value: seekPos ?? max(0.0, min(position, duration)),
                  activeColor: Colors.red,
                  inactiveColor: Colors.black,
                  onChanged: (value) {
                    _dragPositionSubject.add(value);
                  },
                  onChangeEnd: (value) {
                    AudioService.seekTo(Duration(milliseconds: value.toInt()));
                    // Due to a delay in platform channel communication, there is
                    // a brief moment after releasing the Slider thumb before the
                    // new position is broadcast from the platform side. This
                    // hack is to hold onto seekPos until the next state update
                    // comes through.
                    // TODO: Improve this code.
                    seekPos = value;
                    _dragPositionSubject.add(null);
                  },
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transformString(state.currentPosition.inSeconds),
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  transformString(item.duration!.inSeconds),
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget playBar(PlaybackState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.fast_rewind_rounded),
          onPressed: AudioService.rewind,
          iconSize: screenHeight * 0.05,
          color: Colors.black,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        IconButton(
          icon: Icon(state.playing
              ? Icons.pause_circle_filled_rounded
              : Icons.play_circle_fill_rounded),
          onPressed: state.playing ? AudioService.pause : AudioService.play,
          iconSize: screenHeight * 0.1,
          color: Colors.black,
          splashColor: Colors.blue[50],
          highlightColor: Colors.transparent,
        ),
        IconButton(
          icon: Icon(Icons.fast_forward_rounded),
          onPressed: AudioService.fastForward,
          iconSize: screenHeight * 0.05,
          color: Colors.black,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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

              return Container(
                height: screenHeight - 100,
                width: screenWidth,
                padding: EdgeInsets.only(
                    left: screenWidth * 0.1, right: screenWidth * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(),
                    audioImage(mediaItem),
                    titleBar(mediaItem),
                    artistText(mediaItem),
                    slider(mediaItem, playbackState!),  
                    playBar(playbackState),
                  ],
                ),
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
