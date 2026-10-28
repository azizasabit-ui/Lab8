import 'package:flutter/material.dart';

import '../models/product.dart';

class StyleResult {
  final int score;
  final String label;
  final String tip;
  const StyleResult(this.score, this.label, this.tip);
}

/// Scores an outfit (0-100) using simple color-theory rules:
/// neutrals match anything, analogous & complementary hues are rewarded,
/// clashing hues and too many bright colors are penalized.
class StyleScorer {
  static bool isNeutral(Color c) {
    final hsl = HSLColor.fromColor(c);
    final earthy = hsl.hue >= 20 &&
        hsl.hue <= 50 &&
        hsl.lightness > 0.6 &&
        hsl.saturation < 0.6; // beige / khaki
    return hsl.saturation < 0.18 ||
        hsl.lightness < 0.18 ||
        hsl.lightness > 0.88 ||
        earthy;
  }

  static double _hueDiff(Color a, Color b) {
    final d = (HSLColor.fromColor(a).hue - HSLColor.fromColor(b).hue).abs();
    return d > 180 ? 360 - d : d;
  }

  static StyleResult evaluate(Map<ProductCategory, Product?> outfit) {
    final items = outfit.values.whereType<Product>().toList();
    if (items.isEmpty) {
      return const StyleResult(0, 'Empty', 'Pick a piece to start your look.');
    }

    var score = 50;
    String? clashTip;

    final colored = items.where((p) => !isNeutral(p.color)).toList();
    score += (items.length - colored.length) * 8; // neutrals are safe

    for (var i = 0; i < colored.length; i++) {
      for (var j = i + 1; j < colored.length; j++) {
        final d = _hueDiff(colored[i].color, colored[j].color);
        if (d <= 30 || d >= 150) {
          score += 12; // analogous or complementary
        } else if (d >= 100 && d <= 140) {
          score += 4; // triadic-ish
        } else {
          score -= 10;
          clashTip ??=
              '${colored[i].colorName} and ${colored[j].colorName} clash - '
              'try a neutral piece.';
        }
      }
    }

    final tooBright = colored.length >= 3;
    if (tooBright) score -= 12;

    final hasCore = outfit[ProductCategory.top] != null &&
        outfit[ProductCategory.bottom] != null &&
        outfit[ProductCategory.shoes] != null;
    if (hasCore) score += 10;

    score = score.clamp(0, 100).toInt();

    String tip;
    if (clashTip != null) {
      tip = clashTip;
    } else if (tooBright) {
      tip = 'Too many bright colors - swap one for a neutral.';
    } else if (!hasCore) {
      tip = 'Add a top, bottom and shoes to complete the look.';
    } else if (colored.isEmpty) {
      tip = 'Timeless all-neutral look. Add one accent color!';
    } else {
      tip = 'Great color harmony. Ready to wear!';
    }

    final label = score < 40
        ? 'Needs work'
        : score < 60
            ? 'Not bad'
            : score < 80
                ? 'Stylish'
                : 'Fashion icon';
    return StyleResult(score, label, tip);
  }
}
