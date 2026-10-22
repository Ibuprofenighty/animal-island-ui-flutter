import 'upload_story.dart';
import 'form_story.dart';
import 'date_picker_story.dart';
import 'skill_story.dart';
import 'cursor_story.dart';
import 'drawer_story.dart';
import 'notification_story.dart';
import 'tooltip_story.dart';
import 'image_story.dart';
import 'carousel_story.dart';
import 'count_up_story.dart';
import 'table_story.dart';
import 'pagination_story.dart';
import 'tabs_story.dart';
import 'back_top_story.dart';
import 'loading_story.dart';
import 'card_story.dart';
import 'collapse_story.dart';
import 'avatar_story.dart';
import 'badge_story.dart';
import 'background_story.dart';
import 'footer_story.dart';
import 'progress_story.dart';
import 'time_picker_story.dart';
import 'time_story.dart';
import 'countdown_story.dart';
import 'select_story.dart';
import 'icon_story.dart';
import 'typewriter_story.dart';
import 'code_story.dart';
import 'tag_story.dart';
import 'divider_story.dart';
import 'rate_story.dart';
import 'skeleton_story.dart';

import 'package:flutter/material.dart';

import 'button_story.dart';
import 'input_story.dart';
import 'selection_story.dart';
import 'title_story.dart';
import 'modal_story.dart';

/// Each page owns its executable examples. No component internals live in this registry.
final storyBuilders = <String, WidgetBuilder>{
  'upload': (_) => const UploadStory(),
  'form': (_) => const FormStory(),
  'date-picker': (_) => const DatePickerStory(),
  'skill': (_) => const SkillStory(),
  'cursor': (_) => const CursorStory(),
  'drawer': (_) => const DrawerStory(),
  'notification': (_) => const NotificationStory(),
  'tooltip': (_) => const TooltipStory(),
  'image': (_) => const ImageStory(),
  'carousel': (_) => const CarouselStory(),
  'countup': (_) => const CountUpStory(),
  'table': (_) => const TableStory(),
  'pagination': (_) => const PaginationStory(),
  'tabs': (_) => const TabsStory(),
  'backtop': (_) => const BackTopStory(),
  'loading': (_) => const LoadingStory(),
  'card': (_) => const CardStory(),
  'collapse': (_) => const CollapseStory(),
  'avatar': (_) => const AvatarStory(),
  'badge': (_) => const BadgeStory(),
  'background': (_) => const BackgroundStory(),
  'footer': (_) => const FooterStory(),
  'progress': (_) => const ProgressStory(),
  'time-picker': (_) => const TimePickerStory(),
  'time': (_) => const TimeStory(),
  'countdown': (_) => const CountdownStory(),
  'select': (_) => const SelectStory(),
  'icon': (_) => const IconStory(),
  'typewriter': (_) => const TypewriterStory(),
  'codeblock': (_) => const CodeStory(),
  'tag': (_) => const TagStory(),
  'divider-comp': (_) => const DividerStory(),
  'rate': (_) => const RateStory(),
  'skeleton': (_) => const SkeletonStory(),
  'input': (_) => const InputStory(),
  'switch': (_) => const SwitchStory(),
  'checkbox': (_) => const SelectionStory(radio: false),
  'radio': (_) => const SelectionStory(radio: true),
  'button': (_) => const ButtonStory(),
  'title': (_) => const TitleStory(),
  'modal': (_) => const ModalStory(),
};
