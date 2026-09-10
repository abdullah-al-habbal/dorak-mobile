import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';

import 'package:client_app/src/features/profile/avatar.bloc.dart';
import 'package:client_app/src/features/profile/avatar.event.dart';
import 'package:client_app/src/features/profile/avatar.state.dart';
import 'package:client_app/src/features/profile/face_analysis.bloc.dart';
import 'package:client_app/src/features/profile/face_analysis.event.dart';
import 'package:client_app/src/features/profile/face_analysis.state.dart';
import 'package:client_app/src/features/profile/history.bloc.dart';
import 'package:client_app/src/features/profile/history.event.dart';
import 'package:client_app/src/features/profile/history.state.dart';
import 'package:client_app/src/features/profile/photo_picker.provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.history,
    required this.faceAnalysis,
    required this.avatar,
    required this.photoPicker,
    required this.clientName,
    required this.onChangePassword,
    required this.onViewBookings,
  });

  final HistoryBloc history;
  final FaceAnalysisBloc faceAnalysis;
  final AvatarBloc avatar;
  final PhotoPicker photoPicker;
  final String? clientName;
  final VoidCallback onChangePassword;
  final VoidCallback onViewBookings;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    widget.history.add(const HistoryStarted());
    widget.faceAnalysis.add(const FaceAnalysisStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          bloc: widget.history,
          builder: (context, state) {
            if (state.rebooked) return _successView(context);
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification &&
                    notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 200) {
                  widget.history.add(const HistoryLoadMoreRequested());
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  widget.history.add(const HistoryRefreshRequested());
                },
                child: ListView(
                  padding: const EdgeInsets.all(DorakDimensions.marginMobile),
                  children: [
                    _profileHeader(context),
                    const SizedBox(height: DorakDimensions.spacingLarge),
                    SecondaryButton(
                      label: AppLocalizations.of(context)!.changePasswordTitle,
                      onPressed: widget.onChangePassword,
                    ),
                    ..._faceAnalysisSection(context),
                    ..._curatedSection(context),
                    const SizedBox(height: DorakDimensions.spacingLarge),
                    Text(
                      AppLocalizations.of(context)!.historyTitle,
                      style: DorakTypography.titleLg,
                    ),
                    const SizedBox(height: DorakDimensions.spacingSmall),
                    ..._historySection(context, state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _successView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusView(
      icon: Icons.check_circle_outline,
      title: l10n.historyRebookSuccessTitle,
      message: l10n.historyRebookSuccessMessage,
      actionLabel: l10n.bookingViewBookings,
      onAction: () {
        widget.history.add(const HistoryRebookAcknowledged());
        widget.onViewBookings();
      },
    );
  }

  Widget _profileHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final name = widget.clientName;
    final initial = (name == null || name.isEmpty)
        ? '?'
        : name.characters.first.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(DorakDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: DorakDimensions.radiusMd,
      ),
      child: Row(
        children: [
          BlocBuilder<AvatarBloc, AvatarState>(
            bloc: widget.avatar,
            builder: (context, avatarState) {
              return InkWell(
                onTap: () => _pickAndUploadAvatar(context),
                customBorder: const CircleBorder(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _avatarImage(context, avatarState.avatarUrl, initial),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: DorakDimensions.spacingLarge,
                        height: DorakDimensions.spacingLarge,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.outline),
                        ),
                        child: avatarState.isUploading
                            ? const Center(child: AppLoader.inline())
                            : Icon(
                                Icons.camera_alt_outlined,
                                size: 14,
                                color: colors.primary,
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: DorakDimensions.spacingMedium),
          Expanded(
            child: Text(
              (name == null || name.isEmpty) ? l10n.profileMemberLabel : name,
              style: DorakTypography.headlineLgMobile.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarImage(BuildContext context, String? avatarUrl, String initial) {
    final colors = DorakColors.of(context);
    final fallback = ColoredBox(
      color: colors.primaryContainer,
      child: Center(
        child: Text(
          initial,
          style: DorakTypography.titleLg.copyWith(
            color: colors.onPrimaryContainer,
          ),
        ),
      ),
    );
    return ClipOval(
      child: SizedBox(
        width: 56,
        height: 56,
        child: avatarUrl == null
            ? fallback
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final path = await widget.photoPicker.pickPhoto();
    if (path == null) return;
    widget.avatar.add(AvatarPhotoChanged(path));
  }

  List<Widget> _faceAnalysisSection(BuildContext context) {
    return [
      BlocBuilder<FaceAnalysisBloc, FaceAnalysisState>(
        bloc: widget.faceAnalysis,
        builder: (context, state) => _FaceCard(
          state: state,
          onScan: () => _pickAndScanFace(context),
          onCheckAgain: () => widget.faceAnalysis.add(
            const FaceAnalysisCheckedAgain(),
          ),
        ),
      ),
      const SizedBox(height: DorakDimensions.spacingLarge),
    ];
  }

  List<Widget> _curatedSection(BuildContext context) {
    return [
      BlocBuilder<FaceAnalysisBloc, FaceAnalysisState>(
        bloc: widget.faceAnalysis,
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          final colors = DorakColors.of(context);
          if (state.status != FaceAnalysisStatus.ready) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.curatedForYouTitle, style: DorakTypography.titleLg),
              const SizedBox(height: DorakDimensions.spacingSmall),
              if (state.curated.isEmpty)
                Text(
                  l10n.curatedEmptyMessage,
                  style: DorakTypography.bodyMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                )
              else
                ...state.curated.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: DorakDimensions.spacingMedium,
                    ),
                    child: _CuratedCard(item: item),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: DorakDimensions.spacingLarge),
    ];
  }

  Future<void> _pickAndScanFace(BuildContext context) async {
    final path = await widget.photoPicker.pickPhoto();
    if (path == null) return;
    widget.faceAnalysis.add(FaceAnalysisPhotoScanned(path));
  }

  List<Widget> _historySection(BuildContext context, HistoryState state) {
    if (state.page.hasFailedFirst) {
      return [
        StatusView(
          icon: Icons.error_outline,
          title: AppLocalizations.of(context)!.errorTitleGeneric,
          message: AppLocalizations.of(context)!.errorNetwork,
          actionLabel: AppLocalizations.of(context)!.actionRetry,
          onAction: () => widget.history.add(const HistoryRetryRequested()),
        ),
      ];
    }
    if (state.page.isFirstLoad) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: DorakDimensions.spacingMedium,
          ),
          child: Center(child: AppLoader.inline()),
        ),
      ];
    }
    if (state.page.isEmpty) {
      return [
        StatusView(
          icon: Icons.history_outlined,
          title: AppLocalizations.of(context)!.historyEmptyTitle,
          message: AppLocalizations.of(context)!.historyEmptyMessage,
        ),
      ];
    }
    final localeCode = Localizations.localeOf(context).languageCode;
    final children = <Widget>[];
    if (state.rebookError != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(
            bottom: DorakDimensions.spacingSmall,
          ),
          child: StatusBanner(message: _rebookMessage(context, state.rebookError)),
        ),
      );
    }
    final items = _itemNames(localeCode, state.page.items);
    for (var i = 0; i < state.page.items.length; i++) {
      final item = state.page.items[i];
      children.add(
        Padding(
          padding: const EdgeInsets.only(
            bottom: DorakDimensions.spacingMedium,
          ),
          child: _HistoryCard(
            item: item,
            itemName: items[i],
            localeCode: localeCode,
            rebookLabel: AppLocalizations.of(context)!.historyRebookAction,
            isRebooking: state.rebookingId == item.id,
            onRebook: () => _pickRebookTime(context, item),
          ),
        ),
      );
    }
    children.add(_feedFooter(context, state));
    return children;
  }

  Widget _feedFooter(BuildContext context, HistoryState state) {
    if (state.page.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: DorakDimensions.spacingMedium),
        child: Center(child: AppLoader.inline()),
      );
    }
    if (state.page.hasFailedMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DorakDimensions.spacingSmall,
        ),
        child: StatusBanner(
          message: AppLocalizations.of(context)!.errorNetwork,
          actionLabel: AppLocalizations.of(context)!.actionRetry,
          onAction: () => widget.history.add(const HistoryRetryRequested()),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  static List<String> _itemNames(
    String localeCode,
    List<ServiceHistoryDto> items,
  ) {
    return items.map((item) {
      final names = item.catalogItem?.name ?? const <String, String>{};
      return names[localeCode] ?? names['en'] ?? '';
    }).toList();
  }

  String _rebookMessage(BuildContext context, Object? error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is ApiException && error.statusCode == 409) {
      return l10n.bookingConflictMessage;
    }
    if (error is NetworkException) return l10n.errorNetwork;
    return l10n.errorGeneric;
  }

  Object? stateRebookErrorOf(BuildContext context) {
    final state = context.read<HistoryBloc>().state;
    return state.rebookError;
  }

  Future<void> _pickRebookTime(
    BuildContext context,
    ServiceHistoryDto item,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    widget.history.add(
      HistoryRebookRequested(
        item.id,
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      ),
    );
  }
}

String _shapeLabel(AppLocalizations l10n, String shape) {
  switch (shape) {
    case 'oval':
      return l10n.faceShapeOval;
    case 'round':
      return l10n.faceShapeRound;
    case 'square':
      return l10n.faceShapeSquare;
    case 'heart':
      return l10n.faceShapeHeart;
    case 'diamond':
      return l10n.faceShapeDiamond;
    case 'oblong':
      return l10n.faceShapeOblong;
    case 'triangle':
      return l10n.faceShapeTriangle;
  }
  return shape;
}

class _FaceCard extends StatelessWidget {
  const _FaceCard({
    required this.state,
    required this.onScan,
    required this.onCheckAgain,
  });

  final FaceAnalysisState state;
  final VoidCallback onScan;
  final VoidCallback onCheckAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final Widget content = switch (state.status) {
      FaceAnalysisStatus.initial ||
      FaceAnalysisStatus.loading ||
      FaceAnalysisStatus.uploading =>
        const Padding(
          padding: EdgeInsets.symmetric(vertical: DorakDimensions.spacingLarge),
          child: Center(child: AppLoader.inline()),
        ),
      FaceAnalysisStatus.failed => _errorContent(context, l10n),
      FaceAnalysisStatus.ready => _readyContent(context, l10n),
    };
    return Container(
      padding: const EdgeInsets.all(DorakDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: DorakDimensions.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.faceAnalysisTitle, style: DorakTypography.titleLg),
          const SizedBox(height: DorakDimensions.spacingMedium),
          content,
        ],
      ),
    );
  }

  Widget _errorContent(BuildContext context, AppLocalizations l10n) {
    final message = state.error is NetworkException
        ? l10n.errorNetwork
        : l10n.errorGeneric;
    return StatusView(
      icon: Icons.error_outline,
      title: l10n.errorTitleGeneric,
      message: message,
      actionLabel: l10n.actionRetry,
      onAction: onCheckAgain,
    );
  }

  Widget _readyContent(BuildContext context, AppLocalizations l10n) {
    final latest = state.latest;
    if (latest == null) {
      if (state.awaitingAnalysis) return _pendingContent(context, l10n);
      return _emptyContent(context, l10n);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _facePhoto(context, latest.faceProfile?.imageUrl),
            const SizedBox(width: DorakDimensions.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.faceAnalysisDetectedShape}: '
                    '${_shapeLabel(l10n, latest.detectedFaceShape)}',
                    style: DorakTypography.bodyMd,
                  ),
                  const SizedBox(height: DorakDimensions.spacingSmall / 2),
                  Text(
                    '${l10n.faceAnalysisConfidence}: '
                    '${(latest.confidenceScore * 100).round()}%',
                    style: DorakTypography.bodyMd.copyWith(
                      color: DorakColors.of(context).onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: DorakDimensions.spacingMedium),
        SecondaryButton(label: l10n.faceScanAction, onPressed: onScan),
      ],
    );
  }

  Widget _pendingContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.uploadedPhotoUrl != null) ...[
          _facePhoto(context, state.uploadedPhotoUrl),
          const SizedBox(height: DorakDimensions.spacingMedium),
        ],
        Text(l10n.faceAnalysisPendingTitle, style: DorakTypography.titleLg),
        const SizedBox(height: DorakDimensions.spacingSmall / 2),
        Text(
          l10n.faceAnalysisPendingMessage,
          style: DorakTypography.bodyMd.copyWith(
            color: DorakColors.of(context).onSurfaceVariant,
          ),
        ),
        const SizedBox(height: DorakDimensions.spacingMedium),
        SecondaryButton(label: l10n.actionCheckAgain, onPressed: onCheckAgain),
      ],
    );
  }

  Widget _emptyContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.faceAnalysisEmptyTitle, style: DorakTypography.titleLg),
        const SizedBox(height: DorakDimensions.spacingSmall / 2),
        Text(
          l10n.faceAnalysisEmptyMessage,
          style: DorakTypography.bodyMd.copyWith(
            color: DorakColors.of(context).onSurfaceVariant,
          ),
        ),
        const SizedBox(height: DorakDimensions.spacingMedium),
        SecondaryButton(label: l10n.faceScanAction, onPressed: onScan),
      ],
    );
  }

  Widget _facePhoto(BuildContext context, String? url) {
    final colors = DorakColors.of(context);
    final placeholder = Container(
      color: colors.surfaceContainerHighest,
      child: Icon(Icons.face_outlined, color: colors.onSurfaceVariant),
    );
    return ClipRRect(
      borderRadius: DorakDimensions.radiusSm,
      child: SizedBox(
        width: 56,
        height: 56,
        child: url == null
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}

class _CuratedCard extends StatelessWidget {
  const _CuratedCard({required this.item});

  final CatalogItemDto item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final name = item.name[localeCode] ?? item.name['en'] ?? '';
    final price = item.priceRange;
    final lines = <String>[
      if (price?.min != null && price?.max != null)
        l10n.curatedPriceRange(price!.min!, price.max!, price.currency ?? ''),
      if (item.stylePeriod != null) item.stylePeriod!,
    ];
    return Container(
      padding: const EdgeInsets.all(DorakDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: DorakDimensions.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: DorakTypography.titleLg),
          if (lines.isNotEmpty) ...[
            const SizedBox(height: DorakDimensions.spacingSmall / 2),
            Text(
              lines.join('\n'),
              style: DorakTypography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.item,
    required this.itemName,
    required this.localeCode,
    required this.rebookLabel,
    required this.isRebooking,
    required this.onRebook,
  });

  final ServiceHistoryDto item;
  final String itemName;
  final String localeCode;
  final String rebookLabel;
  final bool isRebooking;
  final VoidCallback onRebook;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final performedAt = item.performedAt;
    final metaLines = [
      if (itemName.isNotEmpty) itemName,
      if (item.barber != null) l10n.bookingWithBarber(item.barber!.name),
      if (item.branch != null) item.branch!.name,
    ];
    return Container(
      padding: const EdgeInsets.all(DorakDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: DorakDimensions.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  performedAt == null
                      ? ''
                      : DateFormat.yMMMd(localeCode)
                          .add_Hm()
                          .format(performedAt.toLocal()),
                  style: DorakTypography.titleLg,
                ),
              ),
              if (isRebooking)
                const AppLoader.inline()
              else
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onRebook,
                  child: Text(rebookLabel),
                ),
            ],
          ),
          if (metaLines.isNotEmpty) ...[
            const SizedBox(height: DorakDimensions.spacingSmall / 2),
            Text(
              metaLines.join('\n'),
              style: DorakTypography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}