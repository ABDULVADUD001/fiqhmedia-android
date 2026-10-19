
import 'package:flutter/material.dart';

void main() {
  runApp(const FiqhMediaApp());
}

// =====================================================
// fiqhMedia 1.1.0
// =====================================================

const Color emerald = Color(0xFF087F69);
const Color pageColor = Color(0xFFF7F9F8);
const Color ink = Color(0xFF172B2B);
const Color gold = Color(0xFFD6A449);

const String logoPath = 'assets/icon/fiqhmedia.png';
const double logoOpacity = 0.08;

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

// =====================================================
// APP
// =====================================================

class FiqhMediaApp extends StatelessWidget {
  const FiqhMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fiqhMedia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: emerald,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: pageColor,
          foregroundColor: ink,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// =====================================================
// MAQOLALAR MODELI
// =====================================================

class FiqhArticle {
  final String title;
  final String category;
  final String madhhab;
  final String description;

  const FiqhArticle({
    required this.title,
    required this.category,
    required this.madhhab,
    required this.description,
  });
}

// Hozircha demo ma'lumotlar.
// Bular diniy fatvo emas.
// Tasdiqlangan manbalar keyin ulanadi.

const List<FiqhArticle> articles = [
  FiqhArticle(
    title: 'Tahorat',
    category: 'Poklik',
    madhhab: 'Hanafiy',
    description:
        'Tahorat bo‘yicha tasdiqlangan '
        'manbalar keyinchalik joylashtiriladi.',
  ),
  FiqhArticle(
    title: 'Namoz',
    category: 'Ibodat',
    madhhab: 'Hanafiy',
    description:
        'Namozga oid ishonchli manbalar '
        'keyinchalik qo‘shiladi.',
  ),
  FiqhArticle(
    title: 'Ro‘za',
    category: 'Ibodat',
    madhhab: 'Shofe’iy',
    description:
        'Ro‘za bo‘yicha tasdiqlangan '
        'manbalar hali ulanmagan.',
  ),
  FiqhArticle(
    title: 'Zakot',
    category: 'Ibodat',
    madhhab: 'Molikiy',
    description:
        'Zakotga oid tekshirilgan '
        'materiallar keyin qo‘shiladi.',
  ),
  FiqhArticle(
    title: 'Haj',
    category: 'Ibodat',
    madhhab: 'Hanbaliy',
    description:
        'Haj bo‘yicha tekshirilgan '
        'materiallar hali ulanmagan.',
  ),
];

// =====================================================
// MAIN SCREEN
// =====================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  String? selectedMadhhab;
  String searchText = '';

  final Set<String> favorites = {};

  final TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Color get selectedColor {
    final index = madhhabs.indexOf(
      selectedMadhhab ?? '',
    );

    return index < 0
        ? emerald
        : madhhabColors[index];
  }

  void selectMadhhab(String name) {
    setState(() {
      selectedMadhhab = name;
      searchText = '';
      searchController.clear();
    });
  }

  // Mazhablar aralashmasligi uchun filtr.

