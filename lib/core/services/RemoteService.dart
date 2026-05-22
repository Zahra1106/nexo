import 'package:flutter/services.dart';

class RemoteService {
  static const _channel = MethodChannel('nexo_remote');

  static void init({
    required Function() onPlayPause,
    required Function() onPlay,
    required Function() onPause,
    required Function() onRewind,
    required Function() onFastForward,
    required Function() onChannelUp,
    required Function() onChannelDown,
    required Function() onMenu,
  }) {
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'onRemoteButton') return;

      switch (call.arguments as String) {
        case 'play_pause':   onPlayPause();    break;
        case 'play':         onPlay();         break;
        case 'pause':        onPause();        break;
        case 'rewind':       onRewind();       break;
        case 'fast_forward': onFastForward();  break;
        case 'channel_up':   onChannelUp();    break;
        case 'channel_down': onChannelDown();  break;
        case 'menu':         onMenu();         break;
      }
    });
  }

  static void dispose() {
    _channel.setMethodCallHandler(null);
  }
}