
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FiqhMediaApp());
}

// ====================================================
// fiqhMedia — Premium Android UI
// ====================================================

const emerald = Color(0xFF087F69);
const deepGreen = Color(0xFF064C43);
const gold = Color(0xFFD6A449);
const lightBackground = Color(0xFFF7F9F8);
const logoPath = 'assets/icon/fiqhmedia.png';

const List<String> madhhabs = [
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

// ====================================================
// APPLICATION AND THEME
// ====================================================

class FiqhMediaApp extends StatefulWidget {
  const FiqhMediaApp({super.key});

  @override
  State<FiqhMediaApp> createState() => _FiqhMediaAppState();
}

class _FiqhMediaAppState extends State<FiqhMediaApp> {
  ThemeMode mode = ThemeMode.light;

  void changeTheme() {
    setState(() {
      mode = mode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  ThemeData makeTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emerald,
        brightness: brightness,
      ),
      scaffoldBackgroundColor:
          dark ? const Color(0xFF101918) : lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor:
            dark ? const Color(0xFF101918) : lightBackground,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: dark
            ? const Color(0xFF1C2927)
            : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark
            ? const Color(0xFF1C2927)
            : Colors.white,
        indicatorColor: dark
            ? const Color(0xFF28584E)
            : const Color(0xFFDCF2EA),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark
            ? const Color(0xFF22322F)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
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
      theme: makeTheme(Brightness.light),
      darkTheme: makeTheme(Brightness.dark),
      themeMode: mode,
      home: MainScreen(
        isDark: mode == ThemeMode.dark,
        onThemeChanged: changeTheme,
      ),
    );
  }
}

// ====================================================
// DEMO ARTICLE MODEL
// ====================================================

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

// Demo mavzular. Hali fatvo yoki ilmiy manba emas.

const List<FiqhArticle> articles = [
  FiqhArticle(
    id: 'hanafi_tahorat',
    title: 'Tahorat',
    category: 'Poklik',
    madhhab: 'Hanafiy',
    description:
        'Tahorat mavzusiga oid tasdiqlangan '
        'manbalar keyinchalik qo‘shiladi.',
  ),
  FiqhArticle(
    id: 'hanafi_namoz',
    title: 'Namoz',
    category: 'Ibodat',
    madhhab: 'Hanafiy',
    description:
        'Namoz mavzusiga oid ishonchli '
        'manbalar hali ulanmagan.',
  ),
  FiqhArticle(
    id: 'shafii_roza',
    title: 'Ro‘za',
    category: 'Ibodat',
    madhhab: 'Shofe’iy',
    description:
        'Shofe’iy mazhabiga oid tekshirilgan '
        'manbalar keyinchalik qo‘shiladi.',
  ),
  FiqhArticle(
    id: 'maliki_zakot',
    title: 'Zakot',
    category: 'Ibodat',
    madhhab: 'Molikiy',
    description:
        'Molikiy mazhabiga oid tekshirilgan '
        'manbalar keyinchalik qo‘shiladi.',
  ),
  FiqhArticle(
    id: 'hanbali_haj',
    title: 'Haj',
    category: 'Ibodat',
    madhhab: 'Hanbaliy',
    description:
        'Hanbaliy mazhabiga oid tekshirilgan '
        'manbalar keyinchalik qo‘shiladi.',
  ),
];

// ====================================================
// MAIN SCREEN
// ====================================================

class MainScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeChanged;

  const MainScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int tab = 0;
  String? selectedMadhhab;
  String searchText = '';

  final Set<String> favorites = {};
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void chooseMadhhab(String? value) {
    if (value == null || !madhhabs.contains(value)) {
      return;
    }

    setState(() {
      selectedMadhhab = value;
      searchText = '';
      searchController.clear();
    });
  }

  List<FiqhArticle> get results {
    if (selectedMadhhab == null) return [];

    final query = searchText.trim().toLowerCase();

    return articles.where((article) {
      // Qat'iy mazhab filtri.
      if (article.madhhab != selectedMadhhab) {
        return false;
      }

      if (query.isEmpty) return true;

      return article.title.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query);
    }).toList();
  }

  void openArticle(FiqhArticle article) {
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
          favorites: favorites,
          onOpen: openArticle,
        ),
      ),
    );
  }

  void changeTab(int index) {
    setState(() => tab = index);
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (tab) {
      case 1:
        currentPage = searchPage();
        break;
      case 2:
        currentPage = AiChatScreen(
          key: ValueKey('chat_$selectedMadhhab'),
          madhhab: selectedMadhhab,
          onMadhhabChanged: chooseMadhhab,
        );
        break;
      case 3:
        currentPage = libraryPage();
        break;
      case 4:
        currentPage = profilePage();
        break;
      default:
        currentPage = homePage();
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 15,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                logoPath,
                width: 39,
                height: 39,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'fiqhMedia',
              style: TextStyle(
                color: emerald,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: widget.isDark
                ? 'Yorug‘ rejim'
                : 'Qorong‘i rejim',
            onPressed: widget.onThemeChanged,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                widget.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                key: ValueKey(widget.isDark),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tariflar',
            onPressed: openPlans,
            icon: const Icon(
              Icons.workspace_premium_outlined,
              color: gold,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 230),
          transitionBuilder: (child, animation) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: KeyedSubtree(
            key: ValueKey(tab),
            child: currentPage,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Asosiy',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Qidiruv',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI Chat',
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

  // ==================================================
  // HOME
  // ==================================================

  Widget homePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Assalomu alaykum!',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Ilm sari yana bir qadam.',
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        // Logo bilan premium banner.
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [emerald, deepGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: emerald.withValues(alpha: 0.17),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -25,
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset(
                    logoPath,
                    width: 185,
                    height: 185,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Image.asset(
                      logoPath,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ilm. Ishonch. Kelajak.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To‘rt mazhab. Bir ilmiy makon.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),
        heading('Mazhabni tanlang'),
        const SizedBox(height: 8),
        Text(
          'Har bir mazhab ma’lumotlari alohida.',
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 15),
        madhhabGrid(),

        const SizedBox(height: 25),
        heading('Tezkor xizmatlar'),
        const SizedBox(height: 12),
        actionCard(
          Icons.search,
          'Mavzuni izlash',
          selectedMadhhab == null
              ? 'Avval mazhab tanlang'
              : '$selectedMadhhab mazhabi',
          () => changeTab(1),
        ),
        const SizedBox(height: 12),
        actionCard(
          Icons.auto_awesome,
          'fiqhMedia AI',
          'Mazhabga mos AI yordamchi — demo',
          () => changeTab(2),
        ),

        const SizedBox(height: 24),
        heading('Mavzular'),
        const SizedBox(height: 12),
        if (selectedMadhhab == null)
          emptyCard('Mavzular uchun mazhab tanlang.')
        else
          ...results.map(articleCard),
      ],
    );
  }

  Widget madhhabGrid() {
    return GridView.builder(
      itemCount: madhhabs.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final name = madhhabs[index];
        final selected = selectedMadhhab == name;
        final color = madhhabColors[index];

        return InkWell(
          borderRadius: BorderRadius.circular(23),
          onTap: () => chooseMadhhab(name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  Color.lerp(color, Colors.black, 0.22)!,
                ],
              ),
              borderRadius: BorderRadius.circular(
                selected ? 27 : 22,
              ),
              border: Border.all(
                color: selected ? gold : Colors.transparent,
                width: selected ? 3 : 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(
                    alpha: selected ? 0.28 : 0.10,
                  ),
                  blurRadius: selected ? 17 : 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.auto_stories_outlined,
                    key: ValueKey(selected),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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
    );
  }

  // ==================================================
  // SEARCH
  // ==================================================

  Widget searchPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        heading('Mavzuni izlash'),
        const SizedBox(height: 12),
        const Text('1. Avval mazhabni tanlang'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey(selectedMadhhab),
          initialValue: selectedMadhhab,
          decoration: const InputDecoration(
            labelText: 'Mazhabni tanlang',
            prefixIcon: Icon(Icons.auto_stories_outlined),
          ),
          items: madhhabs.map((m) {
            return DropdownMenuItem(
              value: m,
              child: Text(m),
            );
          }).toList(),
          onChanged: chooseMadhhab,
        ),
        const SizedBox(height: 20),
        const Text('2. Mavzuni yozing'),
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
        const SizedBox(height: 22),
        if (selectedMadhhab == null)
          emptyCard('Qidirish uchun mazhab tanlang.')
        else ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text('Mazhab: $selectedMadhhab'),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '${results.length} ta demo natija',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 13),
          if (results.isEmpty)
            emptyCard(
              'Tanlangan mazhab bo‘yicha natija topilmadi.',
            )
          else
            ...results.map(articleCard),
        ],
      ],
    );
  }

  // ==================================================
  // LIBRARY
  // ==================================================

  Widget libraryPage() {
    final items = selectedMadhhab == null
        ? <FiqhArticle>[]
        : articles
            .where((a) => a.madhhab == selectedMadhhab)
            .toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        heading('Raqamli kutubxona'),
        const SizedBox(height: 9),
        Text(
          'Kitoblar va ulamolar ensiklopediyasi.',
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        actionCard(
          Icons.library_books_outlined,
          'Kitoblar ensiklopediyasi',
          'Tez kunda',
          comingSoon,
        ),
        const SizedBox(height: 12),
        actionCard(
          Icons.school_outlined,
          'Ulamolar ensiklopediyasi',
          'Mualliflar va tarjimai hollar',
          comingSoon,
        ),
        const SizedBox(height: 22),
        if (selectedMadhhab == null)
          emptyCard('Avval mazhabni tanlang.')
        else ...[
          heading('$selectedMadhhab mavzulari'),
          const SizedBox(height: 12),
          ...items.map(articleCard),
        ],
      ],
    );
  }

  // ==================================================
  // PROFILE
  // ==================================================

  Widget profilePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              logoPath,
              width: 94,
              height: 94,
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'fiqhMedia foydalanuvchisi',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 5),
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
          Icons.auto_stories_outlined,
          'Tanlangan mazhab',
          selectedMadhhab ?? 'Tanlanmagan',
          () => changeTab(0),
        ),
        const SizedBox(height: 12),
        actionCard(
          Icons.favorite_outline,
          'Sevimlilar',
          '${favorites.length} ta saqlangan',
          openFavorites,
        ),
        const SizedBox(height: 12),
        actionCard(
          widget.isDark
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined,
          'Ilova mavzusi',
          widget.isDark ? 'Qorong‘i' : 'Yorug‘',
          widget.onThemeChanged,
        ),
        const SizedBox(height: 12),
        actionCard(
          Icons.workspace_premium_outlined,
          'Obuna tariflari',
          'Free, Plus, Pro, Pro Plus',
          openPlans,
        ),
      ],
    );
  }

  // ==================================================
  // SHARED WIDGETS
  // ==================================================

  Widget heading(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget emptyCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.info_outline,
                color: emerald,
                size: 34,
              ),
              const SizedBox(height: 10),
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
    String title,
    String subtitle,
    VoidCallback action,
  ) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(13),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: emerald.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: emerald),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
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
        contentPadding: const EdgeInsets.all(13),
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

  void comingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bu imkoniyat keyingi versiyada qo‘shiladi.',
        ),
      ),
    );
  }
}

