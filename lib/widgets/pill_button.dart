import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  final Widget child;
  final void Function() onTap;
  final double width;

  PillButton({@required this.child, @required this.onTap, this.width = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: width,
      margin: EdgeInsets.all(4),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(32),
        color: Theme.of(context).dividerColor,
        child: InkWell(
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              child: child,
            ),
          ),
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    );
  }
}
