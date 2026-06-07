// =============================================================================
// chat_screen.dart  — v2  (PRODUCTION)
//
// Full Agora Chat SDK integration for the timed written-consultation flow.
//
// Architecture mirrors VideoCallScreen / VideoCallCubit exactly:
//   • ChatScreenSession  — public entry-point (BlocProvider)
//   • _ChatSessionView   — BlocConsumer, renders overlays + ChatBody
//   • ChatBody           — StatefulWidget that owns the Agora Chat SDK
//                          (login, send, receive, history, logout)
//
// Agora Chat SDK lifecycle (owned entirely by ChatBody):
//   initState  → AgoraChatClient.getInstance().startCallback(token, userId)
//             → load conversation history (fetchConversation)
//             → register message listener
//   dispose    → remove listener → logout
//
// Message model:
//   _ChatMessage  — lightweight local model wrapping Agora ChatMessage.
//   Sent messages are appended optimistically; delivery/read receipts can
//   be layered on top using onMessagesDelivered / onMessagesRead.
//
// Overlays (identical to VideoCallScreen):
//   _ChatWaitingOverlay         — initializing / waitingForClient
//   _ChatTwoMinuteWarningBanner — twoMinuteWarning banner
//   _TimerChip                  — live countdown chip
//   _ChatErrorOverlay           — unrecoverable error
//   _EndChatButton              — end-session FAB
//
// Phase-driven UI gating:
//   • ChatBody is mounted only when credentials != null  (step 2 complete)
//   • Message input is disabled unless state.isSessionActive
//   • All navigation via pushAndRemoveUntil (no back stack)
//
// Lawyer-only flow:
//   • timer expired / manual end → showCallSummaryDialog → submitCallSummary
//   • submit success → cubit.endSession() → LayoutPage
//
// Client-only flow:
//   • timer expired / manual end → cubit.endSession() → EndSessionScreen
// =============================================================================

import 'dart:async';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:size_config/size_config.dart';

import '../../../features/User/application/end_session_screen.dart';
import '../../../features/common/layout/layout_screen.dart';
import 'bloc/chat_session_cubit.dart';
import 'bloc/chat_session_state.dart';
import 'dialogs/call_summary_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local lightweight message model
// ─────────────────────────────────────────────────────────────────────────────

enum _MsgStatus { sending, sent, failed }

class _ChatMessage {
  final String msgId;
  final String text;
  final bool isMine;
  final DateTime timestamp;
  _MsgStatus status;

  _ChatMessage({
    required this.msgId,
    required this.text,
    required this.isMine,
    required this.timestamp,
    this.status = _MsgStatus.sent,
  });

  /// Build from an Agora SDK ChatMessage.
  factory _ChatMessage.fromAgora(ChatMessage msg, String myUserId) {
    final body = msg.body as ChatTextMessageBody;
    return _ChatMessage(
      msgId: msg.msgId,
      text: body.content,
      isMine: msg.from == myUserId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        msg.serverTime > 0 ? msg.serverTime : msg.localTime,
      ),
    );
  }
}

// =============================================================================
// PUBLIC ENTRY-POINT  (mirrors VideoCallScreen)
// =============================================================================

class ChatScreenSession extends StatelessWidget {
  const ChatScreenSession({
    Key? key,
    required this.consultationId,
    required this.lawyerId,
    required this.clientId,
    this.peerName,
    this.peerPhotoUrl,
  }) : super(key: key);

  final String consultationId;
  final String lawyerId;
  final String clientId;
  final String? peerName;
  final String? peerPhotoUrl;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatSessionCubit(
        consultationId: consultationId,
        peerName: peerName,
        peerPhotoUrl: peerPhotoUrl,
        lawyerId: lawyerId,
        clientId: clientId,
      )..initialize(),
      child: _ChatSessionView(
        consultationId: consultationId,
        lawyerId: lawyerId,
        clientId: clientId,
      ),
    );
  }
}

// =============================================================================
// INTERNAL VIEW  (mirrors _VideoCallView)
// =============================================================================

class _ChatSessionView extends StatefulWidget {
  const _ChatSessionView({
    required this.consultationId,
    required this.lawyerId,
    required this.clientId,
  });

