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

  final List<Offset> _routePoints = [
    const Offset(0.3, 0.75), 
    const Offset(0.4, 0.55),
    const Offset(0.6, 0.5),
    const Offset(0.55, 0.25), 
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
          Expanded(
            flex: 6,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final riderPos = _getPositionAt(currentProgress);
                final destPos = _routePoints.last;
                
                return Stack(
                  children: [
                    Container(
                      color: const Color(0xFF111111),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _GridPainter(),
                      ),
                    ),
                    CustomPaint(
                      size: Size.infinite, 
                      painter: _RoutePainter(
                        points: _routePoints,
                        progress: currentProgress,
                      )
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.6 * destPos.dy,
                      left: MediaQuery.of(context).size.width * destPos.dx,
                      child: _pulseDot(),
                    ),
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
                              Icons.bolt,
                              color: AppTheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const MonoLabel('LIVE ENGINE STATUS'),
                                  const SizedBox(height: 2),
                                  Text(
                                    order?.statusMessage.toUpperCase() ?? 'INITIALIZING...',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
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
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(top: BorderSide(color: AppTheme.borderDark)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF18181A),
                      border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MonoLabel(order?.status == OrderStatus.completed ? 'ARRIVED_AT' : 'ESTIMATED_ARRIVAL'),
                            const SizedBox(height: 4),
                            Text(
                              order?.status == OrderStatus.completed ? 'JUST NOW' : (order?.etaTime ?? '...'),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (order?.status == OrderStatus.completed ? AppTheme.success : AppTheme.primary).withValues(alpha: 0.1),
                            border: Border.all(color: order?.status == OrderStatus.completed ? AppTheme.success : AppTheme.primary),
                          ),
                          child: Text(
                            (order?.status.displayName ?? 'PENDING').toUpperCase(),
                            style: AppTheme.monoSmall.copyWith(
                              color: order?.status == OrderStatus.completed ? AppTheme.success : AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5 * (1.0 - value))),
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
          boxShadow: [BoxShadow(color: AppTheme.primary, blurRadius: 10, spreadRadius: 2)],
        ),
      ),
    ],
  );

  Widget _buildTimeline(OrderStatus? currentStatus) {
    final statusIndex = currentStatus != null ? OrderStatus.values.indexOf(currentStatus) : 0;
    
    final steps = [
      {'label': 'ORDER_CONFIRMED', 'idx': 0},
      {'label': 'KITCHEN_PREPARING', 'idx': 1},
      {'label': 'RIDER_PICKED_UP', 'idx': 3},
      {'label': 'DELIVERED', 'idx': 4},
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
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: done ? AppTheme.success : (active ? AppTheme.primary : AppTheme.borderDark),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  step['label'].toString(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w900 : FontWeight.w500,
                    color: active ? Colors.white : AppTheme.textSecondary,
                  ),
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
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderDark),
          ),
          clipBehavior: Clip.antiAlias,
          child: CachedNetworkImage(
            imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&q=80',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RAHUL S.',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const MonoLabel('EV EXEC-01 // RATING 4.9'),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primary),
          ),
          child: const Icon(Icons.phone, color: AppTheme.primary, size: 16),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1A1A1A)..strokeWidth = 1;
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
    final remainingPaint = Paint()..color = AppTheme.borderDark..strokeWidth = 2..style = PaintingStyle.stroke;
    final traversedPaint = Paint()..color = AppTheme.primary..strokeWidth = 3..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(size.width * points.first.dx, size.height * points.first.dy);
    for (var i = 1; i < points.length; i++) {
        path.lineTo(size.width * points[i].dx, size.height * points[i].dy);
    }
    canvas.drawPath(path, remainingPaint);
    final metrics = path.computeMetrics();
    for (final m in metrics) {
        canvas.drawPath(m.extractPath(0, m.length * progress), traversedPaint);
    }
  }
  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => true;
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.primary..style = PaintingStyle.fill;
    final path = Path()..moveTo(size.width / 2, 0)..lineTo(0, size.height)..lineTo(size.width, size.height)..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
