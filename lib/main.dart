import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POWER FAN NETWORK',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationHub(),
    );
  }
}

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _selectedIndex = 0;

  // App Global State
  double fanBalance = 20.0; // Welcome Bonus 20 FAN
  double afamBalance = 0.0;
  double baseMiningRate = 0.4;
  int activeReferrals = 0;
  int totalReferrals = 0;
  int dailyCheckInDays = 0; // Check-in Streak Counter

  // Languages
  String selectedLanguage = 'English';
  final List<String> languages = [
    'English', 'Hausa', 'Arabic', 'Spanish', 'French', 
    'Chinese', 'Hindi', 'Portuguese', 'Russian', 'Swahili'
  ];

  // KYC States
  bool kyc1FaceCompleted = false;
  bool kyc2GovIdCompleted = false;
  bool isWalletUnlocked = false;

  // Social Tasks Completed Status
  bool fbFollowed = false;
  bool ytSubscribed = false;
  bool ttFollowed = false;
  bool xFollowed = false;
  bool tgJoined = false;
  bool igFollowed = false;

  // Social Links
  final String fbUrl = "https://www.facebook.com/share/18ipQKYcCV/";
  final String ytUrl = "https://youtube.com/@powerfannetwork?si=yHAa0uXznTHB4Sf";
  final String ttUrl = "https://www.tiktok.com/@power.fan.network?_r=1&_t=ZP-98wsX6qxjV";
  final String xUrl = "https://x.com/Powerfannetwor";
  final String tgUrl = "https://t.me/PowerFannetwor";
  final String igUrl = "https://www.instagram.com/powerfannetwok/";

  Future<void> _launchSocialUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  bool areAllSocialTasksDone() {
    return fbFollowed && ytSubscribed && ttFollowed && xFollowed && tgJoined && igFollowed;
  }

  void _convertFanToAfam() {
    if (kyc1FaceCompleted && kyc2GovIdCompleted && totalReferrals >= 5 && areAllSocialTasksDone()) {
      setState(() {
        isWalletUnlocked = true;
        afamBalance += fanBalance / 100.0;
        fanBalance = 0.0;
      });
    }
  }

  void _showAdAndClaimMining() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('WATCH AD TO CLAIM'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.ondemand_video_rounded, size: 50, color: Colors.purple),
            SizedBox(height: 10),
            Text('Simulating Video Ad playback... Please wait.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                fanBalance += (baseMiningRate * 24);
                _convertFanToAfam();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reward claimed successfully!')),
              );
            },
            child: const Text('CLOSE AD & CLAIM REWARD'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double currentRate = baseMiningRate + (activeReferrals * 0.02);

    final List<Widget> screens = [
      _buildHomeScreen(currentRate),
      _buildReferralScreen(),
      _buildWalletScreen(),
      _buildSettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E1065),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'REFERRAL'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'WALLET'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
        ],
      ),
    );
  }

  // --- 1. HOME SCREEN ---
  Widget _buildHomeScreen(double currentRate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Language Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AFAM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1B4B))),
              Column(
                children: const [
                  Text('POWER FAN NETWORK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E1B4B), letterSpacing: 0.5)),
                  Text('Mine FAN. Earn More', style: TextStyle(fontSize: 12, color: Color(0xFF4338CA), fontWeight: FontWeight.w500)),
                ],
              ),
              DropdownButton<String>(
                value: selectedLanguage,
                underline: const SizedBox(),
                icon: const Icon(Icons.language, color: Color(0xFF1E1B4B), size: 20),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedLanguage = newValue;
                    });
                  }
                },
                items: languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Security Device Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: const [
                Icon(Icons.security, size: 14, color: Colors.blue),
                SizedBox(width: 6),
                Text('Device Security Active: 1 Device = 1 Account Only', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0F0B52), Color(0xFF2E1065)], begin: Alignment.centerLeft, end: Alignment.centerRight),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FAN BALANCE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text(fanBalance.toStringAsFixed(4), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          const Text('FAN', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('≈ \$${(fanBalance * 0.01).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.engineering_rounded, size: 40, color: Colors.amberAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 24H Mining Control Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('MINING RATE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text('${currentRate.toStringAsFixed(2)} FAN/H', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4C1D95))),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('SESSION TIME', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const Text('24:00:00 Hours', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _showAdAndClaimMining,
                    icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 18),
                    label: const Text('START 24H MINING (WATCH AD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E1065), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Daily Check-in Progress Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DAILY CHECK-IN STREAK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E1B4B))),
                    Text('$dailyCheckInDays Days Completed', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple)),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      dailyCheckInDays++;
                      fanBalance += 2;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: const Size(double.infinity, 36)),
                  child: const Text('CLAIM DAILY CHECK-IN (+2 FAN)', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Official Social Media Tasks
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('OFFICIAL SOCIAL MEDIA TASKS (REQUIRED FOR KYC)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1E1B4B))),
                const SizedBox(height: 10),
                _socialTaskTile('Facebook Page', fbUrl, fbFollowed, () => setState(() => fbFollowed = true)),
                _socialTaskTile('YouTube Channel', ytUrl, ytSubscribed, () => setState(() => ytSubscribed = true)),
                _socialTaskTile('TikTok Profile', ttUrl, ttFollowed, () => setState(() => ttFollowed = true)),
                _socialTaskTile('X (Twitter)', xUrl, xFollowed, () => setState(() => xFollowed = true)),
                _socialTaskTile('Telegram Community', tgUrl, tgJoined, () => setState(() => tgJoined = true)),
                _socialTaskTile('Instagram Page', igUrl, igFollowed, () => setState(() => igFollowed = true)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // KYC Tier Status Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('KYC VERIFICATION TIERS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                _kycRow('KYC 1: Face (Requires 14 Days Check-in & Tasks)', dailyCheckInDays >= 14 && areAllSocialTasksDone(), kyc1FaceCompleted, () {
                  if (dailyCheckInDays >= 14 && areAllSocialTasksDone()) {
                    setState(() {
                      kyc1FaceCompleted = true;
                      _convertFanToAfam();
                    });
                  }
                }),
                const Divider(),
                _kycRow('KYC 2: Gov ID (Requires 60 Days Check-in)', dailyCheckInDays >= 60, kyc2GovIdCompleted, () {
                  if (dailyCheckInDays >= 60) {
                    setState(() {
                      kyc2GovIdCompleted = true;
                      _convertFanToAfam();
                    });
                  }
                }),
                const Divider(),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Biometric Verification', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  subtitle: Text('Locked (Will be unlocked by Admin in future update)', style: TextStyle(fontSize: 9, color: Colors.red)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialTaskTile(String title, String url, bool isDone, VoidCallback onComplete) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => _launchSocialUrl(url),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(50, 26)),
                child: const Text('VISIT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: isDone ? null : onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDone ? Colors.green : const Color(0xFF2E1065),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(60, 26),
                ),
                child: Text(isDone ? '✓ DONE' : 'CONFIRM', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _kycRow(String title, bool isEligible, bool isDone, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDone ? Colors.green : Colors.black87))),
        if (isDone)
          const Icon(Icons.check_circle, color: Colors.green, size: 18)
        else if (isEligible)
          TextButton(onPressed: onTap, child: const Text('VERIFY NOW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF2E1065))))
        else
          const Text('LOCKED', style: TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- 2. REFERRAL SCREEN ---
  Widget _buildReferralScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('REFERRAL PROGRAM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E1B4B))),
          const SizedBox(height: 6),
          const Text('Invite friends to get 5 FAN instant bonus + 0.02 FAN/H mining boost per active referral!', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Referrals:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$totalReferrals / 5 required for Migration', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E1065))),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      totalReferrals++;
                      activeReferrals++;
                      fanBalance += 5;
                      _convertFanToAfam();
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E1065)),
                  child: const Text('SIMULATE INVITE FRIEND (+5 FAN)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 3. WALLET SCREEN ---
  Widget _buildWalletScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AFAM WALLET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E1B4B))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: isWalletUnlocked ? Colors.green.shade100 : Colors.red.shade100, borderRadius: BorderRadius.circular(12)),
                child: Text(isWalletUnlocked ? 'UNLOCKED' : 'LOCKED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isWalletUnlocked ? Colors.green : Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // AFAM Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E1B4B), Color(0xFF4338CA)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AFAM COIN BALANCE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${afamBalance.toStringAsFixed(4)} AFAM', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Username / Address: @user_afam_01', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (!isWalletUnlocked) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Wallet Locked Requirements:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13)),
                  SizedBox(height: 6),
                  Text('1. Complete KYC 1 (Face + 14 Days Check-in + Social Tasks)\n2. Complete KYC 2 (Gov ID + 60 Days Check-in)\n3. Invite at least 5 Active Referrals\n\nOnce completed, all FAN coins convert to AFAM (100 FAN = 1 AFAM) automatically.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                ],
              ),
            )
          ] else ...[
            const Text('SEND & RECEIVE AFAM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter Username or Wallet Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E1065)),
                child: const Text('TRANSFER AFAM COINS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ]
        ],
      ),
    );
  }

  // --- 4. SETTINGS SCREEN ---
  Widget _buildSettingsScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E1B4B))),
          const SizedBox(height: 16),
          const ListTile(leading: Icon(Icons.person), title: Text('Username'), subtitle: Text('@user_afam_01')),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('App Language'),
            subtitle: Text(selectedLanguage),
          ),
          const ListTile(leading: Icon(Icons.security), title: Text('Security & Device ID Check')),
          const ListTile(leading: Icon(Icons.help_outline), title: Text('Help & Support')),
        ],
      ),
    );
  }
}
