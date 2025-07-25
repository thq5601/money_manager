import 'package:flutter/material.dart';
import 'package:money_manager/core/routes.dart';
import 'package:money_manager/core/services/profile_service.dart';
import 'package:money_manager/core/services/image_picker.dart';
import 'widgets/profile_info_tile.dart';
import 'utils/profile_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import 'dart:convert'; // Import for base64Decode

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showProfilePictureDialog(BuildContext parentContext) async {
    final profileBloc = BlocProvider.of<ProfileBloc>(parentContext);
    final imagePickerService = ImagePickerService();
    final result = await showDialog<String?>(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: profileBloc,
          child: AlertDialog(
            title: const Text('Select Image'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                    final image = await imagePickerService.pickImage(
                      fromCamera: false,
                    );
                    if (image != null) {
                      parentContext.read<ProfileBloc>().add(
                        ChangeProfilePicture(image),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                    final image = await imagePickerService.pickImage(
                      fromCamera: true,
                    );
                    if (image != null) {
                      parentContext.read<ProfileBloc>().add(
                        ChangeProfilePicture(image),
                      );
                    }
                  },
                ),
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state.photoURL != null && state.photoURL!.isNotEmpty) {
                      return ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text(
                          'Remove Photo',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          Navigator.of(
                            dialogContext,
                            rootNavigator: true,
                          ).pop('remove');
                          parentContext.read<ProfileBloc>().add(
                            RemoveProfilePicture(),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(ProfileService())..add(LoadProfile()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          final fullNameController = TextEditingController(
            text: state.fullName ?? '',
          );
          final phoneController = TextEditingController(
            text: state.phoneNumber ?? '',
          );
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.email == null
                ? const Center(child: Text('Failed to load profile'))
                : Column(
                    children: [
                      Card(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 16,
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          _showProfilePictureDialog(context),
                                      child:
                                          state.photoURL != null &&
                                              state.photoURL!.isNotEmpty
                                          ? (ImagePickerService().isBase64Image(
                                                  state.photoURL!,
                                                )
                                                ? CircleAvatar(
                                                    radius: 50,
                                                    backgroundImage:
                                                        MemoryImage(
                                                          base64Decode(
                                                            state.photoURL!,
                                                          ),
                                                        ),
                                                  )
                                                : Image.network(
                                                    state.photoURL!,
                                                    width: 100,
                                                    height: 100,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            const CircleAvatar(
                                                              radius: 50,
                                                              child: Icon(
                                                                Icons.person,
                                                              ),
                                                            ),
                                                  ))
                                          : const CircleAvatar(
                                              radius: 50,
                                              child: Icon(Icons.person),
                                            ),
                                    ),
                                    if (state.isLoading)
                                      const Positioned.fill(
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    state.fullName ?? 'No Name',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (!state.isEditing)
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        context.read<ProfileBloc>().add(
                                          EditProfile(),
                                        );
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.email ?? '',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Profile Information',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    ProfileInfoTile(
                                      label: 'Full Name',
                                      value: state.fullName ?? 'Not set',
                                      isEditable: state.isEditing,
                                      controller: fullNameController,
                                    ),
                                    ProfileInfoTile(
                                      label: 'Phone Number',
                                      value: state.phoneNumber ?? 'Not set',
                                      isEditable: state.isEditing,
                                      controller: phoneController,
                                    ),
                                    ProfileInfoTile(
                                      label: 'Member Since',
                                      value: state.createdAt != null
                                          ? formatDate(state.createdAt!)
                                          : 'Unknown',
                                      isEditable: false,
                                    ),
                                    ProfileInfoTile(
                                      label: 'Last Login',
                                      value: state.lastLoginAt != null
                                          ? formatDate(state.lastLoginAt!)
                                          : 'Unknown',
                                      isEditable: false,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (state.isEditing) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.read<ProfileBloc>().add(
                                            SaveProfile(
                                              fullNameController.text.trim(),
                                              phoneController.text.trim(),
                                            ),
                                          );
                                        },
                                        child: const Text('Save Changes'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          context.read<ProfileBloc>().add(
                                            LoadProfile(),
                                          );
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Logout'),
                                            content: const Text(
                                              'Are you sure you want to logout?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  context
                                                      .read<ProfileBloc>()
                                                      .add(LogoutProfile());
                                                  Navigator.of(
                                                    context,
                                                  ).pushNamedAndRemoveUntil(
                                                    AppRoutes.login,
                                                    (route) => false,
                                                  );
                                                },
                                                child: const Text('Logout'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.logout),
                                    label: const Text('Logout'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
