import 'package:flutter/foundation.dart';

import 'package:kegel_master/features/progress/domain/session_outcome.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

@immutable
class SessionHistoryEntry {
  const SessionHistoryEntry({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.configSnapshot,
    required this.outcome,
    required this.skippedPhaseCount,
  });

  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final SessionConfig configSnapshot;
  final SessionOutcome outcome;
  final int skippedPhaseCount;
}
