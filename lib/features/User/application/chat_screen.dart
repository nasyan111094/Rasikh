// =============================================================================
// chat_screen.dart  — v3  (PRODUCTION)
//
// Full Agora Chat SDK integration for the timed written-consultation flow.
//
// Architecture mirrors VideoCallScreen / VideoCallCubit exactly:
//   • ChatScreenSession  — public entry-point (BlocProvider)
//   • _ChatSessionView   — BlocConsumer, renders overlays + ChatBody
//   • ChatBody           — StatefulWidget that owns the Agora Chat SDK
//                          (login, send, receive, history, logout)
//
// Agora Chat SDK lifecycle:
//   initState  → login
//             → load conversation history
//             → register message listener
//
//   dispose    → remove listener
//             → logout
//
// Message model:
//   _ChatMessage  — lightweight local model wrapping Agora ChatMessage.
//
// Attachment flow:
//   • Incoming image → download thumbnail automatically.
//   • Image tap with thumbnail only → download original image.
//   • Original image → open full-screen.
//   • File tap → download original file → OpenFilex.
//   • Failed outgoing attachment → retry upload.
//   • Failed incoming attachment → retry download.
//
// IMPORTANT:
//   downloadThumbnail() and downloadAttachment() return void/Future<void>
//   in the installed Agora Chat SDK version. Therefore we NEVER assign
//   their return value to a ChatMessage.
//
// =============================================================================

import 'dart:async';
import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

import 'package:size_config/size_config.dart';

import '../../../features/User/application/end_session_screen.dart';
import '../../../features/common/layout/layout_screen.dart';
import 'bloc/chat_session_cubit.dart';
import 'bloc/chat_session_state.dart';
import 'dialogs/call_summary_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local lightweight message model
// ─────────────────────────────────────────────────────────────────────────────

enum _MsgStatus {
  sending,
  sent,
  failed,
}

enum _MsgType {
  text,
  image,
  file,
}

class _ChatMessage {
  final String msgId;
  final _MsgType type;
  final bool isMine;
  final DateTime timestamp;

  _MsgStatus status;

  /// Text content — only meaningful for [_MsgType.text].
  String text;

  /// Local path to the attachment.
  ///
  /// For outgoing messages this is available immediately.
  /// For received messages this is populated after downloading the original.
  String? localPath;

  /// Downloaded thumbnail path — images only.
  String? thumbnailLocalPath;

  /// Remote path/URL provided by Agora.
  String? remoteUrl;

  /// Original file name — files only.
  String? fileName;

  /// File size in bytes.
  int? fileSize;

  /// Upload/download progress, 0.0–1.0.
  double progress;

  _ChatMessage({
    required this.msgId,
    required this.isMine,
    required this.timestamp,
    this.type = _MsgType.text,
    this.text = '',
    this.status = _MsgStatus.sent,
    this.localPath,
    this.thumbnailLocalPath,
    this.remoteUrl,
    this.fileName,
    this.fileSize,
    this.progress = 0,
  });

  /// Build from an Agora SDK ChatMessage.
  factory _ChatMessage.fromAgora(
      ChatMessage msg,
      String myUserId,
      ) {
    final isMine = msg.from == myUserId;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(
      msg.serverTime > 0 ? msg.serverTime : msg.localTime,
    );

    final body = msg.body;

    if (body is ChatImageMessageBody) {
      return _ChatMessage(
        msgId: msg.msgId,
        type: _MsgType.image,
        isMine: isMine,
        timestamp: timestamp,
        localPath: body.localPath,
        thumbnailLocalPath: body.thumbnailLocalPath,
        remoteUrl: body.remotePath,
        status: _MsgStatus.sent,
      );
    }

    if (body is ChatFileMessageBody) {
      return _ChatMessage(
        msgId: msg.msgId,
        type: _MsgType.file,
        isMine: isMine,
        timestamp: timestamp,
        localPath: body.localPath,
        remoteUrl: body.remotePath,
        fileName: body.displayName,
        fileSize: body.fileSize,
        status: _MsgStatus.sent,
      );
    }

    if (body is ChatTextMessageBody) {
      return _ChatMessage(
        msgId: msg.msgId,
        type: _MsgType.text,
        text: body.content,
        isMine: isMine,
        timestamp: timestamp,
        status: _MsgStatus.sent,
      );
    }

    return _ChatMessage(
      msgId: msg.msgId,
      type: _MsgType.text,
      text: '[نوع رسالة غير مدعوم]',
      isMine: isMine,
      timestamp: timestamp,
      status: _MsgStatus.sent,
    );
  }
}

