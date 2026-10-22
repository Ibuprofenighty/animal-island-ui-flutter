import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

ThemeData galleryTheme() => IslandTheme.create(fontFamily: 'Nunito').copyWith(
  textTheme: IslandTheme.create(fontFamily: 'Nunito').textTheme
      .merge(
        const TextTheme(
          displayLarge: TextStyle(letterSpacing: 0),
          displayMedium: TextStyle(letterSpacing: 0),
          displaySmall: TextStyle(letterSpacing: 0),
          headlineLarge: TextStyle(letterSpacing: 0),
          headlineMedium: TextStyle(letterSpacing: 0),
          headlineSmall: TextStyle(letterSpacing: 0),
          titleLarge: TextStyle(letterSpacing: 0),
          titleMedium: TextStyle(letterSpacing: 0),
          titleSmall: TextStyle(letterSpacing: 0),
          bodyLarge: TextStyle(letterSpacing: 0),
          bodyMedium: TextStyle(letterSpacing: 0),
          bodySmall: TextStyle(letterSpacing: 0),
          labelLarge: TextStyle(letterSpacing: 0),
          labelMedium: TextStyle(letterSpacing: 0),
          labelSmall: TextStyle(letterSpacing: 0),
        ),
      )
      .apply(fontFamilyFallback: const ['IslandGallerySans']),
);
