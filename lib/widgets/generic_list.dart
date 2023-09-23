import 'package:first_priority_app/async_search_delegate.dart';
import 'package:flutter/material.dart';

class GenericList<T> extends StatefulWidget {
  final Widget title;
  final Future<List<T>> Function(String) onSearch;
  final Widget Function(BuildContext, T, Function) resultBuilder;
  final Widget Function(BuildContext, T) itemBuilder;
  final ValueNotifier<List<T>> controller;

  const GenericList({
    Key key,
    @required this.title,
    @required this.onSearch,
    @required this.resultBuilder,
    @required this.itemBuilder,
    this.controller,
  }) : super(key: key);

  @override
  _GenericListState<T> createState() => _GenericListState<T>();
}

class _GenericListState<T> extends State<GenericList<T>> {
  ValueNotifier<List<T>> _items;
  ValueNotifier<List<T>> get items => widget.controller ?? _items;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _items = ValueNotifier<List<T>>([]);
    }
  }

  @override
  void dispose() {
    _items?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                margin: EdgeInsets.only(right: 5),
                child: FloatingActionButton(
                  heroTag: null,
                  elevation: 2,
                  mini: true,
                  child: Icon(Icons.add),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: AsyncSearchDelegate<T>(
                        future: widget.onSearch,
                        builder: (context, item) {
                          return widget.resultBuilder(context, item, () {
                            setState(() {
                              items.value.add(item);
                              // items.notifyListeners();
                              Navigator.of(context).pop();
                            });
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              widget.title,
            ],
          ),
          if (items.value.length > 0)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.value.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.red,
                    ),
                    alignment: Alignment(0.9, 0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      items.value.removeAt(index);
                    });
                  },
                  child: widget.itemBuilder(
                    context,
                    items.value[index],
                  ),
                );
              },
            )
        ],
      ),
    );
  }
}
