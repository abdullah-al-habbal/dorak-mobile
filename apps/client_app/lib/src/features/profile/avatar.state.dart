import 'package:equatable/equatable.dart';

class AvatarState extends Equatable {
  const AvatarState({this.avatarUrl, this.isUploading = false, this.error});

  final String? avatarUrl;
  final bool isUploading;
  final Object? error;

  AvatarState copyWith({
    String? avatarUrl,
    bool clearAvatarUrl = false,
    bool? isUploading,
    Object? error,
    bool clearError = false,
  }) {
    return AvatarState(
      avatarUrl: clearAvatarUrl ? null : avatarUrl ?? this.avatarUrl,
      isUploading: isUploading ?? this.isUploading,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [avatarUrl, isUploading, error];
}