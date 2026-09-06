import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int? conversationId;
  final String sellerName;
  final String productTitle;
  final String productPrice;
  final String? productImage;
  final String sellerAvatar;
  final String phoneNumber;
  final String? initialCustomerMessage;
  final String currentUserName;
  final String currentUserEmail;
  final String? peerEmail;
  final bool isReseller;

  const ChatScreen({
    super.key,
    this.conversationId,
    required this.sellerName,
    required this.productTitle,
    required this.productPrice,
    this.productImage,
    this.sellerAvatar = 'S',
    this.phoneNumber = '+91 98765 43210',
    this.initialCustomerMessage,
    this.currentUserName = 'Campus Student',
    this.currentUserEmail = 'student@campus.edu',
    this.peerEmail,
    this.isReseller = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  int? _activeConversationId;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _canSend = false;

  String get _resolvedPeerEmail {
    if (widget.peerEmail != null && widget.peerEmail!.isNotEmpty) {
      return widget.peerEmail!;
    }
    return widget.isReseller ? 'student@campus.edu' : 'reseller@campus.edu';
  }

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;
    _messageController.addListener(_onTextChanged);
    _initializeChat();
  }

  void _onTextChanged() {
    final canSendNow = _messageController.text.trim().isNotEmpty;
    if (canSendNow != _canSend) {
      setState(() {
        _canSend = canSendNow;
      });
    }
  }

  Future<void> _initializeChat() async {
    if (_activeConversationId == null) {
      final String customerEmail = widget.isReseller ? _resolvedPeerEmail : widget.currentUserEmail;
      final String customerName = widget.isReseller ? widget.sellerName : widget.currentUserName;
      final String resellerEmail = widget.isReseller ? widget.currentUserEmail : _resolvedPeerEmail;
      final String resellerName = widget.isReseller ? widget.currentUserName : widget.sellerName;

      final convData = await ApiService.getOrCreateConversation(
        customerEmail: customerEmail,
        customerName: customerName,
        resellerEmail: resellerEmail,
        resellerName: resellerName,
        productTitle: widget.productTitle,
      );

      if (convData != null && convData['conversationId'] != null) {
        _activeConversationId = int.tryParse(convData['conversationId'].toString());
      }
    }

    await _fetchMessages();

    // Mark conversation as read once on initial screen load
    if (_activeConversationId != null) {
      ApiService.markConversationRead(_activeConversationId!, widget.currentUserEmail);
    }

    // If conversation is empty and Customer opened screen, send initial greeting message in 1 single API call
    if (_messages.isEmpty && !widget.isReseller && _activeConversationId != null) {
      final String initText = (widget.initialCustomerMessage != null && widget.initialCustomerMessage!.trim().isNotEmpty)
          ? widget.initialCustomerMessage!.trim()
          : 'Hi! I am interested in buying ${widget.productTitle}. Is it available for campus handover?';

      final initList = await ApiService.sendChatMessage(
        conversationId: _activeConversationId!,
        senderEmail: widget.currentUserEmail,
        senderName: widget.currentUserName,
        receiverEmail: _resolvedPeerEmail,
        text: initText,
      );

      if (initList.isNotEmpty && mounted) {
        setState(() {
          _messages = initList;
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _fetchMessages() async {
    if (_activeConversationId == null) return;

    final fetched = await ApiService.getConversationMessages(_activeConversationId!);
    if (mounted) {
      final bool lengthChanged = fetched.length != _messages.length;
      setState(() {
        _messages = fetched;
        _isLoading = false;
      });

      if (lengthChanged) {
        _scrollToBottom();
      }
    }
  }

  Future<void> _sendMessage([String? customText]) async {
    final text = customText ?? _messageController.text.trim();
    if (text.isEmpty || _activeConversationId == null) return;

    if (customText == null) {
      _messageController.clear();
      setState(() {
        _canSend = false;
      });
    }

    // 1 SINGLE API CALL: sendChatMessage sends the message and receives all updated messages of the conversation
    final updatedList = await ApiService.sendChatMessage(
      conversationId: _activeConversationId!,
      senderEmail: widget.currentUserEmail,
      senderName: widget.currentUserName,
      receiverEmail: _resolvedPeerEmail,
      text: text,
      messageType: 'text',
    );

    if (updatedList.isNotEmpty && mounted) {
      setState(() {
        _messages = updatedList;
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendImageMessage(String pathOrUrl, {bool isUrl = false, String caption = 'Attached photo'}) async {
    if (_activeConversationId == null) return;

    // 1 SINGLE API CALL: sendChatMessage sends the image message and receives all updated messages
    final updatedList = await ApiService.sendChatMessage(
      conversationId: _activeConversationId!,
      senderEmail: widget.currentUserEmail,
      senderName: widget.currentUserName,
      receiverEmail: _resolvedPeerEmail,
      text: caption,
      imagePath: pathOrUrl,
      messageType: 'image',
    );

    if (updatedList.isNotEmpty && mounted) {
      setState(() {
        _messages = updatedList;
      });
      _scrollToBottom();
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        _sendImageMessage(pickedFile.path, isUrl: false, caption: 'Photo from Gallery');
      }
    } catch (_) {}
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
    } catch (_) {}
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
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF059669)),
                  ),
                  title: Text('Open Device Gallery', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text('Pick photo from your device gallery', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
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
                  subtitle: Text('Capture instant photo or item proof', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
              ],
            ),
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
          duration: const Duration(milliseconds: 250),
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
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No messages yet',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Type a message below to start chatting with ${widget.sellerName}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
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
      backgroundColor: const Color(0xFFF1F5F9),
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
              backgroundColor: const Color(0xFFECFDF5),
              child: Text(
                widget.sellerAvatar,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF059669),
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
                          color: Color(0xFF059669),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.isReseller ? 'Customer • Online' : 'Reseller • Online',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w600,
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
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF059669)),
            tooltip: 'Refresh Messages',
            onPressed: () => _fetchMessages(),
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Color(0xFF059669)),
            tooltip: 'Call Phone',
            onPressed: () async {
              final Uri phoneUri = Uri.parse('tel:${widget.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '')}');
              try {
                if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
              } catch (_) {}
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // PRODUCT SUMMARY TOP BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 36,
                    height: 36,
                    color: const Color(0xFFECFDF5),
                    child: widget.productImage != null && widget.productImage!.isNotEmpty
                        ? Image.network(
                            widget.productImage!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.shopping_bag_outlined,
                              color: Color(0xFF059669),
                              size: 18,
                            ),
                          )
                        : const Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF059669),
                            size: 18,
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
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Marketplace Item',
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // MESSAGES CHAT STREAM LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
                : _messages.isEmpty
                    ? _buildEmptyChatPlaceholder()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final String senderEmail = (msg['senderEmail'] ?? '').toString().toLowerCase();
                          final bool isMe = senderEmail == widget.currentUserEmail.trim().toLowerCase();

                          final bool isImage = msg['type'] == 'image' || (msg['imagePath'] != null && msg['imagePath'].toString().isNotEmpty);
                          final String? imagePath = msg['imagePath'] as String?;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.76,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFF059669) : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(14),
                                  topRight: const Radius.circular(14),
                                  bottomLeft: Radius.circular(isMe ? 14 : 2),
                                  bottomRight: Radius.circular(isMe ? 2 : 14),
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
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  if (isImage && imagePath != null) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: imagePath.startsWith('http') || imagePath.startsWith('blob')
                                          ? Image.network(
                                              imagePath,
                                              width: 200,
                                              height: 140,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 200,
                                                height: 100,
                                                color: Colors.grey.shade300,
                                                child: const Icon(Icons.broken_image, color: Colors.grey),
                                              ),
                                            )
                                          : (kIsWeb
                                              ? Image.network(
                                                  imagePath,
                                                  width: 200,
                                                  height: 140,
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
                                                  height: 140,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    width: 200,
                                                    height: 100,
                                                    color: Colors.grey.shade300,
                                                    child: const Icon(Icons.broken_image, color: Colors.grey),
                                                  ),
                                                )),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  Text(
                                    msg['text'] as String? ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: isMe ? Colors.white : const Color(0xFF0F172A),
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        msg['time'] as String? ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9.5,
                                          color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.done_all_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // WHATSAPP-STYLE BOTTOM INPUT BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF059669)),
                    tooltip: 'Attach Image',
                    onPressed: _showAttachmentPickerModal,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.poppins(fontSize: 13),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _canSend ? _sendMessage() : null,
                        decoration: InputDecoration(
                          hintText: widget.isReseller ? 'Reply to customer...' : 'Type a message to owner...',
                          hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _canSend ? () => _sendMessage() : null,
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _canSend ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
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
}
