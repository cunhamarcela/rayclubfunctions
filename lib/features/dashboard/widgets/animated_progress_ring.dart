// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget de anel de progresso animado para o calendário fitness
class AnimatedProgressRing extends StatefulWidget {
  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;
  final Duration duration;

  const AnimatedProgressRing({
    Key? key,
    required this.progress,
    required this.color,
    this.size = 36,
    this.strokeWidth = 3,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: AnimatedRingPainter(
            progress: _animation.value,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

/// Painter para o anel de progresso animado
class AnimatedRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  AnimatedRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Anel de fundo
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Anel de progresso
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * (progress / 100);
      const startAngle = -math.pi / 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is AnimatedRingPainter &&
        (oldDelegate.progress != progress ||
         oldDelegate.color != color ||
         oldDelegate.strokeWidth != strokeWidth);
  }
}

/// Widget de múltiplos anéis animados (para o calendário)
class AnimatedActivityRings extends StatelessWidget {
  final double moveProgress;
  final double exerciseProgress;
  final double standProgress;
  final double size;
  final Duration duration;

  const AnimatedActivityRings({
    Key? key,
    required this.moveProgress,
    required this.exerciseProgress,
    required this.standProgress,
    this.size = 36,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anel externo (Move - Laranja)
          AnimatedProgressRing(
            progress: moveProgress,
            color: const Color(0xFFF38638),
            size: size,
            strokeWidth: 3,
            duration: duration,
          ),
          
          // Anel médio (Exercise - Roxo)
          AnimatedProgressRing(
            progress: exerciseProgress,
            color: const Color(0xFFCDA8F0),
            size: size * 0.75,
            strokeWidth: 3,
            duration: Duration(milliseconds: duration.inMilliseconds + 200),
          ),
          
          // Anel interno (Stand - Rosa)
          AnimatedProgressRing(
            progress: standProgress,
            color: const Color(0xFFEFB9B7),
            size: size * 0.5,
            strokeWidth: 3,
            duration: Duration(milliseconds: duration.inMilliseconds + 400),
          ),
        ],
      ),
    );
  }
}

/// Widget de progresso animado para barras
class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color color;
  final double height;
  final Duration duration;

  const AnimatedProgressBar({
    Key? key,
    required this.progress,
    required this.color,
    this.height = 8,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget de contador animado
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle? textStyle;
  final Duration duration;

  const AnimatedCounter({
    Key? key,
    required this.value,
    this.textStyle,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _animation.value.round().toString(),
          style: widget.textStyle,
        );
      },
    );
  }
} 