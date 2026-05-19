class Repeater<T> {
  final List<T> items;

  Repeater(this.items);

  int index = 0;

  T get() {
    if (index >= items.length) {
      index = 0;
    }
    final item = items[index];
    index++;
    return item;
  }

  T getOf(int index) => items[index % items.length];
}
