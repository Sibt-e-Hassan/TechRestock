import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shop_pandaa/app.dart';
import 'package:shop_pandaa/services/khata_service.dart';
import 'package:shop_pandaa/services/restock_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Warm the device-local B2B stores (khata ledger + restock reminders).
  await KhataService.instance.load();
  await RestockService.instance.load();
  runApp(const ShoppandaApp());
}
