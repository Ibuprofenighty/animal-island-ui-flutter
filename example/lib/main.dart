import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  runApp(const AnimalIslandGalleryApp());
}

class AnimalIslandGalleryApp extends StatefulWidget {
  const AnimalIslandGalleryApp({super.key});

  @override
  State<AnimalIslandGalleryApp> createState() => _AnimalIslandGalleryAppState();
}

class _AnimalIslandGalleryAppState extends State<AnimalIslandGalleryApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final themeExtension = _isDarkMode ? AnimalIslandTheme.dark : AnimalIslandTheme.light;

    return MaterialApp(
      title: 'Animal Island UI Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: themeExtension.bg,
        canvasColor: themeExtension.bg,
        cardColor: themeExtension.bgContent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeExtension.primary,
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
          surface: themeExtension.bgContent,
        ),
        fontFamily: AnimalTypography.fontFamily,
        fontFamilyFallback: AnimalTypography.fontFamilyFallback,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: themeExtension.text),
          bodyMedium: TextStyle(color: themeExtension.textBody),
          bodySmall: TextStyle(color: themeExtension.textSecondary),
          titleLarge: TextStyle(color: themeExtension.text),
          titleMedium: TextStyle(color: themeExtension.text),
        ),
        extensions: [themeExtension],
      ),
      home: GalleryHomePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: () => setState(() => _isDarkMode = !_isDarkMode),
      ),
    );
  }
}

class GalleryHomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const GalleryHomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<GalleryHomePage> createState() => _GalleryHomePageState();
}

class _GalleryHomePageState extends State<GalleryHomePage> {
  final ScrollController _scrollController = ScrollController();
  int _selectedTab = 0;

