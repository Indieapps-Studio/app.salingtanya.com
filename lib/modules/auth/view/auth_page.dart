import 'package:app_salingtanya/gen/assets.gen.dart';
import 'package:app_salingtanya/modules/top_level_providers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({
    Key? key,
    required this.lastLocation,
  }) : super(key: key);

  final String? lastLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Assets.images.logoSalingtanya.image(
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          _SignInWidget(lastLocation),
        ],
      ),
    );
  }
}

class _SignInWidget extends ConsumerWidget {
  const _SignInWidget(this.lastLocation, {Key? key}) : super(key: key);

  final String? lastLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return auth.maybeWhen(
      idle: () => Center(
        child: SignInButton(
          Buttons.Google,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                8,
              ),
            ),
          ),
          text: tr('signin.google'),
          onPressed: () async {
            await ref.read(authProvider.notifier).signInGoogle(lastLocation);
          },
        ),
      ),
      orElse: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
