import 'package:flutter/material.dart';
import 'dart:async';

class TabuSayfasi extends StatefulWidget {
  const TabuSayfasi({super.key});

  @override
  State<TabuSayfasi> createState() => _TabuSayfasiState();
}

class _TabuSayfasiState extends State<TabuSayfasi> {
  int skor = 0;
  int sure = 60;
  Timer? timer;
  int suankiKelimeIndex = 0;

  List<Map<String, dynamic>> kelimeler = [
  {"kelime": "GÜNEŞ", "yasaklar": ["Sarı", "Sıcak", "Yaz", "Gökyüzü", "Lamba"]},
  {"kelime": "KİTAP", "yasaklar": ["Okumak", "Sayfa", "Kütüphane", "Yazar", "Roman"]},
  {"kelime": "PİZZA", "yasaklar": ["İtalyan", "Hamur", "Peynir", "Dilim", "Yemek"]},
  {"kelime": "ORMAN", "yasaklar": ["Ağaç", "Yeşil", "Piknik", "Doğa", "Oksijen"]},
  {"kelime": "FUTBOL", "yasaklar": ["Top", "Kale", "Maç", "Saha", "Ofsayt"]},
];

  void oyunBaslat() {
    setState(() {
      sure = 60;
      skor = 0;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (sure > 0) {
        setState(() => sure--);
      } else {
        t.cancel();
        _oyunBittiDialog();
      }
    });
  }

  void _oyunBittiDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Süre Bitti!"),
        content: Text("Toplam Skorun: $skor"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tamam"))
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tabu - Skor: $skor"), backgroundColor: Colors.orange),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Kalan Süre: $sure", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            if (timer == null || !timer!.isActive)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(200, 60)),
                onPressed: oyunBaslat, 
                child: const Text("OYUNU BAŞLAT", style: TextStyle(color: Colors.white, fontSize: 20))
              )
            else
              kelimeKarti(),
          ],
        ),
      ),
    );
  }

  Widget kelimeKarti() {
    var data = kelimeler[suankiKelimeIndex];
    return Column(
      children: [
        Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
          ),
          child: Column(
            children: [
              Text(data["kelime"], style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.red)),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              ...data["yasaklar"].map<Widget>((y) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(y, style: const TextStyle(fontSize: 22)),
              )).toList(),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(120, 50)),
              onPressed: () => setState(() => suankiKelimeIndex = (suankiKelimeIndex + 1) % kelimeler.length), 
              child: const Text("TABU", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(120, 50)),
              onPressed: () => setState(() {
                skor++;
                suankiKelimeIndex = (suankiKelimeIndex + 1) % kelimeler.length;
              }), 
              child: const Text("DOĞRU", style: TextStyle(color: Colors.white)),
            ),
          ],
        )
      ],
    );
  }
}