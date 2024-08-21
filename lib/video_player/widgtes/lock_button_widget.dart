import 'package:flutter/material.dart';

class LockButton extends StatelessWidget {
  final ValueNotifier<bool> isLocked;
  final ValueNotifier<bool> showControls;

  const LockButton(
      {super.key, required this.isLocked, required this.showControls});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10,
      child: GestureDetector(
        onTap: () {
          isLocked.value = !isLocked.value;
          if (!isLocked.value) {
            showControls.value = true;
          }
        },
        child: Icon(
          !isLocked.value ? Icons.lock : Icons.lock_open,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
