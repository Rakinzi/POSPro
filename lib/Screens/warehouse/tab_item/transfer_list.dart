import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';

Widget transferWidget({
  required String invoiceNumber,
  required String date,
  required String from,
  required String to,
  required String quantity,
  required String stockValue,
  required BuildContext context,
}) {
  final _theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice: #$invoiceNumber',
                  style: _theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: _theme.textTheme.bodyMedium?.copyWith(
                    color: kPeraColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  onPressed: () {},
                  icon: Icon(
                    CommunityMaterialIcons.printer,
                    color: kSubPeraColor,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  onPressed: () {},
                  icon: Icon(
                    CommunityMaterialIcons.share,
                    color: kSubPeraColor,
                    size: 20,
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    onPressed: () => PopupMenuButton(
                        itemBuilder: (context) => [
                              PopupMenuItem(child: Text('Edit')),
                              PopupMenuItem(child: Text('Delete')),
                            ]),
                    icon: Icon(
                      Icons.more_vert,
                      color: kSubPeraColor,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From',
                  style: _theme.textTheme.bodySmall?.copyWith(
                    color: kPeraColor,
                    fontSize: 13,
                  ),
                ),
                Text(
                  from,
                  style: _theme.textTheme.titleSmall,
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To',
                  style: _theme.textTheme.bodySmall?.copyWith(
                    color: kPeraColor,
                    fontSize: 13,
                  ),
                ),
                Text(
                  from,
                  style: _theme.textTheme.titleSmall,
                )
              ],
            )
          ],
        ),
        SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantity',
                  style: _theme.textTheme.bodySmall?.copyWith(
                    color: kPeraColor,
                    fontSize: 13,
                  ),
                ),
                Text(
                  quantity,
                  style: _theme.textTheme.titleSmall,
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Stock Value',
                  style: _theme.textTheme.bodySmall?.copyWith(
                    color: kPeraColor,
                    fontSize: 13,
                  ),
                ),
                Text(
                  stockValue,
                  textAlign: TextAlign.end,
                  style: _theme.textTheme.titleSmall,
                )
              ],
            )
          ],
        ),
      ],
    ),
  );
}
