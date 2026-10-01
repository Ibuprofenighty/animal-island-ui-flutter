import 'package:flutter/material.dart';

import 'button_story.dart';
import 'icon_story.dart';
import 'typewriter_story.dart';
import 'cursor_story.dart';
import 'card_story.dart';
import 'title_story.dart';
import 'divider_story.dart';
import 'background_story.dart';
import 'collapse_story.dart';
import 'tabs_story.dart';
import 'carousel_story.dart';
import 'input_story.dart';
import 'switch_story.dart';
import 'checkbox_story.dart';
import 'radio_story.dart';
import 'select_story.dart';
import 'date_picker_story.dart';
import 'time_picker_story.dart';
import 'form_story.dart';
import 'form_item_story.dart';
import 'modal_story.dart';
import 'drawer_story.dart';
import 'tooltip_story.dart';
import 'progress_story.dart';
import 'loading_story.dart';
import 'skeleton_story.dart';
import 'back_top_story.dart';
import 'countdown_story.dart';
import 'time_story.dart';
import 'notification_story.dart';
import 'table_story.dart';
import 'pagination_story.dart';
import 'code_block_story.dart';
import 'tag_story.dart';
import 'image_story.dart';
import 'footer_story.dart';

Widget? resolveStoryWidget(String slug) {
  switch (slug) {
    case 'button':
      return const ButtonStory();
    case 'icon':
      return const IconStory();
    case 'typewriter':
      return const TypewriterStory();
    case 'cursor':
      return const CursorStory();
    case 'card':
      return const CardStory();
    case 'title':
      return const TitleStory();
    case 'divider':
      return const DividerStory();
    case 'background':
      return const BackgroundStory();
    case 'collapse':
      return const CollapseStory();
    case 'tabs':
      return const TabsStory();
    case 'carousel':
      return const CarouselStory();
    case 'input':
      return const InputStory();
    case 'switch':
      return const SwitchStory();
    case 'checkbox':
      return const CheckboxStory();
    case 'radio':
      return const RadioStory();
    case 'select':
      return const SelectStory();
    case 'date_picker':
      return const DatePickerStory();
    case 'time_picker':
      return const TimePickerStory();
    case 'form':
      return const FormStory();
    case 'form_item':
      return const FormItemStory();
    case 'modal':
      return const ModalStory();
    case 'drawer':
      return const DrawerStory();
    case 'tooltip':
      return const TooltipStory();
    case 'progress':
      return const ProgressStory();
    case 'loading':
      return const LoadingStory();
    case 'skeleton':
      return const SkeletonStory();
    case 'back_top':
      return const BackTopStory();
    case 'countdown':
      return const CountdownStory();
    case 'time':
      return const TimeStory();
    case 'notification':
      return const NotificationStory();
    case 'table':
      return const TableStory();
    case 'pagination':
      return const PaginationStory();
    case 'code_block':
      return const CodeBlockStory();
    case 'tag':
      return const TagStory();
    case 'image':
      return const ImageStory();
    case 'footer':
      return const FooterStory();
    default:
      return null;
  }
}
