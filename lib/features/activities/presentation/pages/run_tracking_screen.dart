import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/features/activities/presentation/viewmodels/run_tracking_viewmodel.dart';
import 'package:go_router/go_router.dart';

class RunTrackingScreen extends ConsumerStatefulWidget {
  const RunTrackingScreen({super.key});

  @override
  ConsumerState<RunTrackingScreen> createState() => _RunTrackingScreenState();
}

class _RunTrackingScreenState extends ConsumerState<RunTrackingScreen> {
  GoogleMapController? _mapController;
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(runTrackingViewModelProvider);
    final trackingNotifier = ref.read(runTrackingViewModelProvider.notifier);

    // Watch for position updates and move camera
    ref.listen(runTrackingViewModelProvider, (previous, next) {
      if (next.currentPosition != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(next.currentPosition!.latitude, next.currentPosition!.longitude),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.0444, 31.2357), // Cairo Coords
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              if (trackingState.route.isNotEmpty)
                Marker(
                  markerId: const MarkerId('start'),
                  position: trackingState.route.first,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
              if (trackingState.currentPosition != null)
                Marker(
                  markerId: const MarkerId('current'),
                  position: LatLng(trackingState.currentPosition!.latitude, trackingState.currentPosition!.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                ),
            },
            polylines: {
              if (trackingState.route.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: trackingState.route,
                  color: AppColors.primaryGreen,
                  width: 5,
                ),
            },
          ),
          
          // Header Layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.gps_fixed, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        const Text('GPS Strong', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Metrics Layer
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric('الوقت', _formatDuration(trackingState.duration)),
                      _buildMetric('المسافة (كم)', (trackingState.distance / 1000.0).toStringAsFixed(2)),
                      _buildMetric('السرعة (P/K)', trackingState.pace.toStringAsFixed(2)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!trackingState.isTracking)
                        ElevatedButton(
                          onPressed: () => trackingNotifier.startTracking(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('ابدأ الجري', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (trackingState.isPaused)
                              _buildControlButton(
                                onPressed: () => trackingNotifier.resumeTracking(),
                                icon: Icons.play_arrow_rounded,
                                color: AppColors.primaryGreen,
                                label: 'استئناف',
                              )
                            else
                              _buildControlButton(
                                onPressed: () => trackingNotifier.pauseTracking(),
                                icon: Icons.pause_rounded,
                                color: Colors.orange,
                                label: 'مؤقت',
                              ),
                            const SizedBox(width: 24),
                            _buildControlButton(
                              onPressed: () => _showStopDialog(context, trackingNotifier),
                              icon: Icons.stop_rounded,
                              color: Colors.red,
                              label: 'إيقاف',
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.textPrimary),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildControlButton({required VoidCallback onPressed, required IconData icon, required Color color, required String label}) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 32),
          style: IconButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showStopDialog(BuildContext context, RunTrackingViewModel notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('إنهاء الجري؟', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('هل أنت متأكد أنك تريد إنهاء جلسة الجري الحالية؟', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final activity = await notifier.stopTracking();
              if (activity != null && context.mounted) {
                context.pushReplacement('/summary', extra: activity);
              } else if (context.mounted) {
                context.pop(); // Go back if no activity was saved
              }
            },
            child: const Text('إنهاء'),
          ),
        ],
      ),
    );
  }

}
