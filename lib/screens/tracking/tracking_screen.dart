import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Map Area (60%)
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                // Grid pattern background
                Container(
                  color: const Color(0xFF111111),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _GridPainter(),
                  ),
                ),
                // Route line
                CustomPaint(size: Size.infinite, painter: _RoutePainter()),
                // Destination marker
                Positioned(
                  top: 130,
                  left: MediaQuery.of(context).size.width * 0.55,
                  child: _pulseDot(),
                ),
                // Rider marker
                Positioned(
                  top: 280,
                  left: MediaQuery.of(context).size.width * 0.35,
                  child: Column(
                    children: [
                      CustomPaint(
                        size: const Size(20, 20),
                        painter: _ArrowPainter(),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [AppTheme.hardShadow],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBtxzTSpwD7ymXH8Sx6_YMluG00XCFwa_TizFynnoQYp2XKskf3PCRiGFBVSa8mA4w6SjuMnjTIyxRzJGjpFBfZvNYBiIiUSj_4HfedahlL3GsEJbpsskef0S_4acm4lFsQTOqmxegWmOyrwaQBsorhnCYGVOhykCKSSuIuPdoKXxHhL84uIh1H-_B53O0lThH4RUOc1Ekinyfy8s0DJFEdJuzRNrfOS0RocBCrkJqPVR6msBlIPZ9L3TgUy9SfAKXvVmUFEiCcrrXN',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                // Alert
                Positioned(
                  top: MediaQuery.of(context).padding.top + 60,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.borderDark),
                      boxShadow: const [AppTheme.hardShadow],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MonoLabel('Live Status'),
                              const SizedBox(height: 2),
                              Text(
                                'Rider stopped at light (2m)',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.borderDark),
                        boxShadow: const [AppTheme.hardShadow],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Help button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 16,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.borderDark),
                      boxShadow: const [AppTheme.hardShadow],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.support_agent,
                          color: AppTheme.success,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'HELP',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Status Card (40%)
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: const Border(
                  top: BorderSide(color: AppTheme.borderDark),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -4),
                    blurRadius: 20,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ETA Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF18181A),
                      border: Border(
                        bottom: BorderSide(color: AppTheme.borderDark),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MonoLabel('Estimated Arrival'),
                            const SizedBox(height: 4),
                            Text(
                              '12:42 PM',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: AppTheme.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'ON TIME',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Timeline + Rider
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildTimeline(),
                        const Divider(color: AppTheme.borderDark, height: 32),
                        _buildRiderCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pulseDot() => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppTheme.primary.withValues(alpha: 0.2),
      border: Border.all(color: AppTheme.primary),
    ),
    child: Center(
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primary,
        ),
      ),
    ),
  );

  Widget _buildTimeline() {
    final steps = [
      {'label': 'Order Confirmed', 'time': '12:15 PM', 'status': 'done'},
      {'label': 'Kitchen Preparing', 'time': '12:28 PM', 'status': 'done'},
      {
        'label': 'Rider Picked Up',
        'time': '12:35 PM • Heading to you',
        'status': 'active',
      },
      {'label': 'Arriving', 'time': '~ 7 mins', 'status': 'pending'},
    ];
    return Container(
      padding: const EdgeInsets.only(left: 16),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(
        children: steps.map((step) {
          final done = step['status'] == 'done';
          final active = step['status'] == 'active';
          return Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 20),
            child: Stack(
              children: [
                Positioned(
                  left: -32,
                  top: 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? const Color(0xFF555555)
                          : active
                          ? AppTheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: done
                            ? const Color(0xFF555555)
                            : active
                            ? AppTheme.primary
                            : const Color(0xFF555555),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['label']!,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: done
                            ? const Color(0xFF555555)
                            : active
                            ? Colors.white
                            : Colors.grey[400],
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: const Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step['time']!,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: active
                            ? AppTheme.primary
                            : const Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRiderCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.borderDark),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBtxzTSpwD7ymXH8Sx6_YMluG00XCFwa_TizFynnoQYp2XKskf3PCRiGFBVSa8mA4w6SjuMnjTIyxRzJGjpFBfZvNYBiIiUSj_4HfedahlL3GsEJbpsskef0S_4acm4lFsQTOqmxegWmOyrwaQBsorhnCYGVOhykCKSSuIuPdoKXxHhL84uIh1H-_B53O0lThH4RUOc1Ekinyfy8s0DJFEdJuzRNrfOS0RocBCrkJqPVR6msBlIPZ9L3TgUy9SfAKXvVmUFEiCcrrXN',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JASON B.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: const MonoLabel('YAMAHA NMAX'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '★ 4.9',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.call, color: AppTheme.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                'CALL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.success
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dashPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.75)
      ..lineTo(size.width * 0.4, size.height * 0.55)
      ..lineTo(size.width * 0.6, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.25);
    // Draw dashed
    const dashLength = 10.0;
    const gapLength = 5.0;
    final metrics = dashPath.computeMetrics();
    for (final m in metrics) {
      double d = 0;
      while (d < m.length) {
        final end = (d + dashLength).clamp(0.0, m.length);
        canvas.drawPath(m.extractPath(d, end), paint);
        d += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
