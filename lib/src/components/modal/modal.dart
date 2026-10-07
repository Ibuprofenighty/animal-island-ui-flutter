import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/components/modal_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../../internal/interaction/icon_action.dart';
import '../../internal/overlay/animal_route.dart';
import '../../internal/timing/motion_policy.dart';
import '../button/button.dart';
import '../typewriter/typewriter.dart';
import 'modal_surface.dart';

/// Animal Island organic blob modal (C21).
///
/// The widget is the modal surface: a title row with an optional close
/// control, the caller's [content] and an optional [footer]. Present it as a
/// route on the nearest Navigator with one of the typed entry points:
///
/// * [AnimalModal.confirm] returns `Future<bool>`: true only when the confirm
///   action succeeds, false when the modal is cancelled or dismissed.
/// * [AnimalModal.showDialogue] is a confirmation with speaker, avatar and
///   typewriter dialogue text.
/// * [AnimalModal.show] returns `Future<T?>`: the value passed to the `close`
///   callback its builders receive, or null when dismissed.
///
/// The close control, Escape and system back dismiss the route; a barrier tap
/// dismisses it only when `mask` and `maskClosable` are both true. While a
/// confirmation is pending every dismissal is ignored. Focus stays inside the
/// route and returns to the opening control when it closes.
class AnimalModal extends StatelessWidget {
  /// Preferred surface width when none is given.
  static const double _defaultWidth = 500.0;

  /// Title row content, styled with the title text style.
  final Widget? title;

  /// Body content, styled with the body text style.
  final Widget content;

  /// Optional actions row below the body.
  final Widget? footer;

  /// Shows the close control and runs when it is activated.
  final VoidCallback? onClose;

  /// Preferred surface width, 500 logical pixels by default; the surface
  /// never exceeds the screen.
  final double width;

  /// Visual overrides for this modal; see [AnimalModalStyle].
  final AnimalModalStyle? style;

  /// Message of a failed confirmation, shown by the confirmation route only.
  final String? _errorText;

  const AnimalModal({
    super.key,
    this.title,
    required this.content,
    this.footer,
    this.onClose,
    this.width = _defaultWidth,
    this.style,
  }) : _errorText = null;

  const AnimalModal._route({
    this.title,
    required this.content,
    this.footer,
    this.onClose,
    required this.width,
    this.style,
    this._errorText,
  });

  /// Shows a confirmation modal and returns whether it was confirmed.
  ///
  /// [onConfirm] decides whether the confirm action closes the modal: true
  /// closes it and completes the result with true; false keeps it open; a
  /// thrown error keeps it open, shows the error and allows a retry. While
  /// [onConfirm] is pending, repeated confirm and every dismissal are ignored.
  /// Without [onConfirm] the confirm action closes the modal with true.
  /// Cancel, the close control, Escape, back and the barrier complete it with
  /// false.
  static Future<bool> confirm({
    required BuildContext context,
    Widget? title,
    required Widget content,
    FutureOr<bool> Function()? onConfirm,
    String? confirmText,
    String? cancelText,
    double width = _defaultWidth,
    bool mask = true,
    bool maskClosable = true,
    AnimalModalStyle? style,
  }) => _confirmRoute(
    context: context,
    title: title,
    content: content,
    onConfirm: onConfirm,
    confirmText: confirmText,
    cancelText: cancelText,
    width: width,
    mask: mask,
    maskClosable: maskClosable,
    style: style,
    dialogue: false,
  );

  /// Shows an Animal Crossing-style character dialogue and returns whether it
  /// was continued.
  ///
  /// [dialogue] is typed out once; [onFinish] runs once when it is fully
  /// shown. The title is [title], or [speaker] as text. The continue action
  /// follows the [confirm] rules.
  static Future<bool> showDialogue({
    required BuildContext context,
    String? speaker,
    Widget? avatar,
    required String dialogue,
    Widget? title,
    Duration typeSpeed = const Duration(milliseconds: 35),
    VoidCallback? onFinish,
    FutureOr<bool> Function()? onConfirm,
    String? continueText,
    String? cancelText,
    double width = _defaultWidth,
    bool mask = true,
    bool maskClosable = true,
    AnimalModalStyle? style,
  }) => _confirmRoute(
    context: context,
    title: title ?? (speaker != null ? Text(speaker) : null),
    content: _ModalDialogue(
      avatar: avatar,
      dialogue: dialogue,
      typeSpeed: typeSpeed,
      onFinish: onFinish,
      style: style,
    ),
    onConfirm: onConfirm,
    confirmText: continueText,
    cancelText: cancelText,
    width: width,
    mask: mask,
    maskClosable: maskClosable,
    style: style,
    dialogue: true,
  );

