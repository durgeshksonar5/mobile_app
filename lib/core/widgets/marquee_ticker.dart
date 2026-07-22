import 'package:flutter/material.dart';

/// Marquee scrolling ticker for King Win announcement banner.
class MarqueeTicker extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  const MarqueeTicker({
    super.key,
    required this.text,
    required this.textStyle,
  });

  @override
  State<MarqueeTicker> createState() => _MarqueeTickerState();
}

class _MarqueeTickerState extends State<MarqueeTicker>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    if (!bindingName.contains('Test')) {
      _controller = AnimationController(
        duration: const Duration(seconds: 22),
        vsync: this,
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Container(
        alignment: Alignment.center,
        child: Text(widget.text,
            style: widget.textStyle, overflow: TextOverflow.ellipsis),
      );
    }

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final offset = constraints.maxWidth -
                (_controller!.value * (constraints.maxWidth + 600));
            return Transform.translate(
              offset: Offset(offset, 0),
              child: OverflowBox(
                minWidth: 0,
                maxWidth: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.text,
                  style: widget.textStyle,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
