import 'package:equatable/equatable.dart';

sealed class AvatarEvent extends Equatable {
  const AvatarEvent();

  @override
  List<Object?> get props => [];
}

class AvatarPhotoChanged extends AvatarEvent {
  const AvatarPhotoChanged(this.filePath);

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}