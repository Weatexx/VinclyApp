import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../auth/services/auth_service.dart';
import 'package:vincly/core/theme/context_extension.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _authService = AuthService();

  String _selectedLanguage = 'tr';
  String? _selectedAssetAvatar; 
  Uint8List? _selectedGalleryBytes; 

  bool _isLoading = false;

  final List<String> _vinclyAvatars = [
    'assets/avatars/cute_rabbit.png',
    'assets/avatars/cute_bear.png',
    'assets/avatars/cute_cat.png',
  ];

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 400,
      maxHeight: 400,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedGalleryBytes = bytes;
        _selectedAssetAvatar = null;
      });
      if (mounted) Navigator.pop(context); 
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "onboarding.profile_setup.choose_pic".tr(),
                style: TextStyle(
                  color: context.colors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _vinclyAvatars.map((path) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAssetAvatar = path;
                        _selectedGalleryBytes = null;
                      });
                      Navigator.pop(ctx);
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: context.colors.bgWhite,
                      backgroundImage: AssetImage(path),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Divider(color: context.colors.textLight),
              const SizedBox(height: 16),
              
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: context.colors.secondaryPeach,
                ),
                title: Text(
                  'onboarding.profile_setup.upload_gallery'.tr(),
                  style: TextStyle(color: context.colors.textDark),
                ),
                onTap: _pickFromGallery,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('onboarding.profile_setup.error_name'.tr())),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.completeProfileSetup(
        displayName: name,
        language: _selectedLanguage,
        assetAvatarPath: _selectedAssetAvatar,
        galleryImageBytes: _selectedGalleryBytes,
      );

      
      
      
      
      
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'onboarding.profile_setup.title'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textDark,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'onboarding.profile_setup.subtitle'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textLight, fontSize: 16),
              ),
              const SizedBox(height: 48),

              
              GestureDetector(
                onTap: _showAvatarPicker,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: context.colors.cardWhite,
                  backgroundImage: _selectedGalleryBytes != null
                      ? MemoryImage(_selectedGalleryBytes!)
                      : (_selectedAssetAvatar != null
                                ? AssetImage(_selectedAssetAvatar!)
                                : null)
                            as ImageProvider?,
                  child:
                      (_selectedAssetAvatar == null &&
                          _selectedGalleryBytes == null)
                      ? Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: context.colors.secondaryPeach,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 32),

              
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'onboarding.profile_setup.name_label'.tr(),
                  prefixIcon: Icon(
                    Icons.person,
                    color: context.colors.primaryPink,
                  ),
                  filled: true,
                  fillColor: context.colors.cardWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              
              Text(
                'onboarding.profile_setup.language_label'.tr(),
                style: TextStyle(color: context.colors.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedLanguage = 'tr');
                        context.setLocale(const Locale('tr'));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedLanguage == 'tr'
                            ? context.colors.secondaryPeach
                            : context.colors.cardWhite,
                        foregroundColor: _selectedLanguage == 'tr'
                            ? Colors.black
                            : context.colors.cardWhite,
                      ),
                      child: Text('Türkçe'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedLanguage = 'en');
                        context.setLocale(const Locale('en'));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedLanguage == 'en'
                            ? context.colors.secondaryPeach
                            : context.colors.cardWhite,
                        foregroundColor: _selectedLanguage == 'en'
                            ? Colors.black
                            : context.colors.cardWhite,
                      ),
                      child: Text('English'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryPink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'onboarding.profile_setup.btn_finish'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
