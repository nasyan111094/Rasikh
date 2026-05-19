import 'dart:math';

class Shuffler<T> {
  final random = Random();
  final List<T> items;
  final List<T> lastUsedItems = [];

  Shuffler(this.items);

  T get() {
    final notUsedItems = [...items.where((e) => !lastUsedItems.contains(e))];
    final index = random.nextInt(notUsedItems.length);
    final item = notUsedItems[index];
    lastUsedItems.add(item);
    if (lastUsedItems.length >= (items.length / 2).floor()) {
      lastUsedItems.removeAt(0);
    }
    return item;
  }
}
