import '../stories/back_top_story.dart';
import '../stories/background_story.dart';
import '../stories/button_story.dart';
import '../stories/card_story.dart';
import '../stories/carousel_story.dart';
import '../stories/checkbox_story.dart';
import '../stories/code_block_story.dart';
import '../stories/collapse_story.dart';
import '../stories/countdown_story.dart';
import '../stories/cursor_story.dart';
import '../stories/date_picker_story.dart';
import '../stories/divider_story.dart';
import '../stories/drawer_story.dart';
import '../stories/footer_story.dart';
import '../stories/form_item_story.dart';
import '../stories/form_story.dart';
import '../stories/icon_story.dart';
import '../stories/icons_browser_story.dart';
import '../stories/image_story.dart';
import '../stories/input_story.dart';
import '../stories/loading_story.dart';
import '../stories/modal_story.dart';
import '../stories/notification_story.dart';
import '../stories/pagination_story.dart';
import '../stories/progress_story.dart';
import '../stories/radio_story.dart';
import '../stories/select_story.dart';
import '../stories/skeleton_story.dart';
import '../stories/switch_story.dart';
import '../stories/table_story.dart';
import '../stories/tabs_story.dart';
import '../stories/tag_story.dart';
import '../stories/time_picker_story.dart';
import '../stories/time_story.dart';
import '../stories/title_story.dart';
import '../stories/tooltip_story.dart';
import '../stories/typewriter_story.dart';
import 'story.dart';