  /// Shows a content modal and returns the value its content closes it with.
  ///
  /// [builder] builds the body and [footerBuilder] the optional footer. Both
  /// receive `close`, which completes the modal with a typed value; the close
  /// control, Escape, back and the barrier complete it with null.
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    required Widget Function(
      BuildContext context,
      void Function(T result) close,
    )
    builder,
    Widget Function(BuildContext context, void Function(T result) close)?
    footerBuilder,
    double width = _defaultWidth,
    bool mask = true,
    bool maskClosable = true,
    AnimalModalStyle? style,
  }) => _present<T>(
    context: context,
    mask: mask,
    maskClosable: maskClosable,
    style: style,
    modal: (session) => AnimalModal(
      title: title,
      content: Builder(builder: (context) => builder(context, session.close)),
      footer: footerBuilder == null
          ? null
          : Builder(
              builder: (context) => footerBuilder(context, session.close),
            ),
      onClose: session.dismiss,
      width: width,
      style: style,
    ),
  );

  static Future<bool> _confirmRoute({
    required BuildContext context,
    required Widget? title,
    required Widget content,
    required FutureOr<bool> Function()? onConfirm,
    required String? confirmText,
    required String? cancelText,
    required double width,
    required bool mask,
    required bool maskClosable,
    required AnimalModalStyle? style,
    required bool dialogue,
  }) async {
    final bool? confirmed = await _present<bool>(
      context: context,
      mask: mask,
      maskClosable: maskClosable,
      style: style,
      modal: (session) => _ConfirmModal(
        session: session,
        title: title,
        content: content,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        width: width,
        style: style,
        dialogue: dialogue,
      ),
    );
    return confirmed ?? false;
  }

  static Future<T?> _present<T>({
    required BuildContext context,
    required bool mask,
    required bool maskClosable,
    required AnimalModalStyle? style,
    required Widget Function(AnimalRouteSession<T> session) modal,
  }) {
    final AnimalIslandTheme theme = AnimalIslandTheme.of(context);
    final _ResolvedModalStyle resolved = _ResolvedModalStyle.resolve(
      theme,
      style,
    );
    final bool animate = AnimalMotionPolicy.shouldAnimate(context);
    return presentAnimalRoute<T>(
      context: context,
      maskClosable: mask && maskClosable,
      barrierColor: mask ? resolved.barrierColor : const Color(0x00000000),
      transitionDuration: animate ? theme.motion.normal : Duration.zero,
      routeLabel: (context) => AnimalLocalizations.of(context)!.modalRouteLabel,
      builder: (context, session) {
        Widget page = Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Center(
            child: Material(color: Colors.transparent, child: modal(session)),
          ),
        );
        final double sigma = _ResolvedModalStyle.resolve(
          AnimalIslandTheme.of(context),
          style,
        ).barrierBlurSigma;
        if (mask && sigma > 0) {
          page = BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: page,
          );
        }
        return page;
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (!animate) return child;
        return ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: theme.motion.spring),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: theme.motion.ease,
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ResolvedModalStyle s = _ResolvedModalStyle.resolve(
      AnimalIslandTheme.of(context),
      style,
    );
    final MediaQueryData mq = MediaQuery.of(context);
    final double effectiveWidth = math.max(
      0.0,
      math.min(width, mq.size.width - 2 * s.horizontalMargin),
    );
    // The body scrolls inside the space the keyboard leaves free, so long
    // content, large text and an open IME never push the actions off screen.
    final double maxHeight = math.max(
      0.0,
      (mq.size.height - mq.viewInsets.bottom) * _ResolvedModalStyle.heightRatio,
    );
    // On a very narrow surface each horizontal padding side yields to at most
    // a quarter of the width, so the header keeps room for the close control.
    final EdgeInsets padding = s.padding.resolve(Directionality.of(context));
    final double maxSide = effectiveWidth * _ResolvedModalStyle.maxPaddingShare;
    final EdgeInsets surfacePadding = padding.copyWith(
      left: math.min(padding.left, maxSide),
      right: math.min(padding.right, maxSide),
    );
    final String? errorText = _errorText;
    final Widget? footer = this.footer;

    return AnimalModalSurface(
      width: effectiveWidth,
      fillColor: s.backgroundColor,
      borderColor: s.borderColor,
      borderWidth: s.borderWidth,
      shadows: s.shadows,
      padding: surfacePadding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: title != null
                        ? DefaultTextStyle(
                            style: s.titleTextStyle,
                            child: title!,
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (onClose case final VoidCallback onClose)
                    AnimalIconAction(
                      onPressed: onClose,
                      semanticLabel: AnimalLocalizations.of(context)!
                          .modalCloseLabel,
                      padding: s.closeButtonPadding,
                      borderRadius: s.closeButtonBorderRadius,
                      backgroundColor: s.closeButtonBackgroundColor,
                      icon: AnimalIcon(
                        data: AnimalIcons.close,
                        size: s.closeIconSize,
                        color: s.closeIconColor,
                      ),
                    ),
                ],
              ),
              SizedBox(height: s.headerGap),
              DefaultTextStyle(style: s.textStyle, child: content),
              if (errorText != null) ...[
                SizedBox(height: s.errorGap),
                Text(errorText, style: s.errorTextStyle),
              ],
              if (footer != null) ...[SizedBox(height: s.footerGap), footer],
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirmation route body: the pending, error and action state of one
/// [AnimalModal.confirm] or [AnimalModal.showDialogue] presentation.
class _ConfirmModal extends StatefulWidget {
  const _ConfirmModal({
    required this.session,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.confirmText,
    required this.cancelText,
    required this.width,
    required this.style,
    required this.dialogue,
  });