  // Interactive Form State
  bool _switchVal = true;
  bool _checkboxVal = true;
  int _radioVal = 1;
  String? _selectVal = 'apple';
  bool _buttonLoading = false;
  String _inputText = '';
  DateTime? _selectedDate = DateTime.now();
  DateTimeRange? _selectedDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 4)),
  );
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 10, minute: 30);
  double _progressVal = 0.65;
  String _iconFilter = '';
  int _currentPage = 3;
  final AnimalFormController _formController = AnimalFormController();

  @override
  void dispose() {
    _scrollController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimalBackground(
        type: AnimalBackgroundType.dots,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 1. Hero Header Sliver
                SliverToBoxAdapter(
                  child: _buildHeroHeader(),
                ),

                // 2. Navigation Tabs
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: AnimalTabs(
                        selectedIndex: _selectedTab,
                        onChanged: (idx) => setState(() => _selectedTab = idx),
                        tabs: const [
                          AnimalTabItem(label: 'General', icon: LeafIcon(size: 16)),
                          AnimalTabItem(label: 'Forms', icon: EditIcon(size: 16)),
                          AnimalTabItem(label: 'Data', icon: CreditCardIcon(size: 16)),
                          AnimalTabItem(label: 'Overlays', icon: ChatIcon(size: 16)),
                          AnimalTabItem(label: '101 Icons', icon: HeartIcon(size: 16)),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Tab Section Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: _buildActiveSection(),
                      ),
                    ),
                  ),
                ),

                // 4. Footer
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 48.0),
                    child: AnimalFooter(),
                  ),
                ),
              ],
            ),

            // Back to top floating button
            Positioned(
              right: 24,
              bottom: 24,
              child: AnimalBackTop(scrollController: _scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AnimalTime(live: true),
              AnimalButton(
                type: AnimalButtonType.defaultButton,
                size: AnimalButtonSize.small,
                onPressed: widget.onToggleTheme,
                icon: widget.isDarkMode
                    ? const SunIcon(size: 16, color: AnimalColors.warning)
                    : MoonIcon(size: 16, color: AnimalIslandTheme.of(context).text),
                child: Text(widget.isDarkMode ? 'Parchment Mode' : 'Campfire Night'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const AnimalTitle(
            size: AnimalTitleSize.large,
            color: AnimalTileColor.appTeal,
            child: Text('Animal Island UI'),
          ),
          const SizedBox(height: 14),
          AnimalTypewriter(
            text: 'A Cozy, Kawaii Flutter Component Library Inspired by Animal Crossing 🏝️',
            speed: const Duration(milliseconds: 40),
            style: AnimalTypography.headingFor(context),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimalTag(
                variant: AnimalTagVariant.primary,
                icon: const LeafIcon(size: 14, color: AnimalColors.primary),
                child: const Text('36 Components'),
              ),
              const SizedBox(width: 8),
              AnimalTag(
                variant: AnimalTagVariant.success,
                icon: const HeartIcon(size: 14, color: AnimalColors.success),
                child: const Text('101 Cute Icons'),
              ),
              const SizedBox(width: 8),
              AnimalTag(
                variant: AnimalTagVariant.warning,
                icon: const BellIcon(size: 14, color: AnimalColors.warningActive),
                child: const Text('Zero Runtime Bloat'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const AnimalDivider(type: AnimalDividerType.dotted),
        ],
      ),
    );
  }

  Widget _buildActiveSection() {
    switch (_selectedTab) {
      case 0:
        return _buildGeneralSection();
      case 1:
        return _buildFormSection();
      case 2:
        return _buildDataSection();
      case 3:
        return _buildOverlaySection();
      case 4:
        return _buildIconsSection();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- TAB 0: GENERAL ---
  Widget _buildGeneralSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Buttons (Tactile 3D Depth & Spring Physics)'),
        AnimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Primary Buttons (Stacked 3D Sinking Shadow)', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AnimalButton(
                    type: AnimalButtonType.primary,
                    size: AnimalButtonSize.large,
                    icon: const RocketIcon(size: 20, color: Colors.white),
                    onPressed: () {},
                    child: const Text('Large Button'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.primary,
                    size: AnimalButtonSize.middle,
                    icon: const LeafIcon(size: 18, color: Colors.white),
                    onPressed: () {},
                    child: const Text('Middle Primary'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.primary,
                    size: AnimalButtonSize.small,
                    onPressed: () {},
                    child: const Text('Small Button'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Button Styles & States', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AnimalButton(
                    type: AnimalButtonType.defaultButton,
                    onPressed: () {},
                    child: const Text('Default Elevation'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.dashed,
                    onPressed: () {},
                    child: const Text('Dashed Button'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.primary,
                    ghost: true,
                    onPressed: () {},
                    child: const Text('Ghost Primary'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.primary,
                    ghost: true,
                    danger: true,
                    onPressed: () {},
                    child: const Text('Ghost Danger'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.danger,
                    icon: const CloseIcon(size: 18, color: Colors.white),
                    onPressed: () {},
                    child: const Text('Danger 3D'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.text,
                    onPressed: () {},
                    child: const Text('Text Button'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.link,
                    onPressed: () {},
                    child: const Text('Link Style'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.primary,
                    loading: _buttonLoading,
                    onPressed: () {
                      setState(() => _buttonLoading = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _buttonLoading = false);
                      });
                    },
                    child: const Text('Click to Load'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.primary,
                    disabled: true,
                    onPressed: () {},
                    child: const Text('Disabled'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Titles & Swallowtail Ribbons'),
        AnimalCard(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: const [
              AnimalTitle(
                size: AnimalTitleSize.small,
                color: AnimalTileColor.appPink,
                child: Text('Island News'),
              ),
              AnimalTitle(
                size: AnimalTitleSize.middle,
                color: AnimalTileColor.appTeal,
                child: Text('Resident Services'),
              ),
              AnimalTitle(
                size: AnimalTitleSize.large,
                color: AnimalTileColor.appYellow,
                child: Text('Nook\'s Cranny'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Dividers & Dashed Cards'),
        const AnimalCard(
          type: AnimalCardType.dashed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dashed 20px Card with Cozy Dividers',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              AnimalDivider.leaf(),
              SizedBox(height: 8),
              AnimalDivider(type: AnimalDividerType.wavy),
              SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Custom Animal Cursors (Tactile Overlays)'),
        AnimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hover over these interactive cards to experience cozy custom cursors:',
                style: AnimalTypography.subheadingFor(context),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  AnimalCursor(
                    type: AnimalCursorType.defaultCursor,
                    child: Container(
                      width: 170,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AnimalTileColor.appGreen.background.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AnimalColors.primary, width: 2),
                      ),
                      child: const Text('Cozy Finger Cursor', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  AnimalCursor(
                    type: AnimalCursorType.raindrop,
                    child: Container(
                      width: 170,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AnimalTileColor.appTeal.background.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AnimalTileColor.appTeal.background, width: 2),
                      ),
                      child: const Text('Raindrop Cursor', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  AnimalCursor(
                    type: AnimalCursorType.pointer,
                    child: Container(
                      width: 170,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AnimalTileColor.appYellow.background.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AnimalColors.warning, width: 2),
                      ),
                      child: const Text('Pointer Hand', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 1: FORMS ---
  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Inputs & Reactive Form Engine'),
        AnimalCard(
          child: AnimalForm(
            controller: _formController,
            onSubmit: () {
              AnimalNotification.success(
                context,
                message: 'Passport Validated & Registered!',
                description: 'Form submitted successfully with values: ${_formController.values}',
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimalFormItem(
                  name: 'islandName',
                  label: 'Island Name',
                  initialValue: '',
                  required: true,
                  rules: [
                    AnimalRule.required(message: 'Island name is required'),
                    AnimalRule.min(3, message: 'Must be at least 3 characters'),
                  ],
                  helperText: _inputText.isEmpty ? 'Must be a cozy island name!' : 'Welcome to $_inputText!',
                  child: AnimalInput(
                    placeholder: 'e.g. Horizon Isle',
                    prefix: const LeafIcon(size: 18, color: AnimalColors.primary),
                    clearable: true,
                    shadow: true,
                    onChanged: (val) => setState(() => _inputText = val),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AnimalFormItem(
                        name: 'residentEmail',
                        label: 'Resident Email',
                        required: true,
                        rules: [
                          AnimalRule.required(message: 'Email is required'),
                          AnimalRule.email(message: 'Enter a valid email address'),
                        ],
                        child: const AnimalInput(
                          placeholder: 'villager@animalisland.ui',
                          prefix: Icon(Icons.email_outlined, size: 18, color: AnimalColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimalFormItem(
                        name: 'warningStatus',
                        label: 'Warning Status',
                        child: AnimalInput(
                          initialValue: 'Approaching Storm',
                          status: AnimalInputStatus.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimalFormItem(
                  name: 'nativeFruit',
                  label: 'Native Island Fruit',
                  initialValue: 'apple',
                  child: AnimalSelect<String>(
                    value: _selectVal,
                    options: const [
                      AnimalSelectOption(value: 'apple', label: 'Sweet Apple', icon: AppleIcon(size: 18)),
                      AnimalSelectOption(value: 'cherry', label: 'Cherry', icon: CherryIcon(size: 18)),
                      AnimalSelectOption(value: 'strawberry', label: 'Wild Strawberry', icon: StrawberryIcon(size: 18)),
                      AnimalSelectOption(value: 'lemon', label: 'Sun Lemon', icon: LemonIcon(size: 18)),
                    ],
                    onChanged: (val) => setState(() => _selectVal = val),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AnimalFormItem(
                        name: 'airportOpen',
                        label: 'Airport Gates',
                        initialValue: true,
                        child: Row(
                          children: [
                            AnimalSwitch(
                              value: _switchVal,
                              onChanged: (val) => setState(() => _switchVal = val),
                            ),
                            const SizedBox(width: 8),
                            Text(_switchVal ? 'Open' : 'Closed', style: AnimalTypography.bodyFor(context)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: AnimalFormItem(
                        name: 'concertEnabled',
                        label: 'Special Events',
                        initialValue: true,
                        child: AnimalCheckbox(
                          value: _checkboxVal,
                          label: const Text('Enable KK Slider Concert'),
                          onChanged: (val) => setState(() => _checkboxVal = val),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimalFormItem(
                  name: 'hemisphere',
                  label: 'Island Hemisphere',
                  initialValue: 1,
                  child: AnimalRadioGroup<int>(
                    value: _radioVal,
                    onChanged: (val) => setState(() => _radioVal = val),
                    options: const [
                      AnimalOption(value: 1, label: 'Northern Hemisphere'),
                      AnimalOption(value: 2, label: 'Southern Hemisphere'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    AnimalButton(
                      type: AnimalButtonType.primary,
                      size: AnimalButtonSize.middle,
                      onPressed: () => _formController.submit(),
                      child: const Text('Submit Passport'),
                    ),
                    const SizedBox(width: 12),
                    AnimalButton(
                      type: AnimalButtonType.defaultButton,
                      size: AnimalButtonSize.middle,
                      onPressed: () {
                        _formController.resetFields();
                        setState(() {
                          _inputText = '';
                          _selectVal = 'apple';
                          _switchVal = true;
                          _checkboxVal = true;
                          _radioVal = 1;
                        });
                      },
                      child: const Text('Reset Form'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Date & Time Pickers (Continuous Ribbon & 3-Column Scroll)'),
        AnimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Single Date & Range Picker', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  AnimalDatePicker(
                    value: _selectedDate,
                    onChanged: (d) => setState(() => _selectedDate = d),
                  ),
                  AnimalDatePicker(
                    range: true,
                    rangeValue: _selectedDateRange,
                    onRangeChanged: (r) => setState(() => _selectedDateRange = r),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('3-Column Smooth Wheel Time Picker', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  AnimalTimePicker(
                    value: _selectedTime,
                    format: 'HH:mm:ss',
                    onChanged: (t) => setState(() => _selectedTime = t),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: DATA DISPLAY ---
  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('13 Island App-Tile Color Cards'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AnimalTileColor.values.map((tile) {
            return SizedBox(
              width: 190,
              child: AnimalCard(
                color: tile,
                onTap: () {
                  AnimalNotification.success(
                    context,
                    message: 'Tile Selected',
                    description: 'Tapped ${tile.name} island card!',
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tile.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const StarIcon(size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap to lift 2px', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Candy-Cane Progress & Aesthetics'),
        AnimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('45° Barber-Pole Animated Progress', style: AnimalTypography.subheadingFor(context)),
                  Row(
                    children: [
                      IconButton(
                        icon: const RefreshIcon(size: 16),
                        onPressed: () => setState(() => _progressVal = (_progressVal - 0.1).clamp(0.0, 1.0)),
                      ),
                      IconButton(
                        icon: const PlusIcon(size: 16),
                        onPressed: () => setState(() => _progressVal = (_progressVal + 0.1).clamp(0.0, 1.0)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimalProgress(
                percent: _progressVal,
                size: AnimalProgressSize.large,
                infoPosition: AnimalProgressInfoPosition.inside,
              ),
              const SizedBox(height: 12),
              AnimalProgress(
                percent: _progressVal,
                size: AnimalProgressSize.middle,
                infoPosition: AnimalProgressInfoPosition.right,
              ),
              const SizedBox(height: 12),
              AnimalProgress(
                percent: _progressVal,
                size: AnimalProgressSize.small,
                infoPosition: AnimalProgressInfoPosition.none,
              ),
              const SizedBox(height: 24),
              Text('Island Loading Indicators', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 32,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AnimalLoading.spinner(tip: 'Rotating Leaf'),
                  AnimalLoading.dots(tip: 'Bouncing Dots'),
                  AnimalLoading.snowflake(tip: 'Falling Snow'),
                ],
              ),
              const SizedBox(height: 24),
              Text('Warm Shimmer Skeleton Placeholders', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimalSkeleton.avatar(size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimalSkeleton.paragraph(rows: 2),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Turnip Market Closing Countdown (Real-Time)', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              Center(
                child: AnimalCountdown(
                  targetTime: DateTime.now().add(const Duration(hours: 14, minutes: 28, seconds: 45)),
                  variant: AnimalCountdownVariant.island,
                ),
              ),
              const SizedBox(height: 24),
              Text('CodeBlock with One-Click Copy', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              const AnimalCodeBlock(
                language: 'dart',
                code: 'import \'package:animal_island_ui/animal_island_ui.dart\';\n\nAnimalButton(\n  type: AnimalButtonType.primary,\n  onPressed: () => print("Cozy!"),\n  child: Text("Say Hello"),\n);',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Accordion Collapse & Tables'),
        AnimalCard(
          child: Column(
            children: [
              AnimalCollapse(
                accordion: true,
                items: const [
                  AnimalCollapseItem(
                    title: Text('How do I invite island villagers?'),
                    content: Text('Use Nook Miles Tickets to travel to mystery islands or build a campsite on your island!'),
                    isExpanded: true,
                  ),
                  AnimalCollapseItem(
                    title: Text('When does K.K. Slider visit?'),
                    content: Text('Once your island reaches a 3-star rating, K.K. Slider performs every Saturday evening in front of Resident Services.'),
                  ),
                  AnimalCollapseItem(
                    title: Text('How does the Turnip market work?'),
                    content: Text('Buy white turnips on Sunday mornings from Daisy Mae, then sell them to Timmy & Tommy before next Sunday!'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimalTable(
                columns: const [
                  AnimalTableColumn(title: 'Villager', width: 140),
                  AnimalTableColumn(title: 'Personality'),
                  AnimalTableColumn(title: 'Catchphrase', width: 140),
                ],
                rows: const [
                  [Text('Marshal'), Text('Smug'), Text('sulky')],
                  [Text('Raymond'), Text('Smug'), Text('crisp')],
                  [Text('Sherb'), Text('Lazy'), Text('bawrrr')],
                  [Text('Audie'), Text('Peppy'), Text('foxtrot')],
                ],
              ),
              const SizedBox(height: 20),
              Text('Windowed Sinking 3D Pagination', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              AnimalPagination(
                current: _currentPage,
                total: 500,
                pageSize: 10,
                onChanged: (page) => setState(() => _currentPage = page),
              ),
              const SizedBox(height: 12),
              Text('Compact / Mobile Mode Pagination', style: AnimalTypography.captionFor(context)),
              const SizedBox(height: 8),
              AnimalPagination(
                current: _currentPage,
                total: 500,
                pageSize: 10,
                simple: true,
                onChanged: (page) => setState(() => _currentPage = page),
              ),
              const SizedBox(height: 24),
              Text('13 Island Palette Tags & 3 Sizes', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AnimalTag(color: AnimalTileColor.appPink, size: AnimalTagSize.small, child: const Text('Small Pink')),
                  AnimalTag(color: AnimalTileColor.appTeal, size: AnimalTagSize.middle, child: const Text('Middle Teal')),
                  AnimalTag(color: AnimalTileColor.appYellow, size: AnimalTagSize.large, child: const Text('Large Yellow')),
                  AnimalTag(color: AnimalTileColor.appGreen, icon: const LeafIcon(size: 14), child: const Text('Matcha')),
                  AnimalTag(color: AnimalTileColor.purple, icon: const StarIcon(size: 14), child: const Text('Lavender')),
                  AnimalTag(color: AnimalTileColor.brown, child: const Text('Coffee')),
                  AnimalTag(variant: AnimalTagVariant.error, child: const Text('Closable Error'), onClose: () {}),
                  const AnimalTag(variant: AnimalTagVariant.neutral, disabled: true, child: Text('Disabled')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Swipeable Carousel & Slideshow'),
        AnimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Interactive Slide Viewport with AutoPlay & Cozy Dot Indicators', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              AnimalCarousel(
                height: 160,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                items: [
                  Container(
                    decoration: BoxDecoration(
                      color: AnimalTileColor.appGreen.background.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AnimalColors.primary, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LeafIcon(size: 32, color: AnimalColors.primary),
                        SizedBox(width: 12),
                        Text('Slide 1: Island Morning Breeze', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AnimalTileColor.appYellow.background.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AnimalColors.warning, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SunIcon(size: 32, color: AnimalColors.warning),
                        SizedBox(width: 12),
                        Text('Slide 2: Noon Turnip Prices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AnimalTileColor.appPink.background.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AnimalColors.error, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HeartIcon(size: 32, color: AnimalColors.error),
                        SizedBox(width: 12),
                        Text('Slide 3: Cozy Campfire Night', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Picture Frames & Lightbox (AnimalImage)'),
        AnimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cozy Image Frames (Tap to open full-screen Lightbox preview)', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  AnimalImage(
                    image: const NetworkImage('https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=400'),
                    width: 160,
                    height: 120,
                    variant: AnimalImageVariant.standard,
                    preview: true,
                    fallback: Container(
                      width: 160,
                      height: 120,
                      color: AnimalTileColor.appGreen.background.withValues(alpha: 0.3),
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LeafIcon(size: 28, color: AnimalColors.primary),
                          SizedBox(height: 4),
                          Text('Standard Frame', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  AnimalImage(
                    image: const NetworkImage('https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=400'),
                    width: 160,
                    height: 120,
                    variant: AnimalImageVariant.bordered,
                    color: AnimalTileColor.appTeal,
                    preview: true,
                    fallback: Container(
                      width: 160,
                      height: 120,
                      color: AnimalTileColor.appTeal.background.withValues(alpha: 0.3),
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FishIcon(size: 28, color: AnimalColors.primaryActive),
                          SizedBox(height: 4),
                          Text('Bordered Frame', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 3: OVERLAYS ---
  Widget _buildOverlaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Organic Blob Modal Dialog'),
        AnimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hard Rule 9: Modal strictly uses the SVG blob clip path with normalized cubic-beziers. It opens with an easeOutBack spring expansion!',
                style: AnimalTypography.body,
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    AnimalButton(
                      type: AnimalButtonType.primary,
                      size: AnimalButtonSize.large,
                      icon: const ChatIcon(size: 20, color: Colors.white),
                      onPressed: () {
                        AnimalModal.show(
                          context: context,
                          title: const Row(
                            children: [
                              LeafIcon(size: 20, color: AnimalColors.primary),
                              SizedBox(width: 8),
                              Text('Tom Nook Says...'),
                            ],
                          ),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yes, yes! Welcome to your desert island getaway package! Your dream home is ready, and your mortgage is only 98,000 Bells! No rush on repayment, hm?',
                                style: AnimalTypography.body,
                              ),
                            ],
                          ),
                          okText: 'Pay Mortgage',
                          cancelText: 'Maybe Later',
                          onOk: () {
                            AnimalNotification.success(
                              context,
                              message: 'Payment Accepted',
                              description: 'Tom Nook happily received your Bells!',
                            );
                          },
                        );
                      },
                      child: const Text('Open Organic Blob Modal'),
                    ),
                    AnimalButton(
                      type: AnimalButtonType.defaultButton,
                      size: AnimalButtonSize.large,
                      icon: const LeafIcon(size: 20, color: AnimalColors.primary),
                      onPressed: () {
                        AnimalModal.showDialogue(
                          context: context,
                          title: const Text('Isabelle Morning Announcement'),
                          message: 'Good morning everyone! Today is a wonderful sunny day on our cozy island. Let\'s make the most of it and enjoy the island breeze!',
                        );
                      },
                      child: const Text('Open Typewriter Dialogue'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Global Full-Screen Loading'),
        AnimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Snowflake Particles Global Overlay', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              AnimalButton(
                type: AnimalButtonType.primary,
                icon: const SnowflakeIcon(size: 18, color: Colors.white),
                onPressed: () {
                  AnimalLoading.show(
                    context,
                    type: AnimalLoadingType.snowflake,
                    tip: 'Drifting across the snowy island...',
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    AnimalLoading.hide();
                  });
                },
                child: const Text('Trigger Full-Screen Snowflake Loader (2s)'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Side Drawer, Tooltips & Toast Notifications'),
        AnimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('4-Direction Drawer Placements', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AnimalButton(
                    type: AnimalButtonType.defaultButton,
                    onPressed: () {
                      AnimalDrawer.show(
                        context: context,
                        title: const Text('Island Inventory (Right)'),
                        placement: AnimalDrawerPlacement.right,
                        child: ListView(
                          children: const [
                            ListTile(leading: AppleIcon(size: 24), title: Text('10x Apple')),
                            ListTile(leading: MushroomIcon(size: 24), title: Text('3x Rare Mushroom')),
                            ListTile(leading: BellIcon(size: 24), title: Text('150,000 Bells Bag')),
                            ListTile(leading: FishIcon(size: 24), title: Text('1x Sea Bass (At least a C+!)')),
                          ],
                        ),
                      );
                    },
                    child: const Text('Right Drawer'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.defaultButton,
                    onPressed: () {
                      AnimalDrawer.show(
                        context: context,
                        title: const Text('Island Tools (Bottom)'),
                        placement: AnimalDrawerPlacement.bottom,
                        height: 280,
                        child: const Center(child: Text('Slingshot • Net • Fishing Rod • Shovel')),
                      );
                    },
                    child: const Text('Bottom Drawer'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Overlay Toast Notifications (6 Screen Placements)', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AnimalButton(
                    type: AnimalButtonType.primary,
                    onPressed: () {
                      AnimalNotification.success(
                        context,
                        placement: AnimalNotificationPlacement.topRight,
                        message: 'DIY Recipe Learned!',
                        description: 'Golden Slingshot added to your crafting app.',
                      );
                    },
                    child: const Text('Top-Right Success'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.defaultButton,
                    onPressed: () {
                      AnimalNotification.info(
                        context,
                        placement: AnimalNotificationPlacement.top,
                        message: 'Message in a Bottle',
                        description: 'Washed up on the southern shore!',
                      );
                    },
                    child: const Text('Top-Center Info'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.danger,
                    onPressed: () {
                      AnimalNotification.error(
                        context,
                        placement: AnimalNotificationPlacement.bottomRight,
                        message: 'Wasp Nest Shaken Down!',
                        description: 'Ouch! Quick, catch them or apply medicine!',
                      );
                    },
                    child: const Text('Bottom-Right Error'),
                  ),
                  AnimalButton(
                    type: AnimalButtonType.text,
                    onPressed: () => AnimalNotification.destroy(),
                    child: const Text('Dismiss All Toasts'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Cozy Speech Bubble Tooltips', style: AnimalTypography.subheadingFor(context)),
              const SizedBox(height: 12),
              AnimalTooltip(
                message: 'This is a 16px radius speech bubble!',
                variant: AnimalTooltipVariant.island,
                child: AnimalButton(
                  type: AnimalButtonType.defaultButton,
                  onPressed: () {},
                  child: const Text('Hover / Tap for Island Tooltip'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 4: 101 CUTE ICONS BROWSER ---
  Widget _buildIconsSection() {
    final filteredList = animalIconList.where((item) {
      if (_iconFilter.isEmpty) return true;
      return item.label.toLowerCase().contains(_iconFilter.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('101 Kawaii Animal Island Vector Icons'),
        AnimalCard(
          child: Column(
            children: [
              AnimalInput(
                placeholder: 'Search 101 icons (e.g. leaf, apple, bell, heart)...',
                prefix: const SearchIcon(size: 18, color: AnimalColors.textSecondary),
                clearable: true,
                onChanged: (val) => setState(() => _iconFilter = val),
              ),
              const SizedBox(height: 16),
              Text(
                'Showing ${filteredList.length} of 101 icons. Tap any icon to see its Q-elastic bounce animation!',
                style: AnimalTypography.captionFor(context),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 110,
                  mainAxisExtent: 94,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final theme = AnimalIslandTheme.of(context);
                  final item = filteredList[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.bgInput,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: theme.isDark
                            ? theme.border.withValues(alpha: 0.5)
                            : AnimalColors.borderLight.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimalIcon(
                          name: item.name,
                          size: 36,
                          bounce: true,
                          onTap: () {
                            AnimalNotification.info(
                              context,
                              message: '${item.label}Icon',
                              description: 'import { ${item.label}Icon } from \'package:animal_island_ui/animal_island_ui.dart\';',
                              duration: const Duration(seconds: 2),
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AnimalTypography.captionFor(context).copyWith(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = AnimalIslandTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          LeafIcon(size: 18, color: theme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AnimalTypography.headingFor(context).copyWith(fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }
}
