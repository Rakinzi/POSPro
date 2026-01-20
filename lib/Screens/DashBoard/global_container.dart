import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GlobalContainer extends StatelessWidget {
  final String title;
  final String? image;
  final String subtitle;
  final double? minVerticalPadding;
  final double? minTileHeight;
  final EdgeInsets? titlePadding;
  final bool? textColor;
  final bool? alainRight;
  const GlobalContainer({
    super.key,
    required this.title,
    this.image,
    required this.subtitle,
    this.minVerticalPadding,
    this.minTileHeight,
    this.titlePadding,
    this.textColor,
    this.alainRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: textColor == true ? Colors.transparent : Colors.white),
      child: ListTile(
        minVerticalPadding: minVerticalPadding ?? 4,
        minTileHeight: minTileHeight ?? 0,
        contentPadding: titlePadding ?? EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
        leading: image != null
            ? SvgPicture.asset(
                image!,
                height: 40,
                width: 40,
              )
            : null,
        title: Text(
          title,
          textAlign: (alainRight ?? false) ? TextAlign.end : null,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor == true ? Colors.white : Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          textAlign: (alainRight ?? false) ? TextAlign.end : null,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: textColor == true ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
