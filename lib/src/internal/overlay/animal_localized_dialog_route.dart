import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';

/// Pushes a general dialog route whose dismiss barrier follows the active
/// application locale for the entire lifetime of the route.
Future<T?> showAnimalLocalizedDialog<T>({
  required BuildContext context,
  required RoutePageBuilder pageBuilder,
  required Color barrierColor,
  required Duration transitionDuration,
  required RouteTransitionsBuilder transitionBuilder,
  bool barrierDismissible = true,
}) {
  final localizations = AnimalLocalizations.of(context)!;
  return Navigator.of(context, rootNavigator: true).push<T>(
    _AnimalLocalizedDialogRoute<T>(
      pageBuilder: pageBuilder,
      barrierDismissible: barrierDismissible,
      initialBarrierLabel: localizations.dismiss,
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
    ),
  );
}

class _AnimalLocalizedDialogRoute<T> extends RawDialogRoute<T> {
  _AnimalLocalizedDialogRoute({
    required super.pageBuilder,
    required super.barrierDismissible,
    required this.initialBarrierLabel,
    required super.barrierColor,
    required super.transitionDuration,
    required super.transitionBuilder,
  }) : super(barrierLabel: initialBarrierLabel);

  final String initialBarrierLabel;

  @override
  String? get barrierLabel {
    final currentNavigator = navigator;
    if (currentNavigator == null) return initialBarrierLabel;
    return AnimalLocalizations.of(currentNavigator.context)?.dismiss ??
        initialBarrierLabel;
  }
}
