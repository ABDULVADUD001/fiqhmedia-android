
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';
import 'auth_screen.dart';
import 'admin_screen.dart';

// =====================================================
// fiqhMedia Android 1.3.0
// =====================================================

const apiBaseUrl =
    'https://fiqhmedia-backend-production.up.railway.app';

const emerald = Color(0xFF087F69);
const deepGreen = Color(0xFF064C43);
const gold = Color(0xFFD6A449);
const background = Color(0xFFF7F9F8);

const logoPath = 'assets/icon/fiqhmedia.png';

const defaultMadhhabs = [
  'Hanafiy',
  'Shofe’iy',
  'Molikiy',
  'Hanbaliy',
];

const madhhabColors = [
  Color(0xFF087F69),
  Color(0xFF3478DA),
  Color(0xFFE78A3B),
  Color(0xFFD5A527),
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FiqhMediaApp());
}

// =====================================================
// APPLICATION
// =====================================================

class FiqhMediaApp extends StatefulWidget {
  const FiqhMediaApp({super.key});

  @override
  State<FiqhMediaApp> createState() =>
      _FiqhMediaAppState();
}

class _FiqhMediaAppState extends State<FiqhMediaApp> {
  ThemeMode themeMode = ThemeMode.light;

  FiqhUser? currentUser;
  bool checkingSession = true;
  String? sessionError;

  @override
  void initState() {
    super.initState();
    restoreLogin();
  }

  Future<void> restoreLogin() async {
    try {
      final user = await FiqhAuthService.restoreSession();

      if (!mounted) return;

      setState(() {
        currentUser = user;
        sessionError = null;
        checkingSession = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        sessionError = 'Server bilan aloqa o‘rnatilmadi.';
        checkingSession = false;
      });
    }
  }

  void authenticated(FiqhUser user) {
    setState(() {
      currentUser = user;
      sessionError = null;
    });
  }

  Future<void> logout() async {
    await FiqhAuthService.logout();

    if (!mounted) return;

    setState(() {
      currentUser = null;
      sessionError = null;
    });
  }

  void toggleTheme() {
    setState(() {
      themeMode = themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  ThemeData createTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emerald,
        brightness: brightness,
      ),
      scaffoldBackgroundColor:
          dark ? const Color(0xFF111B19) : background,
      appBarTheme: AppBarTheme(
        backgroundColor:
            dark ? const Color(0xFF111B19) : background,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dark
            ? const Color(0xFF20302C)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark
            ? const Color(0xFF20302C)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (checkingSession) {
      home = const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (sessionError != null) {
      home = Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 46,
                  color: emerald,
                ),
                const SizedBox(height: 14),
                Text(sessionError!),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      checkingSession = true;
                    });
                    restoreLogin();
                  },
                  child: const Text('Qayta urinish'),
                ),
                TextButton(
                  onPressed: logout,
                  child: const Text('Boshqa akkauntga kirish'),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (currentUser == null) {
      home = FiqhAuthScreen(
        onAuthenticated: authenticated,
      );
    } else {
      home = MainScreen(
        key: ValueKey(currentUser!.id),
        currentUser: currentUser!,
        isDark: themeMode == ThemeMode.dark,
        onThemeChanged: toggleTheme,
        onLogout: logout,
      );
    }

    return MaterialApp(
      title: 'fiqhMedia',
      debugShowCheckedModeBanner: false,
      theme: createTheme(Brightness.light),
      darkTheme: createTheme(Brightness.dark),
      themeMode: themeMode,
      home: home,
    );
  }
}

// =====================================================
// LOGO
// =====================================================

class FiqhLogo extends StatelessWidget {
  final double size;

  const FiqhLogo({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      logoPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Icon(
          Icons.auto_stories_rounded,
          size: size,
          color: emerald,
        );
      },
    );
  }
}

// =====================================================
// ARTICLE MODEL
// =====================================================

class FiqhArticle {
  final String id;
  final String title;
  final String category;
  final String madhhab;
  final String description;

