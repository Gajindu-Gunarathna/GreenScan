import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  final List<Map<String, dynamic>> _notifications = [];

  int get unreadCount => _unreadCount;
  List<Map<String, dynamic>> get notifications => _notifications;

  void addNotification(String title, String body) {
    _notifications.insert(0, {
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    });
    _unreadCount++;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _notifications) {
      n['isRead'] = true;
    }
    _unreadCount = 0;
    notifyListeners();
  }
}
