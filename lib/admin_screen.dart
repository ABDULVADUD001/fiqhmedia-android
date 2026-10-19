
import 'package:flutter/material.dart';

import 'auth_service.dart';

class FiqhAdminScreen extends StatefulWidget {
  const FiqhAdminScreen({super.key});

  @override
  State<FiqhAdminScreen> createState() =>
      _FiqhAdminScreenState();
}

class _FiqhAdminScreenState extends State<FiqhAdminScreen> {
  static const Color emerald = Color(0xFF087F69);

  late Future<Map<String, dynamic>> statusFuture;

  @override
  void initState() {
    super.initState();
    statusFuture = FiqhAuthService.adminStatus();
  }

  void refresh() {
    setState(() {
      statusFuture = FiqhAuthService.adminStatus();
    });
  }

  Widget statistic({
    required IconData icon,
    required String title,
    required dynamic value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: emerald, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: emerald,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('fiqhMedia Admin'),
        actions: [
          IconButton(
            onPressed: refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: statusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState !=
              ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 45,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: refresh,
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final admin = data['admin'];

          if (admin is! Map ||
              (admin['role'] != 'super_admin' &&
                  admin['role'] != 'admin')) {
            return const Center(
              child: Text(
                'Administrator ruxsati yo‘q.',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      emerald,
                      Color(0xFF064C43),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(23),
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                    SizedBox(height: 13),
                    Text(
                      'Boshqaruv markazi',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Administrator server tomonidan '
                      'tasdiqlangan.',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              statistic(
                icon: Icons.school_outlined,
                title: 'Mualliflar',
                value: data['authors'] ?? 0,
              ),

              statistic(
                icon: Icons.menu_book_outlined,
                title: 'Kitoblar',
                value: data['books'] ?? 0,
              ),

              statistic(
                icon: Icons.article_outlined,
                title: 'Maqolalar',
                value: data['articles'] ?? 0,
              ),

              const SizedBox(height: 22),

              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Keyingi yangilanishda mualliflar, '
                    'kitoblar va maqolalarni kiritish, '
                    'tahrirlash hamda ilmiy tekshirish '
                    'funksiyalari qo‘shiladi.\n\n'
                    'Tasdiqlanmagan diniy ma’lumotlar '
                    'ommaga ko‘rsatilmaydi.',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
