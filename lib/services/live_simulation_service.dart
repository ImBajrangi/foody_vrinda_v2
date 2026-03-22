import 'dart:async';
import '../services/order_service.dart';
import '../models/order_model.dart';

class LiveSimulationService {
  final OrderService _orderService;
  
  LiveSimulationService(this._orderService);

  void startSimulation(String orderId) {
    Timer(const Duration(seconds: 5), () {
      _orderService.updateOrderStatus(orderId, OrderStatus.preparing);
    });

    Timer(const Duration(seconds: 15), () {
      _orderService.updateOrderStatus(orderId, OrderStatus.readyForPickup);
    });

    Timer(const Duration(seconds: 25), () {
      _orderService.updateOrderStatus(orderId, OrderStatus.outForDelivery);
    });

    Timer(const Duration(seconds: 40), () {
      _orderService.updateOrderStatus(orderId, OrderStatus.completed);
    });
  }
}
