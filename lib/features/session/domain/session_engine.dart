import 'package:kegel_master/features/session/domain/session_config.dart';

enum SessionPhase { squeeze, relax, bufferBetweenSets, done, abandoned }

class SessionState {
  const SessionState({
    required this.phase,
    required this.setIndex,
    required this.repIndex,
    required this.remainingSeconds,
    required this.skippedPhaseCount,
    required this.isCompleted,
    required this.isAbandoned,
  });

  final SessionPhase phase;
  final int setIndex;
  final int repIndex;
  final int remainingSeconds;
  final int skippedPhaseCount;
  final bool isCompleted;
  final bool isAbandoned;

  bool get isDone => phase == SessionPhase.done;
}

class SessionEngine {
  SessionEngine({required this.config})
    : _state = SessionState(
        phase: SessionPhase.squeeze,
        setIndex: 1,
        repIndex: 1,
        remainingSeconds: config.squeezeSeconds,
        skippedPhaseCount: 0,
        isCompleted: false,
        isAbandoned: false,
      );

  final SessionConfig config;
  SessionState _state;

  SessionState get state => _state;

  void tick() {
    if (_state.phase == SessionPhase.done || _state.phase == SessionPhase.abandoned) {
      return;
    }

    if (_state.remainingSeconds > 1) {
      _state = _copy(remainingSeconds: _state.remainingSeconds - 1);
      return;
    }

    _advancePhase(markSkipped: false);
  }

  void skipPhase() => _advancePhase(markSkipped: true);

  void endEarly() {
    if (_state.phase == SessionPhase.done || _state.phase == SessionPhase.abandoned) {
      return;
    }

    _state = _copy(
      phase: SessionPhase.abandoned,
      remainingSeconds: 0,
      isAbandoned: true,
      isCompleted: false,
    );
  }

  SessionState _copy({
    SessionPhase? phase,
    int? setIndex,
    int? repIndex,
    int? remainingSeconds,
    int? skippedPhaseCount,
    bool? isCompleted,
    bool? isAbandoned,
  }) {
    return SessionState(
      phase: phase ?? _state.phase,
      setIndex: setIndex ?? _state.setIndex,
      repIndex: repIndex ?? _state.repIndex,
      remainingSeconds: remainingSeconds ?? _state.remainingSeconds,
      skippedPhaseCount: skippedPhaseCount ?? _state.skippedPhaseCount,
      isCompleted: isCompleted ?? _state.isCompleted,
      isAbandoned: isAbandoned ?? _state.isAbandoned,
    );
  }

  void _advancePhase({required bool markSkipped}) {
    if (_state.phase == SessionPhase.done || _state.phase == SessionPhase.abandoned) {
      return;
    }

    final int nextSkipped =
        _state.skippedPhaseCount + (markSkipped ? 1 : 0);

    switch (_state.phase) {
      case SessionPhase.squeeze:
        _state = _copy(
          phase: SessionPhase.relax,
          remainingSeconds: config.relaxSeconds,
          skippedPhaseCount: nextSkipped,
        );
        return;
      case SessionPhase.relax:
        final bool isLastRepInSet = _state.repIndex == config.repsPerSet;
        final bool isLastSet = _state.setIndex == config.targetSets;

        if (!isLastRepInSet) {
          _state = _copy(
            phase: SessionPhase.squeeze,
            repIndex: _state.repIndex + 1,
            remainingSeconds: config.squeezeSeconds,
            skippedPhaseCount: nextSkipped,
          );
          return;
        }

        if (!isLastSet) {
          _state = _copy(
            phase: SessionPhase.bufferBetweenSets,
            remainingSeconds: config.bufferBetweenSetsSeconds,
            skippedPhaseCount: nextSkipped,
          );
          return;
        }

        _state = _copy(
          phase: SessionPhase.done,
          remainingSeconds: 0,
          skippedPhaseCount: nextSkipped,
          isCompleted: true,
        );
        return;
      case SessionPhase.bufferBetweenSets:
        _state = _copy(
          phase: SessionPhase.squeeze,
          setIndex: _state.setIndex + 1,
          repIndex: 1,
          remainingSeconds: config.squeezeSeconds,
          skippedPhaseCount: nextSkipped,
        );
        return;
      case SessionPhase.done:
      case SessionPhase.abandoned:
        return;
    }
  }
}
