part of 'connectivity_cubit.dart';


abstract class ConnectivityState {}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityLoading extends ConnectivityState {}

class ConnectivityConnected extends ConnectivityState {}

class ConnectivityDisconnected extends ConnectivityState {}

/// NEW: في حالة إن الواي فاي أو الداتا غير مفعّلين
class ConnectivityWifiOrMobileOff extends ConnectivityState {}
