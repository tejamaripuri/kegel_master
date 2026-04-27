import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';
import 'package:kegel_master/features/session/domain/session_engine.dart';

void main() {
  group('SessionEngine', () {
    const SessionConfig config = SessionConfig(
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
  });
}
