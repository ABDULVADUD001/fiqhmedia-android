
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FiqhMediaApp());
}

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

class FiqhMediaApp extends StatefulWidget {
  const FiqhMediaApp({super.key});

  @override
  State<FiqhMediaApp> createState() => _FiqhMediaAppState();
}

class _FiqhMediaAppState extends State<FiqhMediaApp> {
  ThemeMode themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      themeMode = themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
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
          dark ? const Color(0xFF101918) : background,
      appBarTheme: AppBarTheme(
        backgroundColor:
            dark ? const Color(0xFF101918) : background,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: dark
            ? const Color(0xFF1C2927)
            : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
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
        dark: themeMode == ThemeMode.dark,
        toggleTheme: toggleTheme,
      ),
    );
  }
}

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

// Faqat sinov ma'lumotlari.
// Ular tasdiqlangan fatvolar emas.
const demoArticles = [
  FiqhArticle(
    id: 'hanafi_tahorat',
    title: 'Tahorat',
    category: 'Poklik',
    madhhab: 'Hanafiy',
    description:
        'Hanafiy mazhabi bo‘yicha tahorat '
        'manbalari keyinchalik ulanadi.',
  ),
  FiqhArticle(
    id: 'hanafi_namoz',
    title: 'Namoz',
    category: 'Ibodat',
    madhhab: 'Hanafiy',
    description:
        'Namoz mavzusiga oid tasdiqlangan '
        'manbalar hozircha mavjud emas.',
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
    category: 'Ibodat',
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

class MainScreen extends StatefulWidget {
  final bool dark;
  final VoidCallback toggleTheme;

  const MainScreen({
    super.key,
    required this.dark,
    required this.toggleTheme,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int tab = 0;
  String? selectedMadhhab;
  String searchText = '';
  List<String> availableMadhhabs =
      List.of(defaultMadhhabs);

  bool loading = true;
  bool online = false;

  final searchController = TextEditingController();
  final Set<String> favorites = {};

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
    setState(() => loading = true);

    try {
      final response = await http
          .get(Uri.parse('$apiBaseUrl/madhhabs'))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data =
          jsonDecode(utf8.decode(response.bodyBytes));

      if (data is! List) {
        throw const FormatException(
          'Mazhablar ro‘yxati noto‘g‘ri',
        );
      }

      final names = <String>[];

      for (final item in data) {
        if (item is Map && item['name'] is String) {
          final name = (item['name'] as String).trim();

          if (name.isNotEmpty &&
              !names.contains(name)) {
            names.add(name);
          }
        }
      }

      if (names.isEmpty) {
        throw const FormatException(
          'Mazhablar ro‘yxati bo‘sh',
        );
      }

      if (!mounted) return;

      setState(() {
        availableMadhhabs = names;
        online = true;
        loading = false;

        if (selectedMadhhab != null &&
            !names.contains(selectedMadhhab)) {
          selectedMadhhab = null;
          searchText = '';
          searchController.clear();
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        availableMadhhabs =
            List.of(defaultMadhhabs);
        online = false;
        loading = false;
      });
    }
  }

  void chooseMadhhab(String? name) {
    if (name == null ||
        !availableMadhhabs.contains(name)) {
      return;
    }

    setState(() {
      selectedMadhhab = name;
      searchText = '';
      searchController.clear();
    });
  }

  List<FiqhArticle> get results {
    final madhhab = selectedMadhhab;

    if (madhhab == null) return [];

    final query = searchText.trim().toLowerCase();

    return demoArticles.where((article) {
      // Boshqa mazhab ma'lumotlari aralashmaydi.
      if (article.madhhab != madhhab) {
        return false;
      }

      if (query.isEmpty) return true;

      return article.title
              .toLowerCase()
              .contains(query) ||
          article.category
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  void changeTab(int index) {
    setState(() => tab = index);
  }

  void openArticle(FiqhArticle article) {
    if (article.madhhab != selectedMadhhab) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleScreen(
          article: article,
          isFavorite: favorites.contains(article.id),
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

  Widget title(String value) {
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
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.info_outline,
                color: emerald,
                size: 35,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget actionCard(
    IconData icon,
    String heading,
    String subtitle,
    VoidCallback action,
  ) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor:
              emerald.withValues(alpha: 0.12),
          child: Icon(icon, color: emerald),
        ),
        title: Text(
          heading,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: action,
      ),
    );
  }

  Widget articleCard(FiqhArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: const Icon(
          Icons.menu_book_outlined,
          color: emerald,
          size: 32,
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

  Widget madhhabPicker() {
    return DropdownButtonFormField<String>(
      key: ValueKey(selectedMadhhab),
      initialValue: selectedMadhhab,
      decoration: const InputDecoration(
        labelText: 'Mazhabni tanlang',
        prefixIcon: Icon(Icons.auto_stories_outlined),
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
        const Text('Fiqh ilmi — bir makonda.'),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [emerald, deepGreen],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -25,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.12,
                    child: Image.asset(
                      logoPath,
                      width: 165,
                      height: 165,
                      errorBuilder: (_, _, _) =>
                          const Icon(
                        Icons.auto_stories,
                        size: 140,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_stories,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 25),
                  Text(
                    'Ilm. Ishonch. Kelajak.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 9),
                  Text(
                    'To‘rt mazhab. Bir ilmiy makon.',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),
        title('Mazhabni tanlang'),
        const SizedBox(height: 10),

        if (loading)
          const LinearProgressIndicator()
        else
          Text(
            online
                ? 'Mazhablar serverdan yuklandi'
                : 'Oflayn mazhablar ro‘yxati',
            style: TextStyle(
              color: online ? emerald : Colors.orange,
            ),
          ),

        const SizedBox(height: 14),

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
            childAspectRatio: 1.55,
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
                duration:
                    const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(22),
                  border: selected
                      ? Border.all(
                          color: gold,
                          width: 3,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.auto_stories_outlined,
                      color: Colors.white,
                      size: 31,
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
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 25),
        title('Asosiy bo‘limlar'),
        const SizedBox(height: 12),

        actionCard(
          Icons.search,
          'Qidiruv',
          'Mazhab bo‘yicha qidirish',
          () => changeTab(1),
        ),
        const SizedBox(height: 10),
        actionCard(
          Icons.auto_awesome,
          'AI yordamchi',
          'Sinov rejimi',
          () => changeTab(2),
        ),
        const SizedBox(height: 10),
        actionCard(
          Icons.menu_book_outlined,
          'Raqamli kutubxona',
          'Kitoblar va ilmiy manbalar',
          () => changeTab(3),
        ),

        const SizedBox(height: 25),
        title('Mavzular'),
        const SizedBox(height: 12),

        if (selectedMadhhab == null)
          emptyCard('Avval mazhabni tanlang.')
        else
          ...results.map(articleCard),
      ],
    );
  }

  Widget searchPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        title('Mavzuni izlash'),
        const SizedBox(height: 16),
        const Text('1. Avval mazhabni tanlang'),
        const SizedBox(height: 10),
        madhhabPicker(),
        const SizedBox(height: 22),
        const Text('2. Mavzuni yozing'),
        const SizedBox(height: 10),

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

        const SizedBox(height: 20),

        if (selectedMadhhab == null)
          emptyCard(
            'Qidirish uchun mazhab tanlang.',
          )
        else ...[
          Chip(
            label: Text(
              'Mazhab: $selectedMadhhab',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${results.length} ta demo natija',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (results.isEmpty)
            emptyCard(
              'Ushbu mazhab bo‘yicha '
              'natija topilmadi.',
            )
          else
            ...results.map(articleCard),
        ],
      ],
    );
  }

  Widget libraryPage() {
    final items = selectedMadhhab == null
        ? <FiqhArticle>[]
        : demoArticles
            .where(
              (a) => a.madhhab == selectedMadhhab,
            )
            .toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        title('Raqamli kutubxona'),
        const SizedBox(height: 10),
        const Text(
          'Kitoblar va ulamolar ensiklopediyasi.',
        ),
        const SizedBox(height: 20),
        actionCard(
          Icons.library_books_outlined,
          'Kitoblar ensiklopediyasi',
          'Tez kunda',
          () => showComingSoon(),
        ),
        const SizedBox(height: 12),
        actionCard(
          Icons.school_outlined,
          'Ulamolar ensiklopediyasi',
          'Tez kunda',
          () => showComingSoon(),
        ),
        const SizedBox(height: 22),
        if (selectedMadhhab == null)
          emptyCard(
            'Avval mazhabni tanlang.',
          )
        else ...[
          title('$selectedMadhhab mavzulari'),
          const SizedBox(height: 12),
          ...items.map(articleCard),
        ],
      ],
    );
  }

  void showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bu imkoniyat keyin qo‘shiladi.',
        ),
      ),
    );
  }

  Widget profilePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Center(
          child: Image.asset(
            logoPath,
            width: 95,
            height: 95,
            errorBuilder: (_, _, _) =>
                const CircleAvatar(
              radius: 45,
              child: Icon(
                Icons.person,
                size: 45,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'fiqhMedia foydalanuvchisi',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 7),
        const Center(
          child: Text(
            'Free',
            style: TextStyle(
              color: emerald,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 25),
        actionCard(
          Icons.auto_stories,
          'Tanlangan mazhab',
          selectedMadhhab ?? 'Tanlanmagan',
          () => changeTab(0),
        ),
        const SizedBox(height: 12),
        actionCard(
          Icons.favorite_outline,
          'Saqlangan maqolalar',
          '${favorites.length} ta',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritesScreen(
                  favoriteIds: Set.of(favorites),
                  onOpen: openArticle,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        actionCard(
          widget.dark
              ? Icons.dark_mode
              : Icons.light_mode,
          'Ilova mavzusi',
          widget.dark ? 'Qorong‘i' : 'Yorug‘',
          widget.toggleTheme,
        ),
        const SizedBox(height: 12),
        actionCard(
          Icons.workspace_premium,
          'Obuna tariflari',
          'Free, Plus, Pro, Pro Plus',
          openPlans,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (tab) {
      case 1:
        page = searchPage();
        break;
      case 2:
        page = AiChatScreen(
          key: ValueKey(
            'chat_$selectedMadhhab',
          ),
          madhhab: selectedMadhhab,
          options: availableMadhhabs,
          onChanged: chooseMadhhab,
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              logoPath,
              width: 37,
              height: 37,
              errorBuilder: (_, _, _) =>
                  const Icon(
                Icons.auto_stories,
                color: emerald,
              ),
            ),
            const SizedBox(width: 9),
            const Text(
              'fiqhMedia',
              style: TextStyle(
                color: emerald,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(
              widget.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          IconButton(
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
          key: ValueKey(tab),
          child: page,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Asosiy',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Qidiruv',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
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

// AI CHAT
class AiChatScreen extends StatefulWidget {
  final String? madhhab;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const AiChatScreen({
    super.key,
    required this.madhhab,
    required this.options,
    required this.onChanged,
  });

  @override
  State<AiChatScreen> createState() =>
      _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final controller = TextEditingController();
  final messages = <ChatMessage>[];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void send() {
    final question = controller.text.trim();

    if (question.isEmpty ||
        widget.madhhab == null) {
      return;
    }

    setState(() {
      messages.add(
        ChatMessage(question, true),
      );

      messages.add(
        ChatMessage(
          'Tanlangan mazhab: ${widget.madhhab}\n\n'
          'fiqhMedia AI hozircha demo rejimida. '
          'Tasdiqlangan ilmiy manbalar va '
          'haqiqiy AI xizmati hali ulanmagan.\n\n'
          'Shuning uchun manbasiz diniy '
          'hukm berilmaydi.',
          false,
        ),
      );

      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark =
        theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // 8% shaffof rasmiy fiqhMedia logo.
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  logoPath,
                  width: 260,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(
                    Icons.auto_stories,
                    color: emerald,
                    size: 180,
                  ),
                ),
              ),
            ),
          ),
        ),

        Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              color: dark
                  ? const Color(0xFF493B22)
                  : const Color(0xFFFFF3D9),
              child: const Text(
                'AI DEMO • Ishonchli manbalar '
                'hali ulanmagan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: DropdownButtonFormField<String>(
                key: ValueKey(widget.madhhab),
                initialValue: widget.madhhab,
                decoration: const InputDecoration(
                  labelText: 'AI uchun mazhab',
                  prefixIcon: Icon(
                    Icons.auto_stories_outlined,
                  ),
                ),
                items: widget.options.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: widget.onChanged,
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
                              Icons.auto_awesome,
                              size: 40,
                              color: emerald,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'fiqhMedia AI',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.madhhab == null
                                  ? 'Avval mazhabni '
                                      'tanlang.'
                                  : '${widget.madhhab} '
                                      'mazhabi tanlandi.\n'
                                      'AI sinov rejimida.',
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
                            padding:
                                const EdgeInsets.all(
                              15,
                            ),
                            margin:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? emerald
                                  : theme.cardColor,
                              borderRadius:
                                  BorderRadius.circular(
                                18,
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
              child: Padding(
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
                        onSubmitted: (_) => send(),
                        decoration: InputDecoration(
                          hintText:
                              widget.madhhab == null
                                  ? 'Mazhab tanlang'
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
                              : send,
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

// MAQOLA
class ArticleScreen extends StatefulWidget {
  final FiqhArticle article;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const ArticleScreen({
    super.key,
    required this.article,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  State<ArticleScreen> createState() =>
      _ArticleScreenState();
}

class _ArticleScreenState
    extends State<ArticleScreen> {
  late bool favorite;

  @override
  void initState() {
    super.initState();
    favorite = widget.isFavorite;
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
              Icons.auto_stories,
              color: emerald,
              size: 65,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            widget.article.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 27,
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
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Tasdiqlangan manbalar '
                'hali ulanmagan.\n\n'
                'Bu sahifa sinov rejimida.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SEVIMLILAR
class FavoritesScreen extends StatelessWidget {
  final Set<String> favoriteIds;
  final ValueChanged<FiqhArticle> onOpen;

  const FavoritesScreen({
    super.key,
    required this.favoriteIds,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final saved = demoArticles
        .where((a) => favoriteIds.contains(a.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sevimlilar'),
      ),
      body: saved.isEmpty
          ? const Center(
              child: Text(
                'Hozircha maqola saqlanmagan.',
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
                    subtitle:
                        Text(article.madhhab),
                    onTap: () => onOpen(article),
                  ),
                );
              },
            ),
    );
  }
}

// TARIFLAR
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Narxlar va imkoniyatlar '
            'hali belgilanmagan.',
          ),
          const SizedBox(height: 20),
          ...plans.map(
            (plan) => Card(
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
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
