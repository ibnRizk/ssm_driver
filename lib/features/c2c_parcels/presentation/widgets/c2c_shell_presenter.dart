import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/notice_dialog.dart';
import '../../../../core/widgets/show_dialog.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../c2c_display.dart';
import '../cubit/c2c_location_cubit.dart';
import '../cubit/c2c_offer_watch_cubit.dart';

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
  /// One dialog at a time; offers found meanwhile are on the board anyway.
  bool _showing = false;

  Future<void> _announce(BuildContext context, List<C2cParcel> offers) async {
    if (_showing) return;
    _showing = true;
    final GoRouter router = GoRouter.of(context);
    final C2cParcel first = offers.first;
    final bool? view = await showAppDialog(
      context: context,
      child: NoticeDialog(
        icon: Icons.home_work_outlined,
        title: Strings.c2cNewOfferTitle,
        // Coarse areas only — the offer isn't accepted yet (contract §7).
        body: offers.length == 1
            ? <String>[
                first.areaRoute,
                if (first.summary.isNotEmpty) first.summary,
              ].join('\n')
            : Strings.c2cNewOfferMany(offers.length),
        confirmText: Strings.parcelNewAssignedView,
        dismissText: Strings.parcelNewAssignedLater,
      ),
    );
    _showing = false;
    if (view == true && mounted) router.goNamed(AppRoutes.parcelsName);
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
