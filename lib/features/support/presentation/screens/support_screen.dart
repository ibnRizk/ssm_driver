import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/support_info.dart';
import '../cubit/support_cubit.dart';
import '../cubit/support_state.dart';

/// PLACEHOLDER layout until the Figma design lands: it proves
/// `GET /delivery-man/support-info` end to end by listing the raw contacts
/// and FAQs. Replace the body, keep the cubit.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocProvider<SupportCubit>(
      create: (_) => ServiceLocator.instance<SupportCubit>()..load(),
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(title: Text(Strings.profileSupport)),
        body: BlocBuilder<SupportCubit, SupportState>(
          builder: (BuildContext context, SupportState state) =>
              switch (state) {
                SupportLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                SupportError(:final String message) => Center(
                  child: ErrorRetryView(
                    message: message,
                    onRetry: context.read<SupportCubit>().load,
                  ),
                ),
                SupportLoaded(:final SupportInfo info) => _SupportDetails(
                  info: info,
                ),
              },
        ),
      ),
    );
  }
}

class _SupportDetails extends StatelessWidget {
  final SupportInfo info;

  const _SupportDetails({required this.info});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return ListView(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      children: <Widget>[
        if (info.phone case final String phone)
          _ContactTile(Icons.phone_outlined, Strings.supportPhone, phone),
        if (info.whatsapp case final String whatsapp)
          _ContactTile(Icons.chat_outlined, Strings.supportWhatsapp, whatsapp),
        if (info.email case final String email)
          _ContactTile(Icons.email_outlined, Strings.supportEmail, email),
        if (info.workingHours case final String hours)
          _ContactTile(
            Icons.schedule_outlined,
            Strings.supportWorkingHours,
            hours,
          ),
        SizedBox(height: AppSpacing.lg.h),
        Text(
          Strings.supportFaqsTitle,
          style: AppTextStyles.title(color: c.textPrimary),
        ),
        SizedBox(height: AppSpacing.sm.h),
        if (info.faqs.isEmpty)
          Text(
            Strings.supportNoFaqs,
            style: AppTextStyles.body(color: c.textSecondary),
          )
        else
          for (final SupportFaq faq in info.faqs)
            ExpansionTile(
              title: Text(faq.question),
              expandedAlignment: AlignmentDirectional.centerStart,
              childrenPadding: EdgeInsets.all(AppSpacing.md.w),
              children: <Widget>[Text(faq.answer)],
            ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      // Phone numbers keep their leading `+` in place in RTL.
      subtitle: SelectableText(value, textDirection: TextDirection.ltr),
    );
  }
}
