import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
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
        fontFamily: 'Roboto',
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? AuthScreen(
              currentLanguage: _currentLanguage,
              onLanguageChanged: _changeLanguage,
            )
          : MainNavigationHub(
              currentLanguage: _currentLanguage,
              onLanguageChanged: _changeLanguage,
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
      'mining_rate': 'MINING RATE',
      'session_time': 'REMAINING TIME',
      'daily_checkin': 'DAILY CHECK-IN STREAK',
      'claim_daily': 'CLAIM DAILY CHECK-IN (+2 FAN)',
      'social_tasks': 'OFFICIAL SOCIAL MEDIA TASKS (STRICT VERIFY)',
      'kyc_tiers': 'KYC VERIFICATION TIERS',
      'device_sec': 'Device Security: 1 Device = 1 Account Only',
      'visit': 'VISIT PAGE',
      'confirm': 'CONFIRM',
      'done': '✓ VERIFIED',
      'wallet': 'AFAM WALLET',
      'referral': 'REFERRAL PROGRAM',
      'settings': 'SETTINGS',
      'home': 'HOME',
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
      'mining_rate': 'TASA DE MINERÍA',
      'session_time': 'TIEMPO RESTANTE',
      'daily_checkin': 'REGISTRO DIARIO',
      'claim_daily': 'RECLAMAR REGISTRO (+2 FAN)',
      'social_tasks': 'TAREAS SOCIALES (VERIFICACIÓN ESTRICTA)',
      'kyc_tiers': 'NIVELES DE VERIFICACIÓN KYC',
      'device_sec': 'Seguridad: 1 Dispositivo = 1 Cuenta',
      'visit': 'VISITAR',
      'confirm': 'CONFIRMAR',
      'done': '✓ VERIFICADO',
      'wallet': 'BILLETERA AFAM',
      'referral': 'REFERIDOS',
      'settings': 'AJUSTES',
      'home': 'INICIO',
      'logout': 'CERRAR SESIÓN',
    },
  };

  static String text(String lang, String key) {
    return _localizedValues[lang]?[key] ?? _localizedValues['English']?[key] ?? key;
  }
}

// ==========================================
// AUTH SCREEN WITH FIREBASE AUTH
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

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
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        String uid = credential.user!.uid;

        // Save User Data in Firebase Realtime Database
        await _db.ref("users/$uid").set({
          "username": username,
          "email": email,
          "fanBalance": 20.0,
          "afamBalance": 0.0,
          "dailyStreak": 0,
          "kyc1": false,
          "kyc2": false,
          "lastMiningStart": 0,
          "referrals": 0,
        });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationHub(
              currentLanguage: widget.currentLanguage,
              onLanguageChanged: widget.onLanguageChanged,
            ),
          ),
        );
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
                    const Icon(Icons.bolt_rounded, size: 70, color: Color(0xFF2E1065)),
                    const SizedBox(height: 10),
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
// MAIN HUB WITH FIREBASE REALTIME ENGINE
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
  int _selectedIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  String username = "User";
  double fanBalance = 20.0;
  double afamBalance = 0.0;
  int dailyStreak = 0;
  bool kyc1 = false;
  bool kyc2 = false;
  int lastMiningStart = 0;

  bool isMiningActive = false;
  int remainingSeconds = 86400;
  Timer? _tickerTimer;

  // Strict Tasks Tracker
  bool fbDone = false, ytDone = false, ttDone = false, xDone = false, tgDone = false, igDone = false;
  bool fbVisited = false, ytVisited = false, ttVisited = false, xVisited = false, tgVisited = false, igVisited = false;

  @override
  void initState() {
    super.initState();
    _loadUserDataFromFirebase();
  }

  void _loadUserDataFromFirebase() {
    if (user == null) return;

    _dbRef.child("users/${user!.uid}").onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          username = data["username"] ?? "User";
          fanBalance = (data["fanBalance"] ?? 20.0).toDouble();
          afamBalance = (data["afamBalance"] ?? 0.0).toDouble();
          dailyStreak = data["dailyStreak"] ?? 0;
          kyc1 = data["kyc1"] ?? false;
          kyc2 = data["kyc2"] ?? false;
          lastMiningStart = data["lastMiningStart"] ?? 0;
        });

        _checkMiningStatus();
      }
    });
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
          fanBalance += (0.4 / 3600.0); // 0.4 FAN per hour rate
        });
      } else {
        timer.cancel();
        setState(() => isMiningActive = false);
        _saveBalanceToFirebase();
      }
    });
  }

  void _saveBalanceToFirebase() {
    if (user != null) {
      _dbRef.child("users/${user!.uid}").update({"fanBalance": fanBalance});
    }
  }

  void _startMiningSession() async {
    int nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (user != null) {
      await _dbRef.child("users/${user!.uid}").update({
        "lastMiningStart": nowSeconds,
      });
      _checkMiningStatus();
    }
  }

  Future<void> _openSocialLink(String url, Function onVisited) async {
    final Uri uri = Uri.parse(url);
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Future.delayed(const Duration(seconds: 4), () {
        setState(() => onVisited());
      });
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _saveBalanceToFirebase();
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('@$username', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthScreen(
                              currentLanguage: widget.currentLanguage,
                              onLanguageChanged: widget.onLanguageChanged,
                            ),
                          ),
                        );
                      }
                    },
                  )
                ],
              ),
              const SizedBox(height: 12),

              // Live Balance Card
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

              // Mining Control
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Text(isMiningActive ? 'Time Remaining: $remainingSeconds sec' : 'Session Inactive', style: const TextStyle(fontWeight: FontWeight.bold)),
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
