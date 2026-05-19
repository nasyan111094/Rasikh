import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:logger/logger.dart';

enum ConnectionStatus {
  disconnected,
  connectedNoInternet,
  connectedWithInternet,
}

class ConnectivityCubit extends Cubit<ConnectionStatus> {
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();

  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late final StreamSubscription<InternetConnectionStatus> _internetSubscription;

  final InternetConnectionChecker _internetChecker = InternetConnectionChecker.createInstance(
    checkInterval: const Duration(seconds: 5), // Slightly longer interval
    checkTimeout: const Duration(seconds: 8), // Increased timeout for reliability
  );

  Timer? _debounceTimer;
  Timer? _retryTimer;
  ConnectionStatus? _lastEmittedState;
  bool _isProcessingConnectivity = false;
  bool _isProcessingInternet = false;
  bool _isInitialized = false;

  DateTime? _lastConnectivityCheck;
  static const Duration _minCheckInterval = Duration(milliseconds: 800);
  static const Duration _retryDelay = Duration(seconds: 3);
  static const int _maxRetries = 3;
  int _retryCount = 0;

  ConnectivityCubit() : super(ConnectionStatus.disconnected);

  // Public method to initialize - better control over when monitoring starts
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeMonitoring();
      _isInitialized = true;
      _logger.d('ConnectivityCubit initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Error initializing ConnectivityCubit: $e', stackTrace: stackTrace);
      emit(ConnectionStatus.disconnected);
    }
  }

  Future<void> _initializeMonitoring() async {
    try {
      // Set up connectivity monitoring
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _handleConnectivityChange,
        onError: (e, stackTrace) {
          _logger.e('Connectivity subscription error: $e', stackTrace: stackTrace);
          _scheduleRetry();
        },
      );

      // Set up internet monitoring with error handling
      _internetSubscription = _internetChecker.onStatusChange.listen(
        _updateInternetStatus,
        onError: (e, stackTrace) {
          _logger.e('Internet subscription error: $e', stackTrace: stackTrace);
          if (state == ConnectionStatus.connectedWithInternet) {
            emit(ConnectionStatus.connectedNoInternet);
          }
        },
      );

      // Check initial connectivity
      await _checkInitialConnectivity();
    } catch (e, stackTrace) {
      _logger.e('Error setting up monitoring: $e', stackTrace: stackTrace);
      throw e;
    }
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity().timeout(
        const Duration(seconds: 10),
        onTimeout: () => [ConnectivityResult.none],
      );

      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        await _updateConnectivity(results.first);
        _logger.d('Initial connectivity checked: ${results.first}');
      } else {
        emit(ConnectionStatus.disconnected);
        _logger.d('Initial connectivity: disconnected');
      }
      _retryCount = 0; // Reset retry count on successful check
    } catch (e, stackTrace) {
      _logger.e('Error checking initial connectivity: $e', stackTrace: stackTrace);
      emit(ConnectionStatus.disconnected);
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (_retryCount >= _maxRetries) {
      _logger.w('Max retries reached, staying in current state');
      return;
    }

    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () {
      _retryCount++;
      _logger.d('Retrying connectivity check (attempt $_retryCount)');
      _checkInitialConnectivity();
    });
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    _retryCount = 0; // Reset retry count on successful connectivity change
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectivity(result);
    });
  }

  Future<void> _updateConnectivity(ConnectivityResult result) async {
    if (_isProcessingConnectivity || isClosed) {
      _logger.d('Skipping connectivity update: processing=${_isProcessingConnectivity}, closed=${isClosed}');
      return;
    }
    _isProcessingConnectivity = true;

    try {
      final now = DateTime.now();
      if (_lastConnectivityCheck != null &&
          now.difference(_lastConnectivityCheck!) < _minCheckInterval) {
        _logger.d('Skipping connectivity update: within min interval');
        return;
      }
      _lastConnectivityCheck = now;

      _logger.d('Updating connectivity: $result');

      if (result == ConnectivityResult.none) {
        _emitIfChanged(ConnectionStatus.disconnected);
      } else {
        // Wait a bit for network to stabilize before checking internet
        await Future.delayed(const Duration(milliseconds: 300));
        if (!isClosed) {
          await _checkInternetConnection();
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error updating connectivity: $e', stackTrace: stackTrace);
      _emitIfChanged(ConnectionStatus.disconnected);
    } finally {
      _isProcessingConnectivity = false;
    }
  }

  Future<void> _checkInternetConnection() async {
    try {
      final hasInternet = await _internetChecker.hasConnection.timeout(
        const Duration(seconds: 8),
        onTimeout: () => false,
      );

      _logger.d('Internet check result: $hasInternet');

      if (hasInternet) {
        _emitIfChanged(ConnectionStatus.connectedWithInternet);
      } else {
        _emitIfChanged(ConnectionStatus.connectedNoInternet);
      }
    } catch (e, stackTrace) {
      _logger.e('Error checking internet: $e', stackTrace: stackTrace);
      _emitIfChanged(ConnectionStatus.connectedNoInternet);
    }
  }

  void _updateInternetStatus(InternetConnectionStatus status) {
    if (_isProcessingInternet || isClosed) {
      _logger.d('Skipping internet status update: processing=${_isProcessingInternet}, closed=${isClosed}');
      return;
    }
    _isProcessingInternet = true;

    try {
      // Only update if we're not in disconnected state
      if (state != ConnectionStatus.disconnected) {
        if (status == InternetConnectionStatus.connected) {
          _emitIfChanged(ConnectionStatus.connectedWithInternet);
        } else {
          _emitIfChanged(ConnectionStatus.connectedNoInternet);
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error updating internet status: $e', stackTrace: stackTrace);
    } finally {
      _isProcessingInternet = false;
    }
  }

  void _emitIfChanged(ConnectionStatus newState) {
    if (_lastEmittedState != newState && !isClosed) {
      _lastEmittedState = newState;
      _logger.d('Emitting state: $newState');
      emit(newState);
    } else {
      _logger.d('Skipping emit: same state ($newState) or cubit closed');
    }
  }

  // Public method for manual connectivity check
  Future<void> checkConnectivity() async {
    if (!_isInitialized) {
      _logger.w('Cubit not initialized, calling initialize first');
      await initialize();
      return;
    }

    if (isClosed || _isProcessingConnectivity) {
      _logger.d('Skipping checkConnectivity: cubit closed or processing');
      return;
    }

    try {
      final results = await _connectivity.checkConnectivity().timeout(
        const Duration(seconds: 10),
        onTimeout: () => [ConnectivityResult.none],
      );

      if (results.isNotEmpty) {
        await _updateConnectivity(results.first);
      } else {
        _emitIfChanged(ConnectionStatus.disconnected);
      }
    } catch (e, stackTrace) {
      _logger.e('Error in checkConnectivity: $e', stackTrace: stackTrace);
      _emitIfChanged(ConnectionStatus.disconnected);
    }
  }

  Future<ConnectivityResult> getCurrentNetworkType() async {
    try {
      final results = await _connectivity.checkConnectivity().timeout(
        const Duration(seconds: 5),
        onTimeout: () => [ConnectivityResult.none],
      );
      return results.isNotEmpty ? results.first : ConnectivityResult.none;
    } catch (e, stackTrace) {
      _logger.e('Error getting network type: $e', stackTrace: stackTrace);
      return ConnectivityResult.none;
    }
  }

  // Better getter for connection status
  bool get hasConnection {
    return state != ConnectionStatus.disconnected;
  }

  bool get hasInternet {
    return state == ConnectionStatus.connectedWithInternet;
  }

  // Deprecated - use hasConnection instead
  @Deprecated('Use hasConnection instead')
  bool get isWiFiConnected {
    return hasConnection;
  }

  @override
  Future<void> close() async {
    _logger.d('Closing ConnectivityCubit');

    // Cancel all timers
    _debounceTimer?.cancel();
    _retryTimer?.cancel();

    // Cancel subscriptions with error handling
    try {
      await _connectivitySubscription.cancel();
      _logger.d('Connectivity subscription canceled');
    } catch (e, stackTrace) {
      _logger.e('Error canceling connectivity subscription: $e', stackTrace: stackTrace);
    }

    try {
      await _internetSubscription.cancel();
      _logger.d('Internet subscription canceled');
    } catch (e, stackTrace) {
      _logger.e('Error canceling internet subscription: $e', stackTrace: stackTrace);
    }

    // Close logger last
    _logger.close();

    return super.close();
  }
}