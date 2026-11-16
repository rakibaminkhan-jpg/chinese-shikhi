import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_screen.dart';
import 'learning_hub_screens.dart';
import 'services/learning_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegister = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _syncing = false;
  bool _emailActionLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _authError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'এই ইমেইল দিয়ে অ্যাকাউন্ট আগে থেকেই আছে।';
      case 'invalid-email':
        return 'সঠিক ইমেইল ঠিকানা লিখুন।';
      case 'weak-password':
        return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের দিন।';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'ইমেইল অথবা পাসওয়ার্ড সঠিক নয়।';
      case 'network-request-failed':
        return 'ইন্টারনেট সংযোগ পরীক্ষা করুন।';
      case 'too-many-requests':
        return 'অনেকবার চেষ্টা হয়েছে। কিছুক্ষণ পরে চেষ্টা করুন।';
      default:
        return e.message ?? 'সমস্যা হয়েছে। আবার চেষ্টা করুন।';
    }
  }

  Future<void> _saveUserDocument(User user, {String? name}) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final existing = await ref.get();

    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    if (name != null && name.trim().isNotEmpty) {
      data['displayName'] = name.trim();
    } else if (!existing.exists) {
      data['displayName'] = user.displayName ?? '';
    }

    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _message('ইমেইল ও পাসওয়ার্ড লিখুন।');
      return;
    }

    if (_isRegister && name.isEmpty) {
      _message('আপনার নাম লিখুন।');
      return;
    }

    if (password.length < 6) {
      _message('পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।');
      return;
    }

    setState(() => _loading = true);

    try {
      UserCredential credential;

      if (_isRegister) {
        credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user!;
        await user.updateDisplayName(name);
        await user.sendEmailVerification();
        await _saveUserDocument(user, name: name);
        await LearningStore.syncWithCloud();
      } else {
        credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await credential.user!.reload();
        await _saveUserDocument(_auth.currentUser ?? credential.user!);
        await LearningStore.syncWithCloud();
      }

      if (mounted) {
        if (_isRegister) {
          _message(
              'অ্যাকাউন্ট তৈরি হয়েছে। Verification email পাঠানো হয়েছে—ইনবক্স দেখুন।');
        } else if ((_auth.currentUser ?? credential.user!).emailVerified) {
          _message('সফলভাবে Login করেছেন!');
        } else {
          _message('Login সফল। আপনার ইমেইল এখনো Verify করা হয়নি।');
        }
      }
    } on FirebaseAuthException catch (e) {
      _message(_authError(e));
    } catch (e) {
      _message('সমস্যা হয়েছে: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _message('প্রথমে ইমেইল লিখুন।');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _message('পাসওয়ার্ড পরিবর্তনের লিংক ইমেইলে পাঠানো হয়েছে।');
    } on FirebaseAuthException catch (e) {
      _message(_authError(e));
    }
  }

  Future<void> _updateName(User user) async {
    final controller = TextEditingController(
      text: user.displayName ?? '',
    );

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নাম পরিবর্তন'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'আপনার নাম',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim(),
            ),
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (name == null || name.isEmpty) return;

    try {
      await user.updateDisplayName(name);
      await _saveUserDocument(user, name: name);
      await LearningStore.syncWithCloud();
      await user.reload();
      if (mounted) setState(() {});
      _message('প্রোফাইল আপডেট হয়েছে।');
    } catch (e) {
      _message('প্রোফাইল আপডেট করা যায়নি: $e');
    }
  }

  Future<void> _sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      _message('প্রথমে Login করুন।');
      return;
    }

    if (user.emailVerified) {
      _message('আপনার ইমেইল ইতিমধ্যে Verified।');
      return;
    }

    setState(() => _emailActionLoading = true);
    try {
      await user.sendEmailVerification();
      _message('Verification email আবার পাঠানো হয়েছে।');
    } on FirebaseAuthException catch (e) {
      _message(_authError(e));
    } catch (e) {
      _message('ইমেইল পাঠানো যায়নি: $e');
    } finally {
      if (mounted) setState(() => _emailActionLoading = false);
    }
  }

  Future<void> _refreshEmailVerification() async {
    setState(() => _emailActionLoading = true);
    try {
      await _auth.currentUser?.reload();
      if (!mounted) return;
      setState(() {});
      final user = _auth.currentUser;
      _message(user?.emailVerified == true
          ? 'সফল! আপনার ইমেইল Verified হয়েছে।'
          : 'এখনো Verify হয়নি। ইমেইল থেকে verification link-এ চাপুন।');
    } on FirebaseAuthException catch (e) {
      _message(_authError(e));
    } catch (e) {
      _message('Status পরীক্ষা করা যায়নি: $e');
    } finally {
      if (mounted) setState(() => _emailActionLoading = false);
    }
  }

  Future<void> _syncData() async {
    setState(() => _syncing = true);
    try {
      await LearningStore.syncWithCloud();
      _message('আপনার শেখার তথ্য Cloud-এ Sync হয়েছে।');
    } catch (e) {
      _message('Sync করা যায়নি: $e');
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      _message('আপনি Logout করেছেন।');
    } catch (e) {
      _message('Logout করা যায়নি: $e');
    }
  }

  Widget _loginScreen() {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার প্রোফাইল'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 85,
                      width: 85,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _isRegister ? 'নতুন অ্যাকাউন্ট তৈরি করুন' : 'স্বাগতম!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'আপনার শেখার অগ্রগতি সংরক্ষণ করতে Login করুন।',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (_isRegister) ...[
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'আপনার নাম',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'ইমেইল',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'পাসওয়ার্ড',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _loading ? null : _submitAuth,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator()
                          : Text(
                              _isRegister ? 'অ্যাকাউন্ট তৈরি করুন' : 'Login',
                            ),
                    ),
                    if (!_isRegister)
                      TextButton(
                        onPressed: _resetPassword,
                        child: const Text('পাসওয়ার্ড ভুলে গেছেন?'),
                      ),
                    const Divider(height: 25),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => setState(
                                () => _isRegister = !_isRegister,
                              ),
                      child: Text(
                        _isRegister
                            ? 'আগে অ্যাকাউন্ট আছে? Login করুন'
                            : 'নতুন ব্যবহারকারী? Signup করুন',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileView(User user) {
    final colorScheme = Theme.of(context).colorScheme;
    final userRef = _firestore.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার প্রোফাইল'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? {};
          final name = (data['displayName'] as String?)?.isNotEmpty == true
              ? data['displayName'] as String
              : (user.displayName ?? 'ব্যবহারকারী');

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const SizedBox(height: 15),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'চ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user.email ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFD4AF37),
                    child: Icon(
                      Icons.insights_rounded,
                      color: Color(0xFF7A1717),
                    ),
                  ),
                  title: const Text(
                    'Learning Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'XP, Level, Streak ও শেখার সম্পূর্ণ অগ্রগতি দেখুন',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ProgressDashboardScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('নাম'),
                      subtitle: Text(name),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _updateName(user),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('ইমেইল'),
                      subtitle: Text(user.email ?? ''),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        user.emailVerified
                            ? Icons.verified_user_rounded
                            : Icons.mark_email_unread_outlined,
                        color: user.emailVerified
                            ? Colors.green
                            : colorScheme.primary,
                      ),
                      title: const Text('অ্যাকাউন্ট স্ট্যাটাস'),
                      subtitle: Text(
                        user.emailVerified
                            ? 'ইমেইল Verified'
                            : 'ইমেইল এখনো Verified নয়',
                      ),
                    ),
                    if (!user.emailVerified) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FilledButton.icon(
                              onPressed: _emailActionLoading
                                  ? null
                                  : _refreshEmailVerification,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('আমি ইমেইল Verify করেছি'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _emailActionLoading
                                  ? null
                                  : _sendVerificationEmail,
                              icon: const Icon(
                                Icons.mark_email_unread_outlined,
                              ),
                              label: const Text(
                                'Verification Email আবার পাঠান',
                              ),
                            ),
                            if (_emailActionLoading)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud_done_rounded),
                  title: const Text('Firebase Cloud Profile'),
                  subtitle: Text(
                    snapshot.hasError
                        ? 'Cloud data লোড করা যায়নি'
                        : 'আপনার Profile Firestore-এ সংরক্ষিত',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _syncing ? null : _syncData,
                icon: _syncing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_sync_rounded),
                label: Text(
                  _syncing ? 'Sync হচ্ছে...' : 'শেখার তথ্য Cloud Sync করুন',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(49),
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return _loginScreen();
        }

        return _profileView(user);
      },
    );
  }
}
