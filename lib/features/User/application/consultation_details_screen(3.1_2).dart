import 'package:rasikh/config/localization/loc_keys.dart';
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/widgets/custom_dotted_container.dart';
import 'package:record/record.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import '../../../core/utils/get_asset_path.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/general_app_bar.dart';
import '../../../core/widgets/general_option_card.dart';
import '../../../core/widgets/picture.dart' show Picture;
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'dialogs/ChooseLawyerMethodDialog.dart';
import 'widgets/consultation_flow_widgets.dart';

class ConsultationDetailsScreen extends StatefulWidget {
  const ConsultationDetailsScreen({super.key});

  @override
  State<ConsultationDetailsScreen> createState() =>
      _ConsultationDetailsScreenState();
}

class _ConsultationDetailsScreenState
    extends State<ConsultationDetailsScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _recordedPath;

  static const int _maxRecordingSeconds = 300;

  @override
  void initState() {
    super.initState();
    final state = context.read<ConsultationApplicationCubit>().state;
    _titleController =
        TextEditingController(text: state.consultationTitle);
    _detailsController =
        TextEditingController(text: state.consultationDetails);

    if (state.voiceNote != null) {
      _recordedPath = state.voiceNote!.path;
    }

    _player.playerStateStream.listen((s) {
      if (mounted) {
        setState(() {
          _isPlaying = s.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _recordingTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }


  Future<void> _pickAttachment() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpeg', 'jpg', 'png', 'doc', 'docx'],
    );
    if (result != null &&
        result.files.isNotEmpty &&
        result.files.first.path != null) {
      context
          .read<ConsultationApplicationCubit>()
          .addAttachment(File(result.files.first.path!));
    }
  }


  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _showPermissionDenied();
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc), path: path);

    setState(() {
      _isRecording = true;
      _recordingDuration = Duration.zero;
      _recordedPath = null;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _recordingDuration =
            Duration(seconds: _recordingDuration.inSeconds + 1);
      });
      if (_recordingDuration.inSeconds >= _maxRecordingSeconds) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    final path = await _recorder.stop();

    if (path != null && mounted) {
      setState(() {
        _isRecording = false;
        _recordedPath = path;
      });
      context.read<ConsultationApplicationCubit>().setVoiceNote(
        File(path),
        _recordingDuration.inSeconds,
      );
    }
  }

  Future<void> _togglePlayback() async {
    if (_recordedPath == null) return;

    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.setFilePath(_recordedPath!);
      await _player.play();
    }
  }

  void _deleteRecording() {
    _player.stop();
    setState(() {
      _recordedPath = null;
      _isPlaying = false;
      _recordingDuration = Duration.zero;
    });
    context.read<ConsultationApplicationCubit>().clearVoiceNote();
  }

  void _showPermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Loc.grantMicrophonePermission(),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _onRefreshPricing() async {
    await context.read<ConsultationApplicationCubit>().loadPricingPlans();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GeneralAppBar(
        title: Loc.consultationDetailsAlt(),
        backIcon: Icons.arrow_back,
        backIconSize: 22,
      ),
      body: SafeArea(
        child: BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ConsultationFlowSpacing.horizontal,
                  ),
                  child: const ConsultationFlowStepper(activeStep: 3),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefreshPricing,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ConsultationFlowSpacing.horizontal,
                      ),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          ConsultationFieldLabel(Loc.chooseConsultationDurationRequired()),
                          Gap(ConsultationFlowSpacing.titleToContent),

                          _buildPricingSection(state, theme, colorScheme),

                          Gap(ConsultationFlowSpacing.sectionGap),

                          ConsultationFieldLabel(Loc.consultationTitleRequired()),
                          Gap(ConsultationFlowSpacing.titleToContent),
                          TextField(
                            controller: _titleController,
                            textAlign: TextAlign.right,
                            onChanged: context
                                .read<ConsultationApplicationCubit>()
                                .updateTitle,
                            decoration: InputDecoration(
                              hintText: Loc.consultationTitleExample(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    ConsultationFlowSpacing.radius),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 16.h),
                            ),
                          ),

                          Gap(ConsultationFlowSpacing.fieldGap),

                          ConsultationFieldLabel(Loc.consultationDetailsRequired()),
                          Gap(ConsultationFlowSpacing.titleToContent),
                          TextField(
                            controller: _detailsController,
                            maxLines: 5,
                            textAlign: TextAlign.right,
                            onChanged: context
                                .read<ConsultationApplicationCubit>()
                                .updateDetails,
                            decoration: InputDecoration(
                              hintText: Loc.writeHere(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    ConsultationFlowSpacing.radius),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 16.h),
                            ),
                          ),

                          Gap(ConsultationFlowSpacing.sectionGap),

                          ConsultationFieldLabel(Loc.voiceNote()),
                          Gap(ConsultationFlowSpacing.titleToContent),
                          _buildVoiceNoteSection(theme, colorScheme, state),

                          Gap(ConsultationFlowSpacing.sectionGap),

                          _buildAttachmentsSection(state, theme, colorScheme),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ConsultationFlowSpacing.horizontal,
                  ),
                  child: ConsultationBottomButton(
                    text: Loc.next(),
                    onPressed: state.canProceedFromDetails
                        ? () => showDialog(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                value:
                                    context.read<ConsultationApplicationCubit>(),
                                child: const ChooseLawyerMethodDialog(),
                              ),
                            )
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }



  Widget _buildPricingSection(
      ConsultationState state, ThemeData theme, ColorScheme colorScheme) {

    if (state.pricingStatus == ConsultationStatus.loading) {
      return _buildPricingShimmer(theme);
    }

    if (state.pricingStatus == ConsultationStatus.failure) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: ErrorStateWidget(
          title: Loc.unableToLoadPricingPlans(),
          message: state.pricingError ?? Loc.errorConnectingToServer(),
          actionLabel: Loc.retryAgain(),
          onAction: () => context
              .read<ConsultationApplicationCubit>()
              .loadPricingPlans(),
        ),
      );
    }

    if (state.pricingPlans.isEmpty) {
      return ConsultationEmptyState(
        icon: Icons.access_time_filled_rounded,
        title: Loc.noPricingPlansAvailable(),
        message: Loc.pricingPlansUnavailableTryLater(),
      );
    }

    return Column(
      children: state.pricingPlans
          .map(
            (pricing) => OptionCard(
          value: pricing.id,
          isHorizontal: true,
          icon: Icon(
            Icons.access_time,
            color: state.selectedPricing?.id == pricing.id
                ? colorScheme.primary
                : theme.hintColor,
          ),
          title: pricing.durationLabel,
          subtitle: pricing.priceLabel,
          isSelected: state.selectedPricing?.id == pricing.id,
          onTap: () => context
              .read<ConsultationApplicationCubit>()
              .selectPricing(pricing),
        ),
      )
          .toList(),
    );
  }

  Widget _buildPricingShimmer(ThemeData theme) {
    final baseColor = theme.brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade700;
    final highlightColor = theme.brightness == Brightness.light
        ? Colors.grey.shade100
        : Colors.grey.shade600;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(
          3,
              (_) => Container(
            margin: EdgeInsets.only(bottom: ConsultationFlowSpacing.cardGap),
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildVoiceNoteSection(
      ThemeData theme, ColorScheme colorScheme, ConsultationState state) {
    if (_isRecording) {
      return _RecordingWidget(
        duration: _recordingDuration,
        maxSeconds: _maxRecordingSeconds,
        onStop: _stopRecording,
        colorScheme: colorScheme,
        theme: theme,
      );
    }

    if (_recordedPath != null || state.voiceNote != null) {
      final path = _recordedPath ?? state.voiceNote!.path;
      return _VoiceNotePreview(
        filePath: path,
        durationSeconds: state.voiceNoteDurationSeconds ??
            _recordingDuration.inSeconds,
        isPlaying: _isPlaying,
        onTogglePlayback: _togglePlayback,
        onDelete: _deleteRecording,
        colorScheme: colorScheme,
        theme: theme,
      );
    }

    return GestureDetector(
      onTap: _startRecording,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                Loc.tapToRecordMaxFiveMinutes(),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor),
                textAlign: TextAlign.right,
              ),
            ),
            CircleAvatar(
              backgroundColor: colorScheme.primary,
              radius: 20.h,
              child: const Icon(Icons.mic, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAttachmentsSection(
      ConsultationState state, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ConsultationFieldLabel(Loc.attachments()),
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: state.attachments.isNotEmpty
                    ? colorScheme.primary.withOpacity(0.1)
                    : theme.dividerColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.h),
              ),
              child: Text(
                '${state.attachments.length}/5',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: state.attachments.isNotEmpty
                      ? colorScheme.primary
                      : theme.hintColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          ],
        ),

        Gap(ConsultationFlowSpacing.titleToContent),

        if (state.attachments.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.attachments.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 2.4,
            ),
            itemBuilder: (context, index) => _AttachmentCard(
              file: state.attachments[index],
              onRemove: () => context
                  .read<ConsultationApplicationCubit>()
                  .removeAttachment(index),
            ),
          ),
          SizedBox(height: 12.h),
        ],

        if (state.attachments.length < 5)
          GestureDetector(
            onTap: _pickAttachment,
            child: AppDottedBorder(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.h),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Picture(
                      getAssetIcon("upload.svg"),
                      width: 36.h,
                      height: 36.h,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      Loc.uploadYourFileHere(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      Loc.allowedFileTypesHint(),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton(
                      onPressed: _pickAttachment,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                        foregroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.h),
                        ),
                        textStyle: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(Loc.chooseFile()),
                    )
                  ],
                ),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding:
            EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05),
              border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    color: colorScheme.primary, size: 18.h),
                SizedBox(width: 8.w),
                Text(
                  Loc.maxFilesReached(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}


class _RecordingWidget extends StatefulWidget {
  final Duration duration;
  final int maxSeconds;
  final VoidCallback onStop;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _RecordingWidget({
    required this.duration,
    required this.maxSeconds,
    required this.onStop,
    required this.colorScheme,
    required this.theme,
  });

  @override
  State<_RecordingWidget> createState() => _RecordingWidgetState();
}

class _RecordingWidgetState extends State<_RecordingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.8, end: 1.2).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.duration.inSeconds / widget.maxSeconds;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: widget.colorScheme.error.withOpacity(0.06),
        border:
        Border.all(color: widget.colorScheme.error.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: widget.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child:
                  const Icon(Icons.mic, color: Colors.white, size: 22),
                ),
              ),
              Text(
                _formatDuration(widget.duration),
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: widget.colorScheme.error,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              GestureDetector(
                onTap: widget.onStop,
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: widget.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stop_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.h),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor:
              widget.colorScheme.error.withOpacity(0.15),
              color: widget.colorScheme.error,
              minHeight: 4.h,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            Loc.recordingTapStopToFinish(),
            style: widget.theme.textTheme.bodySmall
                ?.copyWith(color: widget.colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


class _VoiceNotePreview extends StatelessWidget {
  final String filePath;
  final int durationSeconds;
  final bool isPlaying;
  final VoidCallback onTogglePlayback;
  final VoidCallback onDelete;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _VoiceNotePreview({
    required this.filePath,
    required this.durationSeconds,
    required this.isPlaying,
    required this.onTogglePlayback,
    required this.onDelete,
    required this.colorScheme,
    required this.theme,
  });

  String _formatSeconds(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        border:
        Border.all(color: colorScheme.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTogglePlayback,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  Loc.voiceNoteWithIcon(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Loc.durationWithValue(_formatSeconds(durationSeconds)),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onDelete,
            child: Center(
              child: Picture(
                getAssetIcon("delete.svg"),
                width: 25.h,
                height: 25.h,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _AttachmentCard extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _AttachmentCard({required this.file, required this.onRemove});

  String get _fileName => file.path.split('/').last;

  String get _extension =>
      _fileName.contains('.') ? _fileName.split('.').last.toLowerCase() : '';

  IconData get _icon {
    switch (_extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _iconColor(ColorScheme cs) {
    switch (_extension) {
      case 'pdf':
        return Colors.redAccent;
      case 'doc':
      case 'docx':
        return Colors.blueAccent;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Colors.green;
      default:
        return cs.primary;
    }
  }

  String get _fileSize {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final iconColor = _iconColor(cs);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        border: Border.all(color: iconColor.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Row(
        children: [
          Container(
            width: 36.h,
            height: 36.h,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8.h),
            ),
            child: Icon(_icon, color: iconColor, size: 20.h),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _fileName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                ),
                if (_fileSize.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    _fileSize,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.hintColor),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22.h,
              height: 22.h,
              decoration: BoxDecoration(
                color: cs.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, color: cs.error, size: 14.h),
            ),
          ),
        ],
      ),
    );
  }
}