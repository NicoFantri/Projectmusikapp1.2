import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedCustomWidget extends StatefulWidget {
  final Widget child;
  final Offset? offset;
  final int? delay;

  const AnimatedCustomWidget(
      {super.key, required this.child, this.offset, this.delay});

  @override
  State<AnimatedCustomWidget> createState() => _AnimatedCustomWidgetState();
}

class _AnimatedCustomWidgetState extends State<AnimatedCustomWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _scaleAnimation =
        Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: widget.offset ?? Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    await Future.delayed(Duration(milliseconds: widget.delay ?? 550));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
