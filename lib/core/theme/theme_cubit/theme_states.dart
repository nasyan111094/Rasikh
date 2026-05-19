import 'package:flutter/material.dart';

@immutable
sealed class AppStates {}

class AppInitState extends AppStates {}

class ThemeChangeToDarkState extends AppStates {}

class ThemeChangeToLightState extends AppStates {}

class ThemeChangeToSystemState extends AppStates {}

class ReRenderState extends AppStates {}
