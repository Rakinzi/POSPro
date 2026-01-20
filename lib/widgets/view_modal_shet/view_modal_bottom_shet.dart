import 'package:flutter/material.dart';

import '../../constant.dart';

void viewModalSheet({
  required BuildContext context,
  required Map<String, String> item,
  String? description,
  bool? showImage,
  String? image,
  String? descriptionTitle,
}) {
  final _theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Details',
                    style: _theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 18),
                  )
                ],
              ),
            ),
            Divider(color: kBorderColor, height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showImage == true) ...[
                    SizedBox(height: 15),
                    image != null
                        ? Center(
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(image),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Image.asset(
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              'assets/hrm/image_icon.jpg',
                            ),
                          ),
                    SizedBox(height: 21),
                  ],
                  Column(
                    children: item.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 2,
                              child: Text(
                                '${entry.key} ',
                                style: _theme.textTheme.bodyLarge?.copyWith(
                                  color: kNeutral800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 4,
                              child: Text(
                                ': ${entry.value}',
                                style: _theme.textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (description != null) ...[
                    SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                          text: descriptionTitle ?? 'Description : ',
                          style: _theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: description,
                              style: _theme.textTheme.bodyLarge?.copyWith(
                                color: kNeutral800,
                              ),
                            )
                          ]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
