import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockappprep/screens/product_screen.dart';
import '../providers/providers.dart';
import 'registration_screen.dart';

class LoginScreen extends ConsumerWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key); // Corrected the key passing

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Login Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple, Colors.purpleAccent],
          ),
        ),
        child: userAsyncValue.when(
          data: (user) {
            if (user == null) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        fillColor: Colors.white70,
                        filled: true,
                      ),
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        fillColor: Colors.white70,
                        filled: true,
                      ),
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          foregroundColor: Colors.black87,
                          shadowColor: Colors.black38,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            await ref
                                .read(firebaseAuthProvider)
                                .signInWithEmailAndPassword(
                                  email: _usernameController.text,
                                  password: _passwordController.text,
                                );
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Try Again')));
                          }
                        },
                        child: const Text('Login')),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        Future.microtask(() => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationScreen())));
                      },
                      child: const Text('Don\'t have an account? Register',
                          style: TextStyle(
                              color: Colors.white70,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              );
            } else {
              Future.microtask(() => // Use Future.microtask for navigation
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ProductScreen()),
                  ));
              return const SizedBox.shrink();
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