  final AnimalRouteSession<bool> session;
  final Widget? title;
  final Widget content;
  final FutureOr<bool> Function()? onConfirm;
  final String? confirmText;
  final String? cancelText;
  final double width;
  final AnimalModalStyle? style;
  final bool dialogue;

  @override
  State<_ConfirmModal> createState() => _ConfirmModalState();
}

class _ConfirmModalState extends State<_ConfirmModal> {
  bool _pending = false;
  String? _errorText;

  static bool _accept() => true;

  Future<void> _confirm() async {
    if (widget.session.isBusy || widget.session.isClosed) return;
    setState(() {
      _pending = true;
      _errorText = null;
    });
    final Object? error = await widget.session.confirm(
      widget.onConfirm ?? _accept,
      true,
    );
    if (!mounted) return;
    setState(() {
      _pending = false;
      _errorText = error?.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AnimalLocalizations localizations = AnimalLocalizations.of(context)!;
    final _ResolvedModalStyle s = _ResolvedModalStyle.resolve(
      AnimalIslandTheme.of(context),
      widget.style,
    );
    return AnimalModal._route(
      title: widget.title,
      content: widget.content,
      onClose: widget.session.dismiss,
      width: widget.width,
      style: widget.style,
      errorText: _errorText,
      // The actions wrap instead of overflowing at narrow widths or large text.
      footer: Wrap(
        alignment: WrapAlignment.end,
        spacing: s.actionGap,
        runSpacing: s.actionGap,
        children: [
          AnimalButton(
            variant: AnimalButtonVariant.outlined,
            size: AnimalButtonSize.small,
            onPressed: _pending ? null : widget.session.dismiss,
            child: Text(widget.cancelText ?? localizations.cancel),
          ),
          AnimalButton(
            variant: AnimalButtonVariant.filled,
            tone: AnimalButtonTone.primary,
            size: AnimalButtonSize.small,
            loading: _pending,
            onPressed: _pending ? null : _confirm,
            child: Text(
              widget.confirmText ??
                  (widget.dialogue
                      ? localizations.modalContinue
                      : localizations.modalConfirm),
            ),
          ),
        ],
      ),
    );
  }
}

/// Speaker dialogue body: the explicit [dialogue] text typed out once.
class _ModalDialogue extends StatelessWidget {
  const _ModalDialogue({
    required this.avatar,
    required this.dialogue,
    required this.typeSpeed,
    required this.onFinish,
    required this.style,
  });

  final Widget? avatar;
  final String dialogue;
  final Duration typeSpeed;
  final VoidCallback? onFinish;
  final AnimalModalStyle? style;

  @override
  Widget build(BuildContext context) {
    final Widget text = AnimalTypewriter(
      text: dialogue,
      speed: typeSpeed,
      textAlign: TextAlign.left,
      onComplete: onFinish,
    );
    final Widget? avatar = this.avatar;
    if (avatar == null) return text;
    final _ResolvedModalStyle s = _ResolvedModalStyle.resolve(
      AnimalIslandTheme.of(context),
      style,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        SizedBox(width: s.avatarGap),
        Expanded(child: text),
      ],
    );
  }
}

/// The single resolver of every visual value of [AnimalModal].
///
/// Precedence: instance `style` > `AnimalIslandTheme.components.modal` >
/// defaults derived from theme tokens.
class _ResolvedModalStyle {
  /// Share of the height left free by the keyboard that the body may use.
  static const double heightRatio = 0.85;

