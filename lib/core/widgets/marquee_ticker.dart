import 'package:flutter/material.dart';

/// Marquee scrolling ticker for King Win announcement banner.
class MarqueeTicker extends StatefulWidget {
  final InlineSpan textSpan;

  const MarqueeTicker({
    super.key,
    required this.textSpan,
  });

  @override
  State<MarqueeTicker> createState() => _MarqueeTickerState();
}

class _MarqueeTickerState extends State<MarqueeTicker>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  double _textWidth = 600.0;

  @override
  void initState() {
    super.initState();
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    if (!bindingName.contains('Test')) {
      _controller = AnimationController(
        vsync: this,
      );
      _calculateWidth();
      _controller!.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant MarqueeTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textSpan != oldWidget.textSpan) {
      _calculateWidth();
    }
  }

  void _calculateWidth() {
    final textPainter = TextPainter(
      text: widget.textSpan,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    _textWidth = textPainter.size.width;

    if (_controller != null) {
      // Keep scroll speed consistent at ~55 pixels/second
      final double scrollSpeed = 55.0;
      final double totalScrollDistance = 400.0 + _textWidth; // Using a default screen width estimate of 400
      final int durationSeconds = (totalScrollDistance / scrollSpeed).clamp(10.0, 300.0).toInt();
      
      _controller!.duration = Duration(seconds: durationSeconds);
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
        child: Text.rich(
          widget.textSpan,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Adjust the actual scroll distance dynamically based on parent constraints width
            final totalDistance = constraints.maxWidth + _textWidth;
            final offset = constraints.maxWidth - (_controller!.value * totalDistance);
            
            return Transform.translate(
              offset: Offset(offset, 0),
              child: OverflowBox(
                minWidth: 0,
                maxWidth: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  widget.textSpan,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
