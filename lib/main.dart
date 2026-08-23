import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentLanguage = 'English';

  void _changeLanguage(String lang) {
    setState(() {
      _currentLanguage = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POWER FAN NETWORK',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return MainNavigationHub(
              currentLanguage: _currentLanguage,
              onLanguageChanged: _changeLanguage,
            );
          }
          return AuthScreen(
            currentLanguage: _currentLanguage,
            onLanguageChanged: _changeLanguage,
          );
        },
      ),
    );
  }
}

// ==========================================
// TRANSLATIONS
// ==========================================
class AppTranslations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'English': {
      'app_title': 'POWER FAN NETWORK',
      'sub_title': 'Mine FAN. Earn More',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email Address',
      'password': 'Password',
      'username': 'Username',
      'welcome_back': 'Welcome Back',
      'create_account': 'Create New Account',
      'start_mining': 'START 24H MINING',
      'mining_active': 'MINING IS ACTIVE',
      'fan_balance': 'LIVE FAN BALANCE',
      'remaining_time': 'REMAINING TIME',
      'logout': 'LOGOUT',
    },
    'Spanish': {
      'app_title': 'RED POWER FAN',
      'sub_title': 'Mina FAN. Gana Más',
      'login': 'Iniciar Sesión',
      'register': 'Registrarse',
      'email': 'Correo Electrónico',
      'password': 'Contraseña',
      'username': 'Nombre de usuario',
      'welcome_back': 'Bienvenido de Nuevo',
      'create_account': 'Crear Nueva Cuenta',
      'start_mining': 'INICIAR MINERÍA 24H',
      'mining_active': 'MINERÍA ACTIVA',
      'fan_balance': 'SALDO FAN EN VIVO',
      'remaining_time': 'TIEMPO RESTANTE',
      'logout': 'CERRAR SESIÓN',
    },
  };

  static String text(String lang, String key) {
    return _localizedValues[lang]?[key] ?? _localizedValues['English']?[key] ?? key;
  }
}

// ==========================================
// AUTH SCREEN (FIREBASE AUTH + FIRESTORE)
// ==========================================
class AuthScreen extends StatefulWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const AuthScreen({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _submitAuth() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && username.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save User Data to Cloud Firestore
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'username': username,
          'email': email,
          'fanBalance': 20.0,
          'lastMiningStart': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String lang = widget.currentLanguage;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppTranslations.text(lang, 'app_title'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1B4B))),
                  DropdownButton<String>(
                    value: widget.currentLanguage,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.language, color: Color(0xFF1E1B4B)),
                    onChanged: (String? val) {
                      if (val != null) widget.onLanguageChanged(val);
                    },
                    items: ['English', 'Spanish'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    const Icon(FontAwesomeIcons.bolt, size: 60, color: Color(0xFF2E1065)),
                    const SizedBox(height: 12),
                    Text(
                      isLogin ? AppTranslations.text(lang, 'welcome_back') : AppTranslations.text(lang, 'create_account'),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
                    ),
                    Text(AppTranslations.text(lang, 'sub_title'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (!isLogin) ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: AppTranslations.text(lang, 'username'),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppTranslations.text(lang, 'email'),
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppTranslations.text(lang, 'password'),
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E1065),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isLogin ? AppTranslations.text(lang, 'login') : AppTranslations.text(lang, 'register'),
                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? "Don't have an account? Register" : "Already have an account? Login",
                    style: const TextStyle(color: Color(0xFF4338CA), fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// MAIN HUB WITH FIRESTORE
// ==========================================
class MainNavigationHub extends StatefulWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const MainNavigationHub({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  final User? user = FirebaseAuth.instance.currentUser;

  double fanBalance = 20.0;
  int lastMiningStart = 0;
  bool isMiningActive = false;
  int remainingSeconds = 86400;
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _loadDataFromFirestore();
  }

  void _loadDataFromFirestore() async {
    if (user == null) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        fanBalance = (data['fanBalance'] ?? 20.0).toDouble();
        lastMiningStart = data['lastMiningStart'] ?? 0;
      });
      _checkMiningStatus();
    }
  }

  void _checkMiningStatus() {
    int nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int passed = nowSeconds - lastMiningStart;

    if (passed < 86400 && lastMiningStart > 0) {
      setState(() {
        isMiningActive = true;
        remainingSeconds = 86400 - passed;
      });
      _startLocalTicker();
    } else {
      setState(() {
        isMiningActive = false;
      });
    }
  }

  void _startLocalTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
          fanBalance += (0.4 / 3600.0);
        });
      } else {
        timer.cancel();
        setState(() => isMiningActive = false);
        _saveBalanceToFirestore();
      }
    });
  }

  void _saveBalanceToFirestore() {
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'fanBalance': fanBalance,
      });
    }
  }

  void _startMiningSession() async {
    int nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'lastMiningStart': nowSeconds,
      });
      setState(() {
        lastMiningStart = nowSeconds;
      });
      _checkMiningStatus();
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _saveBalanceToFirestore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String lang = widget.currentLanguage;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(user?.email ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0F0B52), Color(0xFF2E1065)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppTranslations.text(lang, 'fan_balance'), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    const SizedBox(height: 6),
                    Text('${fanBalance.toStringAsFixed(6)} FAN',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Text(isMiningActive ? 'Remaining: $remainingSeconds sec' : 'Session Inactive', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isMiningActive ? null : _startMiningSession,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E1065)),
                        child: Text(isMiningActive ? 'MINING IN PROGRESS...' : 'START 24H MINING SESSION', style: const TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
