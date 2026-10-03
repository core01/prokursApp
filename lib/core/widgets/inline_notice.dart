import 'package:flutter/cupertino.dart';

/// A message shown in place, next to what it is about, instead of an alert: problems the
/// screen itself lets the user resolve (Apple HIG, "Alerts" and "Feedback").
class InlineNotice extends StatelessWidget {
  const InlineNotice({
    super.key,
    required this.text,
    this.color = CupertinoColors.systemRed,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoDynamicColor.resolve(this.color, context);

    // liveRegion: VoiceOver reads it out when it appears.
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(CupertinoIcons.exclamationmark_circle_fill, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
          ],
        ),
      ),
    );
  }
}
