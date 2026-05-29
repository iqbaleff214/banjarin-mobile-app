import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/auth_text_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && _initialized) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui.')),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        // Pre-fill from current state
        if (!_initialized && state is ProfileLoaded) {
          _nameCtrl.text = state.user.name;
          _initialized = true;
        }

        final isLoading = state is ProfileLoading;
        final failure = state is ProfileError ? state.failure : null;
        final nameError = failure is ValidationFailure
            ? failure.fieldErrors['name']?.firstOrNull
            : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Edit Profil')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  key: const Key('name_field'),
                  controller: _nameCtrl,
                  label: 'Nama',
                  textInputAction: TextInputAction.done,
                  errorText: nameError,
                  enabled: !isLoading,
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  key: const Key('save_button'),
                  onPressed: isLoading
                      ? null
                      : () => context.read<ProfileBloc>().add(
                            UpdateProfileName(_nameCtrl.text.trim()),
                          ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
