import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/widgets/google_logo.dart';
import '../bloc/auth_bloc.dart';

class AuthDialog extends StatefulWidget {
  final bool initialIsSignUp;

  const AuthDialog({
    super.key,
    this.initialIsSignUp = false,
  });

  static Future<void> show(BuildContext context, {bool isSignUp = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: AuthDialog(initialIsSignUp: isSignUp),
      ),
    );
  }

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  late bool _isSignUp;
  bool _isForgotPassword = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
    _nameController.addListener(_clearError);
    _ageController.addListener(_clearError);
    _emailController.addListener(_clearError);
    _passwordController.addListener(_clearError);
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_clearError);
    _ageController.removeListener(_clearError);
    _emailController.removeListener(_clearError);
    _passwordController.removeListener(_clearError);
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    if (_isForgotPassword) {
      context.read<AuthBloc>().add(SendPasswordResetEvent(email));
      return;
    }

    if (_isSignUp) {
      context.read<AuthBloc>().add(
            SignUpWithEmailEvent(
              email: email,
              password: password,
              name: name.isNotEmpty ? name : null,
              age: age,
            ),
          );
    } else {
      context.read<AuthBloc>().add(
            SignInWithEmailEvent(email: email, password: password),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final sheetHeight = (screenHeight * 0.82).clamp(580.0, screenHeight * 0.95);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessMessageState) {
          NeoToast.showSuccess(
            context,
            state.message,
          );
          if (!_isForgotPassword || !state.isAnonymous) {
            Navigator.of(context).pop();
          } else {
            setState(() {
              _isForgotPassword = false;
              _errorMessage = null;
            });
          }
        } else if (state is AuthErrorState) {
          setState(() {
            _errorMessage = state.errorMessage;
          });
          NeoToast.showError(
            context,
            state.errorMessage,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;

        return Container(
          height: sheetHeight,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: bottomInset > 0 ? bottomInset + 12 : 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                width: 3,
              ),
              left: BorderSide(
                color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                width: 3,
              ),
              right: BorderSide(
                color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: NeoColors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: NeoColors.purple,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.cloud_sync_rounded,
                      color: NeoColors.purple,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isForgotPassword
                              ? 'Reset Password'
                              : (_isSignUp ? 'Create Account' : 'Sign In'),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          _isForgotPassword
                              ? 'Enter email to receive reset instructions'
                              : (_isSignUp
                                  ? 'Save your profile & back up history to cloud'
                                  : 'Access your cloud backups & history'),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              if (!_isForgotPassword) ...[
                // Google Sign In CTA
                NeoButton(
                  label: 'CONTINUE WITH GOOGLE',
                  backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  textColor: isDark ? Colors.white : NeoColors.textPrimaryLight,
                  borderColor: isDark ? Colors.white24 : NeoColors.borderLight,
                  icon: const GoogleLogo(size: 20),
                  isLoading: isLoading,
                  fullWidth: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<AuthBloc>().add(SignInWithGoogleEvent());
                        },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark ? Colors.white24 : Colors.black12,
                        thickness: 1.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark ? Colors.white24 : Colors.black12,
                        thickness: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Toggle Mode Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          title: 'Sign In',
                          isSelected: !_isSignUp,
                          isDark: isDark,
                          onTap: () => setState(() {
                            _isSignUp = false;
                            _errorMessage = null;
                          }),
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          title: 'Create Account',
                          isSelected: _isSignUp,
                          isDark: isDark,
                          onTap: () => setState(() {
                            _isSignUp = true;
                            _errorMessage = null;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Inline Error Banner if any
                        if (_errorMessage != null) ...[
                          _buildErrorBanner(isDark),
                          const SizedBox(height: 14),
                        ],

                        // If Sign Up: Full Name and Age fields
                        if (_isSignUp && !_isForgotPassword) ...[
                          Text(
                            'Full Name',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hintText: 'Alex Johnson',
                              prefixIcon: Icons.person_outline_rounded,
                              isDark: isDark,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'Age',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hintText: '25',
                              prefixIcon: Icons.cake_outlined,
                              isDark: isDark,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your age';
                              }
                              final parsed = int.tryParse(val.trim());
                              if (parsed == null || parsed < 5 || parsed > 120) {
                                return 'Please enter a valid age';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email Field
                        Text(
                          'Email Address',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: _isForgotPassword ? TextInputAction.done : TextInputAction.next,
                          decoration: _inputDecoration(
                            hintText: 'alex@example.com',
                            prefixIcon: Icons.alternate_email_rounded,
                            isDark: isDark,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field (if not forgot password)
                        if (!_isForgotPassword) ...[
                          Text(
                            'Password',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: _inputDecoration(
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline_rounded,
                              isDark: isDark,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Forgot Password link (in Sign In mode)
                          if (!_isSignUp)
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () => setState(() {
                                  _isForgotPassword = true;
                                  _errorMessage = null;
                                }),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: NeoColors.purple,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],

                        // Action Button
                        NeoButton(
                          label: isLoading
                              ? 'PROCESSING...'
                              : (_isForgotPassword
                                  ? 'SEND RESET LINK'
                                  : (_isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN')),
                          backgroundColor: _isSignUp ? NeoColors.green : NeoColors.purple,
                          textColor: _isSignUp ? NeoColors.textPrimaryLight : Colors.white,
                          isLoading: isLoading,
                          fullWidth: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          onPressed: isLoading ? null : _submit,
                          icon: isLoading
                              ? null
                              : Icon(
                                  _isForgotPassword
                                      ? Icons.mail_outline_rounded
                                      : (_isSignUp
                                          ? Icons.person_add_rounded
                                          : Icons.login_rounded),
                                  color: _isSignUp ? NeoColors.textPrimaryLight : Colors.white,
                                  size: 18,
                                ),
                        ),

                        if (_isForgotPassword) ...[
                          const SizedBox(height: 14),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => setState(() {
                                _isForgotPassword = false;
                                _errorMessage = null;
                              }),
                              icon: const Icon(Icons.arrow_back_rounded, size: 16),
                              label: Text(
                                'Back to Sign In',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF334155) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: isDark ? Colors.white30 : NeoColors.borderLight,
                  width: 1.5,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected
                  ? (isDark ? Colors.white : NeoColors.textPrimaryLight)
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: isDark ? Colors.white38 : Colors.black38,
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      prefixIcon: Icon(
        prefixIcon,
        size: 20,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? NeoColors.borderDark : NeoColors.borderLight,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: NeoColors.purple,
          width: 2.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: NeoColors.pink,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: NeoColors.pink,
          width: 2.5,
        ),
      ),
    );
  }

  Widget _buildErrorBanner(bool isDark) {
    if (_errorMessage == null) return const SizedBox.shrink();

    final isAlreadyRegistered = _errorMessage!.toLowerCase().contains('already exists') ||
        _errorMessage!.toLowerCase().contains('already in use') ||
        _errorMessage!.toLowerCase().contains('sign in instead');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: NeoStyles.neoDecoration(
        backgroundColor: isDark ? const Color(0xFF3B1219) : const Color(0xFFFEE2E2),
        borderColor: NeoColors.pink,
        radius: 12,
        shadow: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: NeoColors.pink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFFECACA) : const Color(0xFF991B1B),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _errorMessage = null),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
          if (isAlreadyRegistered && _isSignUp) ...[
            const SizedBox(height: 10),
            NeoButton(
              label: 'SWITCH TO SIGN IN',
              backgroundColor: NeoColors.cyan,
              textColor: NeoColors.textPrimaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              onPressed: () {
                setState(() {
                  _isSignUp = false;
                  _errorMessage = null;
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}