/// Complete canonical catalog of all 36 design system components + icons browser.
final List<StoryDefinition> componentCatalog = [
  // General & Primitives
  StoryDefinition(
    slug: 'button',
    name: 'Button 按钮',
    capabilityId: 'C01',
    scenarioIds: ['BTN01', 'BTN02', 'BTN03', 'BTN04'],
    category: 'General',
    builder: (context) => const ButtonStory(),
    description: '3D game-like tactile button with 50px pill shape, depth displacement, and orthogonal variants.',
  ),
  StoryDefinition(
    slug: 'icon',
    name: 'Icon 图标',
    capabilityId: 'C02',
    scenarioIds: ['ICO01', 'ICO02', 'ICO03', 'ICO04', 'ICO05'],
    category: 'General',
    builder: (context) => const IconStory(),
    description: 'Canonical vector icon renderer backed by immutable descriptors and 101 built-in glyphs.',
  ),
  StoryDefinition(
    slug: 'icons-browser',
    name: 'Icons Browser 图标浏览',
    capabilityId: 'C101',
    scenarioIds: ['ICO01', 'ICO02'],
    category: 'General',
    builder: (context) => const IconsBrowserStory(),
    description: 'Interactive browser for all 101 Animal Island UI SVG vector icons with size and color controls.',
  ),
  StoryDefinition(
    slug: 'typewriter',
    name: 'Typewriter 打字机',
    capabilityId: 'C03',
    scenarioIds: ['TYP01', 'TYP02', 'TYP03', 'TYP04'],
    category: 'General',
    builder: (context) => const TypewriterStory(),
    description: 'Linear grapheme cluster reveal engine with zero prefix caching and accessible screen reading.',
  ),
  StoryDefinition(
    slug: 'cursor',
    name: 'Cursor 指针',
    capabilityId: 'C04',
    scenarioIds: ['CUR01', 'CUR02', 'CUR03'],
    category: 'General',
    builder: (context) => const CursorStory(),
    description: 'Custom mouse pointer with transparent hit testing and conditional desktop activation.',
  ),

  // Layout & Decor
  StoryDefinition(
    slug: 'card',
    name: 'Card 卡片',
    capabilityId: 'C05',
    scenarioIds: ['CARD01', 'CARD02', 'CARD03'],
    category: 'Layout',
    builder: (context) => const CardStory(),
    description: 'Cozy container with optional crosshatch texture, tactile header/footer ribbons, and hover elevation.',
  ),
  StoryDefinition(
    slug: 'title',
    name: 'Title 标题',
    capabilityId: 'C06',
    scenarioIds: ['TIT01', 'TIT02', 'TIT03'],
    category: 'Layout',
    builder: (context) => const TitleStory(),
    description: 'Folded ribbon and swallowtail banner headings with accessible hierarchy semantics.',
  ),
  StoryDefinition(
    slug: 'divider',
    name: 'Divider 分割线',
    capabilityId: 'C07',
    scenarioIds: ['DIV01', 'DIV02', 'DIV03'],
    category: 'Layout',
    builder: (context) => const DividerStory(),
    description: 'Dashed, wave, and leaf decorative dividers rendered by a single deterministic painter.',
  ),
  StoryDefinition(
    slug: 'background',
    name: 'Background 背景',
    capabilityId: 'C08',
    scenarioIds: ['BG01', 'BG02', 'BG03'],
    category: 'Layout',
    builder: (context) => const BackgroundStory(),
    description: 'Subtle procedural island landscape background pattern.',
  ),
  StoryDefinition(
    slug: 'footer',
    name: 'Footer 页脚',
    capabilityId: 'C36',
    scenarioIds: ['FOT01', 'FOT02', 'FOT03'],
    category: 'Layout',
    builder: (context) => const FooterStory(),
    description: 'Playful island scene footer with wave/tree variations and localized defaults.',
  ),

  // Navigation
  StoryDefinition(
    slug: 'collapse',
    name: 'Collapse 折叠面板',
    capabilityId: 'C09',
    scenarioIds: ['COL01', 'COL02', 'COL03', 'COL04'],
    category: 'Navigation',
    builder: (context) => const CollapseStory(),
    description: 'ID-based controlled accordion and multi-expand panels with smooth height transitions.',
  ),
  StoryDefinition(
    slug: 'tabs',
    name: 'Tabs 标签页',
    capabilityId: 'C10',
    scenarioIds: ['TAB01', 'TAB02', 'TAB03', 'TAB04'],
    category: 'Navigation',
    builder: (context) => const TabsStory(),
    description: 'Adaptive indicator tabs with roving focus keyboard navigation and dynamic label re-measuring.',
  ),
  StoryDefinition(
    slug: 'carousel',
    name: 'Carousel 走马灯',
    capabilityId: 'C11',
    scenarioIds: ['CAR01', 'CAR02', 'CAR03', 'CAR04'],
    category: 'Navigation',
    builder: (context) => const CarouselStory(),
    description: 'Controlled page loop with autoplay pausing on hover, focus, and reduced motion.',
  ),
  StoryDefinition(
    slug: 'back-top',
    name: 'BackTop 回到顶部',
    capabilityId: 'C27',
    scenarioIds: ['BTP01', 'BTP02', 'BTP03'],
    category: 'Navigation',
    builder: (context) => const BackTopStory(),
    description: 'Tactile scroll-to-top button with immediate threshold recalculation and hit test suppression.',
  ),

  // Form Controls
  StoryDefinition(
    slug: 'input',
    name: 'Input 输入框',
    capabilityId: 'C12',
    scenarioIds: ['INP01', 'INP02', 'INP03', 'INP04'],
    category: 'Form',
    builder: (context) => const InputStory(),
    description: 'Single-controller text input with prefix/suffix icons, clear button, and status borders.',
  ),
  StoryDefinition(
    slug: 'switch',
    name: 'Switch 开关',
    capabilityId: 'C13',
    scenarioIds: ['SW01', 'SW02', 'SW03'],
    category: 'Form',
    builder: (context) => const SwitchStory(),
    description: 'Tactile toggle switch with inset pill track and clean thumb displacement.',
  ),
  StoryDefinition(
    slug: 'checkbox',
    name: 'Checkbox 多选框',
    capabilityId: 'C14',
    scenarioIds: ['CHK01', 'CHK02', 'CHK03', 'CHK04'],
    category: 'Form',
    builder: (context) => const CheckboxStory(),
    description: 'Rounded square checkbox with SVG checkmark and group multi-selection binding.',
  ),
  StoryDefinition(
    slug: 'radio',
    name: 'Radio 单选框',
    capabilityId: 'C15',
    scenarioIds: ['RAD01', 'RAD02', 'RAD03', 'RAD04'],
    category: 'Form',
    builder: (context) => const RadioStory(),
    description: 'Mutually exclusive radio group with keyboard arrow navigation and tactile indicator.',
  ),
  StoryDefinition(
    slug: 'select',
    name: 'Select 下拉选择',
    capabilityId: 'C16',
    scenarioIds: ['SEL01', 'SEL02', 'SEL03', 'SEL04'],
    category: 'Form',
    builder: (context) => const SelectStory(),
    description: 'Anchor-aligned dropdown menu with keyboard roving focus and Escape recovery.',
  ),
  StoryDefinition(
    slug: 'date-picker',
    name: 'DatePicker 日期选择器',
    capabilityId: 'C17',
    scenarioIds: ['DAT01', 'DAT02', 'DAT03', 'DAT04', 'DAT05'],
    category: 'Form',
    builder: (context) => const DatePickerStory(),
    description: 'Timezone-free calendar date and range picker sharing an inline/popover panel engine.',
  ),
  StoryDefinition(
    slug: 'time-picker',
    name: 'TimePicker 时间选择器',
    capabilityId: 'C18',
    scenarioIds: ['TIM01', 'TIM02', 'TIM03', 'TIM04', 'TIM05'],
    category: 'Form',
    builder: (context) => const TimePickerStory(),
    description: 'Atomic time value wheel with seconds preservation and program-scroll feedback suppression.',
  ),
  StoryDefinition(
    slug: 'form',
    name: 'Form 表单',
    capabilityId: 'C19',
    scenarioIds: ['FOR01', 'FOR02', 'FOR03', 'FOR04', 'FOR05'],
    category: 'Form',
    builder: (context) => const FormStory(),
    description: 'Strongly typed form state container with revision + epoch race protection for async validators.',
  ),
  StoryDefinition(
    slug: 'form-item',
    name: 'FormItem 表单项',
    capabilityId: 'C20',
    scenarioIds: ['FI01', 'FI02', 'FI03', 'FI04'],
    category: 'Form',
    builder: (context) => const FormItemStory(),
    description: 'Explicit builder binding connecting field controllers to presentation controls.',
  ),

  // Overlays & Feedback
  StoryDefinition(
    slug: 'modal',
    name: 'Modal 对话框',
    capabilityId: 'C21',
    scenarioIds: ['MOD01', 'MOD02', 'MOD03', 'MOD04'],
    category: 'Feedback',
    builder: (context) => const ModalStory(),
    description: 'Blob-outlined modal dialog with async confirm loading and focus trapping.',
  ),
  StoryDefinition(
    slug: 'drawer',
    name: 'Drawer 抽屉',
    capabilityId: 'C22',
    scenarioIds: ['DRW01', 'DRW02', 'DRW03'],
    category: 'Feedback',
    builder: (context) => const DrawerStory(),
    description: 'Non-blocking slide-out drawer supporting four anchor edges and safe area handling.',
  ),
  StoryDefinition(
    slug: 'tooltip',
    name: 'Tooltip 文字提示',
    capabilityId: 'C23',
    scenarioIds: ['TIP01', 'TIP02', 'TIP03'],
    category: 'Feedback',
    builder: (context) => const TooltipStory(),
    description: 'Disjunctive message/richMessage popup with viewport collision detection.',
  ),
  StoryDefinition(
    slug: 'notification',
    name: 'Notification 通知',
    capabilityId: 'C30',
    scenarioIds: ['NOT01', 'NOT02', 'NOT03', 'NOT04', 'NOT05'],
    category: 'Feedback',
    builder: (context) => const NotificationStory(),
    description: 'Scoped host notification queue with same-key timer reset and hover pause.',
  ),
  StoryDefinition(
    slug: 'progress',
    name: 'Progress 进度条',
    capabilityId: 'C24',
    scenarioIds: ['PRO01', 'PRO02', 'PRO03'],
    category: 'Feedback',
    builder: (context) => const ProgressStory(),
    description: 'Bar and circular progress indicators sharing candy-stripe styling and value bounds.',
  ),
  StoryDefinition(
    slug: 'loading',
    name: 'Loading 加载',
    capabilityId: 'C25',
    scenarioIds: ['LOD01', 'LOD02', 'LOD03'],
    category: 'Feedback',
    builder: (context) => const LoadingStory(),
    description:
        'Handle-scoped loading masks with zero orphan entries on early close.',
  ),
  StoryDefinition(
    slug: 'skeleton',
    name: 'Skeleton 骨架屏',
    capabilityId: 'C26',
    scenarioIds: ['SKL01', 'SKL02', 'SKL03'],
    category: 'Feedback',
    builder: (context) => const SkeletonStory(),
    description: 'Content placeholder blocks with shimmer animation halted when disabled or inactive.',
  ),
  StoryDefinition(
    slug: 'countdown',
    name: 'Countdown 倒计时',
    capabilityId: 'C28',
    scenarioIds: ['CDN01', 'CDN02', 'CDN03'],
    category: 'Feedback',
    builder: (context) => const CountdownStory(),
    description: 'Deadline-based scheduling engine with exactly-once onFinish invocation.',
  ),
  StoryDefinition(
    slug: 'time',
    name: 'Time 相对时间',
    capabilityId: 'C29',
    scenarioIds: ['CLK01', 'CLK02', 'CLK03'],
    category: 'Feedback',
    builder: (context) => const TimeStory(),
    description: 'Clock-driven relative time formatting without noisy live screen reader chatter.',
  ),

  // Data Display
  StoryDefinition(
    slug: 'table',
    name: 'Table 表格',
    capabilityId: 'C31',
    scenarioIds: ['TBL01', 'TBL02', 'TBL03', 'TBL04', 'TBL05'],
    category: 'Data Display',
    builder: (context) => const TableStory(),
    description: 'Lazy virtualized data table supporting 10,000+ rows within bounded viewports.',
  ),
  StoryDefinition(
    slug: 'pagination',
    name: 'Pagination 分页',
    capabilityId: 'C32',
    scenarioIds: ['PAG01', 'PAG02', 'PAG03'],
    category: 'Data Display',
    builder: (context) => const PaginationStory(),
    description: 'Adaptive integer pagination with ellipsis navigation and width compaction.',
  ),
  StoryDefinition(
    slug: 'code-block',
    name: 'CodeBlock 代码块',
    capabilityId: 'C33',
    scenarioIds: ['COD01', 'COD02', 'COD03'],
    category: 'Data Display',
    builder: (context) => const CodeBlockStory(),
    description: 'Syntax-highlighted code container with verified clipboard feedback and error handling.',
  ),
  StoryDefinition(
    slug: 'tag',
    name: 'Tag 标签',
    capabilityId: 'C34',
    scenarioIds: ['TAG01', 'TAG02', 'TAG03'],
    category: 'Data Display',
    builder: (context) => const TagStory(),
    description: 'Tactile pill tag with decoupled label and close button hit targets and keyboard actions.',
  ),
  StoryDefinition(
    slug: 'image',
    name: 'Image 图片',
    capabilityId: 'C35',
    scenarioIds: ['IMG01', 'IMG02', 'IMG03', 'IMG04'],
    category: 'Data Display',
    builder: (context) => const ImageStory(),
    description: 'Cozy bordered image with error fallback, loading states, and lightbox zoom preview.',
  ),
];

/// Helper to lookup story by route slug.
StoryDefinition? getStoryBySlug(String slug) {
  for (final story in componentCatalog) {
    if (story.slug == slug) return story;
  }
  return null;
}
