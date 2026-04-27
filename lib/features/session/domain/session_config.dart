class SessionConfig {
  const SessionConfig({
    required this.squeezeSeconds,
    required this.relaxSeconds,
    required this.bufferBetweenSetsSeconds,
    required this.repsPerSet,
    required this.targetSets,
  });

  final int squeezeSeconds;
  final int relaxSeconds;
  final int bufferBetweenSetsSeconds;
  final int repsPerSet;
  final int targetSets;

  static const SessionConfig defaults = SessionConfig(
    squeezeSeconds: 5,
    relaxSeconds: 5,
    bufferBetweenSetsSeconds: 10,
    repsPerSet: 10,
    targetSets: 3,
  );
}
