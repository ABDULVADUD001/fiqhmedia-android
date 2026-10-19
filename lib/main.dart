
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FiqhMediaApp());
}

// ===================================================
// FIQHMEDIA — ANDROID APPLICATION
// ===================================================

const String apiBaseUrl =
    'https://fiqhmedia-backend-production.up.railway.app';

const Color emerald = Color(0xFF087F69);
const Color deepGreen = Color(0xFF064C43);
const Color gold = Color(0xFFD6A449);
const Color background = Color(0xFFF7F9F8);
const Color ink = Color(0xFF182C29);

const String logoPath = 'assets/icon/fiqhmedia.png';

const List<String> defaultMadhhabs = [
  'Hanafiy',
  'Shofe’iy',
  'Molikiy',
  'Hanbaliy',
];

const List<Color> madhhabColors = [
  Color(0xFF087F69),
  Color(0xFF3478DA),
  Color(0xFFE78A3B),
  Color(0xFFD5A527),
];

// ===================================================
// APPLICATION THEME
// ===================================================

class FiqhMediaApp extends StatefulWidget {
  const FiqhMediaApp({super.key});

  @override
  State<FiqhMediaApp> createState() =>
      _FiqhMediaAppState();
}

class _FiqhMediaAppState extends State<FiqhMediaApp> {
  ThemeMode themeMode = ThemeMode.light;

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
        centerTitle: false,
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
    return MaterialApp(
      title: 'fiqhMedia',
      debugShowCheckedModeBanner: false,
      theme: createTheme(Brightness.light),
      darkTheme: createTheme(Brightness.dark),
      themeMode: themeMode,
      home: MainScreen(
        isDark: themeMode == ThemeMode.dark,
        onThemeChanged: toggleTheme,
      ),
    );
  }
}

// ===================================================
// ARTICLE DATA
// ===================================================

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

// Demo mavzular. Haqiqiy fatvo emas.
const List<FiqhArticle> demoArticles = [
  FiqhArticle(
    id: 'hanafi_tahorat',
    title: 'Tahorat',
    category: 'Poklik',
    madhhab: 'Hanafiy',
    description:
        'Tahorat bo‘yicha tekshirilgan '
        'Hanafiy manbalari keyin ulanadi.',
  ),
  FiqhArticle(
    id: 'hanafi_namoz',
    title: 'Namoz',
    category: 'Ibodat',
    madhhab: 'Hanafiy',
    description:
        'Namozga oid ishonchli manbalar '
        'keyingi bosqichda ulanadi.',
  ),
  FiqhArticle(
    id: 'shafii_roza',
    title: 'Ro‘za',
    category: 'Ibodat',
    madhhab: 'Shofe’iy',
    description:
        'Shofe’iy mazhabi bo‘yicha '
        'manbalar keyin qo‘shiladi.',
  ),
  FiqhArticle(
    id: 'maliki_zakot',
    title: 'Zakot',
    category: 'Moliyaviy ibodat',
    madhhab: 'Molikiy',
    description:
        'Molikiy mazhabi bo‘yicha '
        'manbalar keyin qo‘shiladi.',
  ),
  FiqhArticle(
    id: 'hanbali_haj',
    title: 'Haj',
    category: 'Ibodat',
    madhhab: 'Hanbaliy',
    description:
        'Hanbaliy mazhabi bo‘yicha '
        'manbalar keyin qo‘shiladi.',
  ),
];

// ===================================================
// SAFE LOGO WIDGET
// ===================================================

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
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return Icon(
          Icons.auto_stories_rounded,
          size: size,
          color: emerald,
        );
      },
    );
  }
}

// ===================================================
// MAIN NAVIGATION
// ===================================================

class MainScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeChanged;

  const MainScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
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

  final TextEditingController searchController =
      TextEditingController();

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

  // Mazhablar ro‘yxatini Railway'dan yuklash.
  Future<void> loadMadhhabs() async {
    if (mounted) {
      setState(() {
        loadingMadhhabs = true;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/madhhabs'),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}',
        );
      }

      final dynamic decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (decoded is! List) {
        throw const FormatException(
          'Server javobi noto‘g‘ri.',
        );
      }

      final List<String> names = [];

      for (final dynamic item in decoded) {
        if (item is Map && item['name'] is String) {
          final String name =
              (item['name'] as String).trim();

          if (name.isNotEmpty &&
              !names.contains(name)) {
            names.add(name);
          }
        }
      }

      if (names.isEmpty) {
        throw const FormatException(
          'Mazhablar ro‘yxati bo‘sh.',
        );
      }

      if (!mounted) return;

      setState(() {
        availableMadhhabs = names;
        loadingMadhhabs = false;
        connectedToServer = true;

        if (selectedMadhhab != null &&
            !names.contains(selectedMadhhab)) {
          selectedMadhhab = null;
          searchText = '';
          searchController.clear();
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        availableMadhhabs =
            List<String>.from(defaultMadhhabs);
        loadingMadhhabs = false;
        connectedToServer = false;
      });
    }
  }

  void chooseMadhhab(String? value) {
    if (value == null ||
        !availableMadhhabs.contains(value)) {
      return;
    }

    setState(() {
      selectedMadhhab = value;
      searchText = '';
      searchController.clear();
    });
  }

  // QAT'IY MAZHAB FILTER
  List<FiqhArticle> get filteredArticles {
    if (selectedMadhhab == null) {
      return [];
    }

    final String query =
        searchText.trim().toLowerCase();

    return demoArticles.where((article) {
      if (article.madhhab != selectedMadhhab) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return article.title
              .toLowerCase()
              .contains(query) ||
          article.category
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  void switchTab(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  void openArticle(FiqhArticle article) {
    if (article.madhhab != selectedMadhhab) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(
          article: article,
          initialFavorite:
              favorites.contains(article.id),
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
        builder: (context) =>
            const PlansScreen(),
      ),
    );
  }

  void openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          favoriteIds: favorites,
          selectedMadhhab: selectedMadhhab,
          onOpenArticle: openArticle,
        ),
      ),
    );
  }

  // =================================================
  // SHARED WIDGETS
  // =================================================

  Widget heading(String text) {
    return Text(
      text,
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
              size: 32,
              color: emerald,
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
          child: Icon(
            icon,
            color: emerald,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
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
          size: 30,
          color: emerald,
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
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () => openArticle(article),
      ),
    );
  }

  Widget madhhabDropdown() {
    return DropdownButtonFormField<String>(
      key: ValueKey<String?>(
        selectedMadhhab,
      ),
      initialValue: selectedMadhhab,
      decoration: const InputDecoration(
        labelText: 'Mazhabni tanlang',
        prefixIcon: Icon(
          Icons.auto_stories_outlined,
        ),
      ),
      items: availableMadhhabs.map((name) {
        return DropdownMenuItem<String>(
          value: name,
          child: Text(name),
        );
      }).toList(),
      onChanged: chooseMadhhab,
    );
  }

  // =================================================
  // HOME PAGE
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

        // PREMIUM HERO BANNER
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                emerald,
                deepGreen,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
              Positioned(
                right: -25,
                top: -25,
                child: const IgnorePointer(
                  child: Opacity(
                    opacity: 0.12,
                    child: FiqhLogo(size: 180),
                  ),
                ),
              ),
              const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 50,
                    color: Colors.white,
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
        const SizedBox(height: 10),

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
          itemCount: availableMadhhabs.length,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.48,
          ),
          itemBuilder: (context, index) {
            final String name =
                availableMadhhabs[index];

            final bool selected =
                selectedMadhhab == name;

            final Color color = madhhabColors[
                index % madhhabColors.length];

            return InkWell(
              borderRadius:
                  BorderRadius.circular(22),
              onTap: () => chooseMadhhab(name),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      Color.lerp(
                        color,
                        Colors.black,
                        0.20,
                      )!,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(22),
                  border: Border.all(
                    color: selected
                        ? gold
                        : Colors.transparent,
                    width: selected ? 3 : 0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
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
  // SEARCH PAGE
  // =================================================

  Widget searchPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        heading('Mavzuni izlash'),
        const SizedBox(height: 18),

        const Text(
          '1. Avval mazhabni tanlang',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        madhhabDropdown(),

        const SizedBox(height: 22),

        const Text(
          '2. Mavzu nomini yozing',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: searchController,
          enabled: selectedMadhhab != null,
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: selectedMadhhab == null
                ? 'Avval mazhab tanlang'
                : 'Masalan: tahorat',
            prefixIcon: const Icon(
              Icons.search,
            ),
          ),
        ),

        const SizedBox(height: 23),

        if (selectedMadhhab == null)
          emptyCard(
            'Qidiruvni boshlash uchun '
            'mazhab tanlang.',
          )
        else ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: const Icon(
                Icons.verified_outlined,
                size: 17,
              ),
              label: Text(
                'Mazhab: $selectedMadhhab',
              ),
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
              'Ushbu mazhab bo‘yicha '
              'natija topilmadi.\n'
              'Boshqa mazhabdagi ma’lumot '
              'aralashtirilmaydi.',
            )
          else
            ...filteredArticles.map(articleCard),
        ],
      ],
    );
  }

  // =================================================
  // LIBRARY PAGE
  // =================================================

  Widget libraryPage() {
    final List<FiqhArticle> items =
        selectedMadhhab == null
            ? []
            : demoArticles
                .where(
                  (article) =>
                      article.madhhab ==
                      selectedMadhhab,
                )
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
            'Kutubxonani ko‘rish uchun '
            'mazhabni tanlang.',
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
  // PROFILE PAGE
  // =================================================

  Widget profilePage() {
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

        const SizedBox(height: 26),

        actionCard(
          icon: Icons.auto_stories_outlined,
          title: 'Tanlangan mazhab',
          subtitle:
              selectedMadhhab ?? 'Tanlanmagan',
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
          subtitle:
              'Free, Plus, Pro va Pro Plus',
          onTap: openPlans,
        ),

        const SizedBox(height: 26),

        const Center(
          child: Text(
            'fiqhMedia 1.0.0\nAndroid sinov versiyasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // =================================================
  // APP STRUCTURE
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
          key: ValueKey(
            'chat_$selectedMadhhab',
          ),
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

// ===================================================
// AI CHAT
// ===================================================

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
  final TextEditingController controller =
      TextEditingController();

  final List<ChatMessage> messages = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void sendMessage() {
    final question = controller.text.trim();

    if (question.isEmpty ||
        widget.madhhab == null) {
      return;
    }

    setState(() {
      messages.add(
        ChatMessage(
          question,
          true,
        ),
      );

      messages.add(
        ChatMessage(
          'Tanlangan mazhab: ${widget.madhhab}\n\n'
          'fiqhMedia AI hozircha DEMO rejimida.\n\n'
          'Bu mazhab uchun tasdiqlangan '
          'ilmiy manbalar va haqiqiy '
          'AI xizmati hali ulanmagan.\n\n'
          'Shu sababli hozir '
          'manbasiz diniy hukm '
          'berilmaydi.',
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
        // SHAAFFOF LOGO — 8%
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: 0.08,
                child: const FiqhLogo(size: 260),
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
                items: widget.availableMadhhabs
                    .map(
                      (name) =>
                          DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      ),
                    )
                    .toList(),
                onChanged: widget.onMadhhabChanged,
              ),
            ),

            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(25),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: emerald,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'fiqhMedia AI',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w800,
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
                              textAlign:
                                  TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.all(14),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];

                        return Align(
                          alignment: msg.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints:
                                const BoxConstraints(
                              maxWidth: 310,
                            ),
                            margin:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),
                            padding:
                                const EdgeInsets.all(
                              15,
                            ),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? emerald
                                  : theme.cardColor,
                              borderRadius:
                                  BorderRadius.circular(
                                19,
                              ),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isUser
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
                        enabled:
                            widget.madhhab != null,
                        textInputAction:
                            TextInputAction.send,
                        onSubmitted: (value) {
                          sendMessage();
                        },
                        decoration: InputDecoration(
                          hintText:
                              widget.madhhab == null
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
                      onPressed:
                          widget.madhhab == null
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

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage(this.text, this.isUser);
}

// ===================================================
// ARTICLE SCREEN
// ===================================================

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
              color: favorite
                  ? Colors.red
                  : emerald,
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
              label: Text(
                widget.article.madhhab,
              ),
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

// ===================================================
// FAVORITES
// ===================================================

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

// ===================================================
// SUBSCRIPTION PLANS
// ===================================================

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
                          fontWeight:
                              FontWeight.bold,
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
