import 'package:flutter/material.dart';
import 'editorial_colors.dart';
import 'editorial_typography.dart';

enum AppThemeMode { light, dark, system }

class AppThemeController extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.dark;
  EditorialColors _currentColors = EditorialColors.dark();
  EditorialColors _targetColors = EditorialColors.dark();
  EditorialColors _fromColors = EditorialColors.dark();

  AnimationController? _animController;
  Animation<double>? _curvedAnimation;

  AppThemeMode get mode => _mode;
  EditorialColors get colors => _currentColors;
  EditorialTypography get typography =>
      EditorialTypography.fromColors(_currentColors);

  void attachTicker(TickerProvider vsync) {
    _animController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 350),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeInOutCubic,
    );
    _animController!.addListener(() {
      _currentColors = EditorialColors.lerp(
        _fromColors,
        _targetColors,
        _curvedAnimation!.value,
      );
      notifyListeners();
    });
  }

  void setThemeMode(AppThemeMode newMode, [Brightness? systemBrightness]) {
    if (_mode == newMode) return;
    _mode = newMode;

    bool targetDark;
    switch (newMode) {
      case AppThemeMode.light:
        targetDark = false;
        break;
      case AppThemeMode.dark:
        targetDark = true;
        break;
      case AppThemeMode.system:
        targetDark = (systemBrightness ?? Brightness.light) == Brightness.dark;
        break;
    }

    _fromColors = _currentColors;
    _targetColors = targetDark
        ? EditorialColors.dark()
        : EditorialColors.light();

    if (_animController != null) {
      _animController!.forward(from: 0.0);
    } else {
      _currentColors = _targetColors;
      notifyListeners();
    }
  }

  EditorialColors colorsOf(BuildContext context) => _currentColors;
  EditorialTypography typographyOf(BuildContext context) => typography;

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }
}

class EditorialThemeScope extends InheritedNotifier<AppThemeController> {
  const EditorialThemeScope({
    required AppThemeController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppThemeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<EditorialThemeScope>();
    assert(scope != null, 'No EditorialThemeScope found in context');
    return scope!.notifier!;
  }
}

/// Syntactic sugar extensions on BuildContext
extension EditorialThemeContextExtension on BuildContext {
  AppThemeController get editorialTheme => EditorialThemeScope.of(this);

  EditorialColors get editorialColors => editorialTheme.colorsOf(this);

  EditorialTypography get editorialTypography =>
      editorialTheme.typographyOf(this);
}