  /// Largest share of the surface width one horizontal padding side may take.
  static const double maxPaddingShare = 0.25;

  /// Default corner radius of the close control: a circle around its icon.
  static const BorderRadius _closeButtonBorderRadius = BorderRadius.all(
    Radius.circular(24),
  );

  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow> shadows;
  final EdgeInsetsGeometry padding;
  final double horizontalMargin;
  final TextStyle titleTextStyle;
  final TextStyle textStyle;
  final TextStyle errorTextStyle;
  final double headerGap;
  final double errorGap;
  final double footerGap;
  final double actionGap;
  final double avatarGap;
  final Color closeIconColor;
  final double closeIconSize;
  final EdgeInsetsGeometry closeButtonPadding;
  final BorderRadius closeButtonBorderRadius;
  final WidgetStateProperty<Color> closeButtonBackgroundColor;
  final Color barrierColor;
  final double barrierBlurSigma;

  const _ResolvedModalStyle._({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.shadows,
    required this.padding,
    required this.horizontalMargin,
    required this.titleTextStyle,
    required this.textStyle,
    required this.errorTextStyle,
    required this.headerGap,
    required this.errorGap,
    required this.footerGap,
    required this.actionGap,
    required this.avatarGap,
    required this.closeIconColor,
    required this.closeIconSize,
    required this.closeButtonPadding,
    required this.closeButtonBorderRadius,
    required this.closeButtonBackgroundColor,
    required this.barrierColor,
    required this.barrierBlurSigma,
  });

  static _ResolvedModalStyle resolve(
    AnimalIslandTheme theme,
    AnimalModalStyle? style,
  ) {
    final AnimalModalStyle merged = (style ?? AnimalModalStyle()).merge(
      theme.components.modal,
    );
    final colors = theme.colors;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final bool dark = colors.brightness == Brightness.dark;
    final BoxShadow? shadow = merged.shadow;

    return _ResolvedModalStyle._(
      backgroundColor: merged.backgroundColor ?? colors.bgContent,
      borderColor:
          merged.borderColor ??
          (dark
              ? colors.border.withValues(alpha: 0.6)
              : colors.borderLight.withValues(alpha: 0.8)),
      borderWidth: merged.borderWidth ?? 2.0,
      shadows: shadow != null ? <BoxShadow>[shadow] : theme.shadows.modal,
      padding:
          merged.padding ??
          EdgeInsets.symmetric(
            horizontal: spacing.xxl + spacing.xs,
            vertical: spacing.xxl,
          ),
      horizontalMargin: merged.horizontalMargin ?? spacing.xxl / 2,
      titleTextStyle: typography
          .resolve(
            typography.title
                .apply(fontSizeFactor: 0.75)
                .copyWith(fontWeight: FontWeight.w800)
                .merge(merged.titleTextStyle),
          )
          .copyWith(color: merged.titleTextColor ?? colors.text),
      textStyle: typography
          .resolve(
            typography.body
                .apply(fontSizeFactor: 15 / 14)
                .copyWith(height: 1.5)
                .merge(merged.textStyle),
          )
          .copyWith(color: merged.textColor ?? colors.textBody),
      errorTextStyle: typography
          .resolve(
            typography.caption
                .copyWith(fontWeight: FontWeight.bold)
                .merge(merged.errorTextStyle),
          )
          .copyWith(color: merged.errorTextColor ?? colors.error),
      headerGap: merged.headerGap ?? spacing.lg + spacing.xxs,
      errorGap: merged.errorGap ?? spacing.md,
      footerGap: merged.footerGap ?? spacing.xl + spacing.xs,
      actionGap: merged.actionGap ?? spacing.md,
      avatarGap: merged.avatarGap ?? spacing.md + spacing.xxs / 2,
      closeIconColor: merged.closeIconColor ?? colors.textSecondary,
      closeIconSize: merged.closeIconSize ?? 16,
      closeButtonPadding:
          merged.closeButtonPadding ?? EdgeInsets.all(spacing.xs + spacing.xxs),
      closeButtonBorderRadius:
          merged.closeButtonBorderRadius ?? _closeButtonBorderRadius,
      closeButtonBackgroundColor: resolveIconActionBackground(
        merged.closeButtonBackgroundColor,
        idle: const Color(0x00000000),
        hovered: colors.surfaceAlt,
      ),
      barrierColor:
          merged.barrierColor ??
          colors.text.withValues(alpha: dark ? 0.6 : 0.47),
      barrierBlurSigma: merged.barrierBlurSigma ?? 5,
    );
  }
}
