import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client_app/src/features/profile/avatar.event.dart';
import 'package:client_app/src/features/profile/avatar.state.dart';

class AvatarBloc extends Bloc<AvatarEvent, AvatarState> {
  AvatarBloc(this._profile) : super(const AvatarState()) {
    on<AvatarPhotoChanged>(_onPhotoChanged);
  }

  final ProfileRepository _profile;

  Future<void> _onPhotoChanged(
    AvatarPhotoChanged event,
    Emitter<AvatarState> emit,
  ) async {
    if (state.isUploading) return;
    emit(state.copyWith(isUploading: true, clearError: true));
    try {
      final avatar = await _profile.uploadAvatar(event.filePath);
      if (emit.isDone) return;
      emit(state.copyWith(isUploading: false, avatarUrl: avatar.avatarUrl));
    } catch (error) {
      if (emit.isDone) return;
      emit(state.copyWith(isUploading: false, error: error));
    }
  }
}