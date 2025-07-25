import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import 'package:money_manager/core/services/profile_service.dart';
import 'dart:io';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;
  ProfileBloc(this.profileService)
    : super(const ProfileState(isLoading: true)) {
    on<LoadProfile>(_onLoadProfile);
    on<EditProfile>(_onEditProfile);
    on<SaveProfile>(_onSaveProfile);
    on<ChangeProfilePicture>(_onChangeProfilePicture);
    on<RemoveProfilePicture>(_onRemoveProfilePicture);
    on<LogoutProfile>(_onLogoutProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    print('[ProfileBloc] LoadProfile event triggered');
    emit(state.copyWith(isLoading: true));
    try {
      final profile = await profileService.getCurrentUserProfile();
      if (profile != null) {
        emit(
          state.copyWith(
            isLoading: false,
            fullName: profile.fullName,
            phoneNumber: profile.phoneNumber,
            email: profile.email,
            photoURL: profile.photoURL,
            createdAt: profile.createdAt,
            lastLoginAt: profile.lastLoginAt,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false, error: 'Profile not found'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onEditProfile(EditProfile event, Emitter<ProfileState> emit) {
    print('[ProfileBloc] EditProfile event triggered');
    emit(state.copyWith(isEditing: true));
  }

  Future<void> _onSaveProfile(
    SaveProfile event,
    Emitter<ProfileState> emit,
  ) async {
    print('[ProfileBloc] SaveProfile event triggered');
    emit(state.copyWith(isLoading: true));
    try {
      final updated = await profileService.updateUserProfile(
        (await profileService.getCurrentUserProfile())!.copyWith(
          fullName: event.fullName,
          phoneNumber: event.phoneNumber,
        ),
      );
      if (updated) {
        add(LoadProfile());
        emit(state.copyWith(isEditing: false));
      } else {
        emit(
          state.copyWith(isLoading: false, error: 'Failed to update profile'),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onChangeProfilePicture(
    ChangeProfilePicture event,
    Emitter<ProfileState> emit,
  ) async {
    print('[ProfileBloc] ChangeProfilePicture event triggered');
    emit(state.copyWith(isLoading: true));
    try {
      // event.imageFile is a File, compress and encode to Base64
      if (event.imageFile is File) {
        final base64Image = await profileService.compressAndEncodeImage(
          event.imageFile,
        );
        if (base64Image != null) {
          final success = await profileService.updateProfilePicture(
            base64Image,
          );
          if (success) {
            add(LoadProfile());
          } else {
            emit(
              state.copyWith(
                isLoading: false,
                error: 'Failed to update profile picture',
              ),
            );
          }
        } else {
          emit(
            state.copyWith(isLoading: false, error: 'Failed to process image'),
          );
        }
      } else {
        emit(state.copyWith(isLoading: false, error: 'Invalid image file'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRemoveProfilePicture(
    RemoveProfilePicture event,
    Emitter<ProfileState> emit,
  ) async {
    print('[ProfileBloc] RemoveProfilePicture event triggered');
    emit(state.copyWith(isLoading: true));
    try {
      final success = await profileService.removeProfilePicture();
      if (success) {
        add(LoadProfile());
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Failed to remove profile picture',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLogoutProfile(
    LogoutProfile event,
    Emitter<ProfileState> emit,
  ) async {
    print('[ProfileBloc] LogoutProfile event triggered');
    emit(state.copyWith(isLoading: true));
    try {
      await profileService.logout();
      emit(const ProfileState());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
