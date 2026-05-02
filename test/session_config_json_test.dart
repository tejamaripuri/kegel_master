import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

void main() {
  test('roundtrip SessionConfig json', () {
    final SessionConfig original = SessionConfig(
      squeezeSeconds: 4,
      relaxSeconds: 6,
      bufferBetweenSetsSeconds: 8,
      repsPerSet: 12,
      targetSets: 2,
    );
    final json = original.toJson();
    final restored = SessionConfig.fromJson(json);
    expect(restored.squeezeSeconds, 4);
    expect(restored.relaxSeconds, 6);
    expect(restored.bufferBetweenSetsSeconds, 8);
    expect(restored.repsPerSet, 12);
    expect(restored.targetSets, 2);
  });
}
