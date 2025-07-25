import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final bool isEditing;
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.isEditing = false,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.photoURL,
    this.createdAt,
    this.lastLoginAt,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isEditing,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isEditing,
    fullName,
    phoneNumber,
    email,
    photoURL,
    createdAt,
    lastLoginAt,
    error,
  ];
}
