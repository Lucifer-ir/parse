import 'package:flutter/material.dart';
import '../../app/app_routes.dart';

const Color kGreen = Color(0xFF00A37A);
const Color kGreenDeep = Color(0xFF007A5C);
const Color kInk = Color(0xFF152E28);
const Color kMuted = Color(0xFF8A9994);
const Color kLine = Color(0xFFE1EDE8);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F1),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        top: -80,
                        left: -80,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kGreen.withValues(alpha: .06),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: -60,
                        right: -60,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kGreen.withValues(alpha: .05),
                          ),
                        ),
                      ),

                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Center(
                              child: Image.asset(
                                'assets/images/logo-parse.png',
                                width: 76,
                                height: 76,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      color: kGreen.withValues(alpha: .1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.school_rounded,
                                      size: 40,
                                      color: kGreen,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 16,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        'assets/images/character.webp',
                                        width: 240,
                                        height: 240,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) {
                                          return Container(
                                            width: 200,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: kGreen.withValues(
                                                alpha: .08,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.school_outlined,
                                              size: 84,
                                              color: kGreen,
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    const Text(
                                      'یادگیری زبان را از این‌جا شروع کنید',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: kInk,
                                        height: 1.5,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    const Text(
                                      'کلاس‌های انگلیسی، آلمانی و فرانسوی با بهترین اساتید',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: kMuted,
                                        height: 1.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              28,
                              12,
                              28,
                              16,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Login button
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.login,
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kGreenDeep,
                                    minimumSize: const Size.fromHeight(58),
                                    side: const BorderSide(
                                      color: kLine,
                                      width: 1.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    'ورود به حساب کاربری',
                                    style: TextStyle(
                                      fontFamily: 'Estedad',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                const Text(
                                  'با ادامه، قوانین و شرایط استفاده از پارسه را می‌پذیرم.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kMuted,
                                    height: 1.6,
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
            ),
          ),
        ),
      ),
    );
  }
}