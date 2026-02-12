import 'package:flutter/material.dart';
import 'vampir_koylu.dart'; // Vampir Köylü dosyasını bağlıyoruz
import 'tabu.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AnaGirisEkrani(),
  ));
}

class AnaGirisEkrani extends StatelessWidget {
  const AnaGirisEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eğlence Kutusu"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           // main.dart içindeki doğru buton yapısı
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    minimumSize: const Size(250, 70),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  ),
  onPressed: () {
    // Navigator satırı burada olmalı
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TabuSayfasi()),
    );
  },
  child: const Text("TABU", style: TextStyle(fontSize: 22, color: Colors.white)),
),
            const SizedBox(height: 30),
            
            // VAMPİR KÖYLÜ BUTONU
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(250, 70),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                debugPrint("Vampir Köylü sayfasına gidiliyor...");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VampirKoyluSayfasi()),
                );
              },
              child: const Text("VAMPİR KÖYLÜ", style: TextStyle(fontSize: 22, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}