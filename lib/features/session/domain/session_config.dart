class SessionConfig {
  const SessionConfig._({
    required this.squeezeSeconds,
    required this.relaxSeconds,
    required this.bufferBetweenSetsSeconds,
    required this.repsPerSet,
    required this.targetSets,
  });

  factory SessionConfig({
    required int squeezeSeconds,
    required int relaxSeconds,
    required int bufferBetweenSetsSeconds,
    required int repsPerSet,
    required int targetSets,
  }) {
    if (squeezeSeconds < 0) {
      throw ArgumentError.value(squeezeSeconds, 'squeezeSeconds', 'must be non-negative');
    }
    if (relaxSeconds < 0) {
      throw ArgumentError.value(relaxSeconds, 'relaxSeconds', 'must be non-negative');
    }
    if (bufferBetweenSetsSeconds < 0) {
      throw ArgumentError.value(
        bufferBetweenSetsSeconds,
        'bufferBetweenSetsSeconds',
        'must be non-negative',
      );
    }
    if (repsPerSet < 1) {
      throw ArgumentError.value(repsPerSet, 'repsPerSet', 'must be >= 1');
    }
    if (targetSets < 1) {
      throw ArgumentError.value(targetSets, 'targetSets', 'must be >= 1');
    }
    return SessionConfig._(
      squeezeSeconds: squeezeSeconds,
      relaxSeconds: relaxSeconds,
      bufferBetweenSetsSeconds: bufferBetweenSetsSeconds,
      repsPerSet: repsPerSet,
      targetSets: targetSets,
    );
  }

  final int squeezeSeconds;
  final int relaxSeconds;
  final int bufferBetweenSetsSeconds;
  final int repsPerSet;
  final int targetSets;

  static const SessionConfig defaults = SessionConfig._(
    squeezeSeconds: 5,
    relaxSeconds: 5,
    bufferBetweenSetsSeconds: 10,
    repsPerSet: 10,
    targetSets: 3,
  );

  SessionConfig copyWith({
    int? squeezeSeconds,
    int? relaxSeconds,
    int? bufferBetweenSetsSeconds,
    int? repsPerSet,
    int? targetSets,
  }) {
    return SessionConfig(
      squeezeSeconds: squeezeSeconds ?? this.squeezeSeconds,
      relaxSeconds: relaxSeconds ?? this.relaxSeconds,
      bufferBetweenSetsSeconds:
          bufferBetweenSetsSeconds ?? this.bufferBetweenSetsSeconds,
      repsPerSet: repsPerSet ?? this.repsPerSet,
      targetSets: targetSets ?? this.targetSets,
    );
  }
}
