import 'package:flutter/material.dart';
import 'package:tastefit/presentation/auth/forgot_password_screen.dart';
//import 'package:flutter/gestures.dart';  //For TapGestureRecognizer (if needed elsewhere)
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../navigation/bottom_nav.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Logo
              Image.asset('assets/logo.png', height: 120),
              const SizedBox(height: 10),

              /// Title
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              /// Subtitle
              Text(
                "Login to access your recipes",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              /// Form Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(
                      (255 * 0.3).round(),
                    ), // FIXED: Alpha
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    /// Email Field
                    AppTextField(
                      hint: "Email",
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textLight,
                      ), // Now supported
                      fillColor: Colors.white, 
                    ),
                    const SizedBox(height: 16),

                    /// Password Field
                    AppTextField(
                      hint: "Enter your password",
                      isPassword: true,
                      prefixIcon: const Icon(
                        Icons.lock_outlined,
                        color: AppColors.textLight,
                      ),
                      fillColor: Colors.white,
                    ),

                    const SizedBox(height: 20),

                    /// Remember Me + Forgot Password Row
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          activeColor: AppColors.primary,
                          checkColor: Colors.white,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ), // FIXED: Static side
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "Remember me",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// Login Button
                    PrimaryButton(
                      text: "Login",
                      onTap: () {
                        // TODO: Auth logic
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const BottomNav()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              /// Sign Up redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
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
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign up",
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

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
