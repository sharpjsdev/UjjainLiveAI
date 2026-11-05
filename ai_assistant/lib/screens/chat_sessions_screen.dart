import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../constants/app_colors.dart';
import '../models/chat_session.dart';
import '../utils/app_utils.dart';

class ChatSessionsScreen extends StatelessWidget {
  const ChatSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
          ),
        ),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.history_edu_rounded, color: AppColors.templeGold, size: 22),
            SizedBox(width: 10),
            Text(
              'Pilgrimage History',
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_rounded, color: AppColors.devotional),
                    SizedBox(width: 8),
                    Text('Clear All History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final sessions = chatProvider.chatSessions;

          if (sessions.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final isCurrentSession = session.id == chatProvider.currentSession?.id;
              
              return _buildSessionCard(
                context, 
                session, 
                isCurrentSession,
                chatProvider,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewChat(context),
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 54,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Pilgrimage Chats Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ask a question about Mahakaleshwar, Simhastha, or Ujjain to start your pilgrimage history',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    ChatSession session,
    bool isCurrentSession,
    ChatProvider chatProvider,
  ) {
    final lastMessage = session.messages.isNotEmpty 
        ? session.messages.last
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrentSession ? 3 : 1,
      color: isCurrentSession 
          ? AppColors.primary.withValues(alpha: 0.08) 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrentSession 
            ? const BorderSide(color: AppColors.primary, width: 1.5)
            : BorderSide(color: AppColors.primary.withValues(alpha: 0.15), width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _selectSession(context, session.id, chatProvider),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: isCurrentSession 
                      ? AppColors.primaryGradient 
                      : null,
                  color: isCurrentSession 
                      ? null 
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.temple_hindu_rounded,
                  size: 20,
                  color: isCurrentSession 
                      ? Colors.white
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isCurrentSession 
                            ? AppColors.primaryDark
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lastMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        lastMessage.content,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          AppUtils.formatDateTime(session.lastUpdated),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                        const Spacer(),
                        if (session.messages.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrentSession
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              '${session.messages.length} messages',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isCurrentSession ? AppColors.primaryDark : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleSessionAction(
                  context, 
                  value, 
                  session, 
                  chatProvider,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'select',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Open'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.devotional),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectSession(BuildContext context, String sessionId, ChatProvider chatProvider) {
    chatProvider.selectChatSession(sessionId);
    Navigator.of(context).pop();
  }

  void _createNewChat(BuildContext context) async {
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.createNewChatSession();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleMenuAction(BuildContext context, String action) async {
    final chatProvider = context.read<ChatProvider>();

    switch (action) {
      case 'clear_all':
        final confirmed = await AppUtils.showConfirmDialog(
          context,
          title: 'Clear All Pilgrimage Chats',
          content: 'Are you sure you want to delete all chat sessions? This action cannot be undone.',
          confirmText: 'Delete All',
        );
        
        if (confirmed == true && context.mounted) {
          await chatProvider.clearAllChatSessions();
          if (context.mounted) {
            AppUtils.showSuccessSnackBar(context, 'All chat sessions cleared');
          }
        }
        break;
    }
  }

  void _handleSessionAction(
    BuildContext context,
    String action,
    ChatSession session,
    ChatProvider chatProvider,
  ) async {
    switch (action) {
      case 'select':
        _selectSession(context, session.id, chatProvider);
        break;
        
      case 'delete':
        final confirmed = await AppUtils.showConfirmDialog(
          context,
          title: 'Delete Chat',
          content: 'Are you sure you want to delete "${session.title}"? This action cannot be undone.',
          confirmText: 'Delete',
        );
        
        if (confirmed == true && context.mounted) {
          await chatProvider.deleteChatSession(session.id);
          if (context.mounted) {
            AppUtils.showSuccessSnackBar(context, 'Chat session deleted');
          }
        }
        break;
    }
  }
}