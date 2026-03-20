import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Tambah import ini
import 'screens/login_screen.dart';

// 2. Tambahin 'async' di fungsi main
void main() async {
  // 3. Wajib panggil ini biar plugin Flutter siap dipake
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Load file .env lu
  try {
    await dotenv.load(fileName: ".env");
    print("Berhasil load .env!"); // Cek di console nanti
  } catch (e) {
    print("Gagal load .env: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: LoginScreen(),
    );
  }
}
