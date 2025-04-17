import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'RMODashboard.dart';

class RMOLogin extends StatefulWidget {
  const RMOLogin({Key? key}) : super(key: key);

  @override
  State<RMOLogin> createState() => _RMOLoginState();
}

class _RMOLoginState extends State<RMOLogin> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _loginRMO() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String phone = _phoneController.text.trim();
        String password = _passwordController.text.trim();

        // Step 1: Query Firestore to get user data based on the phone number
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();

        if (userSnapshot.docs.isEmpty) {
          throw Exception("User not found.");
        }

        final userData = userSnapshot.docs.first.data();

        // Check if required fields are available
        if (userData['password'] == null || userData['role'] == null) {
          throw Exception("Missing required fields.");
        }

        final storedPassword = userData['password'];
        final role = userData['role'];

        // Step 2: Check if password matches and role is 'RMO'
        if (storedPassword != password) {
          throw Exception("Incorrect password.");
        }

        if (role != 'RMO') {
          throw Exception("Access denied. Not an RMO.");
        }

        // Step 3: Successful login - Navigate to RMO Dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('RMO Login Successful'),
            backgroundColor: Color(0xFF64B5F6),
          ),
        );

        // Navigate to RMO Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RMODashboard()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red[400],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'RMO Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF64B5F6),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF64B5F6), Color(0xFFBBDEFB), Colors.white],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 4,
                  shadowColor: Color(0xFF90CAF9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFBBDEFB).withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person_outline,
                                size: 56,
                                color: Color(0xFF64B5F6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Login to your RMO account',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF90CAF9),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFBBDEFB).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Color(0xFF2196F3)),
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: const TextStyle(color: Color(0xFF64B5F6)),
                                prefixIcon: const Icon(Icons.phone, color: Color(0xFF64B5F6)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Color(0xFFBBDEFB), width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFBBDEFB).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Color(0xFF2196F3)),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(color: Color(0xFF64B5F6)),
                                prefixIcon: const Icon(Icons.lock, color: Color(0xFF64B5F6)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: const Color(0xFF64B5F6),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Color(0xFFBBDEFB), width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Forgot password functionality would go here
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Color(0xFF64B5F6),
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _loginRMO,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF64B5F6),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(0xFFBBDEFB),
                                elevation: 3,
                                shadowColor: Color(0xFF64B5F6).withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}