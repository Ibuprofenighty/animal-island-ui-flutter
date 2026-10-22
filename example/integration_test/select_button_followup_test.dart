import 'package:integration_test/integration_test.dart';

import '../../test/button_motion_frames_test.dart' as motion;
import '../../test/button_states_test.dart' as states;
import '../test/select_test.dart' as select;
import '../test/responsive_story_test.dart' as layout;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const output = String.fromEnvironment('BUTTON_MOTION_EVIDENCE');
  motion.registerButtonMotionTests(
    fontAsset:
        'packages/animal_island_ui/assets/fonts/FiraCode-Variable.ttf',
    captureDirectory: output.isEmpty ? null : output,
  );
  states.main();
  select.main();
  layout.main();
}
