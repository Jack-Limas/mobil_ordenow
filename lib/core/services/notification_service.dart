import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> notifyOrderReady({
    required String tableLabel,
    required String orderId,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'orders_ready_channel',
        'Pedidos Listos',
        channelDescription: 'Avisos cuando tu pedido está listo para ser servido',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      orderId.hashCode & 0x7FFFFFFF,
      '¡Tu pedido está listo! 🍽',
      '$tableLabel — tu pedido está listo para ser servido.',
      details,
    );
  }
}
