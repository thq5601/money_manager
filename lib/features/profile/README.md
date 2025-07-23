# User Profile System

This module provides a comprehensive user profile system that integrates with Firebase Authentication and Firestore.

## Components

### UserProfile Class
A data model that represents a user's profile information:
- `uid`: Unique user identifier
- `email`: User's email address
- `fullName`: User's full name
- `photoURL`: Profile picture URL
- `phoneNumber`: User's phone number
- `createdAt`: Account creation date
- `lastLoginAt`: Last login timestamp

### ProfileService Class
Handles all Firebase operations for user profiles:
- `getCurrentUserProfile()`: Retrieves current user's profile
- `createUserProfile()`: Creates a new user profile
- `updateUserProfile()`: Updates existing profile
- `updateLastLogin()`: Updates last login timestamp
- `logout()`: Signs out the user

### ProfileScreen Widget
A complete UI for viewing and editing user profiles with:
- Profile picture display
- Editable display name and phone number
- Read-only email and timestamps
- Edit mode with save/cancel functionality
- Logout functionality with confirmation dialog

## Usage

### Basic Profile Operations

```dart
import 'package:money_manager/core/services/profile_manager.dart';

// Get current user profile
UserProfile? profile = await ProfileManager.getCurrentProfile();

// Update profile
if (profile != null) {
  UserProfile updatedProfile = profile.copyWith(
    fullName: 'New Name',
    phoneNumber: '+1234567890',
  );
  bool success = await ProfileManager.updateProfile(updatedProfile);
}

// Logout
await ProfileManager.logout();
```

### Navigation to Profile Screen

```dart
// Navigate to profile screen
Navigator.of(context).pushNamed(AppRoutes.profile);
```

### Direct Service Usage

```dart
import 'package:money_manager/feature/profile/profile.dart';

final ProfileService profileService = ProfileService();

// Get profile
UserProfile? profile = await profileService.getCurrentUserProfile();

// Update last login
await profileService.updateLastLogin();
```

## Firebase Setup

The profile system requires the following Firebase services:

1. **Firebase Authentication**: For user authentication
2. **Cloud Firestore**: For storing user profile data

### Firestore Collection Structure

```
users/
  {uid}/
    email: string
    fullName: string (optional)
    photoURL: string (optional)
    phoneNumber: string (optional)
    createdAt: timestamp
    lastLoginAt: timestamp
```

## Features

- ✅ Automatic profile creation for new users
- ✅ Profile editing with validation
- ✅ Last login tracking
- ✅ Secure logout with confirmation
- ✅ Error handling and user feedback
- ✅ Loading states and progress indicators
- ✅ Responsive UI design

## Error Handling

The system includes comprehensive error handling:
- Network connectivity issues
- Firebase authentication errors
- Firestore read/write errors
- User input validation

All errors are logged and displayed to the user via SnackBar notifications.

# Profile Picture Functionality

This implementation provides profile picture functionality without using Firebase Storage (which is no longer free). Instead, it uses Base64 encoding to store images directly in Firestore.

## Features

- **Image Selection**: Users can choose images from gallery or take photos with camera
- **Image Compression**: Images are automatically compressed to reduce size (200x200px, 80% quality)
- **Base64 Storage**: Images are converted to Base64 strings and stored in Firestore
- **Remove Picture**: Users can remove their profile picture
- **Fallback Handling**: Graceful fallback to default icon if image loading fails

## How it Works

### 1. Image Selection
- Users tap the camera icon on their profile picture
- A bottom sheet appears with options: Gallery, Camera, Remove (if picture exists)

### 2. Image Processing
- Selected images are compressed to 200x200 pixels
- JPEG quality is set to 80% to reduce file size
- Images are converted to Base64 strings

### 3. Storage
- Base64 strings are stored in the `photoURL` field of the user document
- This approach works well for small profile pictures but has size limitations

### 4. Display
- The `getProfileImage()` method handles both Base64 and network images
- Automatic fallback to default icon if image fails to load

## Limitations

- **Size Limit**: Base64 strings increase file size by ~33%. Firestore has a 1MB document limit
- **Performance**: Large images may cause performance issues
- **Bandwidth**: Base64 strings use more bandwidth than optimized image URLs

## Alternative Solutions

If you need to handle larger images or want better performance, consider:

1. **Local Storage**: Store images locally and sync metadata to Firestore
2. **Third-party Services**: Use free image hosting services like Imgur API
3. **Cloudinary**: Free tier available for image hosting and optimization
4. **AWS S3**: Pay-per-use storage with generous free tier

## Architecture

The profile functionality has been refactored into separate services for better maintainability:

### ImagePickerService (`lib/core/services/image_picker.dart`)

This service handles all image-related functionality:

```dart
final imagePickerService = ImagePickerService();

// Pick image from gallery or camera
File? image = await imagePickerService.pickImage(fromCamera: false);

// Compress and encode image to Base64
String? base64Image = await imagePickerService.compressAndEncodeImage(imageFile);

// Show image picker bottom sheet
File? selectedImage = await imagePickerService.showImagePickerBottomSheet(context);

// Show image picker with remove option
File? selectedImage = await imagePickerService.showImagePickerWithRemove(
  context,
  hasExistingImage: true,
);

// Create profile image widget
Widget profileImage = imagePickerService.createProfileImage(
  photoURL: userPhotoURL,
  radius: 50,
  onTap: () => print('Image tapped'),
);

// Create profile image with camera overlay
Widget profileImageWithCamera = imagePickerService.createProfileImageWithCamera(
  photoURL: userPhotoURL,
  radius: 50,
  onTap: () => print('Camera tapped'),
);
```

### ProfileService (`lib/core/services/profile_service.dart`)

The ProfileService handles all profile-related operations and uses ImagePickerService for image operations:

```dart
final profileService = ProfileService();

// Get current user profile
UserProfile? profile = await profileService.getCurrentUserProfile();

// Update user profile
bool success = await profileService.updateUserProfile(updatedProfile);

// Pick image from gallery or camera
File? image = await profileService.pickImage(fromCamera: false);

// Update profile picture
String? base64Image = await profileService.compressAndEncodeImage(imageFile);
bool success = await profileService.updateProfilePicture(base64Image);

// Remove profile picture
bool success = await profileService.removeProfilePicture();

// Logout user
await profileService.logout();
```

### ProfileScreen (`lib/feature/profile/profile.dart`)

The ProfileScreen is now focused only on UI and uses the services:

```dart
class ProfileScreen extends StatefulWidget {
  // UI-only code
  // Uses ProfileService and ImagePickerService for functionality
}
```

## Dependencies

- `image_picker`: For selecting images from gallery/camera
- `image`: For image compression and processing
- `dart:convert`: For Base64 encoding/decoding

## Benefits of Refactoring

1. **Separation of Concerns**: 
   - Image functionality is isolated in `ImagePickerService`
   - Profile functionality is isolated in `ProfileService`
   - UI is isolated in `ProfileScreen`

2. **Reusability**: 
   - `ImagePickerService` can be used anywhere in the app
   - `ProfileService` can be used by other features

3. **Maintainability**: 
   - Easier to update and test functionality in isolation
   - Clear separation between UI and business logic

4. **Clean Architecture**: 
   - Services are in `core/services/` for better organization
   - Consistent with existing project structure

5. **Better UI**: 
   - Pre-built widgets for profile images with camera overlay
   - Focused UI code without business logic

## Testing

The profile picture functionality has been tested and is working correctly. Users can:
- Select images from gallery
- Take photos with camera
- Remove profile pictures
- View profile pictures stored as Base64 in Firestore 