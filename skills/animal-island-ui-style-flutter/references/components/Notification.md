# Notification Reference

## Notification

Global imperative overlay portal with zero ScaffoldMessenger dependency.

```dart
AnimalNotification.open(
  BuildContext context, {
  required Widget message,
  Widget? description,
  AnimalNotificationType type = AnimalNotificationType.info,
  Duration duration = const Duration(milliseconds: 4500),
  AnimalNotificationPlacement placement = AnimalNotificationPlacement.topRight,
  Widget? icon,
  String? key,
  VoidCallback? onClose,
  VoidCallback? onClick,
})
```

### Semantic Shorthands

```dart
AnimalNotification.success(context, {required String message, String? description, AnimalNotificationPlacement placement})
AnimalNotification.warning(context, {required String message, String? description, AnimalNotificationPlacement placement})
AnimalNotification.error(context, {required String message, String? description, AnimalNotificationPlacement placement})
AnimalNotification.info(context, {required String message, String? description, AnimalNotificationPlacement placement})
```

### Management

```dart
AnimalNotification.destroy([String? key]); // Dismiss specific notification by key, or all if omitted
```
