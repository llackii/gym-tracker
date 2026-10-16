import 'package:flutter/material.dart';
import 'theme.dart';

/// Flat surface with a hairline border. Use inside ListView / Column(stretch) / Expanded.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final inner = Padding(padding: padding, child: child);
    return Material(
      color: color ?? kSurface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor ?? kBorder),
      ),
      child: onTap == null ? inner : InkWell(onTap: onTap, child: inner),
    );
  }
}

/// Scrollable page with a centered max width and an optional title header.
class AppPage extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  const AppPage({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              if (title != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title!, style: Txt.h1),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(subtitle!, style: Txt.caption.copyWith(fontSize: 13)),
                          ],
                        ],
                      ),
                    ),
                    ?trailing,
                  ],
                ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title.toUpperCase(), style: Txt.label)),
          ?trailing,
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  const StatTile(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              maxLines: 1, overflow: TextOverflow.ellipsis, style: Txt.label.copyWith(fontSize: 10)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: Txt.stat),
          ),
        ],
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  final Color color;
  const Tag(this.text, {super.key, this.color = kMuted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              fontFamily: kFont, fontSize: 10.5, fontWeight: FontWeight.w500, color: color)),
    );
  }
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBadge(this.icon, {super.key, this.color = kAccent, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Round badge with a letter or two (avatars, plan monograms).
class Monogram extends StatelessWidget {
  final String text;
  final double size;
  const Monogram(this.text, {super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: kAccent.withValues(alpha: 0.35)),
      ),
      child: Text(text,
          style: TextStyle(
              fontFamily: kFont,
              fontSize: size * 0.34,
              fontWeight: FontWeight.w700,
              color: kAccent)),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 34, color: kFaint),
          const SizedBox(height: 14),
          Text(title, style: Txt.titleBold, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(message, style: Txt.caption, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const OptionChip(this.label, {super.key, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? kAccent.withValues(alpha: 0.14) : kSurface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? kAccent : kBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kFont,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            color: selected ? kAccent : kMuted,
          ),
        ),
      ),
    );
  }
}

/// Compact segmented control.
class Segmented<T> extends StatelessWidget {
  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;
  const Segmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          for (final e in options.entries)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: e.key == value ? kSelected : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontFamily: kFont,
                      fontSize: 12.5,
                      fontWeight: e.key == value ? FontWeight.w500 : FontWeight.w400,
                      color: e.key == value ? kText : kMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<bool> confirm(
  BuildContext context,
  String title,
  String body, {
  String confirmLabel = 'Confirm',
  bool danger = false,
}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(foregroundColor: kMuted),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: danger ? kDanger : kAccent),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return res ?? false;
}

/// Photo with a dark fade at the bottom so text on top stays readable.
/// Shows a plain placeholder while loading or if the photo cannot load.
class PhotoBanner extends StatelessWidget {
  final String url;
  final double height;
  final double radius;
  final Widget? child;
  final AlignmentGeometry childAlignment;
  final EdgeInsetsGeometry padding;
  const PhotoBanner({
    super.key,
    required this.url,
    this.height = 160,
    this.radius = 16,
    this.child,
    this.childAlignment = Alignment.bottomLeft,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => Container(
          color: kSurface2,
          alignment: Alignment.center,
          child: const Icon(Icons.fitness_center_rounded, size: 32, color: kFaint),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder(),
              loadingBuilder: (context, w, progress) =>
                  progress == null ? w : placeholder(),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Color(0xE60B0D10)],
                ),
              ),
            ),
            if (child != null)
              Padding(
                padding: padding,
                child: Align(alignment: childAlignment, child: child),
              ),
          ],
        ),
      ),
    );
  }
}
