import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../navigation/bottom_nav.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Logo
              Image.asset('assets/logo.png', height: 120),
              const SizedBox(height: 10),

              /// Title & Subtitle (same as login)
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Start organizing your recipes today",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              /// Form Card (same border fix)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withAlpha((255 * 0.2).round()),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    /// Name Field
                    AppTextField(
                      hint: "Name",
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.textLight,
                      ),
                      fillColor: Colors.white,
                    ),
                    const SizedBox(height: 14),

                    /// Email Field
                    AppTextField(
                      hint: "Email",
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textLight,
                      ),
                      fillColor: Colors.white,
                    ),
                    const SizedBox(height: 14),

                    /// Password Field
                    AppTextField(
                      hint: "Password (At least 6 characters)",
                      isPassword: true,
                      prefixIcon: const Icon(
                        Icons.lock_outlined,
                        color: AppColors.textLight,
                      ),
                      fillColor: Colors.white,
                    ),
                    const SizedBox(height: 14),

                    /// Confirm Password Field
                    AppTextField(
                      hint: "Confirm Password",
                      isPassword: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textLight,
                      ),
                      fillColor: Colors.white,
                    ),

                    const SizedBox(height: 16),

                    /// Terms & Conditions Row (FIXED recognizer)
                    Row(
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          activeColor: AppColors.primary,
                          checkColor: Colors.white,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ), // FIXED
                          onChanged: (value) {
                            setState(() {
                              agreeToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                const TextSpan(text: "I agree to the "),
                                TextSpan(
                                  text: "Terms and Conditions",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer() // FIXED: Attached & imported
                                        ..onTap = () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Terms & Conditions opening...',
                                              ),
                                            ),
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// Create Account Button
                    PrimaryButton(
                      text: "Create Account",
                      onTap: agreeToTerms
                          ? () {
                              // TODO: Register logic
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BottomNav(),
                                ),
                              );
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please accept Terms & Conditions",
                                  ),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// Login redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
