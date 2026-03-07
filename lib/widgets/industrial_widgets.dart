import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';

class HardShadowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? radius;

  const HardShadowCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = (color ?? AppTheme.primary).withValues(alpha: 0.1);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(radius ?? AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderDark),
        boxShadow: const [AppTheme.hardShadow],
      ),
      child: child,
    );
  }
}

class MonoLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;

  const MonoLabel(this.text, {super.key, this.color, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? AppTheme.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }
}

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Widget? icon;
  final Widget? trailing;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        margin: _isPressed
            ? const EdgeInsets.only(top: 4, left: 4)
            : EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          boxShadow: _isPressed ? null : const [AppTheme.hardShadow],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 8),
            ],
            Text(
              widget.label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            if (widget.trailing != null) ...[const Spacer(), widget.trailing!],
          ],
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isSelected ? Colors.black : AppTheme.borderDark,
            width: 2,
          ),
          boxShadow: isSelected ? null : const [AppTheme.hardShadow],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchScoreBadge extends StatelessWidget {
  final int score;
  const MatchScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.success,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.analytics, size: 10, color: Colors.black),
          const SizedBox(width: 4),
          Text(
            '$score% MATCH',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class IndustrialTag extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;

  const IndustrialTag(
    this.text, {
    super.key,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.borderDark.withValues(alpha: 0.1),
        border: Border.all(color: textColor ?? AppTheme.borderDark),
        borderRadius: BorderRadius.circular(2),
      ),
      child: MonoLabel(text, fontSize: 8, color: textColor),
    );
  }
}

class SlideToPayButton extends StatefulWidget {
  final double amount;
  final VoidCallback onSlideComplete;

  const SlideToPayButton({
    super.key,
    required this.amount,
    required this.onSlideComplete,
  });

  @override
  State<SlideToPayButton> createState() => _SlideToPayButtonState();
}

class _SlideToPayButtonState extends State<SlideToPayButton> {
  double _dragValue = 0;
  bool _isComplete = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.borderDark, width: 2),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxSlide = constraints.maxWidth - 60;
          return Stack(
            children: [
              Center(
                child: MonoLabel(
                  'SLIDE TO PAY \$${widget.amount.toStringAsFixed(2)}',
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              Positioned(
                left: _dragValue,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isComplete) return;
                    setState(() {
                      _dragValue = (_dragValue + details.delta.dx).clamp(
                        0.0,
                        maxSlide,
                      );
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragValue > maxSlide * 0.8) {
                      setState(() {
                        _dragValue = maxSlide;
                        _isComplete = true;
                      });
                      widget.onSlideComplete();
                    } else {
                      setState(() {
                        _dragValue = 0;
                      });
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [AppTheme.hardShadow],
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
