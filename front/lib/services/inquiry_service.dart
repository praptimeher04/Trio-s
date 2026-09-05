class InquiryService {
  static final List<Map<String, String>> _inquiries = [];

  static List<Map<String, String>> get inquiries => _inquiries;

  static void recordInquiry({
    required String customerName,
    required String productTitle,
    required String price,
    required String lastMessage,
    String? avatar,
    String? image,
    String? phone,
  }) {
    final index = _inquiries.indexWhere((item) =>
        item['customerName'] == customerName && item['productTitle'] == productTitle);

    if (index >= 0) {
      _inquiries[index]['lastMessage'] = lastMessage;
      _inquiries[index]['time'] = 'Just now';
      _inquiries[index]['unread'] = 'true';
    } else {
      _inquiries.insert(0, {
        'customerName': customerName,
        'customerRole': 'Student • Campus Peer',
        'productTitle': productTitle,
        'price': price,
        'lastMessage': lastMessage,
        'time': 'Just now',
        'unread': 'true',
        'avatar': avatar ?? (customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C'),
        'image': image ?? '',
        'phone': phone ?? '+91 98765 43210',
      });
    }
  }

  static void markAsRead(int index) {
    if (index >= 0 && index < _inquiries.length) {
      _inquiries[index]['unread'] = 'false';
    }
  }
}
