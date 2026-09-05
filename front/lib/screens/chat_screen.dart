import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/inquiry_service.dart';

class ChatScreen extends StatefulWidget {
  final String sellerName;
  final String productTitle;
  final String productPrice;
  final String? productImage;
  final String sellerAvatar;
  final String phoneNumber;
  final String? initialCustomerMessage;

  const ChatScreen({
    super.key,
    required this.sellerName,
    required this.productTitle,
    required this.productPrice,
    this.productImage,
    this.sellerAvatar = 'S',
    this.phoneNumber = '+91 98765 43210',
    this.initialCustomerMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  late List<Map<String, dynamic>> _messages;

  final List<String> _sampleGalleryImages = [
    'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1584697964400-2ae6b27a3523?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=400&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _messages = [];
    if (widget.initialCustomerMessage != null && widget.initialCustomerMessage!.trim().isNotEmpty) {
      _messages.add({
        'sender': 'seller',
        'type': 'text',
        'text': widget.initialCustomerMessage!,
        'time': _formatCurrentTime(offsetMinutes: -1),
      });
    }
  }

  String _formatCurrentTime({int offsetMinutes = 0}) {
    final now = DateTime.now().add(Duration(minutes: offsetMinutes));
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _sendMessage([String? customText]) {
    final text = customText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    if (customText == null) {
      _messageController.clear();
    }

    setState(() {
      _messages.add({
        'sender': 'user',
        'type': 'text',
        'text': text,
        'time': _formatCurrentTime(),
      });
    });

    _scrollToBottom();

    // Record real customer message so it appears in Reseller Panel
    InquiryService.recordInquiry(
      customerName: 'Hitija Mhatre',
      productTitle: widget.productTitle,
      price: widget.productPrice,
      lastMessage: text,
      avatar: 'H',
      image: widget.productImage,
    );

    // Auto reply simulation for peer messaging
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      String replyText = 'Thanks for reaching out! Yes, "${widget.productTitle}" is available for pickup!';
      if (text.toLowerCase().contains('price') || text.toLowerCase().contains('discount')) {
        replyText = 'The price ${widget.productPrice} is already campus discounted, but we can talk on handover!';
      } else if (text.toLowerCase().contains('where') || text.toLowerCase().contains('location') || text.toLowerCase().contains('meet')) {
        replyText = 'We can meet near Central Library or Campus Canteen today!';
      }

      setState(() {
        _messages.add({
          'sender': 'seller',
          'type': 'text',
          'text': replyText,
          'time': _formatCurrentTime(),
        });
      });
      _scrollToBottom();
    });
  }

  void _sendImageMessage(String pathOrUrl, {bool isUrl = false, String caption = 'Attached photo from Gallery'}) {
    setState(() {
      _messages.add({
        'sender': 'user',
        'type': 'image',
        'imagePath': pathOrUrl,
        'isUrl': isUrl,
        'text': caption,
        'time': _formatCurrentTime(),
      });
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'seller',
          'type': 'text',
          'text': 'Thanks for sharing the photo! The item condition looks great. Let\'s meet up at the canteen to inspect!',
          'time': _formatCurrentTime(),
        });
      });
      _scrollToBottom();
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        _sendImageMessage(pickedFile.path, isUrl: false, caption: 'Selected from Phone Gallery');
      } else {
        _showSampleGalleryPickerModal();
      }
    } catch (e) {
      _showSampleGalleryPickerModal();
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        _sendImageMessage(pickedFile.path, isUrl: false, caption: 'Photo taken with Camera');
      }
    } catch (e) {
      _showSampleGalleryPickerModal();
    }
  }

  void _showAttachmentPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Attachment Source',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF0B6E4F)),
                  ),
                  title: Text('Open Device Gallery', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text('Pick photo from your photos gallery app', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB)),
                  ),
                  title: Text('Take Camera Photo', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text('Capture instant item image or proof', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3E8FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.collections_rounded, color: Color(0xFF9333EA)),
                  ),
                  title: Text('Campus Sample Photos Gallery', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text('Select from product & proof images', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(context);
                    _showSampleGalleryPickerModal();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSampleGalleryPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select from Gallery',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _sampleGalleryImages.length,
                  itemBuilder: (context, index) {
                    final imgUrl = _sampleGalleryImages[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _sendImageMessage(imgUrl, isUrl: true, caption: 'Attached photo from Gallery');
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFECFDF5),
                            child: const Icon(Icons.image, color: Color(0xFF0B6E4F)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _makePhoneCall() async {
    final cleanPhone = widget.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri phoneUri = Uri.parse('tel:$cleanPhone');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (_) {}

    if (mounted) {
      _showCallerModal(cleanPhone);
    }
  }

  void _showCallerModal(String phoneNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CALLING ANIMATION AVATAR
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0B6E4F), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withAlpha(60),
                      blurRadius: 20,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.sellerAvatar,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B6E4F),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Calling ${widget.sellerName}...',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                phoneNumber,
                style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF0B6E4F), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Direct Campus Peer Line • Connecting',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // CALL ACTIONS (MUTE, LAUNCH PHONE DIALER, END CALL)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.mic_off_rounded, color: Color(0xFF6B7280)),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Mute', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final Uri phoneUri = Uri.parse('tel:$phoneNumber');
                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          }
                        },
                        icon: const Icon(Icons.phone, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Dial App', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.call_end_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('End Call', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildEmptyChatPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40,
                color: Color(0xFF0B6E4F),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No messages here yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start a live conversation with ${widget.sellerName} about "${widget.productTitle}"',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFD1FAE5),
              child: Text(
                widget.sellerAvatar,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF0B6E4F),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sellerName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Active Now • Reseller',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: const Color(0xFF047857),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Color(0xFF0B6E4F)),
            tooltip: 'Call Reseller',
            onPressed: _makePhoneCall,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // PRODUCT SUMMARY BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    color: const Color(0xFFECFDF5),
                    child: widget.productImage != null && widget.productImage!.isNotEmpty
                        ? Image.network(
                            widget.productImage!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.shopping_bag_outlined,
                              color: Color(0xFF0B6E4F),
                              size: 20,
                            ),
                          )
                        : const Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF0B6E4F),
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.productTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.productPrice,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0B6E4F),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Campus Verified',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CHAT MESSAGES LIST
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyChatPlaceholder()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                final isImage = msg['type'] == 'image';
                final String? imagePath = msg['imagePath'] as String?;
                final bool isUrl = msg['isUrl'] == true;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF0B6E4F) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (isImage && imagePath != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: isUrl || imagePath.startsWith('http')
                                ? Image.network(
                                    imagePath,
                                    width: 200,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 200,
                                      height: 100,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  )
                                : Image.file(
                                    File(imagePath),
                                    width: 200,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 200,
                                      height: 100,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          msg['text'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isUser ? Colors.white : const Color(0xFF1F2937),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            color: isUser ? Colors.white70 : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // QUICK CHIP SUGGESTIONS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                _buildQuickChip('Is this item still available?'),
                _buildQuickChip('Can we meet at Canteen?'),
                _buildQuickChip('Is the price negotiable?'),
              ],
            ),
          ),

          // BOTTOM INPUT BAR WITH ATTACH & SEND
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF0B6E4F)),
                    tooltip: 'Attach Image from Gallery',
                    onPressed: _showAttachmentPickerModal,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.poppins(fontSize: 13),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type a message to owner...',
                          hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF9CA3AF)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0B6E4F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
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

  Widget _buildQuickChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ActionChip(
        label: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF0B6E4F), fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFFECFDF5),
        side: const BorderSide(color: Color(0xFFA7F3D0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _sendMessage(text),
      ),
    );
  }
}
