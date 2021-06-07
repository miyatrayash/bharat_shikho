import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bharat_shikho/audio/audio_player.dart';
import 'package:bharat_shikho/media_player.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void _audioTaskEntryPoint() async {
  print("here");

  await AudioServiceBackground.run(() => AudioPlayerTask());
}

final queue = <MediaItem>[];

class MediaPlayerScreen extends StatefulWidget {
  const MediaPlayerScreen({Key? key}) : super(key: key);

  @override
  _MediaPlayerScreenState createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  init() async {
    List<dynamic> list = [];
    for (int i = 0; i < queue.length; i++) {
      var m = queue[i].toJson();
      list.add(m);
    }
    var params = {"data": list};

    await AudioService.connect();
    await AudioService.start(
      backgroundTaskEntrypoint: _audioTaskEntryPoint,
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

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder<AudioState>(
          stream: _audioStateStream,
          builder: (context, snapshot) {
            final audioState = snapshot.data;

            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            // final queue = audioState?.queue;
            final mediaItem = audioState?.mediaItem;
            final playbackState = audioState?.playbackState;

            final processingState =
                playbackState?.processingState ?? AudioProcessingState.none;
            print(processingState);

            return MediaPlayer(item: mediaItem!);
          },
        ),
      ),
    );
  }
}

Stream<AudioState> get _audioStateStream {
  return Rx.combineLatest3<List<MediaItem>?, MediaItem?, PlaybackState,
      AudioState>(
    AudioService.queueStream,
    AudioService.currentMediaItemStream,
    AudioService.playbackStateStream,
    (queue, mediaItem, playbackState) => AudioState(
        queue: queue, mediaItem: mediaItem, playbackState: playbackState),
  );
}
