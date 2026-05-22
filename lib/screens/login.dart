import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nexo/screens/home.dart';

import '../controllers/LoginController.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  final controller = Get.put(LoginController());

  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool _obscurePassword = true;

  // TV Focus Nodes
  final userFocus = FocusNode();
  final passFocus = FocusNode();
  final btnFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      userFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    userFocus.dispose();
    passFocus.dispose();
    btnFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF00BFA5),
            width: 3,
          ),
        ),
        child: Row(
          children: [
            // LEFT SIDE
            Expanded(
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      const LinearGradient(
                        colors: [
                          Color(0xFF00CFFF),
                          Color(0xFF6A5CFF),
                          Color(0xFFFF00CC),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                  child: const Text(
                    "NEXO",
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),

            // DIVIDER
            Container(
              width: 1,
              height: 360,
              color: Colors.white24,
            ),

            // RIGHT SIDE
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Access your IPTV subscription below",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 35),

                      // USERNAME
                      const Text(
                        "Username",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _buildField(
                        controller: usernameController,
                        focusNode: userFocus,
                        nextFocus: passFocus,
                        hint: "Enter your username",
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 25),

                      // PASSWORD
                      const Text(
                        "Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _buildPasswordField(),

                      const SizedBox(height: 18),

                      // ERROR MESSAGE
                      Obx(
                            () => controller
                            .errorMsg.value.isNotEmpty
                            ? Text(
                          controller.errorMsg.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        )
                            : const SizedBox(),
                      ),

                      const SizedBox(height: 30),

                      // LOGIN BUTTON
                      Obx(() {
                        return GestureDetector(
                          onTap: _login,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: btnFocus.hasFocus
                                  ? const Color(0xFF00CFFF)
                                  : const Color(0xFF1296F3),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: btnFocus.hasFocus
                                  ? [const BoxShadow(
                                color: Color(0x5500CFFF),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )]
                                  : [],
                            ),
                            child: Center(
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : const Text(
                                "Start Streaming",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Focus widget hata do — sirf TextField rakho
  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required FocusNode nextFocus,
    required String hint,
    required IconData icon,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: focusNode.hasFocus
                  ? const Color(0xFF00CFFF)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: (_) => nextFocus.requestFocus(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white12,
              prefixIcon: Icon(icon, color: Colors.white38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return AnimatedBuilder(
      animation: passFocus,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: passFocus.hasFocus
                  ? const Color(0xFF00CFFF)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            controller: passwordController,
            focusNode: passFocus,
            obscureText: _obscurePassword,
            onSubmitted: (_) => btnFocus.requestFocus(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white12,
              prefixIcon: const Icon(Icons.key_outlined, color: Colors.white38),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.remove_red_eye_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white38,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton() {
    return Focus(
      focusNode: btnFocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey ==
                LogicalKeyboardKey.select) {
          _login();

          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: AnimatedBuilder(
        animation: btnFocus,
        builder: (context, child) {
          return GestureDetector(
            onTap: _login,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: btnFocus.hasFocus
                    ? const Color(0xFF00CFFF)
                    : const Color(0xFF1296F3),
                borderRadius:
                BorderRadius.circular(6),
                boxShadow: btnFocus.hasFocus
                    ? [
                  const BoxShadow(
                    color: Color(0x5500CFFF),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
                    : [],
              ),
              child: Center(
                child: controller.isLoading.value
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                  CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Text(
                  "Start Streaming",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _login() async {
    await controller.login(
      usernameController.text,
      passwordController.text,
    );
    // LoginController khud navigate karega Get.offAll se
  }
}