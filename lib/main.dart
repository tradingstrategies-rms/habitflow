import 'package:flutter/material.dart';
import 'package:habitflow/core/bootstrap/bootstrap_gate.dart';

void main() {
  // We call runApp immediately with the BootstrapGate to ensure the native 
  // splash screen is replaced by our loading UI as soon as possible.
  runApp(const BootstrapGate());
}
