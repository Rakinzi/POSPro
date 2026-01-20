import 'package:flutter/material.dart';
import 'package:mobile_pos/Screens/Products/product_data.dart';

import '../constant.dart';
import 'button_global.dart';

// ignore: must_be_immutable
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.product, required this.pressed});

  final Product product;

  final VoidCallback pressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              product.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ButtonGlobalWithoutIcon(
              buttontext: 'Select',
              buttonDecoration: kButtonDecoration.copyWith(color: kDarkWhite),
              onPressed: pressed,
              buttonTextColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
