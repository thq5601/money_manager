import 'package:flutter/material.dart';
import 'package:money_manager/core/routes.dart';
import 'package:money_manager/core/services/image_picker.dart';
import 'package:money_manager/core/services/profile_service.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserProfile? profile = await _profileService.getCurrentUserProfile();
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _fullNameController.text = profile.fullName ?? '';
          _phoneNumberController.text = profile.phoneNumber ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_userProfile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserProfile updatedProfile = _userProfile!.copyWith(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
      );

      bool success = await _profileService.updateUserProfile(updatedProfile);

      if (success) {
        setState(() {
          _userProfile = updatedProfile;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _profileService.logout();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  Future<void> _changeProfilePicture() async {
    // Show a simple dialog for image selection
    final result = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context, 'gallery');
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context, 'camera');
                },
              ),
              if (_userProfile?.photoURL != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context, 'remove');
                  },
                ),
            ],
          ),
        );
      },
    );

    if (result == 'gallery') {
      final image = await _imagePickerService.pickImageDirectly(
        fromCamera: false,
      );
      if (image != null) {
        await _processAndUploadImage(image);
      }
    } else if (result == 'camera') {
      final image = await _imagePickerService.pickImageDirectly(
        fromCamera: true,
      );
      if (image != null) {
        await _processAndUploadImage(image);
      }
    } else if (result == 'remove') {
      await _removeProfilePicture();
    }
  }

  Future<void> _processAndUploadImage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Compress and encode the image
      String? base64Image = await _profileService.compressAndEncodeImage(
        imageFile,
      );

      if (base64Image != null) {
        // Update the profile picture
        bool success = await _profileService.updateProfilePicture(base64Image);

        if (success) {
          // Reload the profile to show the new image
          await _loadUserProfile();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile picture')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process image')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeProfilePicture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _profileService.removeProfilePicture();

      if (success) {
        await _loadUserProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove profile picture')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing profile picture: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userProfile == null) {
      return const Center(child: Text('Failed to load profile'));
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'Profile',
      //     style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      //   ),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   iconTheme: const IconThemeData(color: Colors.black),
      // ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Profile Header Card
          Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 3,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        _imagePickerService.createProfileImageWithCamera(
                          photoURL: _userProfile!.photoURL,
                          radius: 50,
                          onTap: _changeProfilePicture,
                        ),
                        if (_isLoading)
                          const Positioned.fill(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _userProfile!.fullName ?? 'No Name',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (!_isEditing)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userProfile!.email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Profile Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildInfoTile(
                          'Full Name',
                          _userProfile!.fullName ?? 'Not set',
                          _isEditing,
                          controller: _fullNameController,
                        ),
                        _buildInfoTile(
                          'Phone Number',
                          _userProfile!.phoneNumber ?? 'Not set',
                          _isEditing,
                          controller: _phoneNumberController,
                        ),
                        _buildInfoTile(
                          'Member Since',
                          _userProfile!.createdAt != null
                              ? _formatDate(_userProfile!.createdAt!)
                              : 'Unknown',
                          false,
                        ),
                        _buildInfoTile(
                          'Last Login',
                          _userProfile!.lastLoginAt != null
                              ? _formatDate(_userProfile!.lastLoginAt!)
                              : 'Unknown',
                          false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Save Changes'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _fullNameController.text =
                                    _userProfile!.fullName ?? '';
                                _phoneNumberController.text =
                                    _userProfile!.phoneNumber ?? '';
                              });
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
                        onPressed: _showLogoutDialog,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
  }

  Widget _buildInfoTile(
    String label,
    String value,
    bool isEditable, {
    TextEditingController? controller,
  }) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: isEditable && controller != null
          ? TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            )
          : Text(value),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
