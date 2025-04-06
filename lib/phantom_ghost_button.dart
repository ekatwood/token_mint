import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PhantomGhostButton extends StatefulWidget {
  final double size;

  const PhantomGhostButton({super.key, this.size = 200});

  @override
  State<PhantomGhostButton> createState() => _PhantomGhostButtonState();
}

class _PhantomGhostButtonState extends State<PhantomGhostButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _rotation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 4 * 3.14), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 4 * 3.14, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Optionally auto-play the animation once on load
    Future.delayed(const Duration(seconds: 1), () {
      _controller.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    if (!_controller.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerAnimation,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotation.value,
            child: Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          );
        },
        child: SvgPicture.asset(
          'assets/phantom-ghost.svg',
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}
