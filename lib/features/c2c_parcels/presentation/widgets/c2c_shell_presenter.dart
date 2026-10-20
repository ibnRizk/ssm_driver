import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../injection_container.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../cubit/c2c_location_cubit.dart';
import '../cubit/c2c_offer_watch_cubit.dart';
import 'c2c_offer_sheet.dart';

/// App-wide C2C duties while a signed-in, approved Driver is in the shell:
/// announces new offers over any tab, and keeps reporting the Driver's
/// position for active jobs (contract §4). Both stop when the shell goes
/// away on sign-out.
class C2cShellPresenter extends StatefulWidget {
  final Widget child;

  const C2cShellPresenter({super.key, required this.child});

  @override
  State<C2cShellPresenter> createState() => _C2cShellPresenterState();
}

class _C2cShellPresenterState extends State<C2cShellPresenter> {
  /// One sheet at a time; offers found meanwhile are on the board anyway.
  bool _showing = false;

  /// Shows the first new offer; accepting it opens its job directly.
  Future<void> _announce(BuildContext context, List<C2cParcel> offers) async {
    if (_showing) return;
    _showing = true;
    final GoRouter router = GoRouter.of(context);
    final C2cOfferSheetResult? result = await showC2cOfferSheet(
      context: context,
      offer: offers.first,
      moreCount: offers.length - 1,
    );
    _showing = false;
    if (!mounted || !context.mounted) return;

    switch (result) {
      case C2cOfferAccepted(:final int parcelId, :final C2cParcel? parcel):
        showAppSnackBar(
          context: context,
          message: Strings.c2cAccepted,
          type: ToastType.success,
        );
        router.pushNamed<void>(
          AppRoutes.c2cJobName,
          pathParameters: <String, String>{'id': '$parcelId'},
          extra: parcel,
        );
      case C2cOfferViewAll():
        router.goNamed(AppRoutes.parcelsName);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<C2cOfferWatchCubit>(
          create: (_) => ServiceLocator.instance<C2cOfferWatchCubit>()..start(),
        ),
        BlocProvider<C2cLocationCubit>(
          // Nothing reads its state; it only has to live with the shell.
          lazy: false,
          create: (_) => ServiceLocator.instance<C2cLocationCubit>()..start(),
        ),
      ],
      child: BlocListener<C2cOfferWatchCubit, C2cOfferWatchState>(
        listener: (BuildContext context, C2cOfferWatchState state) {
          if (state is C2cOfferWatchFound) _announce(context, state.offers);
        },
        child: widget.child,
      ),
    );
  }
}
