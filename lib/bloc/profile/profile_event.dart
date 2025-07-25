import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class EditProfile extends ProfileEvent {}

class SaveProfile extends ProfileEvent {
  final String fullName;
  final String phoneNumber;
  const SaveProfile(this.fullName, this.phoneNumber);
  @override
  List<Object?> get props => [fullName, phoneNumber];
}

class ChangeProfilePicture extends ProfileEvent {
  final dynamic imageFile;
  const ChangeProfilePicture(this.imageFile);
  @override
  List<Object?> get props => [imageFile];
}

class RemoveProfilePicture extends ProfileEvent {}

class LogoutProfile extends ProfileEvent {}