  const FiqhArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.madhhab,
    required this.description,
  });
}

// These are demonstration topics, not fatwas.
const demoArticles = [
  FiqhArticle(
    id: 'hanafi_tahorat',
    title: 'Tahorat',
    category: 'Poklik',
    madhhab: 'Hanafiy',
    description:
        'Tahorat bo‘yicha tekshirilgan Hanafiy '
        'manbalari keyinchalik ulanadi.',
  ),
  FiqhArticle(
    id: 'hanafi_namoz',
    title: 'Namoz',
    category: 'Ibodat',
    madhhab: 'Hanafiy',
    description:
        'Namozga oid tekshirilgan manbalar '
        'keyinchalik ulanadi.',
  ),
  FiqhArticle(
    id: 'shafii_roza',
    title: 'Ro‘za',
    category: 'Ibodat',
    madhhab: 'Shofe’iy',
    description:
        'Shofe’iy mazhabi manbalari '
        'keyinchalik qo‘shiladi.',
  ),
  FiqhArticle(
    id: 'maliki_zakot',
    title: 'Zakot',
    category: 'Moliyaviy ibodat',
    madhhab: 'Molikiy',
    description:
        'Molikiy mazhabi manbalari '
        'keyinchalik qo‘shiladi.',
  ),
  FiqhArticle(
    id: 'hanbali_haj',
    title: 'Haj',
    category: 'Ibodat',
    madhhab: 'Hanbaliy',
    description:
        'Hanbaliy mazhabi manbalari '
        'keyinchalik qo‘shiladi.',
  ),
];

// =====================================================
// MAIN SCREEN
// =====================================================

class MainScreen extends StatefulWidget {
  final FiqhUser currentUser;
  final bool isDark;
  final VoidCallback onThemeChanged;
  final Future<void> Function() onLogout;

  const MainScreen({
    super.key,
    required this.currentUser,
    required this.isDark,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedTab = 0;

  String? selectedMadhhab;
  String searchText = '';

  List<String> availableMadhhabs =
      List<String>.from(defaultMadhhabs);

  bool loadingMadhhabs = true;
  bool connectedToServer = false;

  final searchController = TextEditingController();
  final Set<String> favorites = <String>{};

  @override
  void initState() {
    super.initState();
    loadMadhhabs();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadMadhhabs() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/madhhabs'),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('Server error');
      }

      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (decoded is! List) {
        throw Exception('Invalid response');
      }

      final names = <String>[];

      for (final item in decoded) {
        if (item is Map && item['name'] is String) {
          final name = (item['name'] as String).trim();
          if (name.isNotEmpty && !names.contains(name)) {
            names.add(name);
          }
        }
      }

      if (names.isEmpty) {
        throw Exception('Empty response');
      }

      if (!mounted) return;

      setState(() {
        availableMadhhabs = names;
        loadingMadhhabs = false;
        connectedToServer = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        availableMadhhabs =
            List<String>.from(defaultMadhhabs);
        loadingMadhhabs = false;
        connectedToServer = false;
      });
    }
  }

  void chooseMadhhab(String? madhhab) {
    if (madhhab == null ||
        !availableMadhhabs.contains(madhhab)) {
      return;
    }

    setState(() {
      selectedMadhhab = madhhab;
      searchText = '';
      searchController.clear();
    });
  }

