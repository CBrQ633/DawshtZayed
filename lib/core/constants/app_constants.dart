import 'package:flutter/material.dart';

class AppConstants {
  // Application Info
  static const String appName = 'Dawsha';
  
  // Social Links
  static const String facebookUrl = 'https://www.facebook.com/dawshtzayed';
  static const String instagramUrl = 'https://www.instagram.com/dawshtzayedev';

  // API Config (will be populated later with Supabase details)
  static const String supabaseUrl = 'https://sqafkemeyofuaewgbgzs.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNxYWZrZW1leW9mdWFld2diZ3pzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0ODQ0MzQsImV4cCI6MjA5MTA2MDQzNH0.Y0NsgYSlw4Lsde1ZgZ2pSbcp-9MHD7XCChyFVgdOw4g';
}

class AppColors {
  // Using the Logo Colors
  static const Color primaryGreen = Color(0xFF1EA136); // Estimated from the logo
  static const Color primarySilver = Color(0xFFC0C0C0); 
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
}
