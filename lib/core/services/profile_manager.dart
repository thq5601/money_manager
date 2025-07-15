import 'package:money_manager/core/services/profile_service.dart';

class ProfileManager {
  static final ProfileService _profileService = ProfileService();

  // Get the profile service instance
  static ProfileService get service => _profileService;

  // Get current user profile
  static Future<UserProfile?> getCurrentProfile() async {
    return await _profileService.getCurrentUserProfile();
  }

  // Update user profile
  static Future<bool> updateProfile(UserProfile profile) async {
    return await _profileService.updateUserProfile(profile);
  }

  // Logout user
  static Future<void> logout() async {
    await _profileService.logout();
  }

  // Update last login time
  static Future<void> updateLastLogin() async {
    await _profileService.updateLastLogin();
  }
}
