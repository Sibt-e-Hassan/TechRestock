import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tech_restock/app.dart';
import 'package:tech_restock/utils/auth_messages.dart';
import 'package:tech_restock/utils/user_greeting.dart';
import 'package:tech_restock/widgets/account_deletion_sheet.dart';
import 'package:tech_restock/screens/account/legal_center_screen.dart';
import 'package:tech_restock/screens/account/info_screen.dart';
import 'package:tech_restock/screens/orders/orders_screen.dart';
import 'package:tech_restock/screens/restock/restock_screen.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/widgets/app_modal.dart';
import 'package:tech_restock/widgets/outlined_field.dart';
import 'package:tech_restock/widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.openLegalOnMount = false});

  final bool openLegalOnMount;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isBusy = false;
  late String _email;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _email = user?.email ?? 'No email';

    if (widget.openLegalOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LegalCenterScreen()),
        );
      });
    }
  }

  Stream<String>? _profileNameStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => UserGreeting.resolveDisplayName(user, doc.data()));
  }

  Future<void> _showEditNameModal(String currentName) async {
    await showAppModal<void>(
      context,
      child: _EditProfileNameModal(
        initialName: currentName,
        onSuccess: () {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile name updated successfully.')),
          );
        },
      ),
    );
  }

  Future<void> _showChangePasswordModal() async {
    final currentPassword = TextEditingController();
    final newPassword = TextEditingController();
    final result = await showAppModal<Map<String, String>>(
      context,
      child: AppModalCard(
        title: 'Change password',
        actions: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: AppTheme.link),
            ),
            const SizedBox(width: 8),
            PrimaryButton(
              label: 'Update',
              fullWidth: false,
              onPressed: () => Navigator.of(context).pop({
                'currentPassword': currentPassword.text.trim(),
                'newPassword': newPassword.text.trim(),
              }),
            ),
          ],
        ),
        child: Column(
          children: [
            OutlinedField(
              label: 'Current password',
              controller: currentPassword,
              obscureText: true,
              showToggle: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 12),
            OutlinedField(
              label: 'New password',
              controller: newPassword,
              obscureText: true,
              showToggle: true,
              prefixIcon: Icons.password_outlined,
            ),
          ],
        ),
      ),
    );

    if (result == null) {
      currentPassword.dispose();
      newPassword.dispose();
      return;
    }

    await _changePassword(
      currentPassword: result['currentPassword'] ?? '',
      newPassword: result['newPassword'] ?? '',
    );

    currentPassword.dispose();
    newPassword.dispose();
  }

  Future<void> _changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      return;
    }
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter current and new password.')),
      );
      return;
    }
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 6 characters.')),
      );
      return;
    }

    setState(() => _isBusy = true);
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password updated successfully.')));
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Failed to update password.')));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unexpected error while updating password.')));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _deleteAccount(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password is required to delete account.')));
      return;
    }

    setState(() => _isBusy = true);
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      final firestore = FirebaseFirestore.instance;
      final cartItems = await firestore.collection('users').doc(user.uid).collection('cart').get();
      for (final doc in cartItems.docs) {
        await doc.reference.delete();
      }

      final orders = await firestore.collection('orders').where('userId', isEqualTo: user.uid).get();
      for (final doc in orders.docs) {
        await doc.reference.delete();
      }

      await firestore.collection('users').doc(user.uid).delete();

      await user.delete();

      if (!mounted) {
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil(
        ShoppandaApp.signInRoute,
        (route) => false,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account deleted permanently.')));
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Failed to delete account.')));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unexpected error while deleting account.')));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }


  Future<void> _signOut() async {
    setState(() => _isBusy = true);
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyAuthErrorMessage(e))),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyGenericAuthError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _showDeleteModal() async {
    final passwordController = TextEditingController();
    await showAppModal<void>(
      context,
      child: AppModalCard(
        title: 'Delete account?',
        actions: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: AppTheme.link),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 140,
              child: PrimaryButton(
                label: 'Delete account',
                fullWidth: true,
                onPressed: () async {
                  final password = passwordController.text.trim();
                  Navigator.of(context).pop();
                  await _deleteAccount(password);
                },
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This permanently deletes your sign-in account, your profile in our database, and order records linked to your user ID. This cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                final parentContext = context;
                Navigator.of(parentContext).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (parentContext.mounted) {
                    showAccountDeletionSheet(parentContext);
                  }
                });
              },
              child: Text(
                'Account deletion help',
                style: AppTheme.link.copyWith(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedField(
              label: 'Confirm password',
              controller: passwordController,
              obscureText: true,
              showToggle: true,
              prefixIcon: Icons.lock_outline,
            ),
          ],
        ),
      ),
    );
    passwordController.dispose();
  }

  Future<void> _openEditName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final currentName = UserGreeting.resolveDisplayName(user, doc.data());
    if (!mounted) {
      return;
    }
    await _showEditNameModal(currentName);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Column(
      children: [
        Container(
          color: AppColors.header,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                14,
                AppTheme.spacingLg,
                18,
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                12,
                AppTheme.spacingLg,
                12,
              ),
              children: [
                // --- Avatar + name + email ---
                StreamBuilder<String>(
                  stream: _profileNameStream(),
                  builder: (context, nameSnapshot) {
                    final displayName = nameSnapshot.data ??
                        UserGreeting.resolveDisplayName(
                          FirebaseAuth.instance.currentUser!,
                          null,
                        );
                    return _ProfileHeader(
                      name: displayName,
                      email: _email,
                      onEdit: _isBusy ? null : _openEditName,
                    );
                  },
                ),
                const SizedBox(height: 20),
                // --- Grouped account list ---
                _AccountGroup(
                  rows: [
                    _AccountRow(
                      icon: Icons.receipt_long_outlined,
                      label: 'Orders',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrdersScreen(showBack: true),
                        ),
                      ),
                    ),
                    _AccountRow(
                      icon: Icons.badge_outlined,
                      label: 'My details',
                      onTap: _isBusy ? null : _openEditName,
                    ),
                    _AccountRow(
                      icon: Icons.event_repeat,
                      label: 'Restock reminders',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RestockScreen()),
                      ),
                    ),
                    _AccountRow(
                      icon: Icons.password_outlined,
                      label: 'Change password',
                      onTap: _isBusy ? null : _showChangePasswordModal,
                    ),
                    _AccountRow(
                      icon: Icons.help_outline,
                      label: 'Help',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InfoScreen(
                            title: 'Help',
                            sections: kHelpSections,
                          ),
                        ),
                      ),
                    ),
                    _AccountRow(
                      icon: Icons.info_outline,
                      label: 'About',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InfoScreen(
                            title: 'About',
                            sections: kAboutSections,
                          ),
                        ),
                      ),
                    ),
                    _AccountRow(
                      icon: Icons.description_outlined,
                      label: 'Privacy & Terms',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LegalCenterScreen()),
                      ),
                    ),
                    _AccountRow(
                      icon: Icons.delete_outline,
                      label: 'Delete account',
                      danger: true,
                      onTap: _isBusy ? null : _showDeleteModal,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'TechRestock · v2.0.5',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                ),
              ],
            ),
          ),
          // --- Sign out pinned to the bottom ---
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                8,
                AppTheme.spacingLg,
                12,
              ),
              child: _LogoutButton(
                busy: _isBusy,
                onTap: _isBusy ? () {} : _signOut,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar + name + email row with an edit pencil (matches the reference).
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.email, this.onEdit});

  final String name;
  final String email;
  final VoidCallback? onEdit;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.logoGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.tealDark.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            _initials,
            style: AppTheme.mono(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.teal),
            tooltip: 'Edit name',
          ),
      ],
    );
  }
}

