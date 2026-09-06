import 'package:flutter/foundation.dart';

class InquiryService {
  static final List<Map<String, String>> _inquiries = [];
  static final Map<String, List<Map<String, dynamic>>> _threadMessages = {};

  // Real-time update notifier for instant UI updates across reseller and customer screens
  static final ValueNotifier<int> updateNotifier = ValueNotifier<int>(0);

  static void _notifyListeners() {
    updateNotifier.value++;
  }

  static List<Map<String, String>> get inquiries => _inquiries;

  static List<Map<String, dynamic>> getThreadMessages(String customerName, String productTitle) {
    final cleanCustomer = customerName.trim();
    final cleanProduct = productTitle.trim();
    final key = '${cleanCustomer}_$cleanProduct';
    if (!_threadMessages.containsKey(key)) {
      _threadMessages[key] = [];
    }
    return _threadMessages[key]!;
  }

  static void addMessageToThread({
    required String customerName,
    required String productTitle,
    required String price,
    required Map<String, dynamic> message,
    String? avatar,
    String? image,
    String? phone,
  }) {
    final cleanCustomer = customerName.trim();
    final cleanProduct = productTitle.trim();
    final key = '${cleanCustomer}_$cleanProduct';
    if (!_threadMessages.containsKey(key)) {
      _threadMessages[key] = [];
    }

    // Deduplicate exact message map if already added
    bool exists = false;
    for (final existingMsg in _threadMessages[key]!) {
      if (existingMsg['text'] == message['text'] &&
          existingMsg['sender'] == message['sender'] &&
          existingMsg['time'] == message['time'] &&
          existingMsg['type'] == message['type']) {
        exists = true;
        break;
      }
    }
    if (!exists) {
      _threadMessages[key]!.add(message);
    }

    final index = _inquiries.indexWhere((item) =>
        (item['customerName'] ?? '').trim() == cleanCustomer &&
        (item['productTitle'] ?? '').trim() == cleanProduct);

    final String lastMsgText = (message['type'] == 'image')
        ? '📷 Photo Attachment'
        : (message['text'] as String? ?? '');

    final String timeStr = message['time'] as String? ?? 'Just now';

    if (index >= 0) {
      final item = _inquiries.removeAt(index);
      item['lastMessage'] = lastMsgText;
      item['time'] = timeStr;
      if (message['sender'] == 'customer') {
        item['unread'] = 'true';
      }
      _inquiries.insert(0, item);
    } else {
      _inquiries.insert(0, {
        'customerName': cleanCustomer.isNotEmpty ? cleanCustomer : 'Jay',
        'customerRole': 'Student • Campus Peer',
        'productTitle': cleanProduct,
        'price': price,
        'lastMessage': lastMsgText,
        'time': timeStr,
        'unread': message['sender'] == 'customer' ? 'true' : 'false',
        'avatar': avatar ?? (cleanCustomer.isNotEmpty ? cleanCustomer[0].toUpperCase() : 'J'),
        'image': image ?? '',
        'phone': phone ?? '+91 98765 43210',
      });
    }

    _notifyListeners();
  }

  static void recordInquiry({
    required String customerName,
    required String productTitle,
    required String price,
    required String lastMessage,
    String? avatar,
    String? image,
    String? phone,
  }) {
    final msg = {
      'sender': 'customer',
      'senderName': customerName,
      'type': 'text',
      'text': lastMessage,
      'time': 'Just now',
    };
    addMessageToThread(
      customerName: customerName,
      productTitle: productTitle,
      price: price,
      message: msg,
      avatar: avatar,
      image: image,
      phone: phone,
    );
  }

  static void markAsRead(int index) {
    if (index >= 0 && index < _inquiries.length) {
      _inquiries[index]['unread'] = 'false';
      _notifyListeners();
    }
  }
}
