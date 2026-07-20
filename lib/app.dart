import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_pandaa/screens/auth/create_account_screen.dart';
import 'package:shop_pandaa/screens/auth/forgot_password_screen.dart';
import 'package:shop_pandaa/screens/auth/sign_in_screen.dart';
import 'package:shop_pandaa/screens/cart/cart_screen.dart';
import 'package:shop_pandaa/screens/market/market_detail_screen.dart';
import 'package:shop_pandaa/screens/shop/shop_detail_screen.dart';
import 'package:shop_pandaa/screens/orders/orders_screen.dart';
import 'package:shop_pandaa/screens/product/product_detail_screen.dart';
import 'package:shop_pandaa/screens/shell/main_shell.dart';
import 'package:shop_pandaa/theme/app_theme.dart';
import 'package:shop_pandaa/widgets/auth_gate.dart';
import 'package:shop_pandaa/widgets/cart_scope.dart';

class ShoppandaApp extends StatelessWidget {
  const ShoppandaApp({super.key});

  static const signInRoute = '/';
  static const createAccountRoute = '/create-account';
  static const forgotPasswordRoute = '/forgot-password';
  static const mainRoute = '/main';
  static const productRoute = '/product';
  static const marketDetailRoute = '/market';
  static const shopDetailRoute = '/shop';
  static const ordersRoute = '/orders';
  static const cartRoute = '/cart';

  @override
  Widget build(BuildContext context) {
    return CartScope(
      child: MaterialApp(
      title: 'ThokBazaar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case signInRoute:
            return MaterialPageRoute(builder: (_) => const SignInScreen());
          case createAccountRoute:
            return MaterialPageRoute(builder: (_) => const CreateAccountScreen());
          case forgotPasswordRoute:
            final initialEmail = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => ForgotPasswordScreen(initialEmail: initialEmail),
            );
          case mainRoute:
            if (FirebaseAuth.instance.currentUser != null) {
              return MaterialPageRoute(builder: (_) => const MainShell());
            }
            return MaterialPageRoute(builder: (_) => const SignInScreen());
          case productRoute:
            final id = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: id ?? ''),
            );
          case shopDetailRoute:
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => ShopDetailScreen(
                  shopId: args['shopId'] as String? ?? '',
                  shopName: args['shopName'] as String? ?? 'Shop',
                  category: args['category'] as String?,
                  marketName: args['marketName'] as String?,
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => const ShopDetailScreen(
                shopId: '',
                shopName: 'Shop',
              ),
            );
          case marketDetailRoute:
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => MarketDetailScreen(
                  marketId: args['marketId'] as String? ?? '',
                  marketName: args['marketName'] as String? ?? 'Market',
                  location: args['location'] as String?,
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => const MarketDetailScreen(
                marketId: '',
                marketName: 'Market',
              ),
            );
          case ordersRoute:
            return MaterialPageRoute(builder: (_) => const OrdersScreen());
          case cartRoute:
            return MaterialPageRoute(builder: (_) => const CartScreen());
          default:
            return null;
        }
      },
      ),
    );
  }
}
