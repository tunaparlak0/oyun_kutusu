import 'package:flutter/material.dart';

class VampirKoyluSayfasi extends StatefulWidget {
  const VampirKoyluSayfasi({super.key});

  @override
  State<VampirKoyluSayfasi> createState() => _VampirKoyluSayfasiState();
}

class _VampirKoyluSayfasiState extends State<VampirKoyluSayfasi> {
  int oyuncuSayisi = 5;
  List<String> roller = [];
  int sira = 0;
  bool rolGoster = false;

  void rolleriHazirla() {
    // Basit bir rol dağıtım mantığı
    roller = List.generate(oyuncuSayisi, (index) => index < 2 ? "VAMPİR 🧛" : "KÖYLÜ 👨‍🌾");
    roller.shuffle(); // Roller karıştırılıyor
    setState(() { sira = 0; rolGoster = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vampir Köylü"), backgroundColor: Colors.redAccent),
      body: Center(
        child: roller.isEmpty ? kurulumEkrani() : oyunEkrani(),
      ),
    );
  }

  Widget kurulumEkrani() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Oyuncu Sayısı: $oyuncuSayisi", style: const TextStyle(fontSize: 24)),
        Slider(
          value: oyuncuSayisi.toDouble(),
          min: 4, max: 12, divisions: 8,
          onChanged: (v) => setState(() => oyuncuSayisi = v.toInt()),
        ),
        ElevatedButton(onPressed: rolleriHazirla, child: const Text("Rolleri Dağıt")),
      ],
    );
  }

  Widget oyunEkrani() {
    if (sira >= roller.length) {
      return const Text("Tüm roller dağıtıldı! Oyun Başlasın.", style: TextStyle(fontSize: 22));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("${sira + 1}. Oyuncu Telefonu Al", style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        rolGoster 
          ? Text(roller[sira], style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.red))
          : const Text("????", style: TextStyle(fontSize: 40)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => setState(() => rolGoster = !rolGoster),
          child: Text(rolGoster ? "Gizle" : "Rolümü Gör"),
        ),
        if (rolGoster)
          IconButton(onPressed: () => setState(() { sira++; rolGoster = false; }), icon: const Icon(Icons.arrow_forward, size: 40))
      ],
    );
  }
}