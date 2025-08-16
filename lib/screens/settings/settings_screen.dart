import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/profile_service.dart';
import '../../services/localization_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _budgetController = TextEditingController();
  bool _aiAdviceEnabled = true;
  bool _isLoading = false;
  String _selectedLanguage = 'fr';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser != null) {
      _budgetController.text = authService.currentUser!.monthlyBudget.toString();
      _aiAdviceEnabled = authService.currentUser!.aiAdviceEnabled;
      _selectedLanguage = authService.currentUser!.language;
    }
  }

  Future<void> _updateBudget() async {
    final amount = double.tryParse(_budgetController.text);
    if (amount == null || amount < 0) {
             ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('invalid_amount'.tr()),
           backgroundColor: Colors.red,
         ),
       );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.updateUserBudget(amount);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('budget_updated'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error'.tr()}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateAiAdvice(bool enabled) async {
    setState(() {
      _aiAdviceEnabled = enabled;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.updateAiAdviceSetting(enabled);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled ? 'ai_advice_enabled'.tr() : 'ai_advice_disabled'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error'.tr()}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfilePhoto() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context, listen: false);
    
    if (authService.currentUser == null) return;

    await profileService.showImageSourceDialog(
      context,
      authService.currentUser!.uid,
      (String? photoUrl) async {
        if (photoUrl != null) {
          await authService.updateProfilePhoto(photoUrl);
          if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile_photo_updated'.tr()),
            backgroundColor: Colors.green,
          ),
        );
          }
        }
      },
    );
  }

  Future<void> _updateLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final localizationService = Provider.of<LocalizationService>(context, listen: false);
      
      await authService.updateLanguage(languageCode);
      await localizationService.changeLanguage(context, languageCode);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('language_updated'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error'.tr()}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('sign_out'.tr()),
        content: Text('sign_out_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('sign_out'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final notificationService = Provider.of<NotificationService>(context, listen: false);
        
        if (authService.currentUser != null) {
          await notificationService.deleteFcmToken(authService.currentUser!.uid);
        }
        
        await authService.signOut();
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('${'error'.tr()}: ${e.toString()}'),
             backgroundColor: Colors.red,
           ),
         );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
             appBar: AppBar(
         title: Text('settings'.tr()),
         elevation: 0,
       ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                 Text(
                           'profile'.tr(),
                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _updateProfilePhoto,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    backgroundImage: authService.currentUser!.profilePhotoUrl != null
                                        ? NetworkImage(authService.currentUser!.profilePhotoUrl!)
                                        : null,
                                    child: authService.currentUser!.profilePhotoUrl == null
                                        ? Text(
                                            authService.currentUser!.name[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                            ),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authService.currentUser!.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    authService.currentUser!.email,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                                                     TextButton.icon(
                                     onPressed: _updateProfilePhoto,
                                     icon: const Icon(Icons.edit, size: 16),
                                     label: Text('edit_profile_photo'.tr()),
                                     style: TextButton.styleFrom(
                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                     ),
                                   ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Budget Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                 Text(
                           'monthly_budget'.tr(),
                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _budgetController,
                                keyboardType: TextInputType.number,
                                                                 decoration: InputDecoration(
                                   labelText: 'amount'.tr(),
                                   prefixIcon: const Icon(Icons.attach_money),
                                 ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _updateBudget,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                                                     : Text('update'.tr()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // AI Advice Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                 Text(
                           'ai_advice'.tr(),
                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                        const SizedBox(height: 8),
                                                 Text(
                           'ai_advice_description'.tr(),
                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                           ),
                         ),
                        const SizedBox(height: 16),
                                                 SwitchListTile(
                           title: Text('enable_ai_advice'.tr()),
                           subtitle: Text('ai_advice_subtitle'.tr()),
                           value: _aiAdviceEnabled,
                           onChanged: _updateAiAdvice,
                         ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Language Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                 Text(
                           'language'.tr(),
                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                        const SizedBox(height: 8),
                                                 Text(
                           'choose_language'.tr(),
                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                           ),
                         ),
                        const SizedBox(height: 16),
                        Consumer<LocalizationService>(
                          builder: (context, localizationService, child) {
                            final languages = localizationService.getAvailableLanguages();
                            return Column(
                              children: languages.map((language) {
                                final isSelected = language['code'] == _selectedLanguage;
                                return ListTile(
                                  leading: Text(
                                    language['flag']!,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  title: Text(language['name']!),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).colorScheme.primary,
                                        )
                                      : null,
                                  onTap: () => _updateLanguage(language['code']!),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // App Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                 Text(
                           'about'.tr(),
                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                        const SizedBox(height: 16),
                                                 ListTile(
                           leading: const Icon(Icons.info_outline),
                           title: Text('version'.tr()),
                           subtitle: const Text('1.0.0'),
                         ),
                         ListTile(
                           leading: const Icon(Icons.description),
                           title: Text('license'.tr()),
                           subtitle: const Text('MIT'),
                         ),
                         ListTile(
                           leading: const Icon(Icons.code),
                           title: Text('developed_by'.tr()),
                           subtitle: Text('team_name'.tr()),
                         ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                                         child: Text('sign_out'.tr()),
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
