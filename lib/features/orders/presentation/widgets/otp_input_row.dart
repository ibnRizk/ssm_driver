import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Customer delivery code entry: [length] boxes backed by one invisible
/// [TextField], so the keyboard, paste and SMS one-time-code autofill all
/// work natively. Digits always read left-to-right, even in RTL.
class OtpInputRow extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const OtpInputRow({
    super.key,
    required this.onChanged,
    this.length = 6,
    this.enabled = true,
  });

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? _focusNode.requestFocus : null,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                autofillHints: const <String>[AutofillHints.oneTimeCode],
                maxLength: widget.length,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                onChanged: widget.onChanged,
              ),
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: ListenableBuilder(
              listenable: Listenable.merge(<Listenable>[
                _controller,
                _focusNode,
              ]),
              builder: (BuildContext context, _) {
                final String code = _controller.text;
                return Row(
                  children: <Widget>[
                    for (int i = 0; i < widget.length; i++) ...<Widget>[
                      if (i > 0) SizedBox(width: AppSpacing.xs.w),
                      Expanded(
                        child: OtpBox(
                          value: i < code.length ? code[i] : null,
                          isActive: _focusNode.hasFocus && i == code.length,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OtpBox extends StatelessWidget {
  final String? value;

  /// The box the next digit goes into.
  final bool isActive;

  const OtpBox({super.key, this.value, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? digit = value;
    final bool highlighted = (digit != null && digit.isNotEmpty) || isActive;

    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(
          color: highlighted ? c.secondary : c.border,
          width: highlighted ? 2.w : 1.w,
        ),
      ),
      alignment: Alignment.center,
      child: digit != null && digit.isNotEmpty
          ? Text(
              digit,
              style: AppTextStyles.h1(
                color: c.primaryDark,
              ).copyWith(fontSize: 28.sp),
            )
          : Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: c.border,
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}
