import 'package:flutter/material.dart';

class TopCenterScrollableContainer extends StatelessWidget {
  const TopCenterScrollableContainer({
    super.key,
    this.child,
    this.maxWidth,
    this.maxHeight = double.infinity,
    this.padding,
  });

  final Widget? child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        // wrapping the main Container (below) in a Center makes it so the Center
        // takes up the full width of the view while enforcing a max width on
        // the main Container. This makes the page's scrollbar (from the
        // SingleChildScrollView) stick to the right side of the page rather than
        // being butted up against the main Container, which is annoying on mobile
        child: Center(
          child: Container(
            constraints: (maxWidth == null)
                ? null
                : BoxConstraints(
                    maxWidth: maxWidth!,
                    maxHeight: maxHeight,
                  ),
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: child ?? const SizedBox(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