  List<FiqhArticle> get filteredArticles {
    if (selectedMadhhab == null) {
      return [];
    }

    return articles.where((article) {
      if (article.madhhab != selectedMadhhab) {
        return false;
      }

      final query = searchText.toLowerCase().trim();

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

  void openArticle(FiqhArticle article) {
    if (article.madhhab != selectedMadhhab) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleScreen(
          article: article,
          isFavorite: favorites.contains(
            '${article.madhhab}:${article.title}',
          ),
          onFavorite: () {
            final key =
                '${article.madhhab}:${article.title}';

            setState(() {
              if (!favorites.add(key)) {
                favorites.remove(key);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget screen;

    switch (selectedIndex) {
      case 1:
        screen = buildSearch();
        break;

      case 2:
        screen = AiChatScreen(
          key: ValueKey(selectedMadhhab),
          madhhab: selectedMadhhab,
        );
        break;

      case 3:
        screen = buildLibrary();
        break;

      case 4:
        screen = buildProfile();
        break;

      default:
        screen = buildHome();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'fiqhMedia',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: emerald,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tariflar',
            icon: const Icon(
              Icons.workspace_premium_outlined,
              color: gold,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PlansScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(child: screen),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Asosiy',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Qidiruv',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
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

  // ===================================================
  // BOSH SAHIFA
  // ===================================================

  Widget buildHome() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Assalomu alaykum!',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Fiqh ilmi — bir makonda.',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF087F69),
                Color(0xFF064C43),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 48,
              ),
              SizedBox(height: 20),
              Text(
                'Ilm. Ishonch. Kelajak.',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'To‘rt mazhab uchun zamonaviy '
                'raqamli ilm platformasi.',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),
        sectionTitle('Mazhabni tanlang'),
        const SizedBox(height: 8),

        const Text(
          'Har bir mazhab ma’lumotlari alohida.',
          style: TextStyle(color: Colors.black54),
        ),

        const SizedBox(height: 15),
        madhhabGrid(),

        const SizedBox(height: 24),
        sectionTitle('Tezkor qidiruv'),
        const SizedBox(height: 12),

        actionCard(
          icon: Icons.search,
          title: 'Mavzuni izlash',
          subtitle: selectedMadhhab == null
              ? 'Avval mazhabni tanlang'
              : '$selectedMadhhab mazhabi',
          onTap: () {
            setState(() {
              selectedIndex = 1;
            });
          },
        ),

        const SizedBox(height: 12),

        actionCard(
          icon: Icons.auto_awesome,
          title: 'fiqhMedia AI',
          subtitle: 'AI yordamchi — demo',
          onTap: () {
            setState(() {
              selectedIndex = 2;
            });
          },
        ),

        const SizedBox(height: 24),
        sectionTitle('Mavzular'),
        const SizedBox(height: 12),

        if (selectedMadhhab == null)
          const Text(
            'Mavzularni ko‘rish uchun '
            'mazhab tanlang.',
          )
        else
          ...filteredArticles.map(articleCard),
      ],
    );
  }

  // ===================================================
  // MAZHAB KARTOCHKALARI
  // ===================================================

  Widget madhhabGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: madhhabs.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final name = madhhabs[index];
        final selected = selectedMadhhab == name;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => selectMadhhab(name),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: madhhabColors[index],
              borderRadius: BorderRadius.circular(20),
              border: selected
                  ? Border.all(
                      color: ink,
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
                  size: 28,
                ),
                const SizedBox(height: 8),
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
    );
  }

  // ===================================================
  // QIDIRUV
  // ===================================================

  Widget buildSearch() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        sectionTitle('Mavzuni izlash'),
        const SizedBox(height: 10),
        const Text(
          '1. Avval mazhabni tanlang.',
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          key: ValueKey(selectedMadhhab),
          initialValue: selectedMadhhab,
          decoration: InputDecoration(
            labelText: 'Mazhab',
            prefixIcon: const Icon(
              Icons.auto_stories_outlined,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: madhhabs.map((name) {
            return DropdownMenuItem<String>(
              value: name,
              child: Text(name),
            );
          }).toList(),
          onChanged: (name) {
            if (name != null) {
              selectMadhhab(name);
            }
          },
        ),

        const SizedBox(height: 20),
        const Text('2. Mavzu nomini yozing.'),
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
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (selectedMadhhab == null)
          emptyState(
            'Qidiruv uchun mazhabni tanlang.',
          )
        else ...[
          Text(
            'Mazhab: $selectedMadhhab',
            style: TextStyle(
              color: selectedColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${filteredArticles.length} ta natija',
          ),
          const SizedBox(height: 12),

          if (filteredArticles.isEmpty)
            emptyState(
              'Bu mazhab bo‘yicha mavzu '
              'topilmadi. Boshqa mazhab '
              'natijalari ko‘rsatilmaydi.',
            )
          else
            ...filteredArticles.map(articleCard),
        ],
      ],
    );
  }

  // ===================================================
  // KUTUBXONA
  // ===================================================

  Widget buildLibrary() {
    final items = selectedMadhhab == null
        ? <FiqhArticle>[]
        : articles
            .where(
              (a) => a.madhhab == selectedMadhhab,
            )
            .toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        sectionTitle('Raqamli kutubxona'),
        const SizedBox(height: 12),

        const Text(
          'Kitoblar va tasdiqlangan '
          'manbalar keyinchalik ulanadi.',
        ),

        const SizedBox(height: 20),

        if (selectedMadhhab == null)
          emptyState(
            'Avval bosh sahifadan '
            'mazhabni tanlang.',
          )
        else ...[
          Text(
            '$selectedMadhhab kutubxonasi',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(articleCard),
        ],
      ],
    );
  }

  // ===================================================
  // PROFIL
  // ===================================================

  Widget buildProfile() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xFFE0F3ED),
            child: Icon(
              Icons.person,
              size: 45,
              color: emerald,
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

        const SizedBox(height: 25),

        actionCard(
          icon: Icons.auto_stories,
          title: 'Tanlangan mazhab',
          subtitle:
              selectedMadhhab ?? 'Hali tanlanmagan',
          onTap: () {
            setState(() {
              selectedIndex = 0;
            });
          },
        ),

        const SizedBox(height: 12),

        actionCard(
          icon: Icons.favorite_outline,
          title: 'Sevimlilar',
          subtitle:
              '${favorites.length} ta saqlangan',
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                  'Sevimlilar sahifasi '
                  'keyin qo‘shiladi.',
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        actionCard(
          icon: Icons.workspace_premium_outlined,
          title: 'Obuna tariflari',
          subtitle: 'Free, Plus, Pro, Pro Plus',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PlansScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // ===================================================
  // UMUMIY WIDGETLAR
  // ===================================================

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
        color: ink,
      ),
    );
  }

  Widget emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            color: emerald,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
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
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor:
              const Color(0xFFE2F3EF),
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
          Icons.chevron_right,
        ),
        onTap: onTap,
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
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () => openArticle(article),
      ),
    );
  }
}

