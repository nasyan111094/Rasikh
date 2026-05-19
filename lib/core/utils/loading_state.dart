import 'package:equatable/equatable.dart';

class LoadingState extends Equatable {
  final bool silent;
  final bool loading;
  final bool reloading;
  final bool loadingMore;

  bool get anyLoading => loading || reloading || loadingMore;

  const LoadingState()
      : silent = false,
        loading = false,
        reloading = false,
        loadingMore = false;

  const LoadingState.loading({
    this.silent = false,
  })  : loading = true,
        reloading = false,
        loadingMore = false;

  const LoadingState.reloading({
    this.silent = false,
  })  : loading = false,
        reloading = true,
        loadingMore = false;

  const LoadingState.loadingMore({
    this.silent = false,
  })  : loading = false,
        reloading = false,
        loadingMore = true;

  @override
  List<Object?> get props => [
        silent,
        loading,
        reloading,
        loadingMore,
      ];
}
