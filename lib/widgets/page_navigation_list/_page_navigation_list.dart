import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constant.dart';

class PageNavigationListView extends StatelessWidget {
  const PageNavigationListView({
    super.key,
    this.header,
    this.footer,
    required this.navTiles,
    this.onTap,
  });

  final Widget? header;
  final Widget? footer;
  final List<PageNavigationNavTile> navTiles;
  final void Function(PageNavigationNavTile value)? onTap;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        // Header
        if (header != null) header!,

        // Nav Items
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
          child: ListView.separated(
            shrinkWrap: true,
            primary: false,
            itemCount: navTiles.length,
            itemBuilder: (context, index) {
              final _navTile = navTiles[index];

              return Material(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () => onTap?.call(_navTile),
                  leading: SvgPicture.asset(
                    _navTile.svgIconPath,
                    height: 36,
                    width: 36,
                  ),
                  title: Text(_navTile.title),
                  titleTextStyle: _theme.textTheme.bodyLarge,
                  trailing: (_navTile.hideTrailing ?? false)
                      ? null
                      : _navTile.trailing ??
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: kGreyTextColor,
                          ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  tileColor: _theme.colorScheme.primaryContainer,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: const VisualDensity(
                    vertical: -1,
                    horizontal: -2,
                  ),
                ),
              );
            },
            separatorBuilder: (c, i) => const Divider(height: 1.5),
          ),
        ),

        // Footer
        if (footer != null) footer!,
      ],
    );
  }
}

class PageNavigationNavTile<T> {
  final String title;
  final Widget? trailing;
  final Color? color;
  final String svgIconPath;
  final PageNavigationListTileType type;
  final Widget? route;
  final bool? hideTrailing;
  final T? value;

  const PageNavigationNavTile({
    required this.title,
    this.trailing,
    this.color,
    required this.svgIconPath,
    this.type = PageNavigationListTileType.navigation,
    this.route,
    this.value,
    this.hideTrailing,
  }) : assert(
          type != PageNavigationListTileType.navigation || value == null,
          'value cannot be assigned in navigation type',
        );
}

enum PageNavigationListTileType { navigation, tool, function }