/// Formats a byte count as a short human-readable size string.
String _formatBytes(int? bytes) {
  if (bytes == null) return '';

  if (bytes < 1024) {
    return '$bytes B';
  }

  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

// =============================================================================
// PUBLIC ENTRY-POINT
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
// INTERNAL VIEW
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
              MaterialPageRoute(
                builder: (_) => const LayoutPage(),
              ),
                  (r) => false,
            );
          }
        },
        onSkip: () async {
          await cubit.endSession();

          if (ctx.mounted) {
            Navigator.of(ctx).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const LayoutPage(),
              ),
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

  void _navigateOnEnded(
      BuildContext ctx,
      ChatSessionState state,
      ChatSessionCubit cubit,
      ) {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatSessionCubit, ChatSessionState>(
      listener: (ctx, state) async {
        if (state.phase == ChatSessionPhase.timerExpired &&
            !_timerExpiredDialogShown) {
          _timerExpiredDialogShown = true;

          await _handleTimerExpired(ctx);
          return;
        }

        if (state.phase == ChatSessionPhase.ended) {
          _navigateOnEnded(
            ctx,
            state,
            ctx.read<ChatSessionCubit>(),
          );
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
                if (state.credentials != null)
                  _ChatBody(
                    credentials: state.credentials!,
                    peerName: state.peerName,
                    peerPhotoUrl: state.peerPhotoUrl,
                    isSessionActive: state.isSessionActive,
                    consultationId: widget.consultationId,
                  ),

                if (state.phase == ChatSessionPhase.initializing ||
                    state.phase == ChatSessionPhase.waitingForClient)
                  _ChatWaitingOverlay(
                    phase: state.phase,
                  ),

                if (state.twoMinuteWarningActive)
                  Positioned(
                    top: 100.h,
                    left: 20.w,
                    right: 20.w,
                    child: const _ChatTwoMinuteWarningBanner(),
                  ),

                if (state.phase == ChatSessionPhase.inProgress ||
                    state.phase == ChatSessionPhase.twoMinuteWarning ||
                    state.phase == ChatSessionPhase.timerExpired)
                  Positioned(
                    top: 50.h,
                    left: 16.w,
                    child: _TimerChip(
                      state: state,
                    ),
                  ),

                if (state.phase == ChatSessionPhase.error)
                  _ChatErrorOverlay(
                    message: state.errorMessage,
                  ),

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
// CHAT BODY
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
  // ─────────────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────────────

  final List<_ChatMessage> _messages = [];

  final TextEditingController _inputCtrl =
  TextEditingController();

  final ScrollController _scrollCtrl =
  ScrollController();

  final ImagePicker _imagePicker =
  ImagePicker();

  bool _sdkReady = false;
  bool _sending = false;
  String? _sdkError;

  static const int _maxAttachmentBytes =
      20 * 1024 * 1024;

  /// Raw Agora SDK messages keyed by msgId.
  final Map<String, ChatMessage> _agoraMessages = {};

  // ─────────────────────────────────────────────────────────────────────────
  // Agora references
  // ─────────────────────────────────────────────────────────────────────────

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

    _chatClient.chatManager.removeEventHandler(
      'chat_body_handler',
    );

    _chatClient.logout(false).catchError((_) {});

    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Agora Chat bootstrap
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _bootstrapAgoraChat() async {
    try {
      await _chatClient.loginWithToken(
        widget.credentials.myUserId,
        widget.credentials.token,
      );

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

      await _loadHistory();

      if (!mounted) return;

      setState(() {
        _sdkReady = true;
      });
    } on ChatError catch (e) {
      if (!mounted) return;

      setState(() {
        _sdkError =
        'فشل الاتصال بخادم الرسائل: ${e.description}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _sdkError =
        'خطأ غير متوقع: $e';
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // History
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    try {
      final conversation =
      await _chatClient.chatManager.getConversation(
        widget.credentials.conversationKey,
        type: ChatConversationType.Chat,
        createIfNeed: true,
      );

      if (conversation == null) {
        return;
      }

      List<ChatMessage> history =
      await conversation.loadMessages(
        startMsgId: '',
        loadCount: 50,
        direction: ChatSearchDirection.Up,
      );

      if (history.isEmpty) {
        try {
          final cursor = await _chatClient.chatManager.fetchHistoryMessagesByOption(
            widget.credentials.conversationKey,
            ChatConversationType.Chat,
          );
          history = cursor.data ?? [];
        } catch (e) {
          debugPrint('Error fetching history: $e');
        }
      }

      await conversation.markAllMessagesAsRead();

      if (!mounted) return;

      final myUserId =
          widget.credentials.myUserId;

      final supported = history.where(
            (message) =>
        message.body is ChatTextMessageBody ||
            message.body is ChatImageMessageBody ||
            message.body is ChatFileMessageBody,
      ).toList();

      setState(() {
        for (final message in supported) {
          _agoraMessages[message.msgId] = message;
        }

        _messages.addAll(
          supported.map(
                (message) => _ChatMessage.fromAgora(
              message,
              myUserId,
            ),
          ),
        );
      });

      // Download thumbnails for images already in history.
      for (final message in supported) {
        if (message.body is ChatImageMessageBody) {
          _downloadThumbnail(message);
        }
      }

      _scrollToBottom(
        animate: false,
      );
    } catch (error) {
      debugPrint(
        'Failed to load chat history: $error',
      );

      // History loading is non-fatal.
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Message received
  // ─────────────────────────────────────────────────────────────────────────

  void _onMessagesReceived(
      List<ChatMessage> messages,
      ) {
    if (!mounted || messages.isEmpty) {
      return;
    }

    final myUserId =
        widget.credentials.myUserId;

    final newMessages = <ChatMessage>[];

    for (final message in messages) {
      final body = message.body;

      if (body is! ChatTextMessageBody &&
          body is! ChatImageMessageBody &&
          body is! ChatFileMessageBody) {
        continue;
      }

      // Prevent duplicate messages.
      if (_agoraMessages.containsKey(message.msgId)) {
        continue;
      }

      _agoraMessages[message.msgId] = message;

      newMessages.add(message);
    }

    if (newMessages.isEmpty) {
      return;
    }

    setState(() {
      for (final message in newMessages) {
        _messages.add(
          _ChatMessage.fromAgora(
            message,
            myUserId,
          ),
        );
      }
    });

    _scrollToBottom();

    // Automatically download thumbnails for incoming images.
    for (final message in newMessages) {
      if (message.body is ChatImageMessageBody) {
        _downloadThumbnail(message);
      }
    }

    _chatClient.chatManager
        .sendConversationReadAck(
      widget.credentials.conversationKey,
    )
        .catchError((error) {
      debugPrint(
        'Failed to send read acknowledgment: $error',
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Download image thumbnail
  //
  // IMPORTANT:
  // Agora SDK method returns void/Future<void>.
  // Do NOT do:
  //
  // final updated = await downloadThumbnail(...)
  //
  // Instead, call it and then read the updated body from the same message.
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _downloadThumbnail(
      ChatMessage message,
      ) async {
    try {
      await _chatClient.chatManager.downloadThumbnail(
        message,
      );

      if (!mounted) return;

      final body = message.body;

      if (body is! ChatImageMessageBody) {
        return;
      }

      final thumbnailPath =
          body.thumbnailLocalPath;

      if (thumbnailPath == null ||
          thumbnailPath.isEmpty) {
        return;
      }

      // Keep the same Agora ChatMessage reference.
      _agoraMessages[message.msgId] = message;

      final index = _messages.indexWhere(
            (item) => item.msgId == message.msgId,
      );

      if (index == -1) {
        return;
      }

      setState(() {
        _messages[index].thumbnailLocalPath =
            thumbnailPath;
      });
    } catch (error) {
      debugPrint(
        'Failed to download image thumbnail: $error',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Delivery / read events
  // ─────────────────────────────────────────────────────────────────────────

  void _onMessagesDelivered(
      List<ChatMessage> messages,
      ) {
    if (!mounted) return;

    bool changed = false;

    for (final delivered in messages) {
      final index = _messages.indexWhere(
            (message) =>
        message.msgId == delivered.msgId,
      );

      if (index != -1 &&
          _messages[index].status ==
              _MsgStatus.sending) {
        changed = true;
        break;
      }
    }

    if (!changed) return;

    setState(() {
      for (final delivered in messages) {
        final index = _messages.indexWhere(
              (message) =>
          message.msgId == delivered.msgId,
        );

        if (index != -1 &&
            _messages[index].status ==
                _MsgStatus.sending) {
          _messages[index].status =
              _MsgStatus.sent;
        }
      }
    });
  }

  void _onMessagesRead(
      List<ChatMessage> messages,
      ) {
    // Extend here if you want double-tick/read receipts.
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Send text message
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();

    if (text.isEmpty ||
        _sending ||
        !_sdkReady) {
      return;
    }

    if (!widget.isSessionActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الجلسة غير نشطة، لا يمكن إرسال رسائل',
          ),
        ),
      );

      return;
    }

    _inputCtrl.clear();

    final msg =
    ChatMessage.createTxtSendMessage(
      targetId:
      widget.credentials.peerUserId,
      content: text,
    );

    _agoraMessages[msg.msgId] = msg;

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
      await _chatClient.chatManager.sendMessage(
        msg,
      );

      if (!mounted) return;

      setState(() {
        optimistic.status =
            _MsgStatus.sent;

        _sending = false;
      });
    } on ChatError catch (e) {
      if (!mounted) return;

      setState(() {
        optimistic.status =
            _MsgStatus.failed;

        _sending = false;
      });

      _showError(
        'فشل إرسال الرسالة: ${e.description}',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        optimistic.status =
            _MsgStatus.failed;

        _sending = false;
      });
    }
  }

  void _showError(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pick/send image
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _pickAndSendImage(
      ImageSource source,
      ) async {
    if (!widget.isSessionActive ||
        !_sdkReady) {
      return;
    }

    final XFile? picked =
    await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1920,
    );

    if (picked == null) {
      return;
    }

    final file = File(picked.path);

    final size = await file.length();

    if (size > _maxAttachmentBytes) {
      _showError(
        'حجم الصورة كبير جداً '
            '(الحد الأقصى '
            '${_formatBytes(_maxAttachmentBytes)})',
      );

      return;
    }

    final msg =
    ChatMessage.createImageSendMessage(
      targetId:
      widget.credentials.peerUserId,
      filePath: picked.path,
      sendOriginalImage: false,
    );

    _agoraMessages[msg.msgId] = msg;

    final optimistic = _ChatMessage(
      msgId: msg.msgId,
      type: _MsgType.image,
      isMine: true,
      timestamp: DateTime.now(),
      localPath: picked.path,
      fileSize: size,
      status: _MsgStatus.sending,
    );

    setState(() {
      _messages.add(optimistic);
    });

    _scrollToBottom();

    await _dispatch(
      msg,
      optimistic,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pick/send file
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _pickAndSendFile() async {
    if (!widget.isSessionActive ||
        !_sdkReady) {
      return;
    }

    final result =
    await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'txt',
        'zip',
        'rar',
      ],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final picked = result.files.single;
    final path = picked.path;

    if (path == null) {
      return;
    }

    final file = File(path);

    final size = await file.length();

    if (size > _maxAttachmentBytes) {
      _showError(
        'حجم الملف كبير جداً '
            '(الحد الأقصى '
            '${_formatBytes(_maxAttachmentBytes)})',
      );

      return;
    }

    final fileName = picked.name;

    final msg =
    ChatMessage.createFileSendMessage(
      targetId:
      widget.credentials.peerUserId,
      filePath: path,
      displayName: fileName,
    );

    _agoraMessages[msg.msgId] = msg;

    final optimistic = _ChatMessage(
      msgId: msg.msgId,
      type: _MsgType.file,
      isMine: true,
      timestamp: DateTime.now(),
      localPath: path,
      fileName: fileName,
      fileSize: size,
      status: _MsgStatus.sending,
    );

    setState(() {
      _messages.add(optimistic);
    });

    _scrollToBottom();

    await _dispatch(
      msg,
      optimistic,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dispatch image/file
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _dispatch(
      ChatMessage msg,
      _ChatMessage optimistic,
      ) async {
    try {
      await _chatClient.chatManager.sendMessage(msg);

      if (!mounted) return;

      setState(() {
        optimistic.status = _MsgStatus.sent;
        optimistic.progress = 1;
      });
    } on ChatError catch (e) {
      if (!mounted) return;

      setState(() {
        optimistic.status = _MsgStatus.failed;
      });

      _showError('فشل إرسال المرفق: ${e.description}');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        optimistic.status = _MsgStatus.failed;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Open / download attachment
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleOpenAttachment(
      _ChatMessage message,
      ) async {
    // Do not open/download while currently uploading/downloading.
    if (message.status ==
        _MsgStatus.sending) {
      return;
    }

    final hasLocalFile =
        message.localPath != null &&
            message.localPath!.isNotEmpty &&
            File(message.localPath!).existsSync();

    // ───────────────────────────────────────
    // Image already downloaded
    // ───────────────────────────────────────

    if (message.type == _MsgType.image &&
        hasLocalFile) {
      await _openImage(
        message,
      );

      return;
    }

    // ───────────────────────────────────────
    // File already downloaded
    // ───────────────────────────────────────

    if (message.type == _MsgType.file &&
        hasLocalFile) {
      await _openLocalFile(
        message.localPath!,
      );

      return;
    }

    // ───────────────────────────────────────
    // Failed outgoing message → retry send
    // ───────────────────────────────────────

    if (message.status ==
        _MsgStatus.failed &&
        message.isMine) {
      await _retryMessage(
        message,
      );

      return;
    }

    // ───────────────────────────────────────
    // Received attachment → download
    // ───────────────────────────────────────

    await _downloadAttachment(
      message,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Download original attachment
  //
  // IMPORTANT:
  // downloadAttachment() returns void/Future<void> in this SDK version.
  //
  // We therefore:
  //   await downloadAttachment(agoraMsg)
  //   ↓
  //   read agoraMsg.body
  //
  // We NEVER do:
  //   final updated = await downloadAttachment(...)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _downloadAttachment(
      _ChatMessage message,
      ) async {
    final agoraMsg =
    _agoraMessages[message.msgId];

    if (agoraMsg == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      message.status =
          _MsgStatus.sending;

      message.progress = 0;
    });

    try {
      await _chatClient.chatManager
          .downloadAttachment(
        agoraMsg,
      );

      if (!mounted) {
        return;
      }

      final body =
          agoraMsg.body;

      // ─────────────────────────────────────
      // Image
      // ─────────────────────────────────────

      if (body is ChatImageMessageBody) {
        final localPath =
            body.localPath;

        final thumbnailPath =
            body.thumbnailLocalPath;

        setState(() {
          if (localPath != null &&
              localPath.isNotEmpty) {
            message.localPath =
                localPath;
          }

          if (thumbnailPath != null &&
              thumbnailPath.isNotEmpty) {
            message.thumbnailLocalPath =
                thumbnailPath;
          }

          message.status =
              _MsgStatus.sent;

          message.progress = 1;
        });

        // Automatically open the original image
        // after successful download.
        if (message.localPath != null &&
            message.localPath!.isNotEmpty &&
            File(message.localPath!)
                .existsSync()) {
          await _openImage(
            message,
          );
        }

        return;
      }

      // ─────────────────────────────────────
      // File
      // ─────────────────────────────────────

      if (body is ChatFileMessageBody) {
        final localPath =
            body.localPath;

        setState(() {
          if (localPath != null &&
              localPath.isNotEmpty) {
            message.localPath =
                localPath;
          }

          message.status =
              _MsgStatus.sent;

          message.progress = 1;
        });

        if (message.localPath != null &&
            message.localPath!.isNotEmpty &&
            File(message.localPath!)
                .existsSync()) {
          await _openLocalFile(
            message.localPath!,
          );
        }

        return;
      }

      // Unsupported attachment body.
      setState(() {
        message.status =
            _MsgStatus.sent;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        message.status =
            _MsgStatus.failed;

        message.progress = 0;
      });

      debugPrint(
        'Failed to download attachment: $error',
      );

      _showError(
        'فشل تحميل المرفق',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Open image
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _openImage(
      _ChatMessage message,
      ) async {
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _FullScreenImageViewer(
              localPath:
              message.localPath,
              remoteUrl:
              message.remoteUrl,
            ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Open local file
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _openLocalFile(
      String path,
      ) async {
    try {
      final result =
      await OpenFile.open(
        path,
      );

      if (result.type !=
          ResultType.done) {
        _showError(
          'تعذر فتح الملف، تم حفظه على الجهاز',
        );
      }
    } catch (_) {
      _showError(
        'تعذر فتح الملف',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Retry failed outgoing message
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _retryMessage(
      _ChatMessage failed,
      ) async {
    // Retry is only valid for messages
    // created locally/sent by the current user.
    if (!failed.isMine) {
      return;
    }

    if (failed.type != _MsgType.text &&
        (failed.localPath == null ||
            failed.localPath!.isEmpty)) {
      setState(() {
        failed.status =
            _MsgStatus.failed;
      });

      return;
    }

    setState(() {
      failed.status =
          _MsgStatus.sending;

      failed.progress = 0;
    });

    late final ChatMessage msg;

    switch (failed.type) {
      case _MsgType.text:
        msg =
            ChatMessage.createTxtSendMessage(
              targetId:
              widget.credentials.peerUserId,
              content: failed.text,
            );
        break;

      case _MsgType.image:
        msg =
            ChatMessage.createImageSendMessage(
              targetId:
              widget.credentials.peerUserId,
              filePath:
              failed.localPath!,
              sendOriginalImage: false,
            );
        break;

      case _MsgType.file:
        msg =
            ChatMessage.createFileSendMessage(
              targetId:
              widget.credentials.peerUserId,
              filePath:
              failed.localPath!,
              displayName:
              failed.fileName ??
                  failed.localPath!
                      .split('/')
                      .last,
            );
        break;
    }

    _agoraMessages[msg.msgId] =
        msg;

    // Status callback handled through state management
    // Note: setMessageStatusCallBack method not available in current SDK

    try {
      await _chatClient.chatManager
          .sendMessage(
        msg,
      );
    } on ChatError catch (e) {
      if (!mounted) return;

      setState(() {
        failed.status =
            _MsgStatus.failed;
      });

      _showError(
        'فشل إعادة الإرسال: ${e.description}',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        failed.status =
            _MsgStatus.failed;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Scroll
  // ─────────────────────────────────────────────────────────────────────────

  void _scrollToBottom({
    bool animate = true,
  }) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) {
        return;
      }

      if (animate) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position
              .maxScrollExtent,
          duration:
          const Duration(
            milliseconds: 300,
          ),
          curve:
          Curves.easeOut,
        );
      } else {
        _scrollCtrl.jumpTo(
          _scrollCtrl.position
              .maxScrollExtent,
        );
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    if (_sdkError != null) {
      return _ChatSdkErrorWidget(
        message: _sdkError!,
      );
    }

    return Scaffold(
      backgroundColor:
      theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _ChatHeader(
            peerName:
            widget.peerName,
            peerPhotoUrl:
            widget.peerPhotoUrl,
            isConnecting:
            !_sdkReady,
          ),

          Expanded(
            child: _sdkReady
                ? _messages.isEmpty
                ? Center(
              child: Text(
                'لا توجد رسائل بعد.\n'
                    'ابدأ المحادثة الآن!',
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: colorScheme
                      .onSurface
                      .withOpacity(
                    0.5,
                  ),
                  height: 1.8,
                ),
                textAlign:
                TextAlign.center,
              ),
            )
                : ListView.builder(
              controller:
              _scrollCtrl,
              padding:
              EdgeInsets.symmetric(
                horizontal:
                16.w,
                vertical:
                8.h,
              ),
              itemCount:
              _messages.length,
              itemBuilder:
                  (ctx, i) {
                return _MessageBubble(
                  message:
                  _messages[i],
                  onRetry:
                  _retryMessage,
                  onOpenAttachment:
                  _handleOpenAttachment,
                );
              },
            )
                : const Center(
              child:
              CircularProgressIndicator(),
            ),
          ),

          _ChatInputField(
            controller:
            _inputCtrl,
            enabled:
            widget.isSessionActive &&
                _sdkReady,
            isSending:
            _sending,
            onSend:
            _sendMessage,
            onPickImage:
            _pickAndSendImage,
            onPickFile:
            _pickAndSendFile,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CHAT HEADER
// =============================================================================

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
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Container(
      padding:
      EdgeInsets.only(
        top: 50.h,
        bottom: 12.h,
        left: 16.w,
        right: 16.w,
      ),
      decoration: BoxDecoration(
        color:
        theme.colorScheme.onSecondary,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow
                .withOpacity(0.05),
            blurRadius: 4,
            offset:
            const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration:
            BoxDecoration(
              color: theme.dividerColor
                  .withOpacity(.5),
              borderRadius:
              BorderRadius.circular(
                8.h,
              ),
            ),
            child: Icon(
              Icons.arrow_back,
              size: 20.sp,
              color:
              colorScheme.onSurface,
            ),
          ),

          Gap(10.w),

          CircleAvatar(
            radius: 25.h,
            backgroundColor:
            colorScheme.surfaceVariant,
            backgroundImage:
            peerPhotoUrl != null
                ? NetworkImage(
              peerPhotoUrl!,
            )
                : null,
            child:
            peerPhotoUrl == null
                ? Icon(
              Icons.person,
              color:
              colorScheme
                  .onSurfaceVariant,
              size: 28.sp,
            )
                : null,
          ),

          Gap(10.w),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                peerName ??
                    'المستشار',
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration:
                    BoxDecoration(
                      color:
                      isConnecting
                          ? Colors.orange
                          : Colors.green,
                      shape:
                      BoxShape.circle,
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Text(
                    isConnecting
                        ? 'جاري الاتصال…'
                        : 'متصل',
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color:
                      theme.hintColor,
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

// =============================================================================
// MESSAGE BUBBLE
// =============================================================================

class _MessageBubble
    extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.onRetry,
    required this.onOpenAttachment,
  });

  final _ChatMessage message;

  final void Function(
      _ChatMessage,
      ) onRetry;

  final void Function(
      _ChatMessage,
      ) onOpenAttachment;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final cs =
        theme.colorScheme;

    final timeStr =
    DateFormat(
      'hh:mm a',
      'ar',
    ).format(
      message.timestamp,
    );

    return Padding(
      padding:
      EdgeInsets.only(
        bottom: 12.h,
      ),
      child: message.isMine
          ? _SentBubble(
        message:
        message,
        timeStr:
        timeStr,
        theme:
        theme,
        cs:
        cs,
        onRetry:
        onRetry,
        onOpenAttachment:
        onOpenAttachment,
      )
          : _ReceivedBubble(
        message:
        message,
        timeStr:
        timeStr,
        theme:
        theme,
        cs:
        cs,
        onOpenAttachment:
        onOpenAttachment,
      ),
    );
  }
}

// =============================================================================
// MESSAGE CONTENT
// =============================================================================

class _MessageContent
    extends StatelessWidget {
  const _MessageContent({
    required this.message,
    required this.textColor,
    required this.onOpenAttachment,
  });

  final _ChatMessage message;
  final Color textColor;

  final void Function(
      _ChatMessage,
      ) onOpenAttachment;

  @override
  Widget build(
      BuildContext context,
      ) {
    switch (message.type) {
      case _MsgType.image:
        return _ImageContent(
          message:
          message,
          onOpenAttachment:
          onOpenAttachment,
        );

      case _MsgType.file:
        return _FileContent(
          message:
          message,
          textColor:
          textColor,
          onOpenAttachment:
          onOpenAttachment,
        );

      case _MsgType.text:
        return Text(
          message.text,
          textAlign:
          TextAlign.right,
          style: Theme.of(
            context,
          )
              .textTheme
              .bodyMedium
              ?.copyWith(
            height: 1.5,
            color:
            textColor,
          ),
        );
    }
  }
}

// =============================================================================
// IMAGE CONTENT
// =============================================================================

class _ImageContent
    extends StatelessWidget {
  const _ImageContent({
    required this.message,
    required this.onOpenAttachment,
  });

  final _ChatMessage message;

  final void Function(
      _ChatMessage,
      ) onOpenAttachment;

  ImageProvider? get _provider {
    final local =
        message.localPath;

    if (local != null &&
        local.isNotEmpty &&
        File(local).existsSync()) {
      return FileImage(
        File(local),
      );
    }

    final thumbnail =
        message.thumbnailLocalPath;

    if (thumbnail != null &&
        thumbnail.isNotEmpty &&
        File(thumbnail).existsSync()) {
      return FileImage(
        File(thumbnail),
      );
    }

    // IMPORTANT:
    // Agora remotePath is not necessarily a browser-accessible URL.
    //
    // We therefore intentionally do NOT use NetworkImage(remoteUrl)
    // here. The SDK download methods should handle Agora attachments.
    return null;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final provider =
        _provider;

    final hasOriginal =
        message.localPath != null &&
            message.localPath!.isNotEmpty &&
            File(
              message.localPath!,
            ).existsSync();

    final hasThumbnail =
        message.thumbnailLocalPath != null &&
            message.thumbnailLocalPath!.isNotEmpty &&
            File(
              message.thumbnailLocalPath!,
            ).existsSync();

    return GestureDetector(
      onTap: () {
        // If the original image does not exist,
        // let the parent download it.
        if (!hasOriginal) {
          onOpenAttachment(
            message,
          );

          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                _FullScreenImageViewer(
                  localPath:
                  message.localPath,
                  remoteUrl:
                  message.remoteUrl,
                ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(
          10.h,
        ),
        child: SizedBox(
          width: 180.w,
          height: 180.w,
          child: Stack(
            fit:
            StackFit.expand,
            children: [
              if (provider != null)
                Image(
                  image:
                  provider,
                  fit:
                  BoxFit.cover,
                )
              else
                Container(
                  color:
                  Colors.black12,
                  child:
                  const Icon(
                    Icons.image_outlined,
                    size: 40,
                    color:
                    Colors.grey,
                  ),
                ),

              // Download overlay when no original exists.
              if (!hasOriginal &&
                  message.status ==
                      _MsgStatus.sent)
                Container(
                  color:
                  Colors.black26,
                  child:
                  Center(
                    child:
                    Container(
                      width: 42,
                      height: 42,
                      decoration:
                      const BoxDecoration(
                        color:
                        Colors.black54,
                        shape:
                        BoxShape.circle,
                      ),
                      child:
                      const Icon(
                        Icons
                            .download_rounded,
                        color:
                        Colors.white,
                      ),
                    ),
                  ),
                ),

              if (message.status ==
                  _MsgStatus.sending)
                Container(
                  color:
                  Colors.black38,
                  child:
                  Center(
                    child:
                    CircularProgressIndicator(
                      value: message
                          .progress >
                          0
                          ? message
                          .progress
                          : null,
                      color:
                      Colors.white,
                    ),
                  ),
                ),

              if (message.status ==
                  _MsgStatus.failed)
                Container(
                  color:
                  Colors.black45,
                  child:
                  Center(
                    child:
                    Icon(
                      Icons
                          .error_outline,
                      color:
                      Colors.redAccent,
                      size: 32,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FILE CONTENT
// =============================================================================

class _FileContent
    extends StatelessWidget {
  const _FileContent({
    required this.message,
    required this.textColor,
    required this.onOpenAttachment,
  });

  final _ChatMessage message;
  final Color textColor;

  final void Function(
      _ChatMessage,
      ) onOpenAttachment;

  @override
  Widget build(
      BuildContext context,
      ) {
    final isDownloaded =
        message.localPath != null &&
            message.localPath!.isNotEmpty &&
            File(
              message.localPath!,
            ).existsSync();

    return GestureDetector(
      onTap: () =>
          onOpenAttachment(
            message,
          ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration:
            BoxDecoration(
              color:
              textColor.withOpacity(
                .15,
              ),
              borderRadius:
              BorderRadius.circular(
                8.h,
              ),
            ),
            alignment:
            Alignment.center,
            child: message.status ==
                _MsgStatus.sending
                ? Padding(
              padding:
              const EdgeInsets
                  .all(
                8,
              ),
              child:
              CircularProgressIndicator(
                strokeWidth:
                2,
                value: message
                    .progress >
                    0
                    ? message
                    .progress
                    : null,
                color:
                textColor,
              ),
            )
                : Icon(
              message.status ==
                  _MsgStatus.failed
                  ? Icons
                  .error_outline
                  : (isDownloaded
                  ? Icons
                  .insert_drive_file
                  : Icons
                  .download_rounded),
              color:
              textColor,
            ),
          ),

          SizedBox(
            width: 8.w,
          ),

          Flexible(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Text(
                  message.fileName ??
                      'ملف',
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  TextStyle(
                    color:
                    textColor,
                    fontWeight:
                    FontWeight
                        .w600,
                  ),
                ),
                if (message
                    .fileSize !=
                    null)
                  Text(
                    _formatBytes(
                      message.fileSize,
                    ),
                    style:
                    TextStyle(
                      color: textColor
                          .withOpacity(
                        .7,
                      ),
                      fontSize:
                      11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FULL-SCREEN IMAGE VIEWER
// =============================================================================

class _FullScreenImageViewer
    extends StatelessWidget {
  const _FullScreenImageViewer({
    this.localPath,
    this.remoteUrl,
  });

  final String? localPath;
  final String? remoteUrl;

  @override
  Widget build(
      BuildContext context,
      ) {
    Widget image;

    if (localPath != null &&
        localPath!.isNotEmpty &&
        File(localPath!).existsSync()) {
      image = Image.file(
        File(localPath!),
        fit: BoxFit.contain,
      );
    } else if (remoteUrl != null &&
        remoteUrl!.isNotEmpty &&
        (remoteUrl!.startsWith(
          'http://',
        ) ||
            remoteUrl!.startsWith(
              'https://',
            ))) {
      image = Image.network(
        remoteUrl!,
        fit: BoxFit.contain,
      );
    } else {
      image = const Icon(
        Icons.broken_image,
        color:
        Colors.white38,
        size: 64,
      );
    }

    return Scaffold(
      backgroundColor:
      Colors.black,
      appBar: AppBar(
        backgroundColor:
        Colors.black,
        iconTheme:
        const IconThemeData(
          color:
          Colors.white,
        ),
        elevation: 0,
      ),
      body: Center(
        child:
        InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: image,
        ),
      ),
    );
  }
}

// =============================================================================
// SENT BUBBLE
// =============================================================================

class _SentBubble
    extends StatelessWidget {
  const _SentBubble({
    required this.message,
    required this.timeStr,
    required this.theme,
    required this.cs,
    required this.onRetry,
    required this.onOpenAttachment,
  });

  final _ChatMessage message;
  final String timeStr;
  final ThemeData theme;
  final ColorScheme cs;

  final void Function(
      _ChatMessage,
      ) onRetry;

  final void Function(
      _ChatMessage,
      ) onOpenAttachment;

  @override
  Widget build(
      BuildContext context,
      ) {
    final isAttachment =
        message.type !=
            _MsgType.text;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment
          .start,
      children: [
        CircleAvatar(
          radius: 18.h,
          backgroundColor:
          cs.surfaceVariant,
          child: Icon(
            Icons.person,
            color:
            cs.onSurfaceVariant,
            size: 18.sp,
          ),
        ),

        SizedBox(
          width: 8.w,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Container(
                padding: isAttachment
                    ? EdgeInsets.all(
                  6.w,
                )
                    : EdgeInsets
                    .symmetric(
                  horizontal:
                  16.w,
                  vertical:
                  12.h,
                ),
                decoration:
                BoxDecoration(
                  color:
                  cs.primary,
                  borderRadius:
                  BorderRadius
                      .only(
                    topLeft:
                    Radius.circular(
                      4.h,
                    ),
                    topRight:
                    Radius.circular(
                      12.h,
                    ),
                    bottomLeft:
                    Radius.circular(
                      12.h,
                    ),
                    bottomRight:
                    Radius.circular(
                      12.h,
                    ),
                  ),
                ),
                child:
                _MessageContent(
                  message:
                  message,
                  textColor:
                  cs.onPrimary,
                  onOpenAttachment:
                  onOpenAttachment,
                ),
              ),

              SizedBox(
                height: 4.h,
              ),

              Padding(
                padding:
                EdgeInsets.only(
                  left: 8.w,
                ),
                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color:
                        theme.hintColor,
                        fontSize:
                        11.sp,
                      ),
                    ),

                    SizedBox(
                      width: 4.w,
                    ),

                    _StatusIcon(
                      status:
                      message.status,
                    ),

                    if (message
                        .status ==
                        _MsgStatus.failed)
                      GestureDetector(
                        onTap: () =>
                            onRetry(
                              message,
                            ),
                        child:
                        Padding(
                          padding:
                          EdgeInsets
                              .only(
                            right:
                            6.w,
                          ),
                          child:
                          Icon(
                            Icons
                                .refresh,
                            size:
                            14.sp,
                            color:
                            cs.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          width: 50.w,
        ),
      ],
    );
  }
}

// =============================================================================
// RECEIVED BUBBLE
// =============================================================================

class _ReceivedBubble
    extends StatelessWidget {
  const _ReceivedBubble({
    required this.message,
    required this.timeStr,
    required this.theme,
    required this.cs,
    required this.onOpenAttachment,
  });

  final _ChatMessage message;
  final String timeStr;
  final ThemeData theme;
  final ColorScheme cs;

  final void Function(
      _ChatMessage,
      ) onOpenAttachment;

  @override
  Widget build(
      BuildContext context,
      ) {
    final isAttachment =
        message.type !=
            _MsgType.text;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment
          .start,
      children: [
        SizedBox(
          width: 50.w,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .end,
            children: [
              Container(
                padding: isAttachment
                    ? EdgeInsets.all(
                  6.w,
                )
                    : EdgeInsets
                    .symmetric(
                  horizontal:
                  16.w,
                  vertical:
                  12.h,
                ),
                decoration:
                BoxDecoration(
                  color: theme
                      .dividerColor
                      .withOpacity(
                    .5,
                  ),
                  borderRadius:
                  BorderRadius
                      .only(
                    topLeft:
                    Radius.circular(
                      12.h,
                    ),
                    topRight:
                    Radius.circular(
                      4.h,
                    ),
                    bottomLeft:
                    Radius.circular(
                      12.h,
                    ),
                    bottomRight:
                    Radius.circular(
                      12.h,
                    ),
                  ),
                ),
                child:
                _MessageContent(
                  message:
                  message,
                  textColor:
                  cs.onSurface,
                  onOpenAttachment:
                  onOpenAttachment,
                ),
              ),

              SizedBox(
                height: 4.h,
              ),

              Padding(
                padding:
                EdgeInsets.only(
                  right: 8.w,
                ),
                child: Text(
                  timeStr,
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color:
                    theme.hintColor,
                    fontSize:
                    11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          width: 8.w,
        ),

        CircleAvatar(
          radius: 18.h,
          backgroundColor:
          theme.dividerColor
              .withOpacity(
            .5,
          ),
          child: Icon(
            Icons.person,
            color:
            cs.onSurfaceVariant,
            size: 18.sp,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// MESSAGE STATUS ICON
// =============================================================================

class _StatusIcon
    extends StatelessWidget {
  const _StatusIcon({
    required this.status,
  });

  final _MsgStatus status;

  @override
  Widget build(
      BuildContext context,
      ) {
    final cs =
        Theme.of(context)
            .colorScheme;

    switch (status) {
      case _MsgStatus.sending:
        return SizedBox(
          width: 10.sp,
          height: 10.sp,
          child:
          CircularProgressIndicator(
            strokeWidth:
            1.5,
            color: cs.onSurface
                .withOpacity(
              0.4,
            ),
          ),
        );

      case _MsgStatus.sent:
        return Icon(
          Icons.done_all,
          size: 14.sp,
          color: cs.primary
              .withOpacity(
            0.7,
          ),
        );

      case _MsgStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 14.sp,
          color: cs.error,
        );
    }
  }
}

// =============================================================================
// CHAT INPUT
// =============================================================================

class _ChatInputField
    extends StatelessWidget {
  const _ChatInputField({
    required this.controller,
    required this.enabled,
    required this.isSending,
    required this.onSend,
    required this.onPickImage,
    required this.onPickFile,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool isSending;

  final VoidCallback onSend;

  final void Function(
      ImageSource source,
      ) onPickImage;

  final VoidCallback onPickFile;

  void _showAttachmentSheet(
      BuildContext context,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(
            20,
          ),
        ),
      ),
      builder: (sheetCtx) {
        final theme =
        Theme.of(sheetCtx);

        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets
                .symmetric(
              vertical: 12,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin:
                  const EdgeInsets
                      .only(
                    bottom: 12,
                  ),
                  decoration:
                  BoxDecoration(
                    color: theme
                        .dividerColor,
                    borderRadius:
                    BorderRadius
                        .circular(
                      2,
                    ),
                  ),
                ),

                ListTile(
                  leading:
                  const Icon(
                    Icons
                        .photo_camera_outlined,
                  ),
                  title:
                  const Text(
                    'التقاط صورة',
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetCtx,
                    );

                    onPickImage(
                      ImageSource
                          .camera,
                    );
                  },
                ),

                ListTile(
                  leading:
                  const Icon(
                    Icons
                        .photo_library_outlined,
                  ),
                  title:
                  const Text(
                    'اختيار من المعرض',
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetCtx,
                    );

                    onPickImage(
                      ImageSource
                          .gallery,
                    );
                  },
                ),

                ListTile(
                  leading:
                  const Icon(
                    Icons
                        .insert_drive_file_outlined,
                  ),
                  title:
                  const Text(
                    'إرسال ملف',
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetCtx,
                    );

                    onPickFile();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final cs =
        theme.colorScheme;

    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration:
      BoxDecoration(
        color:
        theme.colorScheme
            .onSecondary,
        boxShadow: [
          BoxShadow(
            color: cs.shadow
                .withOpacity(
              0.05,
            ),
            blurRadius: 4,
            offset:
            const Offset(
              0,
              -2,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: enabled &&
                !isSending
                ? onSend
                : null,
            child:
            AnimatedContainer(
              duration:
              const Duration(
                milliseconds:
                200,
              ),
              width: 44.w,
              height: 44.w,
              decoration:
              BoxDecoration(
                color: enabled
                    ? cs.primary
                    : theme
                    .dividerColor
                    .withOpacity(
                  .5,
                ),
                shape:
                BoxShape.circle,
              ),
              child: isSending
                  ? Padding(
                padding:
                const EdgeInsets
                    .all(
                  10,
                ),
                child:
                CircularProgressIndicator(
                  strokeWidth:
                  2,
                  color:
                  cs.onPrimary,
                ),
              )
                  : Icon(
                Icons.send,
                size:
                20.sp,
                color: enabled
                    ? cs.onPrimary
                    : theme
                    .hintColor,
              ),
            ),
          ),

          SizedBox(
            width: 12.w,
          ),

          Expanded(
            child:
            TextFormField(
              controller:
              controller,
              enabled:
              enabled,
              textAlign:
              TextAlign.right,
              textInputAction:
              TextInputAction
                  .send,
              onFieldSubmitted:
                  (_) {
                if (enabled &&
                    !isSending) {
                  onSend();
                }
              },
              decoration:
              InputDecoration(
                hintText: enabled
                    ? 'اكتب الرسالة هنا...'
                    : 'الجلسة غير نشطة',
                hintStyle: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color:
                  theme.hintColor,
                  fontSize:
                  14.sp,
                ),
                filled: true,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    25.h,
                  ),
                  borderSide:
                  BorderSide.none,
                ),
                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    25.h,
                  ),
                  borderSide:
                  BorderSide.none,
                ),
                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    25.h,
                  ),
                  borderSide:
                  BorderSide.none,
                ),
                contentPadding:
                EdgeInsets
                    .symmetric(
                  horizontal:
                  16.w,
                ),
              ),
              validator:
                  (value) {
                if (value ==
                    null ||
                    value.trim()
                        .isEmpty) {
                  return 'الرجاء إدخال رسالة';
                }

                return null;
              },
            ),
          ),

          SizedBox(
            width: 12.w,
          ),

          _IconBtn(
            icon:
            Icons.attach_file,
            bg:
            cs.surfaceVariant,
            iconColor:
            theme.hintColor,
            onTap: enabled
                ? () =>
                _showAttachmentSheet(
                  context,
                )
                : null,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ICON BUTTON
// =============================================================================

class _IconBtn
    extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.bg,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color bg;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration:
        BoxDecoration(
          color: bg,
          shape:
          BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: iconColor,
        ),
      ),
    );
  }
}

// =============================================================================
// SDK ERROR
// =============================================================================

class _ChatSdkErrorWidget
    extends StatelessWidget {
  const _ChatSdkErrorWidget({
    required this.message,
  });

  final String message;

  @override
  Widget build(
      BuildContext context,
      ) {
    final cs =
        Theme.of(context)
            .colorScheme;

    return Center(
      child:
      SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.all(
            32,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 56,
                color: cs.error,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                message,
                style:
                const TextStyle(
                  fontSize: 15,
                ),
                textAlign:
                TextAlign.center,
              ),

              const SizedBox(
                height: 24,
              ),

              ElevatedButton(
                onPressed: () =>
                    Navigator.of(
                      context,
                    ).pop(),
                child:
                const Text(
                  'العودة',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// WAITING OVERLAY
// =============================================================================

class _ChatWaitingOverlay
    extends StatelessWidget {
  const _ChatWaitingOverlay({
    required this.phase,
  });

  final ChatSessionPhase phase;

  String get _message {
    switch (phase) {
      case ChatSessionPhase
          .initializing:
        return 'جاري تحضير المحادثة…';

      case ChatSessionPhase
          .waitingForClient:
        return 'في انتظار انضمام الطرف الآخر…';

      default:
        return 'جاري التحميل…';
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.black
            .withOpacity(
          0.55,
        ),
        child: Center(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color:
                Colors.white,
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                _message,
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TWO-MINUTE WARNING
// =============================================================================

class _ChatTwoMinuteWarningBanner
    extends StatelessWidget {
  const _ChatTwoMinuteWarningBanner();

  @override
  Widget build(
      BuildContext context,
      ) {
    final cs =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
      const EdgeInsets
          .symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration:
      BoxDecoration(
        color:
        cs.error.withOpacity(
          0.9,
        ),
        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: cs.onError,
            size: 20,
          ),

          const SizedBox(
            width: 8,
          ),

          Text(
            'تبقّت دقيقتان على انتهاء الجلسة',
            style:
            TextStyle(
              color:
              cs.onError,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TIMER CHIP
// =============================================================================

class _TimerChip
    extends StatelessWidget {
  const _TimerChip({
    required this.state,
  });

  final ChatSessionState state;

  @override
  Widget build(
      BuildContext context,
      ) {
    final cs =
        Theme.of(context)
            .colorScheme;

    final isCritical =
        state.twoMinuteWarningActive ||
            (state.remainingSeconds !=
                null &&
                state.remainingSeconds! <=
                    120);

    return AnimatedContainer(
      duration:
      const Duration(
        milliseconds: 300,
      ),
      padding:
      const EdgeInsets
          .symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration:
      BoxDecoration(
        color: isCritical
            ? cs.error
            .withOpacity(
          0.15,
        )
            : cs.surface
            .withOpacity(
          0.95,
        ),
        borderRadius:
        BorderRadius.circular(
          5,
        ),
        border:
        Border.all(
          color: isCritical
              ? cs.error
              .withOpacity(
            0.6,
          )
              : cs.onSurface
              .withOpacity(
            0.25,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.08,
            ),
            blurRadius: 6,
            offset:
            const Offset(
              0,
              2,
            ),
          ),
        ],
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: isCritical
                ? cs.error
                : cs.onSurface
                .withOpacity(
              0.7,
            ),
          ),

          const SizedBox(
            width: 6,
          ),

          Text(
            state.formattedRemaining,
            style: Theme.of(
              context,
            )
                .textTheme
                .bodyMedium
                ?.copyWith(
              color: isCritical
                  ? cs.error
                  : cs.onSurface,
              fontSize: 14,
              fontWeight:
              isCritical
                  ? FontWeight
                  .bold
                  : FontWeight
                  .normal,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Container(
            width: 8,
            height: 8,
            decoration:
            BoxDecoration(
              color:
              state.isSessionActive
                  ? cs.error
                  : Colors.grey,
              shape:
              BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ERROR OVERLAY
// =============================================================================

class _ChatErrorOverlay
    extends StatelessWidget {
  const _ChatErrorOverlay({
    this.message,
  });

  final String? message;

  @override
  Widget build(
      BuildContext context,
      ) {
    final cs =
        Theme.of(context)
            .colorScheme;

    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.black
            .withOpacity(
          0.75,
        ),
        child: Center(
          child: Padding(
            padding:
            const EdgeInsets
                .all(
              32,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color:
                  cs.error,
                  size: 56,
                ),

                const SizedBox(
                  height: 16,
                ),

                Text(
                  message ??
                      'حدث خطأ في تحميل المحادثة',
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 15,
                  ),
                  textAlign:
                  TextAlign.center,
                ),

                const SizedBox(
                  height: 24,
                ),

                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(
                        context,
                      ).pop(),
                  child:
                  const Text(
                    'العودة',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// END CHAT BUTTON
// =============================================================================

class _EndChatButton
    extends StatelessWidget {
  const _EndChatButton({
    required this.consultationId,
    required this.state,
  });

  final String consultationId;
  final ChatSessionState state;

  @override
  Widget build(
      BuildContext context,
      ) {
    final cs =
        Theme.of(context)
            .colorScheme;

    return GestureDetector(
      onTap: () =>
          _handleEndChat(
            context,
          ),
      child: Container(
        padding:
        const EdgeInsets
            .symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration:
        BoxDecoration(
          color: cs.error,
          borderRadius:
          BorderRadius.circular(
            24,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.error
                  .withOpacity(
                0.3,
              ),
              blurRadius: 8,
              offset:
              const Offset(
                0,
                4,
              ),
            ),
          ],
        ),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.call_end,
              color:
              cs.onError,
              size: 18,
            ),

            const SizedBox(
              width: 6,
            ),

            Text(
              'إنهاء المحادثة',
              style:
              TextStyle(
                color:
                cs.onError,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEndChat(
      BuildContext context,
      ) async {
    final confirmed =
    await _EndChatConfirmDialog
        .show(
      context,
    );

    if (confirmed != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final cubit =
    context.read<
        ChatSessionCubit>();

    if (cubit.isLawyer) {
      await showCallSummaryDialog(
        context,
        onSubmit: (summary) async {
          await cubit
              .submitCallSummary(
            summary,
          );

          await cubit.endSession();

          if (context.mounted) {
            Navigator.of(
              context,
            ).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) =>
                const LayoutPage(),
              ),
                  (r) => false,
            );
          }
        },
        onSkip: () async {
          await cubit.endSession();

          if (context.mounted) {
            Navigator.of(
              context,
            ).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) =>
                const LayoutPage(),
              ),
                  (r) => false,
            );
          }
        },
      );
    } else {
      final s =
          cubit.state;

      await cubit.endSession();

      if (context.mounted) {
        Navigator.of(
          context,
        ).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                EndSessionScreen(
                  consultationId:
                  consultationId,
                  lawyerId:
                  s.lawyerId ?? '',
                  clientId:
                  s.clientId ?? '',
                ),
          ),
              (r) => false,
        );
      }
    }
  }
}

// =============================================================================
// END CHAT CONFIRMATION DIALOG
// =============================================================================

class _EndChatConfirmDialog {
  static Future<bool?> show(
      BuildContext context,
      ) {
    final cs =
        Theme.of(context)
            .colorScheme;

    final tt =
        Theme.of(context)
            .textTheme;

    return showDialog<bool>(
      context: context,
      barrierDismissible:
      false,
      builder: (_) => Dialog(
        backgroundColor:
        cs.surface,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            20,
          ),
        ),
        child: Stack(
          clipBehavior:
          Clip.none,
          alignment:
          Alignment.topCenter,
          children: [
            Padding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                20,
                50,
                20,
                20,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    'إنهاء المحادثة',
                    style: tt
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    'هل أنت متأكد من إنهاء جلسة المحادثة؟',
                    style: tt
                        .bodyMedium
                        ?.copyWith(
                      color: cs
                          .onSurface
                          .withOpacity(
                        0.7,
                      ),
                    ),
                    textAlign:
                    TextAlign
                        .center,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                        OutlinedButton(
                          onPressed:
                              () =>
                              Navigator.of(
                                context,
                              ).pop(
                                false,
                              ),
                          style:
                          OutlinedButton.styleFrom(
                            minimumSize:
                            const Size
                                .fromHeight(
                              46,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          child:
                          const Text(
                            'إلغاء',
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                        ElevatedButton(
                          onPressed:
                              () =>
                              Navigator.of(
                                context,
                              ).pop(
                                true,
                              ),
                          style:
                          ElevatedButton.styleFrom(
                            minimumSize:
                            const Size
                                .fromHeight(
                              46,
                            ),
                            backgroundColor:
                            cs.error,
                            foregroundColor:
                            cs.onError,
                            elevation:
                            0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          child:
                          const Text(
                            'إنهاء',
                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: -30,
              child:
              Container(
                width: 60,
                height: 60,
                decoration:
                BoxDecoration(
                  color:
                  cs.error,
                  shape:
                  BoxShape
                      .circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs
                          .error
                          .withOpacity(
                        0.3,
                      ),
                      blurRadius:
                      12,
                      offset:
                      const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),
                child:
                Icon(
                  Icons
                      .chat_bubble_outline,
                  color:
                  cs.onError,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}