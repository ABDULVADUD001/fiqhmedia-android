
import 'package:flutter/material.dart';

void main() {
  runApp(const FiqhMediaApp());
}

const Color primaryBlue = Color(0xFF1677E8);
const Color backgroundColor = Color(0xFFF5F7FB);
const Color darkText = Color(0xFF17233C);

class FiqhMediaApp extends StatelessWidget {
  const FiqhMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fiqhMedia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: darkText,
          centerTitle: false,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

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

// Hozircha faqat dastur interfeysini sinash uchun
// kiritilgan namunaviy ma'lumotlar.
const List<FiqhArticle> articles = [
  FiqhArticle(
    title: 'Tahorat',
    category: 'Poklik',
    madhhab: 'Hanafiy',
    description:
        'Tahorat mavzusining namunaviy bo‘limi. '
        'Tasdiqlangan kitob va sahifalar keyin ulanadi.',
  ),
  FiqhArticle(
    title: 'Namoz',
    category: 'Ibodat',
    madhhab: 'Hanafiy',
    description:
        'Namoz haqidagi materiallar shu bo‘limda joylashadi.',
  ),
  FiqhArticle(
    title: 'Ro‘za',
    category: 'Ibodat',
    madhhab: 'Shofe’iy',
    description:
        'Ro‘za haqidagi tekshirilgan manbalar keyin kiritiladi.',
  ),
  FiqhArticle(
    title: 'Zakot',
    category: 'Moliyaviy ibodat',
    madhhab: 'Molikiy',
    description:
        'Zakotga oid kitoblar va ilmiy izohlar uchun bo‘lim.',
  ),
  FiqhArticle(
    title: 'Haj',
    category: 'Ibodat',
    madhhab: 'Hanbaliy',
    description:
        'Hajga oid ishonchli materiallar uchun bo‘lim.',
  ),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  String selectedMadhhab = 'Hanafiy';
  String searchText = '';
  final Set<String> favorites = {};

  void openArticle(FiqhArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(
          article: article,
          isFavorite: favorites.contains(article.title),
          onFavorite: () {
            setState(() {
              if (!favorites.add(article.title)) {
                favorites.remove(article.title);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      buildHome(),
      buildSearch(),
      buildAi(),
      buildLibrary(),
      buildProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'fiqhMedia',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: primaryBlue,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium),
            tooltip: 'Tariflar',
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
      body: SafeArea(child: screens[selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Bosh sahifa',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Qidiruv',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
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

  Widget buildHome() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Assalomu alaykum!',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Fiqh ilmini bir makonda o‘rganing.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_stories,
                color: Colors.white,
                size: 42,
              ),
              SizedBox(height: 18),
              Text(
                'Ilm. Ishonch. Manba.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '4 mazhab, raqamli kutubxona va AI yordamchi',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Mazhablar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: [
            madhhabCard(
              'Hanafiy',
              const Color(0xFF247AF2),
              Icons.menu_book,
            ),
            madhhabCard(
              'Shofe’iy',
              const Color(0xFF19B69A),
              Icons.auto_stories,
            ),
            madhhabCard(
              'Molikiy',
              const Color(0xFFFF9048),
              Icons.library_books,
            ),
            madhhabCard(
              'Hanbaliy',
              const Color(0xFFF0B83C),
              Icons.book,
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'Mavzular',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 10),
        ...articles.take(3).map(articleTile),
        const SizedBox(height: 18),
        const Text(
          'Sinov rejimi: diniy ma’lumotlar hali '
          'ilmiy tekshiruvdan o‘tkazilmagan.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget madhhabCard(
    String title,
    Color color,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedMadhhab = title;
          selectedIndex = 3;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
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
  }

  Widget articleTile(FiqhArticle article) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F1FF),
          child: Icon(Icons.article_outlined, color: primaryBlue),
        ),
        title: Text(article.title),
        subtitle: Text(
          '${article.category} • ${article.madhhab}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => openArticle(article),
      ),
    );
  }

  Widget buildSearch() {
    final results = articles.where((article) {
      final text =
          '${article.title} ${article.category} ${article.madhhab}'
              .toLowerCase();
      return text.contains(searchText.toLowerCase());
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Qidiruv',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          onChanged: (value) {
            setState(() => searchText = value);
          },
          decoration: InputDecoration(
            hintText: 'Mavzuni qidiring...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('${results.length} ta natija'),
        const SizedBox(height: 12),
        ...results.map(articleTile),
      ],
    );
  }

  Widget buildAi() {
    return const AiDemoScreen();
  }

  Widget buildLibrary() {
    final results = articles
        .where((article) => article.madhhab == selectedMadhhab)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Kutubxona',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: selectedMadhhab,
          decoration: const InputDecoration(
            labelText: 'Mazhab',
            border: OutlineInputBorder(),
          ),
          items: ['Hanafiy', 'Shofe’iy', 'Molikiy', 'Hanbaliy']
              .map(
                (name) => DropdownMenuItem(
                  value: name,
                  child: Text(name),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedMadhhab = value);
            }
          },
        ),
        const SizedBox(height: 18),
        ...results.map(articleTile),
        const SizedBox(height: 15),
        const Text(
          'To‘liq kitoblar bazasi keyin ulanadi.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget buildProfile() {
    final savedArticles = articles
        .where((article) => favorites.contains(article.title))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 38,
            backgroundColor: Color(0xFFE3EFFF),
            child: Icon(
              Icons.person,
              size: 40,
              color: primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Mehmon foydalanuvchi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Card(
          color: Colors.white,
          child: ListTile(
            leading: const Icon(
              Icons.workspace_premium,
              color: Color(0xFFF0A82D),
            ),
            title: const Text('Tarifim: Free'),
            subtitle: const Text('Plus, Pro va Pro Plus'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PlansScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Saqlangan maqolalar (${savedArticles.length})',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (savedArticles.isEmpty)
          const Text('Hali maqola saqlanmagan.'),
        ...savedArticles.map(articleTile),
        const SizedBox(height: 25),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('fiqhMedia 1.0.0'),
          subtitle: Text('Android sinov versiyasi'),
        ),
      ],
    );
  }
}

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
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late bool bookmarked = widget.isFavorite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maqola'),
        actions: [
          IconButton(
            icon: Icon(
              bookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            onPressed: () {
              widget.onFavorite();
              setState(() => bookmarked = !bookmarked);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            widget.article.madhhab,
            style: const TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.article.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 36),
          Text(
            widget.article.description,
            style: const TextStyle(
              fontSize: 17,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'MANBA HOLATI',
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bu sinov matni. Asl kitob, muallif '
            'va sahifa hali biriktirilmagan.',
          ),
        ],
      ),
    );
  }
}

class AiDemoScreen extends StatefulWidget {
  const AiDemoScreen({super.key});

  @override
  State<AiDemoScreen> createState() => _AiDemoScreenState();
}

class _AiDemoScreenState extends State<AiDemoScreen> {
  final TextEditingController controller =
      TextEditingController();

  final List<String> messages = [
    'fiqhMedia AI demo rejimida. '
        'Haqiqiy AI va ishonchli manbalar hali ulanmagan.',
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void send() {
    final question = controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      messages.add('Siz: $question');
      messages.add(
        'AI: Hozircha javob berish tizimi ulanmagan. '
        'Manbasiz diniy hukm chiqarilmaydi.',
      );
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFFFFF0D3),
          padding: const EdgeInsets.all(12),
          child: const Text(
            'AI DEMO — haqiqiy sun’iy intellekt hali ulanmagan',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(messages[index]),
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
                    onSubmitted: (_) => send(),
                    decoration: const InputDecoration(
                      hintText: 'Savolingizni yozing...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: send,
                  icon: const Icon(
                    Icons.send,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('fiqhMedia tariflari')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'O‘zingizga mos tarifni tanlang',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Asosiy diniy bilimlar barcha tariflarda bepul.',
          ),
          const SizedBox(height: 20),
          planCard(
            context,
            'Free',
            '\$0',
            const Color(0xFF667085),
            '5 AI savol/kun • 3 tarjima/kun',
          ),
          planCard(
            context,
            'Plus',
            '\$1 / oy',
            const Color(0xFF1677E8),
            '30 AI savol/kun • 20 tarjima/kun',
          ),
          planCard(
            context,
            'Pro',
            '\$2.99 / oy',
            const Color(0xFF19B69A),
            '100 AI savol/kun • Audio o‘qish',
          ),
          planCard(
            context,
            'Pro Plus',
            '\$4.99 / oy',
            const Color(0xFF172A45),
            '300 AI savol/kun • Kengaytirilgan AI',
          ),
          const SizedBox(height: 16),
          const Text(
            'Tariflar hozircha namuna. '
            'Haqiqiy to‘lov tizimi ulanmagan.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget planCard(
    BuildContext context,
    String name,
    String price,
    Color color,
    String features,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium, color: color),
                const SizedBox(width: 9),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(features),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'To‘lovlar hali yoqilmagan. '
                      'Bu sinov versiyasi.',
                    ),
                  ),
                );
              },
              child: const Text('Batafsil'),
            ),
          ],
        ),
      ),
    );
  }
}
