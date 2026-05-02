import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/session_outcome.dart';
import 'package:kegel_master/features/progress/presentation/progress_scope.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';
import 'package:kegel_master/features/session/domain/session_engine.dart';
import 'package:uuid/uuid.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, this.config});

  final SessionConfig? config;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final SessionEngine _engine;
  Timer? _timer;
  final DateTime _sessionStartedAt = DateTime.now().toUtc();
  bool _persisted = false;

  SessionConfig get _config => widget.config ?? SessionConfig.defaults;

  @override
  void initState() {
    super.initState();
    _engine = SessionEngine(config: _config);
    _startPeriodicTimer();
  }

  @override
  void dispose() {
    _cancelPeriodicTimer();
    super.dispose();
  }

  void _cancelPeriodicTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startPeriodicTimer() {
    _cancelPeriodicTimer();
    final SessionPhase phase = _engine.state.phase;
    if (phase == SessionPhase.done || phase == SessionPhase.abandoned) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _maybeRestartTimerIfActive() {
    if (!mounted) return;
    final SessionPhase phase = _engine.state.phase;
    if (phase == SessionPhase.done || phase == SessionPhase.abandoned) {
      return;
    }
    _startPeriodicTimer();
  }

  void _onTick() {
    if (!mounted) return;
    final SessionPhase phase = _engine.state.phase;
    if (phase == SessionPhase.done || phase == SessionPhase.abandoned) {
      return;
    }
    setState(() {
      _engine.tick();
    });
    final SessionPhase after = _engine.state.phase;
    if (after == SessionPhase.done || after == SessionPhase.abandoned) {
      _cancelPeriodicTimer();
      unawaited(_persistIfNeeded(_engine.state));
    }
  }

  Future<void> _persistIfNeeded(SessionState s) async {
    if (s.phase != SessionPhase.done && s.phase != SessionPhase.abandoned) {
      return;
    }
    if (_persisted) return;
    if (!mounted) return;
    final store = ProgressScope.of(context).sessionHistory;
    final SessionHistoryEntry entry = SessionHistoryEntry(
      id: const Uuid().v4(),
      startedAt: _sessionStartedAt,
      endedAt: DateTime.now().toUtc(),
      configSnapshot: _config,
      outcome: s.isCompleted ? SessionOutcome.completed : SessionOutcome.abandoned,
      skippedPhaseCount: s.skippedPhaseCount,
    );
    try {
      await store.appendRun(entry);
      if (!mounted) return;
      _persisted = true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Session persist failed: $e\n$st');
      }
    }
  }

  void _skip() {
    if (_engine.state.phase == SessionPhase.done ||
        _engine.state.phase == SessionPhase.abandoned) {
      return;
    }
    setState(() {
      _engine.skipPhase();
    });
    if (_engine.state.phase == SessionPhase.done || _engine.state.phase == SessionPhase.abandoned) {
      _cancelPeriodicTimer();
      unawaited(_persistIfNeeded(_engine.state));
    }
  }

  void _popWhenAllowed() {
    if (!mounted) return;
    final NavigatorState nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    }
  }

  Future<void> _requestEndSessionConfirm() async {
    final SessionPhase phase = _engine.state.phase;
    if (phase == SessionPhase.done || phase == SessionPhase.abandoned) {
      _popWhenAllowed();
      return;
    }

    _cancelPeriodicTimer();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('End session early?'),
          content: const Text('Your progress in this session will stop.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('End'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirmed != true) {
      _maybeRestartTimerIfActive();
      return;
    }

    setState(() {
      _engine.endEarly();
    });
    _cancelPeriodicTimer();
    unawaited(_persistIfNeeded(_engine.state));

    _popWhenAllowed();
  }

  Future<void> _onEndSessionPressed() => _requestEndSessionConfirm();

  static String _phaseLabel(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.squeeze:
        return 'Squeeze';
      case SessionPhase.relax:
        return 'Relax';
      case SessionPhase.bufferBetweenSets:
        return 'Between sets';
      case SessionPhase.done:
        return 'Done';
      case SessionPhase.abandoned:
        return 'Ended';
    }
  }

  @override
  Widget build(BuildContext context) {
    final SessionState s = _engine.state;
    final bool allowSystemPop =
        s.phase == SessionPhase.done || s.phase == SessionPhase.abandoned;

    return PopScope(
      canPop: allowSystemPop,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        unawaited(_requestEndSessionConfirm());
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Session')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildBody(context, s),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SessionState s) {
    if (s.phase == SessionPhase.done) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _phaseLabel(s.phase),
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Session complete.',
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          FilledButton(
            onPressed: _popWhenAllowed,
            child: const Text('Back to home'),
          ),
        ],
      );
    }

    if (s.phase == SessionPhase.abandoned) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _phaseLabel(s.phase),
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Session ended early.',
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          FilledButton(
            onPressed: _popWhenAllowed,
            child: const Text('Back to home'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _phaseLabel(s.phase),
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          '${s.remainingSeconds}s',
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'Set ${s.setIndex} of ${_config.targetSets}',
          textAlign: TextAlign.center,
        ),
        Text(
          'Rep ${s.repIndex} of ${_config.repsPerSet}',
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilledButton(
              onPressed: _skip,
              child: const Text('Skip'),
            ),
            OutlinedButton(
              onPressed: _onEndSessionPressed,
              child: const Text('End session'),
            ),
          ],
        ),
      ],
    );
  }
}
