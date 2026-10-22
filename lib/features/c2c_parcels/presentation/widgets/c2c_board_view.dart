import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../cubit/c2c_action_cubit.dart';
import '../cubit/c2c_action_state.dart';
import '../cubit/c2c_board_cubit.dart';
import '../cubit/c2c_board_state.dart';
import 'c2c_parcel_card.dart';

/// The Parcels tab's house-to-house segment: offers to accept, then the
/// Driver's accepted jobs. Pull down to refresh.
class C2cBoardView extends StatelessWidget {
  const C2cBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<C2cBoardCubit>(
          create: (_) => ServiceLocator.instance<C2cBoardCubit>()..load(),
        ),
        BlocProvider<C2cActionCubit>(
          create: (_) => ServiceLocator.instance<C2cActionCubit>(),
        ),
      ],
      child: BlocListener<C2cActionCubit, C2cActionState>(
        listener: (BuildContext context, C2cActionState state) {
          final C2cBoardCubit board = context.read<C2cBoardCubit>();
          switch (state) {
            case C2cActionSuccess(:final int parcelId, :final C2cParcel? parcel):
              showAppSnackBar(
                context: context,
                message: Strings.c2cAccepted,
                type: ToastType.success,
              );
              _openJob(context, parcelId, parcel);
            case C2cRejectSuccess(:final int parcelId, :final int offerId):
              board.removeOffer(parcelId: parcelId, offerId: offerId);
              showAppSnackBar(
                context: context,
                message: Strings.c2cOfferRejected,
                type: ToastType.info,
              );
            case C2cRejectFailure(:final String message):
              showAppSnackBar(
                context: context,
                message: message,
                type: ToastType.error,
              );
            case C2cActionFailure(:final String message, :final bool shouldRefresh):
              showAppSnackBar(
                context: context,
                message: message,
                type: ToastType.error,
              );
              // e.g. the offer expired or went to someone else.
              if (shouldRefresh) board.load();
            default:
              break;
          }
        },
        child: const _Body(),
      ),
    );
  }
}

/// Opens a job and re-reads the board on return, since it may have moved on.
Future<void> _openJob(
  BuildContext context,
  int parcelId,
  C2cParcel? parcel,
) async {
  final C2cBoardCubit board = context.read<C2cBoardCubit>();
  await context.pushNamed<void>(
    AppRoutes.c2cJobName,
    pathParameters: <String, String>{'id': '$parcelId'},
    extra: parcel,
  );
  if (!board.isClosed) await board.load();
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocBuilder<C2cBoardCubit, C2cBoardState>(
      builder: (BuildContext context, C2cBoardState state) => switch (state) {
        C2cBoardLoading() => Center(
          child: CircularProgressIndicator(color: c.secondary),
        ),
        C2cBoardError(:final String message) => ErrorRetryView(
          message: message,
          onRetry: context.read<C2cBoardCubit>().load,
        ),
        final C2cBoardLoaded loaded => RefreshIndicator(
          color: c.secondary,
          onRefresh: context.read<C2cBoardCubit>().load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppSpacing.screen.w),
            children: <Widget>[
              if (loaded.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xxl.h),
                  child: Text(
                    Strings.c2cBoardEmpty,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(color: c.textSecondary),
                  ),
                ),
              if (loaded.offers.isNotEmpty) ...<Widget>[
                _SectionTitle(Strings.c2cOffersTitle),
                for (final C2cParcel offer in loaded.offers) _OfferTile(offer),
              ],
              if (loaded.jobs.isNotEmpty) ...<Widget>[
                _SectionTitle(Strings.c2cJobsTitle),
                for (final C2cParcel job in loaded.jobs)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                    child: C2cParcelCard.job(
                      parcel: job,
                      onTap: () => _openJob(context, job.id, job),
                    ),
                  ),
              ],
            ],
          ),
        ),
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h, top: AppSpacing.xs.h),
      child: Text(
        text,
        style: AppTextStyles.h2(color: context.colors.primaryDark),
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final C2cParcel offer;

  const _OfferTile(this.offer);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: BlocBuilder<C2cActionCubit, C2cActionState>(
        builder: (BuildContext context, C2cActionState actionState) {
          final bool isAccepting = actionState is C2cActionInProgress &&
              actionState.parcelId == offer.id;
          final bool isRejecting = actionState is C2cRejectInProgress &&
              actionState.parcelId == offer.id;
          final bool isAnyBusy = actionState is C2cActionInProgress ||
              actionState is C2cRejectInProgress;

          return C2cParcelCard.offer(
            parcel: offer,
            isAccepting: isAccepting,
            isRejecting: isRejecting,
            // One command at a time.
            onAccept: isAnyBusy
                ? null
                : () => context.read<C2cActionCubit>().run(
                      offer,
                      C2cAction.accept,
                    ),
            onReject: isAnyBusy
                ? null
                : () => context.read<C2cActionCubit>().reject(offer),
          );
        },
      ),
    );
  }
}