/// A grouped white card of account rows separated by hairline dividers.
class _AccountGroup extends StatelessWidget {
  const _AccountGroup({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(const Divider(height: 1, thickness: 1, color: AppColors.borderInput, indent: 62));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.borderInput),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

/// One tappable account row: soft icon square + label + chevron.
class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? AppColors.danger : AppColors.teal;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: danger ? AppColors.danger : AppColors.text,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  color: danger ? AppColors.danger.withValues(alpha: 0.5) : AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

/// Outlined pill "Log out" button with a logout icon (matches the reference).
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap, required this.busy});

  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySoft,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          child: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.teal),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 18, color: AppColors.teal),
                    SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _EditProfileNameModal extends StatefulWidget {
  const _EditProfileNameModal({
    required this.initialName,
    required this.onSuccess,
  });

  final String initialName;
  final VoidCallback onSuccess;

  @override
  State<_EditProfileNameModal> createState() => _EditProfileNameModalState();
}

class _EditProfileNameModalState extends State<_EditProfileNameModal> {
  late final TextEditingController _nameController;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      setState(() => _errorMessage = 'Please enter your name.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    if (newName == widget.initialName.trim()) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await user.updateDisplayName(newName);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await user.reload();

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      widget.onSuccess();
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _errorMessage = e.message ?? 'Failed to update name.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _errorMessage = 'Unexpected error while updating name.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModalCard(
      title: 'Edit profile name',
      actions: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              child: Text('Cancel', style: AppTheme.link),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: 'Save',
              isLoading: _isSaving,
              onPressed: _isSaving ? () {} : _save,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedField(
            label: 'Name',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }
}
