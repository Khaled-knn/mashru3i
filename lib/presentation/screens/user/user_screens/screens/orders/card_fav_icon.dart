import 'package:flutter/material.dart';

class ExpandableOptionsButton extends StatefulWidget {
  final List<IconData> options;
  final Color color;

  const ExpandableOptionsButton({
    super.key,
    required this.options,
    this.color = const Color(0XFFE95A8B),
  });

  @override
  State<ExpandableOptionsButton> createState() => _ExpandableOptionsButtonState();
}

class _ExpandableOptionsButtonState extends State<ExpandableOptionsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late List<Animation<Alignment>> animations;
  late Animation<double> verticalPadding;

  final Duration duration = const Duration(milliseconds: 190);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: duration);

    final curves = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    verticalPadding = Tween<double>(begin: 0, end: 26).animate(curves);

    animations = [
      Tween<Alignment>(begin: Alignment.centerRight, end: Alignment.topRight).animate(curves),
      Tween<Alignment>(begin: Alignment.centerRight, end: Alignment.centerLeft).animate(curves),
      Tween<Alignment>(begin: Alignment.centerRight, end: Alignment.centerLeft).animate(curves),
      Tween<Alignment>(begin: Alignment.centerRight, end: Alignment.bottomLeft).animate(curves),
      Tween<Alignment>(begin: Alignment.centerRight, end: Alignment.bottomRight).animate(curves),
    ];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget getItem(IconData icon) {
    const size = 45.0;
    return GestureDetector(
      onTap: () {
        controller.reverse();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget buildPrimaryButton() {
    const size = 45.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(verticalPadding.value),
            blurRadius: verticalPadding.value,
          ),
        ],
      ),
      child: Icon(
        controller.isCompleted || controller.isAnimating ? Icons.close : Icons.add,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: controller.isAnimating || controller.isCompleted ? 140 : 45,
      height: controller.isAnimating || controller.isCompleted ? 210 : 45,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < widget.options.length && i < animations.length; i++)
                Positioned(
                  right: controller.isAnimating || controller.isCompleted
                      ? null
                      : 0,
                  child: Align(
                    alignment: animations[i].value,
                    child: getItem(widget.options[i]),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    controller.isCompleted ? controller.reverse() : controller.forward();
                  },
                  child: buildPrimaryButton(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
