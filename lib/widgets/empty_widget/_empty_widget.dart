import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    this.message,
  });

  final TextSpan? message;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 260),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset("assets/empty_placeholder.png"),
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox.square(dimension: 12),
            Text.rich(
              message!,
              style: _theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// Avatar Widget
class CircleAvatarWidget extends StatelessWidget {
  final String? name;
  final Size? size;

  const CircleAvatarWidget({super.key, this.name, this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: size?.height ?? 40,
      width: size?.width ?? 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary,
      ),
      child: Center(
        child: Text(
          (name != null && name!.length >= 2) ? name!.substring(0, 2) : (name != null ? name! : ''),
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class EmptyWidgetUpdated extends StatelessWidget {
  const EmptyWidgetUpdated({
    super.key,
    this.message,
  });

  final TextSpan? message;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/empty_image.svg',
            width: 319,
            height: 250,
            placeholderBuilder: (BuildContext context) => CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox.square(dimension: 12),
            Text.rich(
              message!,
              style: _theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
