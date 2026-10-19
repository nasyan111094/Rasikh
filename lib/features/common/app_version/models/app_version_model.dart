// ─────────────────────────────────────────────────────────────────────────────
// features/common/app_version/models/app_version_model.dart
//
// GET /api/app-version/check?appType=android|ios&version=X.Y.Z
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:rasikh/config/app_config.dart';

/// Mirrors the API `updateType`: NONE | OPTIONAL | FORCE.
enum AppUpdateType {
  none,
  optional,
  force;

  static AppUpdateType fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'FORCE':
        return AppUpdateType.force;
      case 'OPTIONAL':
        return AppUpdateType.optional;
      case 'NONE':
      default:
        return AppUpdateType.none;
    }
  }
}

class AppVersionCheck {
  /// Raw flag from the API (note: OPTIONAL responses come with false).
  final bool updateRequired;
  final AppUpdateType updateType;
  final String? minimumVersion;
  final String? latestVersion;
  final String? title;
  final String? message;
  final String? storeUrl;

  const AppVersionCheck({
    required this.updateRequired,
    required this.updateType,
    this.minimumVersion,
    this.latestVersion,
    this.title,
    this.message,
    this.storeUrl,
  });

  /// Accepts both the bare object and the wrapped {success,data,meta} shape.
  factory AppVersionCheck.fromJson(dynamic json) {
    Map<String, dynamic> data;
    if (json is Map<String, dynamic> && json['data'] is Map) {
      data = Map<String, dynamic>.from(json['data'] as Map);
    } else if (json is Map) {
      data = Map<String, dynamic>.from(json);
    } else {
      data = {};
    }

    return AppVersionCheck(
      updateRequired: data['updateRequired'] == true,
      updateType: AppUpdateType.fromString(data['updateType']?.toString()),
      minimumVersion: data['minimumVersion']?.toString(),
      latestVersion: data['latestVersion']?.toString(),
      title: data['title']?.toString(),
      message: data['message']?.toString(),
      storeUrl: data['storeUrl']?.toString(),
    );
  }

  /// FORCE blocks the app; OPTIONAL only suggests.
  /// Decision keys on [updateType] (OPTIONAL arrives with updateRequired=false).
  bool get isForceUpdate =>
      updateType == AppUpdateType.force || updateRequired;

  bool get isOptionalUpdate =>
      !isForceUpdate && updateType == AppUpdateType.optional;

  bool get hasUpdate => isForceUpdate || isOptionalUpdate;

  /// Store destination decided by the current OS:
  /// iOS → App Store, anything else → Google Play.
  String get effectiveStoreUrl {
    if (Platform.isIOS) return AppConfig.appleStoreUrl;
    return AppConfig.googlePlayUrl;
  }
}
