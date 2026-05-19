// features/help_center/logic/content/content_state.dart

part of 'content_cubit.dart';

sealed class ContentState {}

final class ContentInitial extends ContentState {}

final class ContentLoading extends ContentState {}

final class ContentLoaded extends ContentState {
  final ContentModel content;
  final ContentType type;
  final bool isRefreshing;

  ContentLoaded(
    this.content, {
    required this.type,
    this.isRefreshing = false,
  });

  ContentLoaded copyWith({
    ContentModel? content,
    bool? isRefreshing,
  }) {
    return ContentLoaded(
      content ?? this.content,
      type: type,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final class ContentFailure extends ContentState {
  final String message;
  ContentFailure(this.message);
}
