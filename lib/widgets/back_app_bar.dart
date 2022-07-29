import 'package:first_priority_app/widgets/text/title_text.dart';
import 'package:flutter/material.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData actionIcon;
  final void Function() onActionPressed;
  @override
  Size get preferredSize => const Size.fromHeight(75);

  BackAppBar({
    Key key,
    @required this.title,
    this.actionIcon,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Material(
        elevation: 2,
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment(-0.9, 0),
                child: IconButton(
                  constraints: BoxConstraints(maxHeight: 28, maxWidth: 28),
                  padding: EdgeInsets.all(0.0),
                  icon: Icon(Icons.arrow_back),
                  iconSize: 28,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Align(
                child: TitleText(
                  title,
                  fontSize: 24,
                ),
              ),
              if (actionIcon != null && onActionPressed != null)
                Align(
                  alignment: Alignment(0.9, 0),
                  child: IconButton(
                    constraints: BoxConstraints(maxHeight: 28, maxWidth: 28),
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(actionIcon),
                    iconSize: 28,
                    onPressed: onActionPressed,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
