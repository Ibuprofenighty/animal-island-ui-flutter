import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/stories/form_story.dart';
import 'package:island_gallery/pages/stories/notification_story.dart';
import 'package:island_gallery/pages/stories/upload_story.dart';
import 'package:island_gallery/shared/theme.dart';

import '../../test/readable_motion_test.dart' show opaque;

// Exercise the real Gallery callbacks. This tests their presentation boundary,
// not Form validation, OS file picking or real browser alert geometry.
void main() {
  for (final kind in ['form', 'notification', 'upload']) {
    testWidgets(
      '$kind callback keeps content and backing opaque throughout its route',
      (t) async {
        var reduced = false;
        late StateSetter update;
        await t.pumpWidget(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return MaterialApp(
                theme: galleryTheme(),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: reduced),
                  child: child!,
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: switch (kind) {
                      'form' => const FormStory(),
                      'notification' => const NotificationStory(),
                      _ => const UploadStory(),
                    },
                  ),
                ),
              );
            },
          ),
        );
        await t.pump();
        late Finder content;
        if (kind == 'form') {
          t.widgetList<IslandForm>(find.byType(IslandForm)).last.onFinish!({
            'email': 'test@example.invalid',
            'age': '20',
            'code': '123',
          });
          content = find.textContaining('提交:');
        } else if (kind == 'notification') {
          final trigger = find.widgetWithText(IslandButton, 'onClick 可点击');
          await t.ensureVisible(trigger);
          await t.tap(trigger);
          await t.pump();
          await t.pump(const Duration(milliseconds: 400));
          await t.tap(find.text('点击我'));
          content = find.text('通知被点击了!');
        } else {
          final upload = t
              .widgetList<IslandUpload>(find.byType(IslandUpload))
              .firstWhere((w) => w.onPreview != null);
          upload.onPreview!(
            const IslandUploadFile(id: 'synthetic', name: 'synthetic.txt'),
          );
          content = find.text('该文件暂无可预览的图片');
        }
        await t.pump();
        final route = ModalRoute.of(t.element(content))!;
        for (final ms in [0, 16, 30, 50]) {
          await t.pump(Duration(milliseconds: ms));
          opaque(t, content);
          final material = find.ancestor(
            of: content,
            matching: find.byType(Material),
          );
          if (kind != 'upload') {
            final color = t.widget<Material>(material.first).color!;
            expect(color.a, 1, reason: 'AlertDialog backing remains opaque');
          }
        }
        update(() => reduced = true);
        await t.pump();
        await t.pump();
        opaque(t, content);
        expect(route.animation!.value, 1);
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pumpAndSettle();
        expect(content, findsNothing);
        await t.pumpWidget(const SizedBox());
        expect(t.takeException(), isNull);
      },
    );
  }
}
