import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client_app/src/features/profile/face_analysis.event.dart';
import 'package:client_app/src/features/profile/face_analysis.state.dart';

class FaceAnalysisBloc extends Bloc<FaceAnalysisEvent, FaceAnalysisState> {
  FaceAnalysisBloc(this._faceProfile, this._catalog)
      : super(const FaceAnalysisState()) {
    on<FaceAnalysisStarted>(_onStarted);
    on<FaceAnalysisPhotoScanned>(_onPhotoScanned);
    on<FaceAnalysisCheckedAgain>(_onCheckedAgain);
  }

  static const int _maxCatalogPages = 5;

  final FaceProfileRepository _faceProfile;
  final ServiceCatalogRepository _catalog;

  Future<void> _onStarted(
    FaceAnalysisStarted event,
    Emitter<FaceAnalysisState> emit,
  ) async {
    if (state.status != FaceAnalysisStatus.initial) return;
    await _load(emit);
  }

  Future<void> _onPhotoScanned(
    FaceAnalysisPhotoScanned event,
    Emitter<FaceAnalysisState> emit,
  ) async {
    if (state.status == FaceAnalysisStatus.uploading) return;
    emit(
      state.copyWith(
        status: FaceAnalysisStatus.uploading,
        clearUploadedPhotoUrl: true,
        clearError: true,
        awaitingAnalysis: true,
      ),
    );
    try {
      final photo = await _faceProfile.uploadFacePhoto(event.filePath);
      if (emit.isDone) return;
      emit(state.copyWith(uploadedPhotoUrl: photo.imageUrl));
      await _load(emit);
    } catch (error) {
      if (emit.isDone) return;
      emit(state.copyWith(status: FaceAnalysisStatus.failed, error: error));
    }
  }

  Future<void> _onCheckedAgain(
    FaceAnalysisCheckedAgain event,
    Emitter<FaceAnalysisState> emit,
  ) async {
    final status = state.status;
    if (status == FaceAnalysisStatus.initial ||
        status == FaceAnalysisStatus.loading ||
        status == FaceAnalysisStatus.uploading) {
      return;
    }
    await _load(emit);
  }

  Future<void> _load(Emitter<FaceAnalysisState> emit) async {
    emit(state.copyWith(status: FaceAnalysisStatus.loading));
    try {
      final recommendations = await _faceProfile.getRecommendations();
      if (emit.isDone) return;
      if (recommendations.isEmpty) {
        emit(
          state.copyWith(
            status: FaceAnalysisStatus.ready,
            clearLatest: true,
            clearCurated: true,
          ),
        );
        return;
      }
      final latest = recommendations.first;
      final curated = await _resolveCurated(latest.recommendedCatalogItemIds);
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: FaceAnalysisStatus.ready,
          latest: latest,
          curated: curated,
          awaitingAnalysis: false,
        ),
      );
    } catch (error) {
      if (emit.isDone) return;
      emit(state.copyWith(status: FaceAnalysisStatus.failed, error: error));
    }
  }

  Future<List<CatalogItemDto>> _resolveCurated(List<String>? ids) async {
    if (ids == null || ids.isEmpty) return const [];
    final wanted = ids.toSet();
    final found = <CatalogItemDto>[];
    try {
      for (var page = 1;
          page <= _maxCatalogPages && found.length < wanted.length;
          page++) {
        final result = await _catalog.getCatalogItems(page: page, perPage: 100);
        for (final item in result.data) {
          if (wanted.contains(item.id)) found.add(item);
        }
      }
    } catch (_) {
      return found;
    }
    return found;
  }
}