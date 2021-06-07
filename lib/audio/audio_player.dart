import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class AudioPlayerTask extends BackgroundAudioTask {
  List<MediaItem> _queue = [];

  int _queueIndex = -1;
  AudioPlayer _audioPlayer = AudioPlayer();
  AudioProcessingState? _audioProcessingState;
  bool? _playing;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<PlaybackEvent>? _eventSubscription;

  @override
  Future<void> onStart(Map<String, dynamic>? params) {
    _queue.clear();
    List mediaItems = params!['data'];
    for (int i = 0; i < mediaItems.length; i++) {
      MediaItem mediaItem = MediaItem.fromJson(mediaItems[i]);
      _queue.add(mediaItem);
    }
    _playerStateSubscription = _audioPlayer.playerStateStream
        .where((state) => state.processingState == ProcessingState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });

    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      switch (event.processingState) {
        case ProcessingState.idle:
          break;
        case ProcessingState.loading:
          _setState(
              processingState: AudioProcessingState.connecting,
              position: event.updatePosition);
          break;
        case ProcessingState.buffering:
          break;
        case ProcessingState.ready:
          _setState(
              processingState: AudioProcessingState.ready,
              position: event.updatePosition);
          break;
        case ProcessingState.completed:
          break;
      }
    });

    AudioServiceBackground.setQueue(_queue);
    onSkipToNext();
    return super.onStart(params);
  }

  @override
  Future<void> onPlay() async {
    if (_audioProcessingState == null) {
      _playing = true;
      _audioPlayer.play();
    }
  }

  @override
  Future<void> onPause() async {
    _playing = false;
    _audioPlayer.pause();
  }

  @override
  Future<void> onSkipToNext() async {
    // await AudioService.skipToNext();
    await skip(1);
    // onSkipToQueueItem(mediaItem.id);
    await super.onSkipToNext();
  }

  @override
  Future<void> onSkipToPrevious() async {
    // await AudioService.skipToPrevious();
    await skip(-1);
    // onSkipToQueueItem(mediaItem.id);
    await super.onSkipToPrevious();
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    _audioPlayer.setUrl(mediaId);
    onPlay();
  }

  Future<void> skip(int offset) async {
    int newPos = _queueIndex + offset;
    print(offset);
    if (!(newPos >= 0 && newPos < _queue.length)) {
      return;
    }
    if (null == _playing) {
      _playing = true;
    } else if (_playing!) {
      await _audioPlayer.stop();
    }
    _queueIndex = newPos;
    _audioProcessingState = offset > 0
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    await AudioServiceBackground.setMediaItem(mediaItem);
    await _audioPlayer.setUrl(mediaItem.id);
    print(mediaItem.id);
    _audioProcessingState = null;
    if (_playing!) {
      onPlay();
    } else {
      _setState(processingState: AudioProcessingState.ready);
    }
  }

  @override
  Future<void> onStop() async {
    _playing = false;
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _playerStateSubscription!.cancel();
    _eventSubscription!.cancel();
    return super.onStop();
  }

  @override
  Future<void> onSeekTo(Duration position) async {
    _audioPlayer.seek(position);
  }

  @override
  Future<void> onClick(MediaButton button) async {
    // playPause();
  }

  @override
  Future<void> onFastForward() async {
    _seekRelative(fastForwardInterval);
  }

  @override
  Future<void> onRewind() async {
    _seekRelative(rewindInterval,isRewind: true);
  }

  Future<void> _seekRelative(Duration offset,{bool isRewind = false}) async {
    var newPosition;
    if(isRewind)
      newPosition = _audioPlayer.position - offset;
    else
      newPosition = _audioPlayer.position + offset;

    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    }
    if (newPosition > mediaItem.duration!) {
      newPosition = mediaItem.duration!;
    }
    if(isRewind)
      await _audioPlayer.seek(_audioPlayer.position - offset);
    else
      await _audioPlayer.seek(_audioPlayer.position + offset);
  }

  void playPause() {
    if (AudioServiceBackground.state.playing)
      onPause();
    else
      onPlay();
  }

  _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  Future<void> _setState({
    AudioProcessingState? processingState,
    Duration? position,
    Duration? bufferedPosition,
  }) async {
    print('SetState $processingState');
    if (position == null) {
      position = _audioPlayer.position;
    }
    await AudioServiceBackground.setState(
      controls: getControls(),
      systemActions: [MediaAction.seekTo],
      processingState:
          processingState ?? AudioServiceBackground.state.processingState,
      playing: _playing,
      position: position,
      bufferedPosition: bufferedPosition ?? position,
      speed: _audioPlayer.speed,
    );
  }

  List<MediaControl> getControls() {
    if (_playing!) {
      return [
        skipToPreviousControl,
        pauseControl,
        stopControl,
        skipToNextControl,
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
        stopControl,
        skipToNextControl
      ];
    }
  }
}

class AudioState {
  final List<MediaItem>? queue;
  final MediaItem? mediaItem;
  final PlaybackState playbackState;

  AudioState({this.queue, this.mediaItem, required this.playbackState});
}
