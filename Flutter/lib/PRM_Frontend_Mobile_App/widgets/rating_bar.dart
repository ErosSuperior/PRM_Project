import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double? rating;
  final ValueChanged<double>? onRatingSelected;
  final int maxRating;
  final double iconSize;

  const RatingBar({
    super.key,
    this.rating,
    this.onRatingSelected,
    this.maxRating = 5,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        final isFilled = rating != null && rating! >= starValue;

        return InkWell(
          onTap: onRatingSelected == null
              ? null
              : () => onRatingSelected!(starValue.toDouble()),
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: iconSize,
          ),
        );
      }),
    );
  }
}

