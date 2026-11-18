import 'package:flutter/widgets.dart';

enum CampusSticker {
  goose(96, 'goose.png', right: -6, bottom: -8),
  raccoon(140, 'raccoon.png', textClearance: 120),
  capybara(128, 'capybara.png');

  const CampusSticker(
    this.size,
    this.fileName, {
    this.right,
    this.bottom,
    this.textClearance = 0,
  });

  final double size;
  final String fileName;
  final double? right;
  final double? bottom;
  final double textClearance;

  String get assetPath => 'assets/images/stickers/$fileName';
}

/// Decorative campus sticker, sized independently of the image resolution.
class StickerSlot extends StatelessWidget {
  const StickerSlot({super.key, required this.sticker, this.artwork});

  final CampusSticker sticker;
  final Widget? artwork;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: sticker.size,
        child: artwork == null
            ? Image.asset(
                sticker.assetPath,
                fit: BoxFit.contain,
                cacheWidth:
                    (sticker.size * MediaQuery.devicePixelRatioOf(context))
                        .ceil(),
              )
            : FittedBox(fit: BoxFit.contain, child: artwork),
      ),
    );
  }
}
