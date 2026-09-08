/// `TimeSource` provayderlari — vaqtga kirishning yagona yo'li (§7).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clock_verdict.dart';
import 'time_source.dart';

/// Ilova bo'ylab yagona `TimeSource` (keepAlive: monoton langar yo'qolmasin).
final Provider<TimeSource> timeSourceProvider = Provider<TimeSource>((Ref ref) {
  final TimeSource source = TimeSource();
  ref.onDispose(source.dispose);
  return source;
});

/// Skew darajasi oqimi — sariq/qizil bannerlar shundan chizadi (§7.2).
final StreamProvider<ClockSkewLevel> clockSkewLevelProvider = StreamProvider<ClockSkewLevel>(
  (Ref ref) => ref.watch(timeSourceProvider).skewLevelChanges,
);