// ====================================================
// AI CHAT — MADHHAB SELECTION + WATERMARK
// ====================================================

class AiChatScreen extends StatefulWidget {
  final String? madhhab;
  final ValueChanged<String?> onMadhhabChanged;

  const AiChatScreen({
    super.key,
    required this.madhhab,
    required this.onMadhhabChanged,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final controller = TextEditingController();
  final List<ChatMessage> messages = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void send() {
    final question = controller.text.trim();

    if (question.isEmpty || widget.madhhab == null) {
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
          'Tasdiqlangan ilmiy manbalar '
          'va haqiqiy AI xizmati hali ulanmagan.\n\n'
          'Shuning uchun hozir manbasiz '
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
    final dark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // 8% KO'RINADIGAN RASMIY LOGO

        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  logoPath,
                  width: 260,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        Column(
          children: [
            Container(
              width: double.infinity,
              color: dark
                  ? const Color(0xFF493B22)
                  : const Color(0xFFFFF3D9),
              padding: const EdgeInsets.all(12),
              child: const Text(
                'AI DEMO • Manbalar hali ulanmagan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),

            // MAZHAB CHAT ICHIDA TANLANADI

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
                items: madhhabs.map((m) {
                  return DropdownMenuItem<String>(
                    value: m,
                    child: Text(m),
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
                              Icons.auto_awesome,
                              color: emerald,
                              size: 38,
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'fiqhMedia AI',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Text(
                              widget.madhhab == null
                                  ? 'Boshlash uchun mazhab tanlang.'
                                  : '${widget.madhhab} mazhabi tanlandi.\n'
                                    'Savolingizni yozishingiz mumkin.\n'
                                    'Hozircha demo rejimi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
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
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? emerald
                                  : (dark
                                      ? const Color(0xFF243330)
                                      : Colors.white),
                              borderRadius:
                                  BorderRadius.circular(19),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isUser
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
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
                        onSubmitted: (_) => send(),
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
                      onPressed:
                          widget.madhhab == null ? null : send,
                      icon: const Icon(Icons.send_rounded),
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

// ====================================================
// ARTICLE SCREEN
// ====================================================

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
              setState(() => favorite = !favorite);
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
              size: 66,
              color: emerald,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            widget.article.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Chip(
              label: Text(widget.article.madhhab),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(21),
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
                'Manba holati: tasdiqlangan manba '
                'hali ulanmagan.\n\n'
                'Kitob nomi, muallif tarjimai holi '
                'va manba tafsilotlari keyingi '
                'bosqichda qo‘shiladi.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================
// FAVORITES
// ====================================================

class FavoritesScreen extends StatelessWidget {
  final Set<String> favorites;
  final ValueChanged<FiqhArticle> onOpen;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final saved = articles
        .where((a) => favorites.contains(a.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sevimlilar'),
      ),
      body: saved.isEmpty
          ? const Center(
              child: Text(
                'Hozircha saqlangan mavzular yo‘q.',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
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
                    trailing:
                        const Icon(Icons.chevron_right),
                    onTap: () => onOpen(article),
                  ),
                );
              },
            ),
    );
  }
}

// ====================================================
// SUBSCRIPTION PLANS
// ====================================================

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
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Narxlar va imkoniyatlar '
            'hali yakuniy belgilanmagan.',
          ),
          const SizedBox(height: 20),
          ...plans.map(
            (plan) => Card(
              margin: const EdgeInsets.only(bottom: 13),
              child: Padding(
                padding: const EdgeInsets.all(19),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: gold,
                      size: 30,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        plan,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
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
