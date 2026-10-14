import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/values/strings.dart';
import '../../features/c2c_parcels/presentation/widgets/c2c_board_view.dart';
import '../../features/parcels/presentation/screens/parcels_screen.dart';

/// The `parcels` tab: house-to-house (C2C) work and warehouse parcels are
/// separate APIs and flows (C2C contract), so each keeps its own view under
/// one segmented switch. Both stay alive while switching.
class ParcelsTab extends StatefulWidget {
  const ParcelsTab({super.key});

  @override
  State<ParcelsTab> createState() => _ParcelsTabState();
}

enum _Segment { c2c, warehouse }

class _ParcelsTabState extends State<ParcelsTab> {
  _Segment _segment = _Segment.c2c;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen.w,
                AppSpacing.sm.h,
                AppSpacing.screen.w,
                0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<_Segment>(
                  showSelectedIcon: false,
                  segments: <ButtonSegment<_Segment>>[
                    ButtonSegment<_Segment>(
                      value: _Segment.c2c,
                      label: Text(Strings.c2cSegment),
                    ),
                    ButtonSegment<_Segment>(
                      value: _Segment.warehouse,
                      label: Text(Strings.warehouseSegment),
                    ),
                  ],
                  selected: <_Segment>{_segment},
                  onSelectionChanged: (Set<_Segment> s) =>
                      setState(() => _segment = s.single),
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _segment.index,
                children: const <Widget>[C2cBoardView(), ParcelsScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