  List<FiqhArticle> get filteredArticles {
    if (selectedMadhhab == null) return [];

    final query = searchText.trim().toLowerCase();

    return demoArticles.where((article) {
      if (article.madhhab != selectedMadhhab) {
        return false;
      }

      if (query.isEmpty) return true;

      return article.title.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query);
    }).toList();
  }

  void switchTab(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  void openArticle(FiqhArticle article) {
    if (article.madhhab != selectedMadhhab) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleScreen(
          article: article,
          initialFavorite: favorites.contains(article.id),
          onFavorite: () {
            setState(() {
              if (!favorites.add(article.id)) {
                favorites.remove(article.id);
              }
            });
          },
        ),
      ),
    );
  }

  void openPlans() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PlansScreen(),
      ),
    );
  }

  void openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(
          favoriteIds: favorites,
          selectedMadhhab: selectedMadhhab,
          onOpenArticle: openArticle,
        ),
      ),
    );
  }

  void openAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FiqhAdminScreen(),
      ),
    );
  }

  Widget heading(String value) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget emptyCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: emerald,
              size: 33,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(13),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: emerald.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: emerald),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  Widget articleCard(FiqhArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(13),
        leading: const Icon(
          Icons.menu_book_outlined,
          color: emerald,
          size: 30,
        ),
        title: Text(
          article.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${article.category} • ${article.madhhab}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => openArticle(article),
      ),
    );
  }

  Widget madhhabDropdown() {
    return DropdownButtonFormField<String>(
      key: ValueKey(selectedMadhhab),
      initialValue: selectedMadhhab,
      decoration: const InputDecoration(
        labelText: 'Mazhabni tanlang',
        prefixIcon: Icon(Icons.auto_stories_outlined),
      ),
      items: availableMadhhabs.map((name) {
        return DropdownMenuItem(
          value: name,
          child: Text(name),
        );
      }).toList(),
      onChanged: chooseMadhhab,
    );
  }

  // =================================================
  // HOME
  // =================================================

  Widget homePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Assalomu alaykum!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Fiqh ilmini bir makonda o‘rganing.',
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [emerald, deepGreen],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: emerald.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned(
                top: -25,
                right: -25,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.12,
                    child: FiqhLogo(size: 180),
                  ),
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(height: 25),
                  Text(
                    'Ilm. Ishonch. Manba.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 9),
                  Text(
                    'To‘rt mazhab. Bir ilmiy makon.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),
        heading('Mazhabni tanlang'),
        const SizedBox(height: 12),

        if (loadingMadhhabs)
          const LinearProgressIndicator()
        else
          Text(
            connectedToServer
                ? 'Mazhablar serverdan yuklandi'
                : 'Oflayn ro‘yxat ishlamoqda',
            style: TextStyle(
              color: connectedToServer
                  ? emerald
                  : Colors.orange,
              fontSize: 12,
            ),
          ),

        const SizedBox(height: 15),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availableMadhhabs.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.48,
          ),
          itemBuilder: (context, index) {
            final name = availableMadhhabs[index];
            final selected = selectedMadhhab == name;
            final color =
                madhhabColors[index % madhhabColors.length];

            return InkWell(
              onTap: () => chooseMadhhab(name),
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      Color.lerp(color, Colors.black, 0.2)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected ? gold : Colors.transparent,
                    width: selected ? 3 : 0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.auto_stories_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    if (selected)
                      const Text(
                        'Tanlangan',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 27),
        heading('Asosiy bo‘limlar'),
        const SizedBox(height: 12),

        actionCard(
          icon: Icons.search,
          title: 'Qidiruv',
          subtitle: 'Mavzu va savollar',
          onTap: () => switchTab(1),
        ),
        const SizedBox(height: 10),
        actionCard(
          icon: Icons.auto_awesome,
          title: 'fiqhMedia AI',
          subtitle: 'AI yordamchi — DEMO',
          onTap: () => switchTab(2),
        ),
        const SizedBox(height: 10),
        actionCard(
          icon: Icons.menu_book_outlined,
          title: 'Kutubxona',
          subtitle: 'Raqamli ilm manbalari',
          onTap: () => switchTab(3),
        ),

        const SizedBox(height: 25),
        heading('Mavzular'),
        const SizedBox(height: 12),

        if (selectedMadhhab == null)
          emptyCard(
            'Mavzularni ko‘rish uchun '
            'avval mazhabni tanlang.',
          )
        else if (filteredArticles.isEmpty)
          emptyCard(
            'Tanlangan mazhab bo‘yicha '
            'demo mavzu mavjud emas.',
          )
        else
          ...filteredArticles.map(articleCard),
      ],
    );
  }

  // =================================================
  // SEARCH
  // =================================================

  Widget searchPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        heading('Mavzuni izlash'),
        const SizedBox(height: 18),
        const Text(
          '1. Avval mazhabni tanlang',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        madhhabDropdown(),
        const SizedBox(height: 22),
        const Text(
          '2. Mavzu nomini yozing',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: searchController,
          enabled: selectedMadhhab != null,
          onChanged: (value) {
            setState(() => searchText = value);
          },
          decoration: InputDecoration(
            hintText: selectedMadhhab == null
                ? 'Avval mazhab tanlang'
                : 'Masalan: tahorat',
            prefixIcon: const Icon(Icons.search),
          ),
        ),

        const SizedBox(height: 23),

        if (selectedMadhhab == null)
          emptyCard(
            'Qidiruvni boshlash uchun mazhab tanlang.',
          )
        else ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: const Icon(
                Icons.verified_outlined,
                size: 17,
              ),
              label: Text('Mazhab: $selectedMadhhab'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${filteredArticles.length} ta demo natija',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (filteredArticles.isEmpty)
            emptyCard(
              'Natija topilmadi.\n'
              'Boshqa mazhabdagi ma’lumotlar '
              'aralashtirilmaydi.',
            )
          else
            ...filteredArticles.map(articleCard),
        ],
      ],
    );
  }

  // =================================================
  // LIBRARY
  // =================================================

  Widget libraryPage() {
    final items = selectedMadhhab == null
        ? <FiqhArticle>[]
        : demoArticles
            .where((a) => a.madhhab == selectedMadhhab)
            .toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        heading('Raqamli kutubxona'),
        const SizedBox(height: 10),
        const Text(
          'Kitoblar va ulamolar ensiklopediyasi.',
        ),
        const SizedBox(height: 22),

        actionCard(
          icon: Icons.library_books_outlined,
          title: 'Kitoblar ensiklopediyasi',
          subtitle: 'Tez kunda',
          onTap: showComingSoon,
        ),
        const SizedBox(height: 12),
        actionCard(
          icon: Icons.school_outlined,
          title: 'Ulamolar ensiklopediyasi',
          subtitle: 'Mualliflar va ilmiy manbalar',
          onTap: showComingSoon,
        ),

        const SizedBox(height: 23),

        if (selectedMadhhab == null)
          emptyCard(
            'Kutubxonani ko‘rish uchun mazhab tanlang.',
          )
        else ...[
          heading('$selectedMadhhab mavzulari'),
          const SizedBox(height: 12),
          if (items.isEmpty)
            emptyCard('Demo ma’lumot mavjud emas.')
          else
            ...items.map(articleCard),
        ],
      ],
    );
  }

  void showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bu imkoniyat keyinchalik qo‘shiladi.',
        ),
      ),
    );
  }

  // =================================================
  // PROFILE + ADMIN
  // =================================================

  Widget profilePage() {
    final user = widget.currentUser;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Center(
          child: FiqhLogo(size: 95),
        ),
        const SizedBox(height: 17),
        const Center(
          child: Text(
            'fiqhMedia foydalanuvchisi',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Free',
            style: TextStyle(
              color: emerald,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),

        Card(
          child: ListTile(
            leading: const Icon(
              Icons.account_circle_outlined,
              size: 35,
              color: emerald,
            ),
            title: Text(
              user.email,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              user.isAdmin
                  ? 'Administrator'
                  : 'Oddiy foydalanuvchi',
            ),
            trailing: user.isAdmin
                ? const Icon(
                    Icons.verified_rounded,
                    color: gold,
                  )
                : null,
          ),
        ),

        if (user.isAdmin) ...[
          const SizedBox(height: 12),
          actionCard(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Admin Panel',
            subtitle: 'fiqhMedia boshqaruv markazi',
            onTap: openAdmin,
          ),
        ],

        const SizedBox(height: 12),
        actionCard(
          icon: Icons.auto_stories_outlined,
          title: 'Tanlangan mazhab',
          subtitle: selectedMadhhab ?? 'Tanlanmagan',
          onTap: () => switchTab(0),
        ),

        const SizedBox(height: 12),
        actionCard(
          icon: Icons.favorite_outline,
          title: 'Saqlangan maqolalar',
          subtitle: '${favorites.length} ta',
          onTap: openFavorites,
        ),

        const SizedBox(height: 12),
        actionCard(
          icon: widget.isDark
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined,
          title: 'Ilova mavzusi',
          subtitle:
              widget.isDark ? 'Qorong‘i' : 'Yorug‘',
          onTap: widget.onThemeChanged,
        ),

        const SizedBox(height: 12),
        actionCard(
          icon: Icons.workspace_premium_outlined,
          title: 'Obuna tariflari',
          subtitle: 'Free, Plus, Pro va Pro Plus',
          onTap: openPlans,
        ),

        const SizedBox(height: 12),
        actionCard(
          icon: Icons.logout_rounded,
          title: 'Akkauntdan chiqish',
          subtitle: 'Boshqa akkaunt bilan kirish',
          onTap: () async {
            await widget.onLogout();
          },
        ),

        const SizedBox(height: 26),
        const Center(
          child: Text(
            'fiqhMedia 1.3.0\nAndroid sinov versiyasi',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // =================================================
  // NAVIGATION
  // =================================================

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedTab) {
      case 1:
        page = searchPage();
        break;
      case 2:
        page = AiChatScreen(
          key: ValueKey('chat_$selectedMadhhab'),
          madhhab: selectedMadhhab,
          availableMadhhabs: availableMadhhabs,
          onMadhhabChanged: chooseMadhhab,
        );
        break;
      case 3:
        page = libraryPage();
        break;
      case 4:
        page = profilePage();
        break;
      default:
        page = homePage();
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 14,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FiqhLogo(size: 38),
            SizedBox(width: 10),
            Text(
              'fiqhMedia',
              style: TextStyle(
                color: emerald,
                fontWeight: FontWeight.w900,
                fontSize: 23,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mavzuni o‘zgartirish',
            onPressed: widget.onThemeChanged,
            icon: Icon(
              widget.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Obuna tariflari',
            onPressed: openPlans,
            icon: const Icon(
              Icons.workspace_premium_outlined,
              color: gold,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: KeyedSubtree(
          key: ValueKey(selectedTab),
          child: page,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: switchTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Asosiy',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Qidiruv',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Kutubxona',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// AI DEMO
// =====================================================

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage(this.text, this.isUser);
}

class AiChatScreen extends StatefulWidget {
  final String? madhhab;
  final List<String> availableMadhhabs;
  final ValueChanged<String?> onMadhhabChanged;

  const AiChatScreen({
    super.key,
    required this.madhhab,
    required this.availableMadhhabs,
    required this.onMadhhabChanged,
  });

  @override
  State<AiChatScreen> createState() =>
      _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final controller = TextEditingController();
  final List<ChatMessage> messages = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void sendMessage() {
    final question = controller.text.trim();

    if (question.isEmpty || widget.madhhab == null) {
      return;
    }

    setState(() {
      messages.add(ChatMessage(question, true));

      messages.add(
        ChatMessage(
          'Tanlangan mazhab: ${widget.madhhab}\n\n'
          'fiqhMedia AI hozircha DEMO rejimida.\n\n'
          'Bu mazhab uchun tasdiqlangan ilmiy '
          'manbalar va haqiqiy AI xizmati '
          'hali ulanmagan.\n\n'
          'Shu sababli hozir manbasiz '
          'diniy hukm berilmaydi.',
          false,
        ),
      );

      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    return Stack(
      children: [
        const Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: 0.08,
                child: FiqhLogo(size: 260),
              ),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: double.infinity,
              color: isDark
                  ? const Color(0xFF493B22)
                  : const Color(0xFFFFF3D9),
              padding: const EdgeInsets.all(13),
              child: const Text(
                'AI DEMO • Tekshirilgan manbalar '
                'hali ulanmagan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              child: DropdownButtonFormField<String>(
                key: ValueKey(widget.madhhab),
                initialValue: widget.madhhab,
                decoration: const InputDecoration(
                  labelText: 'AI uchun mazhab',
                  prefixIcon: Icon(
                    Icons.auto_stories_outlined,
                  ),
                ),
                items: widget.availableMadhhabs.map((name) {
                  return DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: widget.onMadhhabChanged,
              ),
            ),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 40,
                              color: emerald,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'fiqhMedia AI',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 23,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.madhhab == null
                                  ? 'Boshlash uchun '
                                      'mazhabni tanlang.'
                                  : '${widget.madhhab} '
                                      'mazhabi tanlandi.\n'
                                      'AI hozircha demo.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];

                        return Align(
                          alignment: message.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 310,
                            ),
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: message.isUser
                                  ? emerald
                                  : theme.cardColor,
                              borderRadius:
                                  BorderRadius.circular(19),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: message.isUser
                                    ? Colors.white
                                    : theme.colorScheme
                                        .onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Container(
                color: theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        enabled: widget.madhhab != null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendMessage(),
                        decoration: InputDecoration(
                          hintText: widget.madhhab == null
                              ? 'Avval mazhab tanlang'
                              : 'Savolingizni yozing...',
                          prefixIcon: const Icon(
                            Icons.edit_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: widget.madhhab == null
                          ? null
                          : sendMessage,
                      icon: const Icon(
                        Icons.send_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =====================================================
// ARTICLE SCREEN
// =====================================================

class ArticleScreen extends StatefulWidget {
  final FiqhArticle article;
  final bool initialFavorite;
  final VoidCallback onFavorite;

  const ArticleScreen({
    super.key,
    required this.article,
    required this.initialFavorite,
    required this.onFavorite,
  });

  @override
  State<ArticleScreen> createState() =>
      _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late bool favorite;

  @override
  void initState() {
    super.initState();
    favorite = widget.initialFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
        actions: [
          IconButton(
            onPressed: () {
              widget.onFavorite();
              setState(() {
                favorite = !favorite;
              });
            },
            icon: Icon(
              favorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: favorite ? Colors.red : emerald,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: Icon(
              Icons.auto_stories_rounded,
              size: 65,
              color: emerald,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.article.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Chip(
              label: Text(widget.article.madhhab),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                widget.article.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 13),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Manba holati: tasdiqlangan '
                'manba hali ulanmagan.\n\n'
                'Bu sahifa sinov rejimida.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// FAVORITES
// =====================================================

class FavoritesScreen extends StatelessWidget {
  final Set<String> favoriteIds;
  final String? selectedMadhhab;
  final ValueChanged<FiqhArticle> onOpenArticle;

  const FavoritesScreen({
    super.key,
    required this.favoriteIds,
    required this.selectedMadhhab,
    required this.onOpenArticle,
  });

  @override
  Widget build(BuildContext context) {
    final saved = demoArticles.where((article) {
      return favoriteIds.contains(article.id) &&
          article.madhhab == selectedMadhhab;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sevimlilar'),
      ),
      body: saved.isEmpty
          ? const Center(
              child: Text(
                'Tanlangan mazhabda '
                'saqlangan maqola yo‘q.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: saved.length,
              itemBuilder: (context, index) {
                final article = saved[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    title: Text(article.title),
                    subtitle: Text(article.madhhab),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onOpenArticle(article);
                    },
                  ),
                );
              },
            ),
    );
  }
}

// =====================================================
// SUBSCRIPTION PLANS
// =====================================================

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const plans = [
      'Free',
      'Plus',
      'Pro',
      'Pro Plus',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Obuna tariflari'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'fiqhMedia obunalari',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Narxlar va imkoniyatlar '
            'hali yakuniy belgilanmagan.',
          ),
          const SizedBox(height: 23),
          ...plans.map(
            (plan) => Card(
              margin: const EdgeInsets.only(
                bottom: 13,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: gold,
                      size: 31,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        plan,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      plan == 'Free'
                          ? 'Bepul'
                          : 'Tez kunda',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
