// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../model/timer_state.dart';

// class TimerNotifier extends Notifier<TimerState> {
//   Timer? _timer;

//   @override
//   TimerState build() {
//     ref.onDispose(() {
//       _timer?.cancel();
//     });

//     return const TimerState(startTime: null, isRunning: false);
//   }

//   /// 🔥 Start timer with API startTime
//   void start(DateTime startTime) {
//     debugPrint("TIMER START CALLED => $startTime");

//     if (state.isRunning && state.startTime != null) {
//       debugPrint("BLOCKED: already running");
//       return;
//     }

//     _timer?.cancel();

//     state = state.copyWith(startTime: startTime, isRunning: true);

//     _startTicker();
//   }

//   void _startTicker() {
//     _timer?.cancel();

//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (state.startTime == null || !state.isRunning) return;

//       // 🔥 ONLY notify listeners, don't recreate full state
//       state = state.copyWith();
//     });
//   }

//   /// ⏸ Pause (keeps startTime, just stops UI updates)
//   void pause() {
//     _timer?.cancel();

//     state = TimerState(startTime: state.startTime, isRunning: false);
//   }

//   /// ▶ Resume
//   void resume() {
//     if (state.startTime == null) return;
//     if (state.isRunning) return;

//     state = TimerState(startTime: state.startTime, isRunning: true);

//     _startTicker();
//   }

//   /// 🔄 Reset
//   void reset() {
//     _timer?.cancel();

//     state = const TimerState(startTime: null, isRunning: false);
//   }

//   void pauseLocal() {
//     state = state.copyWith(isRunning: false);
//   }

//   void startLocal() {
//     state = state.copyWith(isRunning: true);
//   }
// }

// /// Timer state class
// class TimerState {
//   final DateTime? startTime;
//   final bool isRunning;

//   const TimerState({required this.startTime, required this.isRunning});

//   TimerState copyWith({DateTime? startTime, bool? isRunning}) {
//     return TimerState(
//       startTime: startTime ?? this.startTime,
//       isRunning: isRunning ?? this.isRunning,
//     );
//   }

//   Duration get duration {
//     if (startTime == null) return Duration.zero;
//     return DateTime.now().difference(startTime!);
//   }

//   String get formattedTime {
//     final d = duration;

//     return "${d.inHours.toString().padLeft(2, '0')}:"
//         "${(d.inMinutes % 60).toString().padLeft(2, '0')}:"
//         "${(d.inSeconds % 60).toString().padLeft(2, '0')}";
//   }
// }

// /// Global provider
// final timerProvider = NotifierProvider<TimerNotifier, TimerState>(
//   () => TimerNotifier(),
// );

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/timer_state.dart';

class TimerNotifier extends Notifier<TimerState> {
  Timer? _timer;
  void initialize({required int totalSeconds, required bool isRunning}) {
    _timer?.cancel();

    state = TimerState(elapsedSeconds: totalSeconds, isRunning: isRunning);

    if (isRunning) {
      _startTicker();
    }
  }

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    return const TimerState(elapsedSeconds: 0, isRunning: false);
  }

  /// 🔥 Start timer with API startTime
  // void start(DateTime startTime) {
  //   debugPrint("TIMER START CALLED => $startTime");

  //   if (state.isRunning && state.startTime != null) {
  //     debugPrint("BLOCKED: already running");
  //     return;
  //   }

  //   _timer?.cancel();

  //   state = state.copyWith(startTime: startTime, isRunning: true);

  //   _startTicker();
  // }

  void _startTicker() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isRunning) return;

      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void pauseLocal() {
    _timer?.cancel();

    state = state.copyWith(isRunning: false);
  }

  /// ⏸ Pause (keeps startTime, just stops UI updates)
  void pause() {
    _timer?.cancel();

    state = state.copyWith(isRunning: false);
  }

  /// ▶ Resume
  void resume() {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);

    _startTicker();
  }

  /// 🔄 Reset
  void reset() {
    _timer?.cancel();

    state = const TimerState(elapsedSeconds: 0, isRunning: false);
  }

  // void pauseLocal() {
  //   state = state.copyWith(isRunning: false);
  // }

  void startLocal() {
    state = state.copyWith(isRunning: true);

    _startTicker();
  }
}

/// Timer state class
class TimerState {
  final int elapsedSeconds;
  final bool isRunning;

  const TimerState({required this.elapsedSeconds, required this.isRunning});

  TimerState copyWith({int? elapsedSeconds, bool? isRunning}) {
    return TimerState(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  String get formattedTime {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;

    return "${h.toString().padLeft(2, '0')}:"
        "${m.toString().padLeft(2, '0')}:"
        "${s.toString().padLeft(2, '0')}";
  }
}

/// Global provider
final timerProvider = NotifierProvider<TimerNotifier, TimerState>(
  () => TimerNotifier(),
);
