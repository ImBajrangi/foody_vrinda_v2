import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';

class TrackingScreen extends StatefulWidget {
  final String? orderId;
  const TrackingScreen({super.key, this.orderId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Define the route points as normalized coordinates (0.0 to 1.0)
  final List<Offset> _routePoints = [
    const Offset(0.3, 0.75), // Start
    const Offset(0.4, 0.55),
    const Offset(0.6, 0.5),
    const Offset(0.55, 0.25), // End
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..forward();
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuad,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getPositionAt(double progress) {
    if (_routePoints.isEmpty) return Offset.zero;
    if (progress <= 0) return _routePoints.first;
    if (progress >= 1) return _routePoints.last;

    final totalSegments = _routePoints.length - 1;
    final segmentDecimal = progress * totalSegments;
    final index = segmentDecimal.floor();
    final segmentProgress = segmentDecimal - index;

    final start = _routePoints[index];
    final end = _routePoints[index + 1];

    return Offset(
      start.dx + (end.dx - start.dx) * segmentProgress,
      start.dy + (end.dy - start.dy) * segmentProgress,
    );
  }

  double _getTargetProgress(OrderStatus? status) {
    if (status == null) return 0.0;
    switch (status) {
      case OrderStatus.newOrder: return 0.0;
      case OrderStatus.preparing: return 0.25;
      case OrderStatus.readyForPickup: return 0.5;
      case OrderStatus.outForDelivery: return 0.75;
      case OrderStatus.completed: return 1.0;
      default: return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderService = context.read<OrderService>();
    final stream = widget.orderId != null 
        ? orderService.orderStream(widget.orderId!) 
        : null;

    if (stream == null) return _buildScaffold(context, 0.5, null);

    return StreamBuilder<OrderModel?>(
      stream: stream,
      builder: (context, snapshot) {
        final order = snapshot.data;
        final targetProgress = _getTargetProgress(order?.status);
        
        // Smoothly animate to the new target progress
        _controller.animateTo(
          targetProgress,
          duration: const Duration(seconds: 3),
          curve: Curves.easeInOut,
        );

        return _buildScaffold(context, _animation.value, order);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, double currentProgress, OrderModel? order) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Map Area (60%)
          Expanded(
            flex: 6,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final riderPos = _getPositionAt(currentProgress);
                final destPos = _routePoints.last;
                
                return Stack(
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
                    CustomPaint(
                      size: Size.infinite, 
                      painter: _RoutePainter(
                        points: _routePoints,
                        progress: currentProgress,
                      )
                    ),
                    // Destination marker
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.6 * destPos.dy,
                      left: MediaQuery.of(context).size.width * destPos.dx,
                      child: _pulseDot(),
                    ),
                    // Rider marker
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.6 * riderPos.dy,
                      left: MediaQuery.of(context).size.width * riderPos.dx,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -0.5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                                imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
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
                                    _animation.value < 0.3 
                                      ? 'Rider just picked up order' 
                                      : _animation.value > 0.8 
                                        ? 'Rider is arriving soon!' 
                                        : 'Rider stopped at light (2m)',
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
                );
              },
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
                            MonoLabel(order?.status == OrderStatus.completed ? 'Arrived at' : 'Estimated Arrival'),
                            const SizedBox(height: 4),
                            Text(
                              order?.status == OrderStatus.completed ? 'JUST NOW' : '12:42 PM',
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
                            color: (order?.status == OrderStatus.completed ? AppTheme.success : AppTheme.primary).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: (order?.status == OrderStatus.completed ? AppTheme.success : AppTheme.primary).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            (order?.status.name ?? 'ON TIME').toUpperCase().replaceAll('_', ' '),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: order?.status == OrderStatus.completed ? AppTheme.success : AppTheme.primary,
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
                        _buildTimeline(order?.status),
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

  Widget _pulseDot() => Stack(
    alignment: Alignment.center,
    children: [
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 2),
        builder: (context, value, child) {
          return Container(
            width: 32 * (1.0 + value),
            height: 32 * (1.0 + value),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withValues(alpha: 0.2 * (1.0 - value)),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.5 * (1.0 - value)),
              ),
            ),
          );
        },
      ),
      Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primary,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildTimeline(OrderStatus? currentStatus) {
    final statusIndex = currentStatus != null ? OrderStatus.values.indexOf(currentStatus) : 0;
    
    final steps = [
      {'label': 'Order Confirmed', 'time': '12:15 PM', 'idx': 0},
      {'label': 'Kitchen Preparing', 'time': '12:28 PM', 'idx': 1},
      {
        'label': 'Rider Picked Up',
        'time': '12:35 PM • Heading to you',
        'idx': 3, // outForDelivery
      },
      {'label': 'Arriving', 'time': '~ 7 mins', 'idx': 4}, // delivered
    ];
    return Container(
      padding: const EdgeInsets.only(left: 16),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(
        children: steps.map((step) {
          final stepIdx = step['idx'] as int;
          final done = statusIndex > stepIdx;
          final active = statusIndex == stepIdx;
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
                      step['label'].toString(),
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
                      step['time'].toString(),
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
                  'RAHUL S.',
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
                      child: const MonoLabel('EV ECO-SCOOTER'),
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
  final List<Offset> points;
  final double progress;

  _RoutePainter({required this.points, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // 1. Draw Remaining (Gray/Dashed)
    final remainingPaint = Paint()
      ..color = AppTheme.borderDark
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fullPath = Path();
    fullPath.moveTo(size.width * points.first.dx, size.height * points.first.dy);
    for (var i = 1; i < points.length; i++) {
      fullPath.lineTo(size.width * points[i].dx, size.height * points[i].dy);
    }

    // Draw full path dashed
    const dashLength = 10.0;
    const gapLength = 6.0;
    final metrics = fullPath.computeMetrics();
    for (final m in metrics) {
      double d = 0;
      while (d < m.length) {
        final end = (d + dashLength).clamp(0.0, m.length);
        canvas.drawPath(m.extractPath(d, end), remainingPaint);
        d += dashLength + gapLength;
      }
    }

    // 2. Draw Traversed (Success Color/Solid)
    final traversedPaint = Paint()
      ..color = AppTheme.success
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final m in metrics) {
      final totalLen = m.length;
      final currentLen = totalLen * progress;
      if (currentLen > 0) {
        canvas.drawPath(m.extractPath(0, currentLen), traversedPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => 
      oldDelegate.points != points || oldDelegate.progress != progress;
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
