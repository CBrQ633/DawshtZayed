import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dawsha_app/data/models/activity_model.dart';
import 'package:dawsha_app/data/repositories/activity_repository.dart';
import 'package:dawsha_app/data/repositories/auth_repository.dart';

class RunTrackingState {
  final bool isTracking;
  final bool isPaused;
  final Duration duration;
  final double distance; // in meters
  final double pace; // min/km
  final List<LatLng> route;
  final Position? currentPosition;

  RunTrackingState({
    this.isTracking = false,
    this.isPaused = false,
    this.duration = Duration.zero,
    this.distance = 0.0,
    this.pace = 0.0,
    this.route = const [],
    this.currentPosition,
  });

  RunTrackingState copyWith({
    bool? isTracking,
    bool? isPaused,
    Duration? duration,
    double? distance,
    double? pace,
    List<LatLng>? route,
    Position? currentPosition,
  }) {
    return RunTrackingState(
      isTracking: isTracking ?? this.isTracking,
      isPaused: isPaused ?? this.isPaused,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      pace: pace ?? this.pace,
      route: route ?? this.route,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}

class RunTrackingViewModel extends StateNotifier<RunTrackingState> {
  final ActivityRepository _activityRepository;
  final AuthRepository _authRepository;
  
  Timer? _timer;
  StreamSubscription<Position>? _positionStream;

  RunTrackingViewModel(this._activityRepository, this._authRepository) : super(RunTrackingState());

  Future<void> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    state = state.copyWith(isTracking: true, isPaused: false);

    _startTimer();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (!state.isPaused) {
        _onPositionUpdate(position);
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPaused) {
        state = state.copyWith(duration: state.duration + const Duration(seconds: 1));
        _updatePace();
      }
    });
  }

  void pauseTracking() {
    state = state.copyWith(isPaused: true);
  }

  void resumeTracking() {
    state = state.copyWith(isPaused: false);
  }

  void _onPositionUpdate(Position position) {
    List<LatLng> newRoute = [...state.route, LatLng(position.latitude, position.longitude)];
    double newDistance = state.distance;
    
    if (state.route.isNotEmpty) {
      final lastPoint = state.route.last;
      final distanceAdded = Geolocator.distanceBetween(
        lastPoint.latitude, 
        lastPoint.longitude, 
        position.latitude, 
        position.longitude
      );
      newDistance += distanceAdded;
    }

    state = state.copyWith(
      currentPosition: position,
      route: newRoute,
      distance: newDistance,
    );
  }

  void _updatePace() {
    if (state.distance > 0) {
      final km = state.distance / 1000.0;
      final minutes = state.duration.inSeconds / 60.0;
      final pace = minutes / km;
      state = state.copyWith(pace: pace);
    }
  }

  Future<ActivityModel?> stopTracking() async {
    final activityData = state;
    state = state.copyWith(isTracking: false, isPaused: false);
    _timer?.cancel();
    _positionStream?.cancel();

    final user = _authRepository.currentUser;
    if (user != null && activityData.distance > 10) { // minimum 10 meters to save
      final activity = ActivityModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        distance: activityData.distance / 1000.0,
        duration: activityData.duration,
        pace: activityData.pace,
        route: activityData.route.map((e) => {'lat': e.latitude, 'lng': e.longitude}).toList(),
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);
      return activity;
    }
    return null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}

final runTrackingViewModelProvider = StateNotifierProvider.autoDispose<RunTrackingViewModel, RunTrackingState>((ref) {
  final activityRepository = ref.watch(activityRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return RunTrackingViewModel(activityRepository, authRepository);
});
