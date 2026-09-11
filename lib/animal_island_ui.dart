/// Animal Island UI - A cozy Kawaii component library for Flutter.
///
/// Ported with enterprise-grade standards from guokaigdg/animal-island-ui.
///
/// Features:
/// - 36 Production-grade UI components
/// - 101 Native cute vector island icons
/// - 7 Canonical Design Laws & 14 Visual Hard Rules
/// - 3D tactile press depth & spring physics
library;

// =============================================================================
// 1. Design Tokens
// =============================================================================
export 'src/tokens/colors.dart';
export 'src/tokens/typography.dart';
export 'src/tokens/shadows.dart';
export 'src/tokens/radii.dart';
export 'src/tokens/theme.dart';

// =============================================================================
// 2. Low-level Primitives
// =============================================================================
export 'src/primitives/pressable.dart';
export 'src/primitives/blob_clipper.dart';
export 'src/primitives/ribbon_painter.dart';

// =============================================================================
// 3. 101 Vector Icons
// =============================================================================
export 'src/icons/animal_icons.dart';
export 'src/icons/icon_widget.dart';

// =============================================================================
// 4. Canonical Component Categories (9 Distinct Design System Categories)
// =============================================================================

// Category 1: General (Button, Cursor, Typewriter, Icon)
export 'src/components/general/button.dart';
export 'src/components/general/cursor.dart';
export 'src/components/general/typewriter.dart';

// Category 2: Layout (Card, Title, Divider, Background, Collapse, Tabs, Carousel)
export 'src/components/layout/card.dart';
export 'src/components/layout/title.dart';
export 'src/components/layout/divider.dart';
export 'src/components/layout/background.dart';
export 'src/components/layout/collapse.dart';
export 'src/components/layout/tabs.dart';
export 'src/components/layout/carousel.dart';

// Category 3: Form Controls (Input, Switch, Checkbox, Radio, Select, DatePicker, TimePicker)
export 'src/components/form_controls/input.dart';
export 'src/components/form_controls/switch.dart';
export 'src/components/form_controls/checkbox.dart';
export 'src/components/form_controls/radio.dart';
export 'src/components/form_controls/select.dart';
export 'src/components/form_controls/date_picker.dart';
export 'src/components/form_controls/time_picker.dart';

// Category 4: Form Container (Form, FormItem)
export 'src/components/form/form.dart';

// Category 5: Overlays (Modal, Drawer, Tooltip)
export 'src/components/overlays/modal.dart';
export 'src/components/overlays/drawer.dart';
export 'src/components/overlays/tooltip.dart';

// Category 6: Feedback (Progress, Loading, Skeleton, BackTop, Countdown, Time)
export 'src/components/feedback/progress.dart';
export 'src/components/feedback/loading.dart';
export 'src/components/feedback/skeleton.dart';
export 'src/components/feedback/back_top.dart';
export 'src/components/feedback/countdown.dart';
export 'src/components/feedback/time.dart';

// Category 7: Notification (Notification Imperative API & Portal)
export 'src/components/notification/notification.dart';

// Category 8: Data Display (Table, Pagination, CodeBlock, Tag, Image)
export 'src/components/data_display/table.dart';
export 'src/components/data_display/pagination.dart';
export 'src/components/data_display/code_block.dart';
export 'src/components/data_display/tag.dart';
export 'src/components/data_display/image.dart';

// Category 9: Decorative (Footer)
export 'src/components/decorative/footer.dart';
