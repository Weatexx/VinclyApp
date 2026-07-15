import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/services/auth_service.dart';
import 'package:vincly/core/theme/context_extension.dart';
import 'language_selection_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _isUploadingPic = false;

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
      if (mounted) Navigator.pop(context); // close bottom sheet
      setState(() => _isUploadingPic = true);
      try {
        await _authService.updateProfilePicture(galleryBytes: bytes);
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isUploadingPic = false);
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.bgWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'onboarding.profile_setup.choose_pic'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textDark,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children:
                    [
                      'assets/avatars/cute_rabbit.png',
                      'assets/avatars/cute_bear.png',
                      'assets/avatars/cute_cat.png',
                    ].map((path) {
                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(ctx);
                          setState(() => _isUploadingPic = true);
                          await _authService.updateProfilePicture(
                            assetPath: path,
                          );
                          setState(() => _isUploadingPic = false);
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: context.colors.cardWhite,
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
                  color: context.colors.primaryPink,
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

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.bgWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final themeProvider = Provider.of<ThemeProvider>(ctx, listen: false);
        return Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'profile.theme'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'profile.theme_system'.tr(),
                  style: TextStyle(color: context.colors.textDark),
                ),
                trailing: themeProvider.themeMode == ThemeMode.system
                    ? Icon(Icons.check, color: context.colors.primaryPink)
                    : null,
                onTap: () {
                  themeProvider.toggleTheme(ThemeMode.system);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(
                  'profile.theme_light'.tr(),
                  style: TextStyle(color: context.colors.textDark),
                ),
                trailing: themeProvider.themeMode == ThemeMode.light
                    ? Icon(Icons.check, color: context.colors.primaryPink)
                    : null,
                onTap: () {
                  themeProvider.toggleTheme(ThemeMode.light);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(
                  'profile.theme_dark'.tr(),
                  style: TextStyle(color: context.colors.textDark),
                ),
                trailing: themeProvider.themeMode == ThemeMode.dark
                    ? Icon(Icons.check, color: context.colors.primaryPink)
                    : null,
                onTap: () {
                  themeProvider.toggleTheme(ThemeMode.dark);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String? url, {double radius = 40}) {
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: context.colors.cardWhite,
        child: Icon(
          Icons.person,
          size: radius,
          color: context.colors.textLight,
        ),
      );
    }
    if (url.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: context.colors.cardWhite,
        backgroundImage: NetworkImage(url),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: context.colors.cardWhite,
        backgroundImage: AssetImage(url),
      );
    }
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('profile.copied'.tr())));
  }


  void _showUnlinkDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Unlink Partner',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to unlink from your partner? Your shared streak will be inaccessible until linked again.',
          style: TextStyle(color: context.colors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.textLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Unlink',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.unlinkPartner();
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Warning: This action is permanent and unrecoverable. Your account, messages, and profile will be deleted forever.',
          style: TextStyle(color: context.colors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.textLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'DELETE FOREVER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.deleteAccount();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: context.colors.cardWhite.withValues(alpha: 0.5),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? context.colors.secondaryPeach).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color ?? context.colors.secondaryPeach),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? context.colors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: context.colors.textLight,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'profile.title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _authService.getUserStream(),
        builder: (context, userSnap) {
          if (!userSnap.hasData || !userSnap.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = userSnap.data!.data() as Map<String, dynamic>;
          final partnerId = userData['partner_id'] as String?;
          final myPic = userData['profile_pic_url'] as String?;
          final myName = userData['display_name'] ?? 'User';
          final myCode = userData['vincly_code'] ?? '------';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // === CURRENT USER SECTION ===
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _isUploadingPic ? null : _showAvatarPicker(),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            _buildAvatar(myPic, radius: 55),
                            if (_isUploadingPic)
                              Positioned.fill(
                                child: CircularProgressIndicator(
                                  color: context.colors.primaryPink,
                                ),
                              ),
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: context.colors.primaryPink,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        myName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _copyToClipboard(myCode),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.secondaryPeach.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: context.colors.secondaryPeach,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${'profile.vincly_code'.tr()}: ',
                                style: TextStyle(
                                  color: context.colors.secondaryPeach,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                myCode,
                                style: TextStyle(
                                  color: context.colors.textDark,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.copy,
                                color: context.colors.secondaryPeach,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // === LINKED PARTNER SECTION ===
                Text(
                  'profile.linked_partner'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                partnerId == null
                    ? Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'profile.not_linked'.tr(),
                          style: TextStyle(
                            color: context.colors.textLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : StreamBuilder<DocumentSnapshot>(
                        stream: _authService.getPartnerStream(partnerId),
                        builder: (context, partnerSnap) {
                          if (!partnerSnap.hasData ||
                              !partnerSnap.data!.exists) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final pData =
                              partnerSnap.data!.data() as Map<String, dynamic>;
                          final pPic = pData['profile_pic_url'] as String?;
                          final pName = pData['display_name'] ?? 'Partner';

                          return Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.colors.cardWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.colors.primaryPink.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildAvatar(pPic, radius: 24),
                                const SizedBox(width: 16),
                                Text(
                                  pName,
                                  style: TextStyle(
                                    color: context.colors.textDark,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.favorite,
                                  color: context.colors.primaryPink,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                // === VINCLY PRO BANNER ===
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vincly Pro Subscription coming soon!'),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          context.colors.primaryPink,
                          context.colors.secondaryPeach,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primaryPink.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Colors.amber,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'profile.pro_title'.tr(),
                                style: TextStyle(
                                  color: context.colors.textDark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'profile.pro_subtitle'.tr(),
                                style: TextStyle(
                                  color: context.colors.textDark.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: context.colors.textDark,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // === SETTINGS MENU ===
                Text(
                  'profile.settings'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildSettingItem(
                  Icons.language_rounded,
                  context.locale.languageCode == 'tr'
                      ? 'Dil Değiştir'
                      : 'Change Language',
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LanguageSelectionPage(),
                    ),
                  ),
                ),
                _buildSettingItem(
                  Icons.notifications_active_outlined,
                  'profile.notifications'.tr(),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Notification settings coming soon! 🔔',
                        ),
                        backgroundColor: context.colors.primaryPink,
                      ),
                    );
                  },
                ),
                _buildSettingItem(
                  Icons.color_lens_outlined,
                  'profile.theme'.tr(),
                  () {
                    _showThemePicker();
                  },
                ),

                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                        child: Text(
                          'DANGER ZONE',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      _buildSettingItem(
                        Icons.link_off,
                        'Unlink Partner',
                        () => _showUnlinkDialog(),
                        color: Colors.redAccent,
                      ),
                      _buildSettingItem(
                        Icons.delete_forever,
                        'Delete Account',
                        () => _showDeleteDialog(),
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSettingItem(
                  Icons.logout,
                  'profile.logout'.tr(),
                  () => _authService.signOut(),
                  color: context.colors.textLight,
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}
