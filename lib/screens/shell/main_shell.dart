import 'package:flutter/material.dart';
import 'package:shop_pandaa/app.dart';
import 'package:shop_pandaa/screens/account/profile_screen.dart';
import 'package:shop_pandaa/screens/home/home_screen.dart';
import 'package:shop_pandaa/screens/khata/khata_screen.dart';
import 'package:shop_pandaa/screens/offers/offers_screen.dart';
import 'package:shop_pandaa/screens/orders/orders_screen.dart';
import 'package:shop_pandaa/screens/search/search_screen.dart';
import 'package:shop_pandaa/widgets/app_bottom_nav.dart';
import 'package:shop_pandaa/widgets/gradient_scaffold.dart';

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
          const KhataScreen(showBack: false),
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
