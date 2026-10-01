import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class OverlayOrchestrationRecipe extends StatefulWidget {
  const OverlayOrchestrationRecipe({super.key});

  @override
  State<OverlayOrchestrationRecipe> createState() =>
      _OverlayOrchestrationRecipeState();
}

class _OverlayOrchestrationRecipeState
    extends State<OverlayOrchestrationRecipe> {
  int _notificationCount = 0;
  String _lastActionStatus = 'Idle';

  void _showNotification(AnimalNotificationType type) {
    setState(() => _notificationCount++);
    final count = _notificationCount;

    AnimalNotification.open(
      context,
      message: Text('Island Broadcast #$count'),
      description: const Text(
        'New weather forecast and visitor bulletin delivered to your island mailbox.',
      ),
      type: type,
      duration: const Duration(seconds: 4),
      key: 'bulletin_$count',
      onClose: () {
        if (mounted) {
          setState(() => _lastActionStatus = 'Notification #$count dismissed');
        }
      },
    );
  }

  void _showModalDialogue() {
    AnimalModal.show(
      context: context,
      title: const Text('Island Mayor Dialogue'),
      content: const Text(
        'Hello island resident! The annual fireworks festival is taking place tonight at 8 PM. Would you like to reserve a front-row lawn chair?',
      ),
      typewriter: true,
      okText: 'Reserve Chair',
      cancelText: 'Maybe Later',
      onOk: () {
        setState(() => _lastActionStatus = 'Lawn chair successfully reserved!');
        return true;
      },
    );
  }

  void _openDrawer() {
    AnimalDrawer.show(
      context: context,
      title: const Text('Island Preferences'),
      placement: AnimalDrawerPlacement.right,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sound Effects: Enabled'),
          const SizedBox(height: 12),
          const Text('Seasonal Theme: Spring Breeze'),
          const SizedBox(height: 12),
          const Text('Visitor Clearance: Verified Residents Only'),
          const Spacer(),
          AnimalButton(
            variant: AnimalButtonVariant.filled,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close Preferences'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerScopedLoading() async {
    setState(() => _lastActionStatus = 'Initiating cloud backup sync...');
    final handle = AnimalLoading.show(
      context,
      tip: 'Synchronizing island state...',
    );

    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(
          () => _lastActionStatus = 'Cloud sync completed successfully!',
        );
        _showNotification(AnimalNotificationType.success);
      }
    } finally {
      handle.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimalTitle(
            size: AnimalTitleSize.large,
            child: const Text('Recipe 2: Overlay & Notification Orchestration'),
          ),
          const SizedBox(height: 8),
          Text(
            'End-to-end interactive workflow coordinating scoped notification queues, modal dialogues, slide-out drawer, and loading mask',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Multi-Tier Overlay Dispatcher',
            capabilityIds: const [
              'C21-MOD',
              'C22-DRW',
              'C23-TIP',
              'C25-LOD',
              'C30-NOT',
              'F04',
              'F07',
              'F14',
              'F23',
            ],
            description: 'Test concurrent notifications with automated queue expiration, modal dialogues without reflection crashes, and loading handles.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Scoped Notification Queue (F07 Tested)',
                  style: theme.typography.heading.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AnimalButton(
                      variant: AnimalButtonVariant.filled,
                      tone: AnimalButtonTone.primary,
                      icon: const AnimalIcon(data: AnimalIcons.bell, size: 18),
                      onPressed: () =>
                          _showNotification(AnimalNotificationType.info),
                      child: const Text('Trigger Info Notice'),
                    ),
                    AnimalButton(
                      variant: AnimalButtonVariant.filled,
                      tone: AnimalButtonTone.success,
                      icon: const AnimalIcon(data: AnimalIcons.check, size: 18),
                      onPressed: () =>
                          _showNotification(AnimalNotificationType.success),
                      child: const Text('Trigger Success Notice'),
                    ),
                    AnimalButton(
                      variant: AnimalButtonVariant.filled,
                      tone: AnimalButtonTone.warning,
                      icon: const AnimalIcon(data: AnimalIcons.close, size: 18),
                      onPressed: () =>
                          _showNotification(AnimalNotificationType.warning),
                      child: const Text('Trigger Warning Notice'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const AnimalDivider(type: AnimalDividerType.dashed),
                const SizedBox(height: 20),
                Text(
                  '2. Typewriter Modal & Dialogues (F23 Tested)',
                  style: theme.typography.heading.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    AnimalButton(
                      variant: AnimalButtonVariant.filled,
                      tone: AnimalButtonTone.primary,
                      icon: const AnimalIcon(data: AnimalIcons.chat, size: 18),
                      onPressed: _showModalDialogue,
                      child: const Text('Open Mayor Dialogue'),
                    ),
                    AnimalTooltip(
                      message: 'Click to inspect town drawer settings',
                      child: AnimalButton(
                        variant: AnimalButtonVariant.outlined,
                        icon: const AnimalIcon(
                          data: AnimalIcons.home,
                          size: 18,
                        ),
                        onPressed: _openDrawer,
                        child: const Text('Open Island Drawer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const AnimalDivider(type: AnimalDividerType.dashed),
                const SizedBox(height: 20),
                Text(
                  '3. Deterministic Loading Mask (F14 Tested)',
                  style: theme.typography.heading.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AnimalButton(
                  variant: AnimalButtonVariant.filled,
                  tone: AnimalButtonTone.neutral,
                  icon: const AnimalIcon(data: AnimalIcons.refresh, size: 18),
                  onPressed: _triggerScopedLoading,
                  child: const Text('Simulate Heavy Cloud Sync (1.5s)'),
                ),
                const SizedBox(height: 24),
                // Status Output Card
                AnimalCard(
                  child: Row(
                    children: [
                      AnimalIcon(
                        data: AnimalIcons.compass,
                        size: 20,
                        color: theme.colors.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'System Event Status: ',
                        style: theme.typography.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _lastActionStatus,
                          style: theme.typography.body.copyWith(
                            color: theme.colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
