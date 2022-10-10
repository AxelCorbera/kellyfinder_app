import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class CustomLikeButton extends StatelessWidget {
  final Function callback;
  final double iconSize;
  final bool isLiked;

  const CustomLikeButton(
      {Key key,
      this.callback,
      this.iconSize = 24,
      this.isLiked = false,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      isLiked: isLiked,
      size: iconSize,
      circleColor: CircleColor(
        start: Theme.of(context).buttonColor,
        end: Theme.of(context).buttonColor,
      ),
      bubblesColor: BubblesColor(
        dotPrimaryColor: Theme.of(context).buttonColor,
        dotSecondaryColor: Theme.of(context).buttonColor,
      ),
      likeBuilder: (bool isLiked) {
        return Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Theme.of(context).buttonColor : Colors.grey,
          size: iconSize,
        );
      },
      onTap: callback,
    );
  }
}
