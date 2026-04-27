import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';
import 'package:kegel_master/features/session/domain/session_engine.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, this.config});

  final SessionConfig? config;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final SessionEngine _engine;
  Timer? _timer;

  SessionConfig get _config => widget.config ?? SessionConfig.defaults;

  @override
  void initState() {
    super.initState();
    _engine = SessionEngine(config: _config);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
      _timer?.cancel();
      _timer = null;
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
      _timer?.cancel();
      _timer = null;
    }
  }

  void _endSession() {
    if (_engine.state.phase == SessionPhase.done ||
        _engine.state.phase == SessionPhase.abandoned) {
      return;
    }
    setState(() {
      _engine.endEarly();
    });
    _timer?.cancel();
    _timer = null;
  }

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

    return Scaffold(
      appBar: AppBar(title: const Text('Session')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildBody(context, s),
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
            onPressed: () {},
            child: const Text('Continue'),
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
            onPressed: () {},
            child: const Text('Continue'),
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
              onPressed: _endSession,
              child: const Text('End session'),
            ),
          ],
        ),
      ],
    );
  }
}
