import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One line in [OrderItemsCard]: a description and its price.
class OrderLineItem {
  final String description;
  final String price;

  const OrderLineItem({required this.description, required this.price});
}

/// White receipt-style card listing every item in the order (plus fees like
/// delivery), description on the right, price in orange on the left.
class OrderItemsCard extends StatelessWidget {
  final List<OrderLineItem> items;

  const OrderItemsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.xs.h,
      ),
      decoration: AppDecorations.card(c),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) const Divider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      items[i].description,
                      style: AppTextStyles.body(color: c.textPrimary),
                    ),
                  ),
                  Text(
                    items[i].price,
                    style: AppTextStyles.titleSmall(color: c.secondary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
