import 'package:flutter/material.dart';

PreferredSize preferredSizeWidget(Widget child) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(48.0),
    child: child,
  );
}
