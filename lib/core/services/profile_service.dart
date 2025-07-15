import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/core/services/image_picker.dart';
import 'dart:io';

class UserProfile {
  final String uid;
  final String email;
  final String? fullName;
  final String? photoURL;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  UserProfile({
    required this.uid,
    required this.email,
    this.fullName,
    this.photoURL,
    this.phoneNumber,
    this.createdAt,
    this.lastLoginAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'],
      photoURL: data['photoURL'],
      phoneNumber: data['phoneNumber'],
      createdAt: data['createdAt']?.toDate(),
      lastLoginAt: data['lastLoginAt']?.toDate(),
    );
  }

  // Get image widget for profile picture
  Widget getProfileImage({double radius = 50}) {
    final imagePickerService = ImagePickerService();
    return imagePickerService.createProfileImage(
      photoURL: photoURL,
      radius: radius,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? photoURL,
    String? phoneNumber,
    DateTime? lastLoginAt,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePickerService _imagePickerService = ImagePickerService();

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      } else {
        // Create profile if it doesn't exist
        return await createUserProfile(user);
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Create new user profile
  Future<UserProfile> createUserProfile(User user) async {
    try {
      UserProfile profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        fullName: user.displayName,
        photoURL: user.photoURL,
        phoneNumber: user.phoneNumber,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(profile.toMap());

      return profile;
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserProfile updatedProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(updatedProfile.uid)
          .update(updatedProfile.toMap());
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Update last login time
  Future<void> updateLastLogin() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': DateTime.now(),
        });
      }
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }

  // Pick image from gallery or camera
  Future<File?> pickImage({bool fromCamera = false}) async {
    return _imagePickerService.pickImage(fromCamera: fromCamera);
  }

  // Remove profile picture
  Future<bool> removeProfilePicture() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': null,
        'lastLoginAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error removing profile picture: $e');
      return false;
    }
  }

  // Compress and convert image to Base64
  Future<String?> compressAndEncodeImage(File imageFile) async {
    return _imagePickerService.compressAndEncodeImage(imageFile);
  }

  // Update profile picture
  Future<bool> updateProfilePicture(String base64Image) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': base64Image,
        'lastLoginAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error updating profile picture: $e');
      return false;
    }
  }
}
