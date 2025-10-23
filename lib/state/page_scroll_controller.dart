import 'package:flutter/material.dart';

class PageScrollController extends ScrollController {
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasClients) {
        animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