  final String consultationId;
  final String lawyerId;
  final String clientId;

  @override
  State<_ChatSessionView> createState() => _ChatSessionViewState();
}

class _ChatSessionViewState extends State<_ChatSessionView> {
  bool _timerExpiredDialogShown = false;

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _handleTimerExpired(BuildContext ctx) async {
    final cubit = ctx.read<ChatSessionCubit>();

    if (cubit.isLawyer) {
      await showCallSummaryDialog(
        ctx,
        onSubmit: (summary) async {
          await cubit.submitCallSummary(summary);
          await cubit.endSession();
          if (ctx.mounted) {
            Navigator.of(ctx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LayoutPage()),
                  (r) => false,
            );
          }
        },
        onSkip: () async {
          await cubit.endSession();
          if (ctx.mounted) {
            Navigator.of(ctx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LayoutPage()),
                  (r) => false,
            );
          }
        },
      );
    } else {
      final s = cubit.state;
      await cubit.endSession();
      if (ctx.mounted) {
        Navigator.of(ctx).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => EndSessionScreen(
              consultationId: widget.consultationId,
              lawyerId: s.lawyerId ?? widget.lawyerId,
              clientId: s.clientId ?? widget.clientId,
            ),
          ),
              (r) => false,
        );
      }
    }
  }

  void _navigateOnEnded(BuildContext ctx, ChatSessionState state,
      ChatSessionCubit cubit) {
    final lawyerId = state.lawyerId ?? widget.lawyerId;
    final clientId = state.clientId ?? widget.clientId;

    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => cubit.isLawyer
            ? const LayoutPage()
            : EndSessionScreen(
          consultationId: widget.consultationId,
          lawyerId: lawyerId,
          clientId: clientId,
        ),
      ),
          (r) => false,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatSessionCubit, ChatSessionState>(
      listener: (ctx, state) async {
        // Timer expired → summary dialog (lawyer) / end screen (client)
        if (state.phase == ChatSessionPhase.timerExpired &&
            !_timerExpiredDialogShown) {
          _timerExpiredDialogShown = true;
          await _handleTimerExpired(ctx);
          return;
        }

        // Server confirmed session ended → navigate away
        if (state.phase == ChatSessionPhase.ended) {
          _navigateOnEnded(ctx, state, ctx.read<ChatSessionCubit>());
        }
      },
      builder: (ctx, state) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // ── Chat body — mounted as soon as credentials are ready ────
                if (state.credentials != null)
                  _ChatBody(
                    credentials: state.credentials!,
                    peerName: state.peerName,
                    peerPhotoUrl: state.peerPhotoUrl,
                    isSessionActive: state.isSessionActive,
                    consultationId: widget.consultationId,
                  ),

                // ── Full-screen waiting overlay ────────────────────────────
                if (state.phase == ChatSessionPhase.initializing ||
                    state.phase == ChatSessionPhase.waitingForClient)
                  _ChatWaitingOverlay(phase: state.phase),

                // ── Two-minute warning banner ──────────────────────────────
                if (state.twoMinuteWarningActive)
                  Positioned(
                    top: 100.h,
                    left: 20.w,
                    right: 20.w,
                    child: const _ChatTwoMinuteWarningBanner(),
                  ),

                // ── Timer chip ────────────────────────────────────────────
                if (state.phase == ChatSessionPhase.inProgress ||
                    state.phase == ChatSessionPhase.twoMinuteWarning ||
                    state.phase == ChatSessionPhase.timerExpired)
                  Positioned(
                    top: 50.h,
                    left: 16.w,
                    child: _TimerChip(state: state),
                  ),

                // ── Full-screen error overlay ─────────────────────────────
                if (state.phase == ChatSessionPhase.error)
                  _ChatErrorOverlay(message: state.errorMessage),

                // ── End-chat button ───────────────────────────────────────
                if (state.isSessionActive ||
                    state.phase == ChatSessionPhase.waitingForClient)
                  Positioned(
                    bottom: 90.h,
                    left: 16.w,
                    child: _EndChatButton(
                      consultationId: widget.consultationId,
                      state: state,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// CHAT BODY  — owns the Agora Chat SDK entirely
// =============================================================================

class _ChatBody extends StatefulWidget {
  const _ChatBody({
    required this.credentials,
    required this.isSessionActive,
    required this.consultationId,
    this.peerName,
    this.peerPhotoUrl,
  });

  final AgoraChatCredentials credentials;
  final bool isSessionActive;
  final String consultationId;
  final String? peerName;
  final String? peerPhotoUrl;

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  // ── State ──────────────────────────────────────────────────────────────────
  final List<_ChatMessage> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  bool _sdkReady = false;
  bool _sending = false;
  String? _sdkError;

  // ── Agora Chat SDK references ──────────────────────────────────────────────
  late final ChatClient _chatClient;
  late final ChatEventHandler _msgHandler;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _chatClient = ChatClient.getInstance;
    _bootstrapAgoraChat();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _chatClient.chatManager.removeEventHandler('chat_body_handler');
    // Best-effort logout — don't block dispose
    _chatClient.logout(false).catchError((_) {});
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Agora Chat SDK bootstrap
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _bootstrapAgoraChat() async {
    try {
      // 1. Login with the short-lived token
      await _chatClient.loginWithAgoraToken(
        widget.credentials.myUserId, // my own Agora user ID
        widget.credentials.token,
      );

      // 2. Register message listener
      _msgHandler = ChatEventHandler(
        onMessagesReceived: _onMessagesReceived,
        onMessagesDelivered: _onMessagesDelivered,
        onMessagesRead: _onMessagesRead,
        onCmdMessagesReceived: null,
        onGroupMessageRead: null,
      );
      _chatClient.chatManager.addEventHandler(
        'chat_body_handler',
        _msgHandler,
      );

      // 3. Load conversation history
      await _loadHistory();

      if (mounted) setState(() => _sdkReady = true);
    } on ChatError catch (e) {
      if (mounted) {
        setState(() => _sdkError = 'فشل الاتصال بخادم الرسائل: ${e.description}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sdkError = 'خطأ غير متوقع: $e');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Load conversation history from local Agora Chat cache → server fallback
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    try {
      final conversation = await _chatClient.chatManager.getConversation(
        widget.credentials.conversationKey,
        type: ChatConversationType.Chat,
        createIfNeed: true,
      );

      if (conversation == null) return;

      // Fetch from local cache first
      List<ChatMessage> history = await conversation.loadMessages(
        startMsgId: '',
        loadCount: 50,
        direction: ChatSearchDirection.Up,
      );

      // If local cache is empty, pull from server
      if (history.isEmpty) {
        final cursor = await _chatClient.chatManager.fetchHistoryMessages(
          conversationId: widget.credentials.conversationKey,
          type: ChatConversationType.Chat,
          pageSize: 50,
        );
        history = cursor.data;
      }

      // Mark all as delivered/read
      await conversation.markAllMessagesAsRead();

      if (!mounted) return;

      final myUserId = widget.credentials.myUserId;
      setState(() {
        _messages.addAll(
          history.map((m) => _ChatMessage.fromAgora(m, myUserId)),
        );
      });

      _scrollToBottom(animate: false);
    } catch (_) {
      // History load is non-fatal — the user can still chat
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Message event handlers
  // ─────────────────────────────────────────────────────────────────────────

  void _onMessagesReceived(List<ChatMessage> messages) {
    if (!mounted) return;
    final myUserId = widget.credentials.myUserId;
    setState(() {
      for (final m in messages) {
        if (m.body is ChatTextMessageBody) {
          _messages.add(_ChatMessage.fromAgora(m, myUserId));
        }
      }
    });
    _scrollToBottom();

    // Mark as read
    _chatClient.chatManager
        .sendConversationReadAck(widget.credentials.conversationKey)
        .catchError((_) {});
  }

  void _onMessagesDelivered(List<ChatMessage> messages) {
    if (!mounted) return;
    setState(() {
      for (final delivered in messages) {
        final idx = _messages.indexWhere((m) => m.msgId == delivered.msgId);
        if (idx != -1) {
          _messages[idx].status = _MsgStatus.sent;
        }
      }
    });
  }

  void _onMessagesRead(List<ChatMessage> messages) {
    // Extend here if you want double-tick read receipts
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Send message
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending || !_sdkReady) return;
    if (!widget.isSessionActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الجلسة غير نشطة، لا يمكن إرسال رسائل')),
      );
      return;
    }

    _inputCtrl.clear();

    // Build Agora message
    final msg = ChatMessage.createTxtSendMessage(
      targetId: widget.credentials.peerUserId,
      content: text,
    );

    // Optimistic local append
    final optimistic = _ChatMessage(
      msgId: msg.msgId,
      text: text,
      isMine: true,
      timestamp: DateTime.now(),
      status: _MsgStatus.sending,
    );

    setState(() {
      _messages.add(optimistic);
      _sending = true;
    });
    _scrollToBottom();

    try {
      await _chatClient.chatManager.sendMessage(msg);
      if (!mounted) return;
      setState(() {
        optimistic.status = _MsgStatus.sent;
        _sending = false;
      });
    } on ChatError catch (e) {
      if (!mounted) return;
      setState(() {
        optimistic.status = _MsgStatus.failed;
        _sending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إرسال الرسالة: ${e.description}')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        optimistic.status = _MsgStatus.failed;
        _sending = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Retry a failed message
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _retryMessage(_ChatMessage failed) async {
    setState(() => failed.status = _MsgStatus.sending);
    final msg = ChatMessage.createTxtSendMessage(
      targetId: widget.credentials.conversationKey,
      content: failed.text,
    );
    try {
      await _chatClient.chatManager.sendMessage(msg);
      if (!mounted) return;
      setState(() {
        // Replace old failed entry with the new one
        final idx = _messages.indexOf(failed);
        if (idx != -1) {
          _messages[idx] = _ChatMessage(
            msgId: msg.msgId,
            text: failed.text,
            isMine: true,
            timestamp: DateTime.now(),
            status: _MsgStatus.sent,
          );
        }
      });
    } on ChatError {
      if (!mounted) return;
      setState(() => failed.status = _MsgStatus.failed);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Scroll helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      if (animate) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // SDK error — shown inline inside the body
    if (_sdkError != null) {
      return _ChatSdkErrorWidget(message: _sdkError!);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _ChatHeader(
            peerName: widget.peerName,
            peerPhotoUrl: widget.peerPhotoUrl,
            isConnecting: !_sdkReady,
          ),

          // ── Messages list ────────────────────────────────────────────────
          Expanded(
            child: _sdkReady
                ? _messages.isEmpty
                ? Center(
              child: Text(
                'لا توجد رسائل بعد.\nابدأ المحادثة الآن!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              controller: _scrollCtrl,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 8.h),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                return _MessageBubble(
                  message: _messages[i],
                  onRetry: _retryMessage,
                );
              },
            )
                : const Center(child: CircularProgressIndicator()),
          ),

          // ── Input field ──────────────────────────────────────────────────
          _ChatInputField(
            controller: _inputCtrl,
            enabled: widget.isSessionActive && _sdkReady,
            isSending: _sending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// WIDGETS
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// Chat header
// ─────────────────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    this.peerName,
    this.peerPhotoUrl,
    required this.isConnecting,
  });

  final String? peerName;
  final String? peerPhotoUrl;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
          top: 50.h, bottom: 12.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondary,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back-arrow placeholder (PopScope blocks actual navigation)
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(.5),
              borderRadius: BorderRadius.circular(8.h),
            ),
            child: Icon(Icons.arrow_back,
                size: 20.sp, color: colorScheme.onSurface),
          ),
          Gap(10.w),

          // Avatar
          CircleAvatar(
            radius: 25.h,
            backgroundColor: colorScheme.surfaceVariant,
            backgroundImage:
            peerPhotoUrl != null ? NetworkImage(peerPhotoUrl!) : null,
            child: peerPhotoUrl == null
                ? Icon(Icons.person,
                color: colorScheme.onSurfaceVariant, size: 28.sp)
                : null,
          ),
          Gap(10.w),

          // Name + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                peerName ?? 'المستشار',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: isConnecting
                          ? Colors.orange
                          : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    isConnecting ? 'جاري الاتصال…' : 'متصل',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message bubble
// ─────────────────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.onRetry});

  final _ChatMessage message;
  final void Function(_ChatMessage) onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final timeStr =
    DateFormat('hh:mm a', 'ar').format(message.timestamp);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: message.isMine
          ? _SentBubble(
        message: message,
        timeStr: timeStr,
        theme: theme,
        cs: cs,
        onRetry: onRetry,
      )
          : _ReceivedBubble(
        message: message,
        timeStr: timeStr,
        theme: theme,
        cs: cs,
      ),
    );
  }
}

class _SentBubble extends StatelessWidget {
  const _SentBubble({
    required this.message,
    required this.timeStr,
    required this.theme,
    required this.cs,
    required this.onRetry,
  });

  final _ChatMessage message;
  final String timeStr;
  final ThemeData theme;
  final ColorScheme cs;
  final void Function(_ChatMessage) onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 18.h,
          backgroundColor: cs.surfaceVariant,
          child: Icon(Icons.person, color: cs.onSurfaceVariant, size: 18.sp),
        ),
        SizedBox(width: 8.w),

        // Bubble + meta
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.h),
                    topRight: Radius.circular(12.h),
                    bottomLeft: Radius.circular(12.h),
                    bottomRight: Radius.circular(12.h),
                  ),
                ),
                child: Text(
                  message.text,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(height: 1.5, color: cs.onPrimary),
                ),
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor, fontSize: 11.sp),
                    ),
                    SizedBox(width: 4.w),
                    _StatusIcon(status: message.status),
                    if (message.status == _MsgStatus.failed)
                      GestureDetector(
                        onTap: () => onRetry(message),
                        child: Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Icon(Icons.refresh,
                              size: 14.sp, color: cs.error),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 50.w),
      ],
    );
  }
}

