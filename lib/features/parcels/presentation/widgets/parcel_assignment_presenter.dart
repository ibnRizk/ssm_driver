import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/notice_dialog.dart';
import '../../../../core/widgets/show_dialog.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/parcel.dart';
import '../cubit/parcel_assignment_cubit.dart';
import '../cubit/parcel_assignment_state.dart';
import '../parcel_display.dart';

/// Announces parcels newly assigned while the app is open, over any tab.
///
/// Lives in the bottom-nav shell, which only exists for a signed-in,
/// approved Driver — so the watch starts after sign-in and its cubit closes
/// with the shell on sign-out.
class ParcelAssignmentPresenter extends StatefulWidget {
  final Widget child;

  const ParcelAssignmentPresenter({super.key, required this.child});

  @override
  State<ParcelAssignmentPresenter> createState() =>
      _ParcelAssignmentPresenterState();
}

class _ParcelAssignmentPresenterState extends State<ParcelAssignmentPresenter> {
  /// One dialog at a time; parcels found meanwhile still reach the Parcels
  /// tab, whose list refreshes on the same push.
  bool _showing = false;

  Future<void> _announce(BuildContext context, List<Parcel> parcels) async {
    if (_showing) return;
    _showing = true;
    final GoRouter router = GoRouter.of(context);
    final Parcel first = parcels.first;
    final bool? view = await showAppDialog(
      context: context,
      child: NoticeDialog(
        icon: Icons.inventory_2_outlined,
        title: Strings.parcelNewAssignedTitle,
        body: parcels.length == 1
            ? <String>[
                '${first.label} • ${first.recipientLabel}',
                if (first.deliveryAddress.isNotEmpty) first.deliveryAddress,
                if (first.isCashOnDelivery) first.paymentLabel,
              ].join('\n')
            : Strings.parcelNewAssignedMany(parcels.length),
        confirmText: Strings.parcelNewAssignedView,
        dismissText: Strings.parcelNewAssignedLater,
      ),
    );
    _showing = false;
    if (view != true || !mounted) return;

    router.goNamed(AppRoutes.parcelsName);
    if (parcels.length == 1) {
      router.pushNamed<void>(
        AppRoutes.parcelDetailsName,
        pathParameters: <String, String>{'id': '${first.id}'},
        extra: first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParcelAssignmentCubit>(
      create: (_) => ServiceLocator.instance<ParcelAssignmentCubit>()..start(),
      child: BlocListener<ParcelAssignmentCubit, ParcelAssignmentState>(
        listener: (BuildContext context, ParcelAssignmentState state) {
          if (state is ParcelAssignmentFound) _announce(context, state.parcels);
        },
        child: widget.child,
      ),
    );
  }
}
