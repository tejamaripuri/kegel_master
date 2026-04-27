import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';
import 'package:kegel_master/features/session/domain/session_engine.dart';

void main() {
  group('SessionConfig', () {
    test('rejects negative squeezeSeconds', () {
      expect(
        () => SessionConfig(
          squeezeSeconds: -1,
          relaxSeconds: 1,
          bufferBetweenSetsSeconds: 0,
          repsPerSet: 1,
          targetSets: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects repsPerSet below 1', () {
      expect(
        () => SessionConfig(
          squeezeSeconds: 1,
          relaxSeconds: 1,
          bufferBetweenSetsSeconds: 0,
          repsPerSet: 0,
          targetSets: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects targetSets below 1', () {
      expect(
        () => SessionConfig(
          squeezeSeconds: 1,
          relaxSeconds: 1,
          bufferBetweenSetsSeconds: 0,
          repsPerSet: 1,
          targetSets: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('SessionEngine', () {
    final SessionConfig config = SessionConfig(
      squeezeSeconds: 5,
      relaxSeconds: 5,
      bufferBetweenSetsSeconds: 10,
      repsPerSet: 2,
      targetSets: 2,
    );

    test('starts on squeeze for set 1 rep 1', () {
      final SessionEngine engine = SessionEngine(config: config);

      expect(engine.state.phase, SessionPhase.squeeze);
      expect(engine.state.setIndex, 1);
      expect(engine.state.repIndex, 1);
      expect(engine.state.remainingSeconds, 5);
    });

    test('runs buffer only between sets', () {
      final SessionEngine engine = SessionEngine(config: config);

      engine.skipPhase(); // squeeze 1
      engine.skipPhase(); // relax 1
      engine.skipPhase(); // squeeze 2
      engine.skipPhase(); // relax 2 -> buffer

      expect(engine.state.phase, SessionPhase.bufferBetweenSets);
      engine.skipPhase(); // next set squeeze
      expect(engine.state.phase, SessionPhase.squeeze);
      expect(engine.state.setIndex, 2);
      expect(engine.state.repIndex, 1);
    });

    test('done counts as completed even with skips', () {
      final SessionEngine engine = SessionEngine(config: config);

      while (!engine.state.isDone) {
        engine.skipPhase();
      }

      expect(engine.state.isCompleted, isTrue);
      expect(engine.state.skippedPhaseCount, greaterThan(0));
    });

    test('end before done does not count as completed', () {
      final SessionEngine engine = SessionEngine(config: config);

      engine.endEarly();

      expect(engine.state.isAbandoned, isTrue);
      expect(engine.state.isCompleted, isFalse);
    });

    test('tick countdown transitions at least one phase', () {
      final SessionConfig short = SessionConfig(
        squeezeSeconds: 2,
        relaxSeconds: 3,
        bufferBetweenSetsSeconds: 0,
        repsPerSet: 1,
        targetSets: 1,
      );
      final SessionEngine engine = SessionEngine(config: short);

      engine.tick();
      expect(engine.state.phase, SessionPhase.squeeze);
      expect(engine.state.remainingSeconds, 1);

      engine.tick();
      expect(engine.state.phase, SessionPhase.relax);
      expect(engine.state.remainingSeconds, 3);
    });

    test('completes via ticks only with done and completed', () {
      final SessionConfig minimal = SessionConfig(
        squeezeSeconds: 1,
        relaxSeconds: 1,
        bufferBetweenSetsSeconds: 0,
        repsPerSet: 1,
        targetSets: 1,
      );
      final SessionEngine engine = SessionEngine(config: minimal);

      engine.tick();
      expect(engine.state.phase, SessionPhase.relax);

      engine.tick();
      expect(engine.state.phase, SessionPhase.done);
      expect(engine.state.isCompleted, isTrue);
      expect(engine.state.skippedPhaseCount, 0);
    });

    test('after endEarly tick and skipPhase do not change state', () {
      final SessionEngine engine = SessionEngine(config: config);
      engine.endEarly();
      final SessionState frozen = engine.state;

      engine.tick();
      engine.skipPhase();

      expect(engine.state.phase, frozen.phase);
      expect(engine.state.setIndex, frozen.setIndex);
      expect(engine.state.repIndex, frozen.repIndex);
      expect(engine.state.remainingSeconds, frozen.remainingSeconds);
      expect(engine.state.skippedPhaseCount, frozen.skippedPhaseCount);
      expect(engine.state.isCompleted, frozen.isCompleted);
      expect(engine.state.isAbandoned, frozen.isAbandoned);
    });

    test('endEarly no-ops when already abandoned', () {
      final SessionEngine engine = SessionEngine(config: config);
      engine.endEarly();
      final SessionState afterFirst = engine.state;

      engine.endEarly();

      expect(engine.state.phase, afterFirst.phase);
      expect(engine.state.setIndex, afterFirst.setIndex);
      expect(engine.state.repIndex, afterFirst.repIndex);
      expect(engine.state.remainingSeconds, afterFirst.remainingSeconds);
      expect(engine.state.skippedPhaseCount, afterFirst.skippedPhaseCount);
      expect(engine.state.isCompleted, afterFirst.isCompleted);
      expect(engine.state.isAbandoned, afterFirst.isAbandoned);
    });
  });
}
