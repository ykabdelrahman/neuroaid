import 'package:flutter/material.dart';

Widget CornerMarkerWidget(Alignment alignment) {
  return Align(
    alignment: alignment,
    child: Container(
      margin: const EdgeInsets.all(8),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: alignment == Alignment.topLeft || alignment == Alignment.topRight
              ? const BorderSide(color: Color(0xFF0E7772), width: 4)
              : BorderSide.none,
          bottom:
              alignment == Alignment.bottomLeft ||
                  alignment == Alignment.bottomRight
              ? const BorderSide(color: Color(0xFF0E7772), width: 4)
              : BorderSide.none,
          left:
              alignment == Alignment.topLeft ||
                  alignment == Alignment.bottomLeft
              ? const BorderSide(color: Color(0xFF0E7772), width: 4)
              : BorderSide.none,
          right:
              alignment == Alignment.topRight ||
                  alignment == Alignment.bottomRight
              ? const BorderSide(color: Color(0xFF0E7772), width: 4)
              : BorderSide.none,
        ),
      ),
    ),
  );
}
