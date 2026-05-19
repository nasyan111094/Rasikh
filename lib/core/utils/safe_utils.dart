extension SafeList<E> on Iterable<E> {
  E? safeElementAt(int index) {
    if (index < length && index >= 0) {
      return elementAt(index);
    }
    return null;
  }

  E? get safeFirst {
    if (isNotEmpty) {
      return first;
    }
    return null;
  }

  E? get safeLast {
    if (isNotEmpty) {
      return last;
    }
    return null;
  }

  E? safeFirstWhere(bool Function(E e) predicate) {
    if (any(predicate)) {
      return firstWhere(predicate);
    }
    return null;
  }
}

extension EnumByName<E extends Enum> on Iterable<E> {
  E? safeByName(String name) {
    if (any((e) => e.name == name)) {
      return byName(name);
    }
    return null;
  }
}
