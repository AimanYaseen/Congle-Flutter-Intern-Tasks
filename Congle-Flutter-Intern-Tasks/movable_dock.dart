import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Dock(
            items: const [
              Icons.home,
              Icons.search,
              Icons.work,
              Icons.settings,
              Icons.person,
              Icons.email,
              Icons.photo_camera,
              Icons.music_note,
            ],
            builder: (context, icon, isHovered) {
              return Container(
                width: isHovered ? 60 : 48,
                height: isHovered ? 60 : 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isHovered ? 30 : 24,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  final List<T> items;
  final Widget Function(BuildContext, T, bool isHovered) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late List<T> _items;
  final List<bool> _hoverStates = [];
  final List<GlobalKey> _itemKeys = [];

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
    _hoverStates.addAll(List.filled(widget.items.length, false));
    _itemKeys.addAll(List.generate(widget.items.length, (index) => GlobalKey()));
  }

  void _updateHoverState(int index, bool isHovering) {
    setState(() {
      _hoverStates[index] = isHovering;
    });
  }

  void _handleDragAccept(DragTargetDetails<int> details, int targetIndex) {
    final draggedIndex = details.data;
    if (draggedIndex == targetIndex) return;

    setState(() {
      final item = _items.removeAt(draggedIndex);
      _items.insert(targetIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];

          return Draggable<int>(
            key: _itemKeys[index],
            data: index,
            feedback: Material(
              type: MaterialType.transparency,
              child: Transform.scale(
                scale: 1.2,
                child: Opacity(
                  opacity: 0.8,
                  child: widget.builder(context, item, true),
                ),
              ),
            ),
            childWhenDragging: Container(width: 48, height: 48), // Empty space
            child: DragTarget<int>(
              onAcceptWithDetails: (details) => _handleDragAccept(details, index),
              builder: (context, candidateData, rejectedData) {
                return GestureDetector(
                  onTap: () {}, // Empty to prevent tap conflicts
                  child: MouseRegion(
                    onEnter: (_) => _updateHoverState(index, true),
                    onExit: (_) => _updateHoverState(index, false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: widget.builder(context, item, _hoverStates[index]),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}