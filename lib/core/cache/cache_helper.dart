// ─────────────────────────────────────────────────────────────────────────────
// cache_helper.dart
//
// Enterprise-grade cache manager built for:
// • GetIt Dependency Injection
// • SharedPreferences
// • FlutterSecureStorage
// • Session restoration
// • TTL cache expiration
// • Strong logging
// • Production-ready architecture
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/core/cache/pref_keys.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cache Exception
// ─────────────────────────────────────────────────────────────────────────────

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

// ─────────────────────────────────────────────────────────────────────────────
// Cache Entry
// Used for TTL cache support
// ─────────────────────────────────────────────────────────────────────────────

class CacheEntry {
  const CacheEntry(
      this.value, {
        this.expiry,
      });

  final String value;
  final DateTime? expiry;

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'expiry': expiry?.toIso8601String(),
    };
  }

  static CacheEntry? fromJson(String json) {
    if (!json.trimLeft().startsWith('{')) {
      return null;
    }

    try {
      final map = jsonDecode(json);

      if (map is! Map<String, dynamic>) {
        return null;
      }

      if (!map.containsKey('value')) {
        return null;
      }

      return CacheEntry(
        map['value'] as String,
        expiry: map['expiry'] != null
            ? DateTime.tryParse(map['expiry'])
            : null,
      );
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cache Helper
// ─────────────────────────────────────────────────────────────────────────────

class CacheHelper {
  CacheHelper();

  // ─────────────────────────────────────────────────────────────────────────
  // Internals
  // ─────────────────────────────────────────────────────────────────────────

  late SharedPreferences _prefs;

  final FlutterSecureStorage _secureStorage =
  const FlutterSecureStorage();

  final Logger _logger = Logger();

  bool _isInitialized = false;

  bool _isInitializing = false;

  // ─────────────────────────────────────────────────────────────────────────
  // In-memory state
  // ─────────────────────────────────────────────────────────────────────────

  bool? isDarkTheme;

  bool onBoardingDone = false;

  String? currentToken;
  String? registerToken;

  UserProfileData? currentUser;


  VendorType ? cachedVendorType ;

  // ─────────────────────────────────────────────────────────────────────────
  // Init
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;

    if (_isInitializing) {
      var waited = 0;

      while (_isInitializing && waited < 5000) {
        await Future.delayed(
          const Duration(milliseconds: 20),
        );

        waited += 20;
      }

      if (_isInitializing) {
        throw const CacheException(
          'CacheHelper initialization timeout',
        );
      }

      return;
    }

    _isInitializing = true;

    try {
      _setupLogging();

      _logger.i('Initializing CacheHelper...');

      _prefs = await SharedPreferences.getInstance();

      // ─────────────────────────────────────────────────────────────────────
      // Restore onboarding
      // ─────────────────────────────────────────────────────────────────────

      onBoardingDone =
          _prefs.getBool(PrefKeys.onBoardingDone) ?? false;

      // ─────────────────────────────────────────────────────────────────────
      // Restore theme
      // ─────────────────────────────────────────────────────────────────────

      isDarkTheme =
          _prefs.getBool(PrefKeys.kIsDarkTheme);

      // ─────────────────────────────────────────────────────────────────────
      // Restore token
      // ─────────────────────────────────────────────────────────────────────

      currentToken = await _readSecureDirect(
        PrefKeys.userToken,
      );

      // ─────────────────────────────────────────────────────────────────────
      // Restore current user
      // ─────────────────────────────────────────────────────────────────────

      currentUser = await _readCachedUserDirect();

      // ─────────────────────────────────────────────────────────────────────
      // Restore cached vendor type
      // ─────────────────────────────────────────────────────────────────────

      try {
        final rawVendorType = _prefs.getString(PrefKeys.cachedVendorType);
        if (rawVendorType != null && rawVendorType.isNotEmpty) {
          // Try to parse as CacheEntry first (backward compatibility)
          final entry = CacheEntry.fromJson(rawVendorType);
          if (entry != null) {
            // Valid CacheEntry format
            cachedVendorType = VendorType.values.byName(entry.value);
          } else {
            // Legacy format - treat as plain string
            cachedVendorType = VendorType.values.byName(rawVendorType);
          }
        }
      } catch (e) {
        _logger.w('Failed to restore cached vendor type: $e');
        cachedVendorType = null;
      }

      // ─────────────────────────────────────────────────────────────────────
      // Cleanup expired cache
      // ─────────────────────────────────────────────────────────────────────

      await _cleanExpiredEntries();

      _isInitialized = true;

      _logger.i('CacheHelper initialized successfully');
    } catch (e, st) {
      _logger.e(
        'Failed to initialize CacheHelper',
        error: e,
        stackTrace: st,
      );

      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Ensure Initialized
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Save Data
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> saveData({
    required String key,
    required String value,
    bool isSensitive = false,
    int? expirySeconds,
  }) async {
    await _ensureInitialized();

    try {
      // ─────────────────────────────────────────────────────────────────────
      // Secure Storage
      // ─────────────────────────────────────────────────────────────────────

      if (isSensitive) {
        await _secureStorage.write(
          key: key,
          value: value,
          iOptions: _getIOSOptions(),
          aOptions: _getAndroidOptions(),
        );

        if (key == PrefKeys.userToken) {
          currentToken = value;
        }

        _logger.i('Sensitive key saved: $key');

        return true;
      }

      // ─────────────────────────────────────────────────────────────────────
      // SharedPreferences
      // ─────────────────────────────────────────────────────────────────────

      final entry = CacheEntry(
        value,
        expiry: expirySeconds != null
            ? DateTime.now().add(
          Duration(seconds: expirySeconds),
        )
            : null,
      );

      final encoded = jsonEncode(
        entry.toJson(),
      );

      final success = await _prefs.setString(
        key,
        encoded,
      );

      if (success) {
        _logger.i('Key saved: $key');
      }

      return success;
    } catch (e, st) {
      _logger.e(
        'Failed to save key: $key',
        error: e,
        stackTrace: st,
      );

      throw CacheException(
        'Failed to save key: $key',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Get Data
  // ─────────────────────────────────────────────────────────────────────────

  Future<String?> getData(
      String key, {
        bool isSensitive = false,
      }) async {
    await _ensureInitialized();

    try {
      // ─────────────────────────────────────────────────────────────────────
      // Secure Storage
      // ─────────────────────────────────────────────────────────────────────

      if (isSensitive) {
        return await _secureStorage.read(
          key: key,
          iOptions: _getIOSOptions(),
          aOptions: _getAndroidOptions(),
        );
      }

      // ─────────────────────────────────────────────────────────────────────
      // SharedPreferences
      // ─────────────────────────────────────────────────────────────────────

      final raw = _prefs.getString(key);

      if (raw == null) {
        return null;
      }

      final entry = CacheEntry.fromJson(raw);

      // Legacy value support
      if (entry == null) {
        return raw;
      }

      // Expired
      if (entry.expiry != null &&
          entry.expiry!.isBefore(DateTime.now())) {
        await removeData(key);

        return null;
      }

      return entry.value;
    } catch (e, st) {
      _logger.e(
        'Failed to read key: $key',
        error: e,
        stackTrace: st,
      );

      throw CacheException(
        'Failed to read key: $key',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Remove Data
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> removeData(
      String key, {
        bool isSensitive = false,
      }) async {
    await _ensureInitialized();

    try {
      if (isSensitive) {
        await _secureStorage.delete(
          key: key,
          iOptions: _getIOSOptions(),
          aOptions: _getAndroidOptions(),
        );

        if (key == PrefKeys.userToken) {
          currentToken = null;
        }

        _logger.i('Sensitive key removed: $key');

        return true;
      }

      final success = await _prefs.remove(key);

      _logger.i('Key removed: $key');

      return success;
    } catch (e, st) {
      _logger.e(
        'Failed to remove key: $key',
        error: e,
        stackTrace: st,
      );

      throw CacheException(
        'Failed to remove key: $key',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Has Key
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> hasKey(
      String key, {
        bool isSensitive = false,
      }) async {
    await _ensureInitialized();

    try {
      if (isSensitive) {
        final all = await _secureStorage.readAll(
          iOptions: _getIOSOptions(),
          aOptions: _getAndroidOptions(),
        );

        return all.containsKey(key);
      }

      return _prefs.containsKey(key);
    } catch (e) {
      throw CacheException(
        'Failed to check key: $key',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Clear All
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> clearAll({
    bool includeSensitive = false,
  }) async {
    await _ensureInitialized();

    try {
      final success = await _prefs.clear();

      if (includeSensitive) {
        await _secureStorage.deleteAll(
          iOptions: _getIOSOptions(),
          aOptions: _getAndroidOptions(),
        );

        currentToken = null;

        currentUser = null;
      }

      _logger.i('Cache cleared');

      return success;
    } catch (e, st) {
      _logger.e(
        'Failed to clear cache',
        error: e,
        stackTrace: st,
      );

      throw CacheException(
        'Failed to clear cache',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // User
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> setCurrentUser(
      UserProfileData? user,
      ) async {
    await _ensureInitialized();

    currentUser = user;

    try {
      if (user == null) {
        await removeData(
          PrefKeys.currentUser,
          isSensitive: true,
        );

        return;
      }

      await saveData(
        key: PrefKeys.currentUser,
        value: jsonEncode(
          user.toJson(),
        ),
        isSensitive: true,
      );

      await setOnBoardingDone(true);

      _logger.i('Current user cached');
    } catch (_) {
      rethrow;
    }
  }



  Future<void> setCurrentVendorType(
      VendorType? vendorType,
      ) async {
    await _ensureInitialized();

    cachedVendorType = vendorType;

    try {
      if (vendorType == null) {
        await removeData(
          PrefKeys.cachedVendorType,
        );
        return;
      }

      await saveData(
        key: PrefKeys.cachedVendorType,
        value: vendorType.name,
      );


      _logger.i('Current Vendor Type cached');
    } catch (_) {
      rethrow;
    }
  }







  Future<UserProfileData?> getCachedUser() async {
    await _ensureInitialized();

    currentUser = await _readCachedUserDirect();

    return currentUser;
  }




  Future<VendorType?> getCachedVendorType() async {
    await _ensureInitialized();

    try {
      final vendorTypeStr = getData(PrefKeys.cachedVendorType);
      if (vendorTypeStr == null ) {
        return cachedVendorType;
      }
      cachedVendorType = VendorType.values.byName(vendorTypeStr as String);
    } catch (e) {
      _logger.w('Failed to get cached vendor type: $e');
    }

    return cachedVendorType;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tokens
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> setUserToken(
      String token,
      ) async {
    currentToken = token;

    await saveData(
      key: PrefKeys.userToken,
      value: token,
      isSensitive: true,
    );
  }

  Future<String?> getUserToken() async {
    await _ensureInitialized();

    return await _readSecureDirect(
      PrefKeys.userToken,
    );
  }

  Future<void> setRefreshToken(
      String token,
      ) async {
    await saveData(
      key: PrefKeys.refreshToken,
      value: token,
      isSensitive: true,
    );
  }

  Future<String?> getRefreshToken() async {
    return await _readSecureDirect(
      PrefKeys.refreshToken,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Session
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> clearUserSession() async {
    await _ensureInitialized();

    currentToken = null;

    currentUser = null;

    await removeData(
      PrefKeys.userToken,
      isSensitive: true,
    );

    await removeData(
      PrefKeys.refreshToken,
      isSensitive: true,
    );

    await removeData(
      PrefKeys.currentUser,
      isSensitive: true,
    );

    _logger.i('User session cleared');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Onboarding
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> setOnBoardingDone(
      bool value,
      ) async {
    await _ensureInitialized();

    onBoardingDone = value;

    await _prefs.setBool(
      PrefKeys.onBoardingDone,
      value,
    );
  }

  Future<bool> getOnBoardingDone() async {
    await _ensureInitialized();

    return _prefs.getBool(
      PrefKeys.onBoardingDone,
    ) ??
        false;
  }

  Future<void> setOnBoardingShowState({
    bool? state,
  }) =>
      setOnBoardingDone(
        state ?? false,
      );

  Future<bool> getOnBoardingShowState() =>
      getOnBoardingDone();

  // ─────────────────────────────────────────────────────────────────────────
  // Theme
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> setDarkTheme(
      bool value,
      ) async {
    await _ensureInitialized();

    isDarkTheme = value;

    await _prefs.setBool(
      PrefKeys.kIsDarkTheme,
      value,
    );
  }

  Future<bool> getDarkTheme() async {
    await _ensureInitialized();

    return _prefs.getBool(
      PrefKeys.kIsDarkTheme,
    ) ??
        false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Expired Cache Cleanup
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _cleanExpiredEntries() async {
    final keys = _prefs.getKeys();

    for (final key in keys) {
      final raw = _prefs.get(key);

      if (raw is! String) continue;

      final entry = CacheEntry.fromJson(raw);

      if (entry?.expiry == null) continue;

      if (entry!.expiry!.isBefore(DateTime.now())) {
        await removeData(key);

        _logger.i('Expired cache removed: $key');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cache Size Manager
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> manageCacheSize() async {
    await _ensureInitialized();

    const maxBytes = 10 * 1024 * 1024;

    int total = 0;

    final keys = _prefs.getKeys().toList();

    for (final key in keys) {
      final value = _prefs.getString(key);

      if (value != null) {
        total += value.length;
      }
    }

    final sizeMb =
    (total / (1024 * 1024)).toStringAsFixed(2);

    _logger.i(
      'Cache size: ${sizeMb}MB',
    );

    if (total <= maxBytes) return;

    keys.sort();

    for (final key in keys) {
      if (total <= maxBytes) break;

      final value = _prefs.getString(key);

      if (value != null) {
        total -= value.length;

        await removeData(key);
      }
    }

    _logger.w(
      'Cache cleaned because size exceeded limit',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal Readers
  // ─────────────────────────────────────────────────────────────────────────

  Future<String?> _readSecureDirect(
      String key,
      ) async {
    try {
      final value = await _secureStorage.read(
        key: key,
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions(),
      );

      if (value == null || value.isEmpty) {
        return null;
      }

      return value;
    } catch (_) {
      return null;
    }
  }

  Future<UserProfileData?> _readCachedUserDirect() async {
    try {
      final encoded = await _readSecureDirect(
        PrefKeys.currentUser,
      );

      if (encoded == null) {
        return null;
      }

      final decoded = jsonDecode(encoded);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return UserProfileData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }


  Future<UserProfileData?> _readCachedVendorType() async {
    try {
      final encoded = await _readSecureDirect(
        PrefKeys.currentUser,
      );

      if (encoded == null) {
        return null;
      }

      final decoded = jsonDecode(encoded);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return UserProfileData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Secure Storage Options
  // ─────────────────────────────────────────────────────────────────────────

  IOSOptions _getIOSOptions() {
    return const IOSOptions(
      accessibility:
      KeychainAccessibility.unlocked,
      synchronizable: false,
    );
  }

  AndroidOptions _getAndroidOptions() {
    return const AndroidOptions(
      encryptedSharedPreferences: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Logging
  // ─────────────────────────────────────────────────────────────────────────

  void _setupLogging() {
    Logger.level = Level.debug;

    if (kDebugMode) {
      _logger.d('Logger initialized');
    }
  }
}