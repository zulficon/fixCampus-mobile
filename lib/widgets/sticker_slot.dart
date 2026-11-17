import 'package:flutter/widgets.dart';

enum CampusSticker {
  pigeon(96, right: -6, bottom: -8),
  cat(140, right: -10, bottom: -6, textClearance: 120),
  rabbit(128);

  const CampusSticker(
    this.size, {
    this.right,
    this.bottom,
    this.textClearance = 0,
  });

  final double size;
  final double? right;
  final double? bottom;
  final double textClearance;
}

/// Leaves the illustration's space available while its artwork is absent.
class StickerSlot extends StatelessWidget {
  const StickerSlot({super.key, required this.sticker, this.artwork});

  final CampusSticker sticker;
  final Widget? artwork;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: sticker.size,
      child: artwork == null
          ? null
          : FittedBox(fit: BoxFit.contain, child: artwork),
    );
  }
}
