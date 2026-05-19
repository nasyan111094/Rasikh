typedef StateExtractor<S> = dynamic Function(S s);

bool Function(S p, S c) compareStates<S>(List<StateExtractor<S>> extractors) => (p, c) => extractors.any((e) => e(p) != e(c));
