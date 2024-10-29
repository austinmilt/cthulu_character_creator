import 'package:flutter/material.dart';

class TopCenterListView extends StatelessWidget {
  const TopCenterListView({
    super.key,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.padding,
    this.itemCount,
    required this.itemBuilder,
  });

  final int? itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
        itemCount: itemCount,
        padding: padding,
        itemBuilder: (context, index) => Center(
          child: ConstrainedBox(
              constraints: BoxConstraints.loose(Size.fromWidth(maxWidth)),
              child: itemBuilder(context, index) ?? const SizedBox()),
        ),
      ),
    );
  }
}
