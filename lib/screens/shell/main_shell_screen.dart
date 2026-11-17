import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../lost_found/lost_found_feed_screen.dart';
import '../listings/create_listing_screen.dart';
import '../profile/profile_screen.dart';
import '../radar/radar_feed_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    RadarFeedScreen(bottomClearance: AppTheme.overlaidNavigationClearance),
    LostFoundFeedScreen(),
    CreateListingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      extendBody: _currentIndex == 0,
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              actions: [
                IconButton(
                  tooltip: 'İlanlarım',
                  icon: const Icon(Icons.article_outlined),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.myListings),
                ),
              ],
              title: Row(
                children: [
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'fix'),
                        TextSpan(
                          text: 'Campus',
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      ],
                    ),
                    style: AppTheme.logo,
                    semanticsLabel: 'fixCampus',
                  ),
                  if (auth.isAdmin) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.ink,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('YÖNETİCİ', style: AppTheme.adminLabel),
                    ),
                  ],
                ],
              ),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: AppTheme.line),
              ),
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (final (index, page) in _pages.indexed)
            TickerMode(enabled: index == _currentIndex, child: page),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        key: const ValueKey('main-bottom-nav'),
        selectedIndex: _currentIndex,
        onSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
