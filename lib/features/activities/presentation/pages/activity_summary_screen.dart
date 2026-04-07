import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:dawsha_app/core/constants/app_constants.dart';
import 'package:dawsha_app/data/models/activity_model.dart';
import 'package:intl/intl.dart' hide TextDirection;

class ActivitySummaryScreen extends StatelessWidget {
  final ActivityModel activity;

  const ActivitySummaryScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    List<LatLng> routePoints = activity.route.map((p) => LatLng(p['lat']!, p['lng']!)).toList();
    
    // Calculate map bounds if route is not empty
    LatLngBounds? bounds;
    if (routePoints.isNotEmpty) {
      double minLat = routePoints.first.latitude;
      double maxLat = routePoints.first.latitude;
      double minLng = routePoints.first.longitude;
      double maxLng = routePoints.first.longitude;

      for (var point in routePoints) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ملخص النشاط', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hide back button to force user to use "Done" button
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map View Header (Static Map)
            Container(
              height: 300,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: routePoints.isNotEmpty ? routePoints.first : const LatLng(30.0444, 31.2357),
                  zoom: 15,
                ),
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                zoomGesturesEnabled: false,
                polylines: {
                  if (routePoints.isNotEmpty)
                    Polyline(
                      polylineId: const PolylineId('summary_route'),
                      points: routePoints,
                      color: AppColors.primaryGreen,
                      width: 5,
                    ),
                },
                markers: {
                  if (routePoints.isNotEmpty) ...[
                    Marker(
                      markerId: const MarkerId('start'),
                      position: routePoints.first,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                    ),
                    Marker(
                      markerId: const MarkerId('end'),
                      position: routePoints.last,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    ),
                  ]
                },
                onMapCreated: (GoogleMapController controller) {
                  if (bounds != null) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds!, 50));
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            // Date and Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'جري مسائي', // We can make this dynamic based on time later
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy • h:mm a').format(activity.createdAt),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Metrics Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildMetricCard('المسافة (كم)', activity.distance.toStringAsFixed(2), Icons.route, Colors.blue),
                  _buildMetricCard('الوقت', _formatDuration(activity.duration), Icons.timer, Colors.orange),
                  _buildMetricCard('السرعة (P/K)', activity.pace.toStringAsFixed(2), Icons.speed, Colors.purple),
                  _buildMetricCard('السعرات (كالوري)', _calculateCalories().toString(), Icons.local_fire_department, Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement Share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('المشاركة ستتوفر قريباً!')),
                        );
                      },
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text('مشاركة', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primarySilver.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('تم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0) {
      return "${d.inHours}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  // Simple hardcoded calorie estimation based on distance for now.
  // 1 km run roughly burns between 60-80 calories.
  int _calculateCalories() {
    return (activity.distance * 70).round();
  }
}
