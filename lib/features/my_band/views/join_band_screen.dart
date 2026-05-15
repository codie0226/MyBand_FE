import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/band_repository.dart';
import '../providers/band_provider.dart';

class JoinBandScreen extends ConsumerStatefulWidget {
  const JoinBandScreen({super.key});

  @override
  ConsumerState<JoinBandScreen> createState() => _JoinBandScreenState();
}

class _JoinBandScreenState extends ConsumerState<JoinBandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final band = await ref
          .read(bandRepositoryProvider)
          .joinByInviteCode(_inviteCodeController.text.trim());
      ref.invalidate(bandsProvider);
      ref.read(selectedBandIdProvider.notifier).select(band.id);
      ref.invalidate(selectedBandProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${band.name} 밴드에 가입했습니다.')));
      context.go('/my_band');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('밴드 가입 실패: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('밴드 가입'), centerTitle: false),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Text(
                '초대 코드를 입력해 밴드에 참여하세요.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _inviteCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(hintText: '예: AB12CD34'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? '초대 코드를 입력해주세요.'
                    : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text('가입하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