class _ReceivedBubble extends StatelessWidget {
  const _ReceivedBubble({
    required this.message,
    required this.timeStr,
    required this.theme,
    required this.cs,
  });

  final _ChatMessage message;
  final String timeStr;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 50.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(.5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.h),
                    topRight: Radius.circular(4.h),
                    bottomLeft: Radius.circular(12.h),
                    bottomRight: Radius.circular(12.h),
                  ),
                ),
                child: Text(
                  message.text,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5, color: cs.onSurface),
                ),
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Text(
                  timeStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor, fontSize: 11.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        CircleAvatar(
          radius: 18.h,
          backgroundColor: theme.dividerColor.withOpacity(.5),
          child:
          Icon(Icons.person, color: cs.onSurfaceVariant, size: 18.sp),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message status icon
// ─────────────────────────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final _MsgStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case _MsgStatus.sending:
        return SizedBox(
          width: 10.sp,
          height: 10.sp,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: cs.onSurface.withOpacity(0.4),
          ),
        );
      case _MsgStatus.sent:
        return Icon(Icons.done_all, size: 14.sp,
            color: cs.primary.withOpacity(0.7));
      case _MsgStatus.failed:
        return Icon(Icons.error_outline, size: 14.sp, color: cs.error);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat input field
// ─────────────────────────────────────────────────────────────────────────────

class _ChatInputField extends StatelessWidget {
  const _ChatInputField({
    required this.controller,
    required this.enabled,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondary,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Send button
          GestureDetector(
            onTap: enabled && !isSending ? onSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: enabled
                    ? cs.primary
                    : theme.dividerColor.withOpacity(.5),
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? Padding(
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: cs.onPrimary),
              )
                  : Icon(Icons.send,
                  size: 20.sp,
                  color: enabled
                      ? cs.onPrimary
                      : theme.hintColor),
            ),
          ),
          SizedBox(width: 12.w),

          // Text field
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(25.h),
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                textAlign: TextAlign.right,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (enabled && !isSending) onSend();
                },
                decoration: InputDecoration(
                  hintText: enabled
                      ? 'اكتب الرسالة هنا...'
                      : 'الجلسة غير نشطة',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                    fontSize: 14.sp,
                  ),
                  fillColor: theme.dividerColor,
                  filled: true,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Attachment (placeholder)
          _IconBtn(
            icon: Icons.attach_file,
            bg: cs.surfaceVariant,
            iconColor: theme.hintColor,
            onTap: enabled ? () {} : null,
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn(
      {required this.icon,
        required this.bg,
        required this.iconColor,
        this.onTap});

  final IconData icon;
  final Color bg;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 20.sp, color: iconColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SDK error widget
// ─────────────────────────────────────────────────────────────────────────────

class _ChatSdkErrorWidget extends StatelessWidget {
  const _ChatSdkErrorWidget({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 56, color: cs.error),
              const SizedBox(height: 16),
              Text(message,
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('العودة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen waiting overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ChatWaitingOverlay extends StatelessWidget {
  const _ChatWaitingOverlay({required this.phase});
  final ChatSessionPhase phase;

  String get _message {
    switch (phase) {
      case ChatSessionPhase.initializing:
        return 'جاري تحضير المحادثة…';
      case ChatSessionPhase.waitingForClient:
        return 'في انتظار انضمام الطرف الآخر…';
      default:
        return 'جاري التحميل…';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                _message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Two-minute warning banner
// ─────────────────────────────────────────────────────────────────────────────

class _ChatTwoMinuteWarningBanner extends StatelessWidget {
  const _ChatTwoMinuteWarningBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.error.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: cs.onError, size: 20),
          const SizedBox(width: 8),
          Text(
            'تبقّت دقيقتان على انتهاء الجلسة',
            style: TextStyle(
                color: cs.onError, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timer chip
// ─────────────────────────────────────────────────────────────────────────────

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.state});
  final ChatSessionState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCritical = state.twoMinuteWarningActive ||
        (state.remainingSeconds != null && state.remainingSeconds! <= 120);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCritical
            ? cs.error.withOpacity(0.15)
            : cs.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCritical
              ? cs.error.withOpacity(0.6)
              : cs.onSurface.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: isCritical ? cs.error : cs.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            state.formattedRemaining,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isCritical ? cs.error : cs.onSurface,
              fontSize: 14,
              fontWeight: isCritical ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: state.isSessionActive ? cs.error : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen error overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ChatErrorOverlay extends StatelessWidget {
  const _ChatErrorOverlay({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: cs.error, size: 56),
                const SizedBox(height: 16),
                Text(
                  message ?? 'حدث خطأ في تحميل المحادثة',
                  style:
                  const TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('العودة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// End-chat floating button + confirmation dialog
// ─────────────────────────────────────────────────────────────────────────────

class _EndChatButton extends StatelessWidget {
  const _EndChatButton({
    required this.consultationId,
    required this.state,
  });

  final String consultationId;
  final ChatSessionState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _handleEndChat(context),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: cs.error,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: cs.error.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.call_end, color: cs.onError, size: 18),
            const SizedBox(width: 6),
            Text(
              'إنهاء المحادثة',
              style: TextStyle(
                  color: cs.onError, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEndChat(BuildContext context) async {
    final confirmed = await _EndChatConfirmDialog.show(context);
    if (confirmed != true) return;
    if (!context.mounted) return;

    final cubit = context.read<ChatSessionCubit>();

    if (cubit.isLawyer) {
      await showCallSummaryDialog(
        context,
        onSubmit: (summary) async {
          await cubit.submitCallSummary(summary);
          await cubit.endSession();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LayoutPage()),
                  (r) => false,
            );
          }
        },
        onSkip: () async {
          await cubit.endSession();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LayoutPage()),
                  (r) => false,
            );
          }
        },
      );
    } else {
      final s = cubit.state;
      await cubit.endSession();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => EndSessionScreen(
              consultationId: consultationId,
              lawyerId: s.lawyerId ?? '',
              clientId: s.clientId ?? '',
            ),
          ),
              (r) => false,
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// End-chat confirmation dialog
// ─────────────────────────────────────────────────────────────────────────────

class _EndChatConfirmDialog {
  static Future<bool?> show(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: cs.surface,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding:
              const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'إنهاء المحادثة',
                    style: tt.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هل أنت متأكد من إنهاء جلسة المحادثة؟',
                    style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12)),
                          ),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            backgroundColor: cs.error,
                            foregroundColor: cs.onError,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12)),
                          ),
                          child: const Text('إنهاء',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Icon badge
            Positioned(
              top: -30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: cs.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: cs.error.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(Icons.chat_bubble_outline,
                    color: cs.onError, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}