// =====================================================
// FIqhMEDIA AI CHAT
// =====================================================

class AiChatScreen extends StatefulWidget {
  final String? madhhab;

  const AiChatScreen({
    super.key,
    required this.madhhab,
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
          text: question,
          isUser: true,
        ),
      );

      messages.add(
        ChatMessage(
          text:
              'Siz ${widget.madhhab} mazhabini '
              'tanladingiz.\n\n'
              'Hozircha fiqhMedia AI sinov '
              'rejimida ishlamoqda. '
              'Ushbu mazhab bo‘yicha '
              'tasdiqlangan manbalar '
              'va AI xizmati hali ulanmagan.\n\n'
              'Shuning uchun hozir '
              'manbasiz diniy hukm '
              'berilmaydi.',
          isUser: false,
        ),
      );

      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ============================================
        // RASMIY FIQHMEDIA LOGOSI
        // KO'RINISH 8%, SHAFFOFLIK 92%
        // ============================================

        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: logoOpacity,
                child: Image.asset(
                  logoPath,
                  width: 260,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // ============================================
        // AI CHAT INTERFEYSI
        // ============================================

        Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: const Color(0xFFFFF3D9),
              child: const Text(
                'AI DEMO • Tasdiqlangan '
                'manbalar hali ulanmagan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: widget.madhhab == null
                  ? const Text(
                      'AI chatdan foydalanish '
                      'uchun avval bosh sahifada '
                      'mazhab tanlang.',
                      textAlign: TextAlign.center,
                    )
                  : Chip(
                      avatar: const Icon(
                        Icons.auto_stories,
                        size: 18,
                      ),
                      label: Text(
                        'Mazhab: ${widget.madhhab}',
                      ),
                    ),
            ),

            Expanded(
              child: messages.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          'Assalomu alaykum!\n\n'
                          'fiqhMedia AI yordamchisi '
                          'sinov rejimida.\n\n'
                          'Haqiqiy ilmiy manbalar '
                          'keyin ulanadi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.all(14),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message =
                            messages[index];

                        return Align(
                          alignment: message.isUser
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
                                const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: message.isUser
                                  ? emerald
                                  : Colors.white
                                      .withValues(
                                      alpha: 0.94,
                                    ),
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: message.isUser
                                    ? Colors.white
                                    : ink,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // ========================================
            // SAVOL YOZISH
            // ========================================

            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        enabled:
                            widget.madhhab != null,
                        onSubmitted: (_) {
                          sendMessage();
                        },
                        decoration: InputDecoration(
                          hintText:
                              widget.madhhab == null
                                  ? 'Avval mazhab tanlang'
                                  : 'Savolingizni yozing...',
                          filled: true,
                          fillColor: pageColor,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              24,
                            ),
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

// =====================================================
// CHAT MESSAGE MODEL
// =====================================================

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

// =====================================================
// MAQOLA SAHIFASI
// =====================================================

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

class _ArticleScreenState extends State<ArticleScreen> {
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
          const Icon(
            Icons.auto_stories_rounded,
            size: 65,
            color: emerald,
          ),

          const SizedBox(height: 20),

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

          const SizedBox(height: 16),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Manba holati: hali '
                'tasdiqlangan manba ulanmagan.\n\n'
                'Bu sahifa faqat ilova '
                'interfeysini sinash uchun.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// FREE / PLUS / PRO / PRO PLUS
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
            'O‘zingizga mos tarifni tanlang',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Narxlar va imkoniyatlar '
            'hali yakuniy tasdiqlanmagan.',
          ),

          const SizedBox(height: 18),

          ...plans.map(
            (plan) => Card(
              margin: const EdgeInsets.only(
                bottom: 14,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: gold,
                      size: 30,
                    ),

                    const SizedBox(width: 16),

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
