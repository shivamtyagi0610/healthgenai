import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import 'package:healthgenai/features/chat/data/models/chat_message_model.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Attach Health Document',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3BBD70).withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: const Color(0xFF3BBD70), size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend([String? text]) async {
    final messageText = text ?? _controller.text.trim();
    if (messageText.isEmpty && _selectedImageBytes == null) return;
    if (_isLoading) return;

    final imageToSend = _selectedImageBytes;

    if (text == null) _controller.clear();
    setState(() {
      _isLoading = true;
      _selectedImageBytes = null; // Clear preview
    });
    
    await ref.read(chatProvider.notifier).sendMessage(
      messageText.isEmpty ? "Analyze this document" : messageText,
      imageBytes: imageToSend,
    );
    
    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const _PrivacyBanner(),
          Expanded(
            child: messages.isEmpty
                ? _buildInitialState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: messages.length + (_isLoading ? 1 : 0) + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const _DateSeparator(date: 'Today');
                      }
                      
                      final messageIndex = index - 1;
                      
                      if (messageIndex == messages.length) {
                        return _buildTypingIndicator();
                      }
                      
                      final message = messages[messageIndex];
                      final showAvatar = !message.isUser && 
                          (messageIndex == 0 || messages[messageIndex - 1].isUser);
                      
                      return _buildChatBubble(message, showAvatar, messageIndex == 0);
                    },
                  ),
          ),
          _buildQuickReplies(),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const _AIAvatar(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Doctor',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3BBD70),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online · Powered by AI',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3BBD70),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.verified_user_outlined, color: Color(0xFF9CA3AF), size: 22),
          tooltip: 'Security Status',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Your health conversation is encrypted and private.',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                backgroundColor: const Color(0xFF3BBD70),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF9CA3AF), size: 22),
          onSelected: (value) {
            if (value == 'clear') {
              _showClearChatDialog();
            } else if (value == 'export') {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting chat history... (Coming Soon)')),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                   Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                   SizedBox(width: 12),
                   Text('Clear Chat'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                   Icon(Icons.ios_share_rounded, size: 20, color: Color(0xFF4B5563)),
                   SizedBox(width: 12),
                   Text('Export History'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat?', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text('This will delete all messages in this session.', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
              Navigator.pop(context);
            },
            child: Text('Clear', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
     return const Center(child: _DateSeparator(date: 'Today'));
  }

  Widget _buildChatBubble(ChatMessage message, bool showAvatar, bool isFirstMessage) {
    final isUser = message.isUser;
    final time = DateFormat('h:mm a').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                if (showAvatar)
                  const _AIAvatar(size: 32)
                else
                  const SizedBox(width: 32),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF3BBD70) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : (showAvatar ? 4 : 20)),
                          bottomRight: Radius.circular(isUser ? 4 : 20),
                        ),
                        boxShadow: [
                          if (!isUser)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.imageBytes != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                message.imageBytes!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          isUser
                              ? Text(
                                  message.text,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                )
                              : MarkdownBody(
                                  data: message.text,
                                  styleSheet: MarkdownStyleSheet(
                                    p: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                    strong: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                          
                          // First message suggestions
                          if (!isUser && isFirstMessage) ...[
                            const SizedBox(height: 16),
                            _SuggestionChip(
                              icon: Icons.personal_injury_outlined,
                              label: 'I have a headache and dizziness',
                              onTap: () => _handleSend('I have a headache and dizziness'),
                            ),
                            const SizedBox(height: 8),
                            _SuggestionChip(
                              icon: Icons.thermostat_outlined,
                              label: 'I have a fever and cold',
                              onTap: () => _handleSend('I have a fever and cold'),
                            ),
                            const SizedBox(height: 8),
                            _SuggestionChip(
                              icon: Icons.eco_outlined,
                              label: 'Tips for healthy lifestyle',
                              onTap: () => _handleSend('Tips for healthy lifestyle'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF3BBD70)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isUser) const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF3BBD70).withValues(alpha: 0.5)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'AI Doctor is thinking...',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF9CA3AF),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    final replies = ['When did it start?', 'Any other symptoms?', 'Medical history?'];
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: replies.length,
        itemBuilder: (context, index) {
          final icons = [Icons.access_time_rounded, Icons.person_search_outlined, Icons.assignment_outlined];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(replies[index]),
              avatar: Icon(icons[index], size: 16, color: const Color(0xFF3BBD70)),
              onSelected: (_) => _handleSend(replies[index]),
              backgroundColor: Colors.white,
              selectedColor: Colors.white,
              checkmarkColor: const Color(0xFF3BBD70),
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedImageBytes != null) _buildImagePreview(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _showImageSourceSheet,
                          child: const Icon(Icons.attach_file_rounded, color: Color(0xFF9CA3AF), size: 22),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onSubmitted: (_) => _handleSend(),
                            decoration: InputDecoration(
                              hintText: _selectedImageBytes != null ? 'Add a caption...' : 'Type your question...',
                              hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 14),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              filled: false,
                            ),
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _handleSend(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3BBD70),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _selectedImageBytes!,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image attached',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'AI will analyze this document',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImageBytes = null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }


}

class _AIAvatar extends StatelessWidget {
  final double size;
  const _AIAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF3BBD70),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: size * 0.5),
    );
  }
}



class _PrivacyBanner extends StatelessWidget {
  const _PrivacyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3BBD70).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: Color(0xFF3BBD70), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your health and privacy is our priority. Secure & confidential.',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF064E3B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showPrivacySheet(context),
            child: Text(
              'Learn more',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3BBD70),
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF3BBD70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF3BBD70), size: 28),
                const SizedBox(width: 12),
                Text(
                  'Your Privacy Matters',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'We use advanced AI technology to provide you with insights, but your privacy always comes first.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildPrivacyPoint(
              Icons.lock_person_outlined,
              'Secure & Anonymous',
              'Your conversations are encrypted and we do not share personal details with third parties.',
            ),
            const SizedBox(height: 16),
            _buildPrivacyPoint(
              Icons.bolt_outlined,
              'AI Powered Insights',
              'Insights are generated by AI for information. Always consult a real doctor for critical matters.',
            ),
            const SizedBox(height: 16),
            _buildPrivacyPoint(
              Icons.visibility_off_outlined,
              'Data Ownership',
              'You own your data. We only use it to improve your immediate application experience.',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3BBD70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Got it, thanks!',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPoint(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF3BBD70), size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final String date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          date,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF3BBD70)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
