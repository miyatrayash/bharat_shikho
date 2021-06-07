import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bharat_shikho/audio/audio_player.dart';
import 'package:bharat_shikho/audio_player.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';


void _audioTaskEntryPoint() async {
  print("here");

  await AudioServiceBackground.run(() => AudioPlayerTask());
}

final queue = <MediaItem>[
  MediaItem(
    id: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
    album: "Science Friday",
    title: "A Salute To Head-Scratching Science",
    artist: "Science Friday and WNYC Studios",
    duration: Duration(milliseconds: 5739820),
    artUri:
    Uri.parse("https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
  ),
  MediaItem(
    id: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
    album: "Science Friday",
    title: "From Cat Rheology To Operatic Incompetence",
    artist: "Science Friday and WNYC Studios",
    duration: Duration(milliseconds: 2856950),
    artUri:
    Uri.parse("https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
  ),
];


class MediaPlayerScreen extends StatefulWidget {
  const MediaPlayerScreen({Key? key}) : super(key: key);

  @override
  _MediaPlayerScreenState createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {

  final BehaviorSubject<double?> _dragPositionSubject =
  BehaviorSubject.seeded(null);


  init() async {

    List<dynamic> list = [];
    for (int i = 0; i < queue.length; i++) {
      var m = queue[i].toJson();
      list.add(m);
    }
    var params = {"data" : list};

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

            if(!snapshot.hasData)
              {
                return CircularProgressIndicator();
              }
            // final queue = audioState?.queue;
            final mediaItem = audioState?.mediaItem;
            final playbackState = audioState?.playbackState;

            final processingState =
                playbackState?.processingState ?? AudioProcessingState.none;
            print(processingState);



             return MediaPlayer(item: mediaItem!);
            // return Container(
            //   width: MediaQuery.of(context).size.width,
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       if (processingState == AudioProcessingState.none) ...[
            //         _startAudioPlayBtn()
            //       ] else ...[
            //         positionIndicator(mediaItem, playbackState),
            //         SizedBox(height: 20),
            //         Text(mediaItem.title),
            //         SizedBox(height: 20),
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             !playing
            //                 ? IconButton(
            //               icon: Icon(Icons.play_arrow),
            //               iconSize: 64.0,
            //               onPressed: AudioService.play,
            //             )
            //                 : IconButton(
            //               icon: Icon(Icons.pause),
            //               iconSize: 64.0,
            //               onPressed: AudioService.pause,
            //             ),
            //             IconButton(
            //               icon: Icon(Icons.stop),
            //               iconSize: 64.0,
            //               onPressed: AudioService.stop,
            //             ),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 IconButton(
            //                   icon: Icon(Icons.skip_previous),
            //                   iconSize: 64,
            //                   onPressed: () {
            //                     if (mediaItem == queue.first) {
            //                       return;
            //                     }
            //                     AudioService.skipToPrevious();
            //                   },
            //                 ),
            //                 IconButton(
            //                   icon: Icon(Icons.skip_next),
            //                   iconSize: 64,
            //                   onPressed: () {
            //                     if (mediaItem == queue.last) {
            //                       return;
            //                     }
            //                     AudioService.skipToNext();
            //                   },
            //                 )
            //               ],
            //             ),
            //           ],
            //         )
            //       ],
            //     ],
            //   ),
            // );
          },
        ),
      ),
    );
  }

  Widget positionIndicator(MediaItem mediaItem, PlaybackState state) {
    double? seekPos;
    return StreamBuilder(
      stream: Rx.combineLatest2<double?, double?, double?>(
          _dragPositionSubject.stream,
          Stream.periodic(Duration(milliseconds: 200)),
              (dragPosition, _) => dragPosition),
      builder: (context, snapshot) {
        double position =
            snapshot.data as double? ?? state.currentPosition.inMilliseconds.toDouble();
        double? duration = mediaItem.duration?.inMilliseconds.toDouble();
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
            Text(_printDuration(state.currentPosition)),
          ],
        );
      },
    );
  }
}
String _printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

// _startAudioPlayBtn() {
//
//   List<dynamic> list = [];
//   for (int i = 0; i < queue.length; i++) {
//     var m = queue[i].toJson();
//     list.add(m);
//   }
//   var params = {"data" : list};
//   return MaterialButton(
//       child: Text('Start Audio Player'),
//       onPressed: () async {
//         await AudioService.connect();
//         await AudioService.start(
//           backgroundTaskEntrypoint: _audioTaskEntryPoint,
//           androidNotificationChannelName: 'Audio Service Demo',
//           androidNotificationColor: 0xFF2222f5,
//           params: params,
//         );
//         print("here");
//
//       });
// }

Stream<AudioState> get _audioStateStream {
  return Rx.combineLatest3<List<MediaItem>?, MediaItem?, PlaybackState,
      AudioState>(
    AudioService.queueStream,
    AudioService.currentMediaItemStream,
    AudioService.playbackStateStream,
    (queue, mediaItem, playbackState) =>
        AudioState(queue: queue,mediaItem: mediaItem, playbackState: playbackState),
  );
}
