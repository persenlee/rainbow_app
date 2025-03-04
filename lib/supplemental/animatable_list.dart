import 'package:flutter/material.dart';

class AnimatableList<E> {
  AnimatableList({
    @required this.listKey,
    @required this.removedItemBuilder,
    Iterable<E> initialItems,
  })  : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<E> _items;

  AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  List<E> unwrapList() {
    return _items;
  }

  void addAll(Iterable<E> iterable){
    _items.addAll(iterable);
  }

  void clear() {
    _items.clear();
  }

  bool remove(E item){
    if (item == null) {
      return false;
    }
    int index = _items.indexOf(item);
    if (index >= 0 && index < _items.length) {
       return this.removeAt(index) !=null;
    }
    return false;
  }
  
  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(index,
          (BuildContext context, Animation<double> animation) {
        return removedItemBuilder(removedItem, context, animation);
      });
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}