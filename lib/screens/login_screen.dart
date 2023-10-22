import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockappprep/screens/product_screen.dart';
import '../providers/providers.dart';

class LoginScreen extends ConsumerWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key); // Corrected the key passing

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(firebaseAuthProvider)
                              .signInWithEmailAndPassword(
                                email: _usernameController.text,
                                password: _passwordController.text,
                              );
                        } catch (e) {
                          // You might want to show an error to the user
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: const Text('Login')),
                ],
              ),
            );
          } else {
            Future.microtask(() => // Use Future.microtask for navigation
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProductScreen()),
                ));
            return const SizedBox.shrink(); // Return a minimal widget
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
