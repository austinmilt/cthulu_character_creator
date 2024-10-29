import 'package:flutter/material.dart';

class TopCenterContainer extends StatelessWidget {
  const TopCenterContainer({super.key, this.child, this.maxWidth, this.padding});

  final Widget? child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Center(
        child: Container(
          constraints: (maxWidth == null) ? null : BoxConstraints(maxWidth: maxWidth!),
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
    );
  }
}
