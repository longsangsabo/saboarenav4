import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final savedPassword = prefs.getString('saved_password');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (rememberMe && savedEmail != null && savedPassword != null) {
        setState(() {
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
          _rememberMe = true;
        });
        
        // Auto-login if credentials are saved
        print('🔐 Auto-login: Found saved credentials, attempting auto-login...');
        _handleAutoLogin(savedEmail, savedPassword);
      }
    } catch (e) {
      print('❌ Error loading saved credentials: $e');
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', email);
        await prefs.setString('saved_password', password);
        await prefs.setBool('remember_me', true);
        print('💾 Credentials saved successfully');
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
        print('🗑️ Credentials cleared');
      }
    } catch (e) {
      print('❌ Error saving credentials: $e');
    }
  }

  Future<void> _handleAutoLogin(String email, String password) async {
    try {
      print('🔐 Auto-login: Attempting with saved credentials...');
      
      final result = await AuthService.instance.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (result.isSuccess && mounted) {
        print('🔐 Auto-login: SUCCESS - Navigating to home');
        Navigator.of(context).pushReplacementNamed(AppRoutes.homeFeed);
      } else {
        print('🔐 Auto-login: FAILED - ${result.message}');
        // Clear invalid saved credentials
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
        
        if (mounted) {
          setState(() {
            _emailController.clear();
            _passwordController.clear();
            _rememberMe = false;
          });
        }
      }
    } catch (e) {
      print('❌ Auto-login error: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Use real Supabase authentication
      print('🔐 Login: Attempting login with email: $email');
      
      final result = await AuthService.instance.signInWithEmail(
        email: email,
        password: password,
      );
      
      print('🔐 Login result: ${result.isSuccess ? "SUCCESS" : "FAILED - ${result.message}"}');
      
      if (result.isSuccess && mounted) {
        // Save credentials if Remember Me is checked
        await _saveCredentials(email, password);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎯 Đăng nhập thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRoutes.homeFeed);
      } else if (mounted) {
        // If login failed with invalid credentials, offer to create account
        if (result.message.contains('Invalid login credentials') || 
            result.message.contains('invalid_credentials')) {
          _showSignupDialog(email, password);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Đăng nhập thất bại: ${result.message}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔧 Chế độ demo - Hãy thử demo@sabo.com / demo123'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSignupDialog(String email, String password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tài khoản không tồn tại'),
        content: Text('Email $email chưa được đăng ký.\nBạn có muốn tạo tài khoản mới không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleAutoSignup(email, password);
            },
            child: const Text('Tạo tài khoản'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAutoSignup(String email, String password) async {
    setState(() => _isLoading = true);

    try {
      // Extract username from email
      final username = email.split('@')[0];
      final displayName = username.replaceAll('.', ' ').replaceAll('_', ' ');

      print('🔐 Signup: Creating account for $email with username: $username');

      final result = await AuthService.instance.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
        bio: 'Billiards player from SABO Arena',
      );

      print('🔐 Signup result: ${result.isSuccess ? "SUCCESS" : "FAILED - ${result.message}"}');

      if (result.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Tài khoản đã được tạo thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRoutes.homeFeed);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Tạo tài khoản thất bại: ${result.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi tạo tài khoản: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  void _navigateToDemo() {
    // For testing purposes, navigate to main app without authentication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚀 Chế độ demo - Chào mừng đến SABO ARENA!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pushReplacementNamed(AppRoutes.homeFeed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.sports_basketball,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'SABO ARENA',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng nhập vào tài khoản',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Nhập email của bạn',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 16
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Vui lòng nhập email';
                    if (!value!.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    hintText: 'Nhập mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 16
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Vui lòng nhập mật khẩu';
                    if (value!.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Remember Me Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Ghi nhớ đăng nhập',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Login Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Demo Button (for testing)
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _navigateToDemo,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      'Xem Demo',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Register Link
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToRegister,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}