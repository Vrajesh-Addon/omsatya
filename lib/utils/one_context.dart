import 'package:flutter/material.dart';

class OneContext{
  static BuildContext? _context;

  /// The almost top root context of the app,
  /// use it carefully or don't use it directly!
  BuildContext? get context {
  assert(_context != null);
  return _context;
  }

  static bool get hasContext => _context != null;
  set context(BuildContext? newContext) => _context = newContext;
}