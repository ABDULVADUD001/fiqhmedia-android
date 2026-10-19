
import 'package:flutter/material.dart';

import 'auth_service.dart';

class FiqhAuthScreen extends StatefulWidget {
  final ValueChanged<FiqhUser> onAuthenticated;

  const FiqhAuthScreen({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<FiqhAuthScreen> createState() =>
      _FiqhAuthScreenState();
}

class _FiqhAuthScreenState extends State<FiqhAuthScreen> {
  static const Color emerald = Color(0xFF087F69);
  static const Color deepGreen = Color(0xFF064C43);
  static const Color gold = Color(0xFFD6A449);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isRegister = false;
  bool loading = false;
  bool showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() => loading = true);

    try {
      final FiqhUser user;

      if (isRegister) {
        user = await FiqhAuthService.register(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        user = await FiqhAuthService.login(
          email: emailController.text,
          password: passwordController.text,
        );
      }

      if (!mounted) return;

      widget.onAuthenticated(user);
    } catch (error) {
      if (!mounted) return;

      final message = error is AuthException
          ? error.message
          : 'Kutilmagan xatolik yuz berdi.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    Center(
                      child: Image.asset(
                        'assets/icon/fiqhmedia.png',
                        width: 112,
                        height: 112,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.auto_stories_rounded,
                            size: 85,
                            color: emerald,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 19),

                    const Text(
                      'fiqhMedia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: deepGreen,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Ilm. Ishonch. Manba.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: emerald,
                      ),
                    ),

                    const SizedBox(height: 34),

                    Container(
                      padding: const EdgeInsets.all(23),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 26,
                            offset: const Offset(0, 9),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isRegister
                                ? 'Akkaunt yaratish'
                                : 'Xush kelibsiz!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w800,
                              color: deepGreen,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            isRegister
                                ? 'fiqhMedia’da yangi '
                                    'akkaunt oching.'
                                : 'Akkauntingizga kiring.',
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 24),

                          TextFormField(
                            controller: emailController,
                            keyboardType:
                                TextInputType.emailAddress,
                            textInputAction:
                                TextInputAction.next,
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'email@example.com',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                              ),
                              filled: true,
                              fillColor:
                                  const Color(0xFFF4F7F6),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              final email =
                                  (value ?? '').trim();

                              if (!email.contains('@') ||
                                  !email.contains('.')) {
                                return 'Emailni to‘g‘ri yozing';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          TextFormField(
                            controller: passwordController,
                            obscureText: !showPassword,
                            textInputAction:
                                TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!loading) submit();
                            },
                            decoration: InputDecoration(
                              labelText: 'Parol',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword =
                                        !showPassword;
                                  });
                                },
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  const Color(0xFFF4F7F6),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').length < 12) {
                                return 'Parol kamida '
                                    '12 belgidan iborat';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            height: 54,
                            child: FilledButton(
                              onPressed:
                                  loading ? null : submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: emerald,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child:
                                          CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isRegister
                                          ? 'Ro‘yxatdan o‘tish'
                                          : 'Kirish',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextButton(
                            onPressed: loading
                                ? null
                                : () {
                                    setState(() {
                                      isRegister = !isRegister;
                                    });
                                  },
                            child: Text(
                              isRegister
                                  ? 'Akkauntingiz bormi? Kirish'
                                  : 'Akkauntingiz yo‘qmi? '
                                      'Ro‘yxatdan o‘tish',
                              style: const TextStyle(
                                color: emerald,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: gold,
                          size: 17,
                        ),
                        SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Xavfsiz akkaunt tizimi',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
