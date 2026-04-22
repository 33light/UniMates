import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UniMatesUser user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _universityController;

  bool _isSaving = false;
  bool _hasChanges = false;
  String? _localImagePath; // picked but not yet saved
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _universityController =
        TextEditingController(text: widget.user.university);

    for (final c in [
      _nameController,
      _usernameController,
      _bioController,
      _universityController,
    ]) {
      c.addListener(() {
        final changed = _nameController.text != widget.user.name ||
            _usernameController.text != widget.user.username ||
            _bioController.text != (widget.user.bio ?? '') ||
            _universityController.text != widget.user.university;
        if (changed != _hasChanges) {
          setState(() => _hasChanges = changed);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;

    setState(() { _localImagePath = picked.path; _isUploadingPhoto = true; _hasChanges = true; });

    final newUrl = await MockApiService.instance.updateProfileImage(picked.path);

    if (!mounted) return;
    if (newUrl != null) {
      setState(() { _isUploadingPhoto = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated!'), backgroundColor: Colors.green),
      );
    } else {
      setState(() { _localImagePath = null; _isUploadingPhoto = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload photo. Try again.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> _showDiscardDialog() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to go back?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updated = UniMatesUser(
        id: widget.user.id,
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: widget.user.email,
        university: _universityController.text.trim(),
        profileImageUrl: widget.user.profileImageUrl,
        isVerified: widget.user.isVerified,
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        rating: widget.user.rating,
        reviewsCount: widget.user.reviewsCount,
        joinDate: widget.user.joinDate,
      );

      await MockApiService.instance.updateUserProfile(updated);

      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showDiscardDialog();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          elevation: 0,
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: GestureDetector(
                    onTap: _isUploadingPhoto ? null : _changePhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage: _localImagePath != null
                              ? FileImage(File(_localImagePath!)) as ImageProvider
                              : (widget.user.profileImageUrl != null &&
                                      widget.user.profileImageUrl!.isNotEmpty
                                  ? NetworkImage(widget.user.profileImageUrl!)
                                  : null),
                          child: (_localImagePath == null &&
                                  (widget.user.profileImageUrl == null ||
                                      widget.user.profileImageUrl!.isEmpty))
                              ? Text(
                                  widget.user.name.isNotEmpty
                                      ? widget.user.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: _isUploadingPhoto
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.camera_alt,
                                    size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('Tap camera to change photo',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                const SizedBox(height: 28),

                // Name
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Username is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // University
                TextFormField(
                  controller: _universityController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'University',
                    prefixIcon: Icon(Icons.school_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'University is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Bio
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Bio (optional)',
                    prefixIcon: Icon(Icons.info_outline),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
