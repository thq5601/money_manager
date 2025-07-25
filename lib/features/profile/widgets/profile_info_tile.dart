import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_event.dart';

class ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditable;
  final TextEditingController? controller;

  const ProfileInfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.isEditable,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
              onChanged: (val) {
                if (label == 'Full Name') {
                  context.read<ProfileBloc>().add(EditProfile());
                } else if (label == 'Phone Number') {
                  context.read<ProfileBloc>().add(EditProfile());
                }
              },
            )
          : Text(value),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
