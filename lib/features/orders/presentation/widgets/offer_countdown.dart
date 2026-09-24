import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// "Expires in 25s", counted down from the server's `remaining_seconds`
/// rather than a local guess (API docs §10). Calls [onExpired] once when it
/// reaches zero; a new [remainingSeconds] restarts it.
class OfferCountdown extends StatefulWidget {
  final int remainingSeconds;
  final VoidCallback onExpired;

  const OfferCountdown({
    super.key,
    required this.remainingSeconds,
    required this.onExpired,
  });

  @override
  State<OfferCountdown> createState() => _OfferCountdownState();
}

class _OfferCountdownState extends State<OfferCountdown> {
  Timer? _ticker;
  late DateTime _deadline;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void didUpdateWidget(OfferCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingSeconds != widget.remainingSeconds) _restart();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _restart() {
    _ticker?.cancel();
    _deadline = DateTime.now().add(Duration(seconds: widget.remainingSeconds));
    _secondsLeft = widget.remainingSeconds;
    if (_secondsLeft <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onExpired();
      });
      return;
    }
    // Measured against the deadline, not by counting ticks, so a janky
    // frame can't make the countdown drift.
    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final int left =
          (_deadline.difference(DateTime.now()).inMilliseconds / 1000)
              .ceil()
              .clamp(0, widget.remainingSeconds);
      setState(() => _secondsLeft = left);
      if (left == 0) {
        timer.cancel();
        widget.onExpired();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Text(
      Strings.orderOfferExpiresIn(_secondsLeft),
      style: AppTextStyles.caption(
        color: _secondsLeft <= 10 ? c.error : c.textSecondary,
      ),
    );
  }
}
