import 'package:flutter/material.dart';
import 'package:tech_restock/app.dart';
import 'package:tech_restock/screens/account/profile_screen.dart';
import 'package:tech_restock/screens/home/home_screen.dart';
import 'package:tech_restock/screens/offers/offers_screen.dart';
import 'package:tech_restock/screens/orders/orders_screen.dart';
import 'package:tech_restock/screens/search/search_screen.dart';
import 'package:tech_restock/widgets/app_bottom_nav.dart';
import 'package:tech_restock/widgets/gradient_scaffold.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _openLegal = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (args['tab'] is int) {
        _index = args['tab'] as int;
      }
      if (args['legal'] == true) {
        _openLegal = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onSearchTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchScreen(
                  onClose: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
            onCartTap: () =>
                Navigator.of(context).pushNamed(ShoppandaApp.cartRoute),
          ),
          const OffersScreen(),
          const OrdersScreen(showBack: false),
          ProfileScreen(openLegalOnMount: _openLegal),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
