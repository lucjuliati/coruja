import 'package:flutter/material.dart';

class ResizableWidget extends StatefulWidget {
  final Widget child;
  final double? height;
  final double? minHeight;
  final double? maxHeight;

  const ResizableWidget({
    super.key,
    required this.child,
    this.height,
    this.minHeight,
    this.maxHeight,
  });

  @override
  ResizableWidgetState createState() => ResizableWidgetState();
}

class ResizableWidgetState extends State<ResizableWidget> {
  double _height = 300;
  double _minHeight = 280;
  double _maxHeight = 380;
  bool isHovering = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _height = widget.height ?? 300;
      _minHeight = widget.minHeight ?? 280;
      _maxHeight = widget.maxHeight ?? 380;
    });
  }

  void toggleHovering(bool value) {
    setState(() {
      isHovering = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: _height,
          child: widget.child,
        ),
        Positioned(
          top: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.grabbing,
            opaque: true,
            onEnter: (event) => toggleHovering(true),
            onExit: (event) => toggleHovering(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _height -= (details.delta.dy);
                    _height = _height.clamp(_minHeight, _maxHeight);
                  });
                },
                child: Container(
                  width: 50,
                  height: 6.5,
                  decoration: BoxDecoration(
                    color: isHovering
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                        : const Color.fromARGB(255, 111, 111, 123),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
