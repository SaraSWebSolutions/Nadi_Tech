// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../model/service_timer_model.dart';

// class ServiceTimerNotifier extends Notifier<ServiceTimerState> {
//   Timer? _ticker;

//   @override
//   ServiceTimerState build() {
//     ref.onDispose(() {
//       _ticker?.cancel();
//     });
//     return const ServiceTimerState();
//   }

//   void start() {
//     if (state.isRunning) return;

//     final startTime = state.startTime ?? DateTime.now();

//     state = state.copyWith(
//       startTime: startTime,
//       isRunning: true,
//     );
//     _ticker?.cancel();
//     _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
//       state = state.copyWith();
//     });
//   }

//   void pause() {
//     if (!state.isRunning) return;

//     _ticker?.cancel();

//     state = ServiceTimerState(
//       startTime: null,
//       pausedDuration: state.elapsed,
//       isRunning: false,
//     );
//   }

//   void reset() {
//     _ticker?.cancel();
//     state = const ServiceTimerState();
//   }
// }

// /// ✅ PROVIDER
// final serviceTimerProvider =
//     NotifierProvider<ServiceTimerNotifier, ServiceTimerState>(
//   ServiceTimerNotifier.new,

// );
// lib/providers/timer_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/timer_state.dart';

class TimerNotifier extends Notifier<TimerState> {
  Timer? _timer;

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    return const TimerState(startTime: null, isRunning: false);
  }

  /// 🔥 Start timer with API startTime
  void start(DateTime startTime) {
    debugPrint("TIMER START CALLED => $startTime");

    if (state.isRunning && state.startTime != null) {
      debugPrint("BLOCKED: already running");
      return;
    }

    _timer?.cancel();

    state = state.copyWith(startTime: startTime, isRunning: true);

    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.startTime == null || !state.isRunning) return;

      // 🔥 ONLY notify listeners, don't recreate full state
      state = state.copyWith();
    });
  }

  /// ⏸ Pause (keeps startTime, just stops UI updates)
  void pause() {
    _timer?.cancel();

    state = TimerState(startTime: state.startTime, isRunning: false);
  }

  /// ▶ Resume
  void resume() {
    if (state.startTime == null) return;
    if (state.isRunning) return;

    state = TimerState(startTime: state.startTime, isRunning: true);

    _startTicker();
  }

  /// 🔄 Reset
  void reset() {
    _timer?.cancel();

    state = const TimerState(startTime: null, isRunning: false);
  }
}

/// Timer state class
class TimerState {
  final DateTime? startTime;
  final bool isRunning;

  const TimerState({required this.startTime, required this.isRunning});

  TimerState copyWith({DateTime? startTime, bool? isRunning}) {
    return TimerState(
      startTime: startTime ?? this.startTime,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  Duration get duration {
    if (startTime == null) return Duration.zero;
    return DateTime.now().difference(startTime!);
  }

  String get formattedTime {
    final d = duration;

    return "${d.inHours.toString().padLeft(2, '0')}:"
        "${(d.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }
}

/// Global provider
final timerProvider = NotifierProvider<TimerNotifier, TimerState>(
  () => TimerNotifier(),
);
