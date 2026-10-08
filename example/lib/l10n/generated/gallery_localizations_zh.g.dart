// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'gallery_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class GalleryLocalizationsZh extends GalleryLocalizations {
  GalleryLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get galleryAppTitle => 'Animal Island UI 展示页';

  @override
  String get galleryBrandName => 'Animal Island UI';

  @override
  String get gallerySearchTooltip => '搜索组件';

  @override
  String get gallerySearchAction => '搜索';

  @override
  String get galleryLocaleSwitch => '切换语言';

  @override
  String get galleryLocaleSwitchValue => '中文 / EN';

  @override
  String get galleryTextScaleTooltip => '文字缩放比例';

  @override
  String get galleryReducedMotionOn => '动效已减弱';

  @override
  String get galleryReducedMotionOff => '动效正常';

  @override
  String get galleryThemeTooltip => '切换主题';

  @override
  String get galleryThemeDark => '深色';

  @override
  String get galleryThemeLight => '浅色';

  @override
  String get galleryCategoryExplore => '探索与证据';

  @override
  String get galleryCategoryRecipes => '交互式端到端示例';

  @override
  String get galleryCategoryGeneral => '1. 通用';

  @override
  String get galleryCategoryLayout => '2. 结构与布局';

  @override
  String get galleryCategoryNavigation => '3. 导航';

  @override
  String get galleryCategoryFormControls => '4. 表单控件';

  @override
  String get galleryCategoryFormEngine => '5. 表单引擎';

  @override
  String get galleryCategoryOverlays => '6. 浮层';

  @override
  String get galleryCategoryFeedback => '7. 反馈与动画';

  @override
  String get galleryCategoryNotifications => '8. 通知';

  @override
  String get galleryCategoryDataDisplay => '9. 数据展示';

  @override
  String get galleryCategoryDecorative => '10. 装饰';

  @override
  String get galleryOverviewNav => '概览';

  @override
  String galleryCount(int count) {
    return '$count';
  }

  @override
  String get galleryRecipeBadge => '端到端';

  @override
  String get galleryDevelopmentCandidateBadge => '开发候选';

  @override
  String galleryTextScaleValue(num scale) {
    final intl.NumberFormat scaleNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 1,
        );
    final String scaleString = scaleNumberFormat.format(scale);

    return '$scaleString×';
  }

  @override
  String get galleryIconsNav => '101 个矢量图标';

  @override
  String get galleryProvenanceNav => '构建来源';

  @override
  String get galleryRecipeFormNav => '表单与异步验证';

  @override
  String get galleryRecipeOverlayNav => '浮层编排';

  @override
  String get galleryRecipeTableNav => '数据表格与展示页';

  @override
  String get galleryComponentC01 => '按钮 (C01)';

  @override
  String get galleryComponentC02 => '图标 (C02)';

  @override
  String get galleryComponentC03 => '打字机 (C03)';

  @override
  String get galleryComponentC04 => '光标 (C04)';

  @override
  String get galleryComponentC05 => '卡片 (C05)';

  @override
  String get galleryComponentC06 => '标题 (C06)';

  @override
  String get galleryComponentC07 => '分隔符 (C07)';

  @override
  String get galleryComponentC08 => '背景 (C08)';

  @override
  String get galleryComponentC09 => '折叠面板 (C09)';

  @override
  String get galleryComponentC10 => '标签页 (C10)';

  @override
  String get galleryComponentC11 => '轮播图 (C11)';

  @override
  String get galleryComponentC12 => '输入框 (C12)';

  @override
  String get galleryComponentC13 => '开关 (C13)';

  @override
  String get galleryComponentC14 => '复选框 (C14)';

  @override
  String get galleryComponentC15 => '单选框 (C15)';

  @override
  String get galleryComponentC16 => '选择器 (C16)';

  @override
  String get galleryComponentC17 => '日期选择器 (C17)';

  @override
  String get galleryComponentC18 => '时间选择器 (C18)';

  @override
  String get galleryComponentC19 => '表单 (C19)';

  @override
  String get galleryComponentC20 => '表单项 (C20)';

  @override
  String get galleryComponentC21 => '对话框 (C21)';

  @override
  String get galleryComponentC22 => '抽屉 (C22)';

  @override
  String get galleryComponentC23 => '提示框 (C23)';

  @override
  String get galleryComponentC24 => '进度条 (C24)';

  @override
  String get galleryComponentC25 => '加载状态 (C25)';

  @override
  String get galleryComponentC26 => '骨架屏 (C26)';

  @override
  String get galleryComponentC27 => '回到顶部 (C27)';

  @override
  String get galleryComponentC28 => '倒计时 (C28)';

  @override
  String get galleryComponentC29 => '时间 (C29)';

  @override
  String get galleryComponentC30 => '通知 (C30)';

  @override
  String get galleryComponentC31 => '表格 (C31)';

  @override
  String get galleryComponentC32 => '分页 (C32)';

  @override
  String get galleryComponentC33 => '代码块 (C33)';

  @override
  String get galleryComponentC34 => '标签 (C34)';

  @override
  String get galleryComponentC35 => '图片 (C35)';

  @override
  String get galleryComponentC36 => '页脚 (C36)';

  @override
  String get galleryWelcomeTitle => '欢迎来到 Animal Island UI';

  @override
  String get galleryWelcomeSubtitle => '为企业级 Flutter 应用打造的温暖可爱组件库';

  @override
  String get galleryMetricComponents => '目录组件';

  @override
  String get galleryMetricIcons => '标准 SVG 图标';

  @override
  String get galleryRecipesTitle => '交互式端到端示例';

  @override
  String get galleryRecipeFormTitle => '表单与异步验证';

  @override
  String get galleryRecipeFormDescription => '展示带类型字段键、并发异步验证和自动定位错误的完整表单生命周期。';

  @override
  String get galleryRecipeOverlayTitle => '浮层编排';

  @override
  String get galleryRecipeOverlayDescription => '演示通知排队、对话框、滑出抽屉和加载遮罩的协同。';

  @override
  String get galleryRecipeTableTitle => '数据表格与展示页';

  @override
  String get galleryRecipeTableDescription =>
      '演示包含 1,000 行数据的虚拟表格、排序、分页、代码复制和图片预览。';

  @override
  String get galleryExploreCategoriesTitle => '浏览组件类别';

  @override
  String get galleryChipButton => '按钮';

  @override
  String get galleryChipIcons => '101 个图标';

  @override
  String get galleryChipTypewriter => '打字机';

  @override
  String get galleryChipInputForms => '输入与表单';

  @override
  String get galleryChipDateTime => '日期与时间选择器';

  @override
  String get galleryChipModal => '对话框与提示';

  @override
  String get galleryChipTable => '虚拟表格';

  @override
  String get galleryChipPagination => '分页';

  @override
  String get galleryChipCodeBlock => '代码块';

  @override
  String get galleryChipImage => '图片预览';

  @override
  String get galleryChipTabs => '标签页与折叠面板';

  @override
  String get galleryChipNotifications => '通知管理器';

  @override
  String get galleryDemoBadge => '演示';

  @override
  String get galleryLaunchRecipe => '打开示例';

  @override
  String get galleryNotFoundTitle => '404：岛上没有这个页面';

  @override
  String galleryNotFoundRoute(String route) {
    return '找不到路由“$route”对应的组件示例';
  }

  @override
  String get galleryReturnOverview => '返回概览';

  @override
  String get provenanceUnavailable => '此构建未加盖构建身份。';

  @override
  String get provenanceTitle => '构建来源与授权记录';

  @override
  String get provenanceDescription => '此页面展示本次构建加盖的身份和项目目标；当前验收状态以候选证据为准。';

  @override
  String get provenanceReleaseIdentity => '构建身份';

  @override
  String get provenancePackageIdentity => '软件包身份';

  @override
  String provenancePackageValue(String packageName, String version) {
    return '$packageName v$version';
  }

  @override
  String get provenanceSourceCommit => '源 Git 提交';

  @override
  String get provenanceBuildSdk => '构建所用 Flutter SDK';

  @override
  String provenanceSdkValue(String flutterVersion, String dartVersion) {
    return 'Flutter $flutterVersion（Dart $dartVersion）';
  }

  @override
  String get provenanceUpstreamValue => 'guokaigdg/animal-island-ui';

  @override
  String get provenanceApiHash => '公共 API 签名 SHA-256';

  @override
  String get provenanceUpstream => '上游设计系统';

  @override
  String get provenanceLicense => '许可证说明';

  @override
  String provenanceLicenseValue(String license) {
    return '$license（非商业署名许可）';
  }
}
