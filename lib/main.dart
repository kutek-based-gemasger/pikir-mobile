import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // ProviderScope is installed now, before any state exists, so repositories
  // can be overridden at the top later without the app shell being rebuilt.
  runApp(const ProviderScope(child: PikirApp()));
}
