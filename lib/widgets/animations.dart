import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../config/lottie_assets.dart';
import '../config/app_theme.dart';

/// Animated loading indicator with Lottie
class AnimatedLoader extends StatefulWidget {
  final double size;
  final String? message;

  const AnimatedLoader({super.key, this.size = 150, this.message});

  @override
  State<AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader> {
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showAnimation = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showAnimation ? 1.0 : 0.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_showAnimation)
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: RepaintBoundary(
                child: LottieAssets.build(
                  LottieAssets.foodLoading,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          if (widget.message != null && _showAnimation) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state with Lottie animation
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String animationUrl;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    required this.animationUrl,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: RepaintBoundary(
                child: LottieAssets.build(
                  animationUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Success animation overlay
class SuccessAnimationOverlay extends StatefulWidget {
  final VoidCallback? onComplete;
  final String? message;

  const SuccessAnimationOverlay({super.key, this.onComplete, this.message});

  @override
  State<SuccessAnimationOverlay> createState() => _SuccessAnimationOverlayState();
}

class _SuccessAnimationOverlayState extends State<SuccessAnimationOverlay> {
  @override
  void initState() {
    super.initState();
    if (widget.onComplete != null) {
      Future.delayed(const Duration(milliseconds: 2500), widget.onComplete);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: RepaintBoundary(
                child: LottieAssets.build(
                  LottieAssets.orderSuccess,
                  repeat: false,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 24),
              Text(
                widget.message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bouncy add to cart button
class BouncyAddButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isAdded;
  final String label;

  const BouncyAddButton({
    super.key, 
    this.onPressed, 
    this.isAdded = false,
    this.label = 'ADD TO CART',
  });

  @override
  State<BouncyAddButton> createState() => _BouncyAddButtonState();
}

class _BouncyAddButtonState extends State<BouncyAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BouncyAddButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAdded && !oldWidget.isAdded) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: widget.isAdded ? AppTheme.success : AppTheme.primary,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [AppTheme.hardShadow],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.isAdded ? Icons.check_rounded : Icons.add_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.isAdded ? 'ADDED!' : widget.label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pulse animation wrapper
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final bool animate;

  const PulseAnimation({super.key, required this.child, this.animate = true});

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && oldWidget.animate) {
      _controller.stop();
      _controller.animateTo(0, duration: const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}

/// Celebration confetti overlay
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: RepaintBoundary(
            child: LottieAssets.build(
              LottieAssets.confetti,
              fit: BoxFit.cover,
              repeat: false,
            ),
          ),
        ),
      ),
    );
  }
}
