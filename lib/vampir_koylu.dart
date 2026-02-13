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

  // Role özel renk veren yardımcı fonksiyon
  Color _rolRengi(String rol) {
    if (rol.contains("VAMPİR")) return Colors.red;
    if (rol.contains("DOKTOR")) return Colors.blue;
    if (rol.contains("GÖZCÜ")) return Colors.purple;
    return Colors.green; // Köylü için
  }

  // Role özel talimat veren yardımcı fonksiyon
  String _rolAciklamasi(String rol) {
    if (rol.contains("VAMPİR")) return "Her gece bir köylüyü elemek için arkadaşınla fısıldaş.";
    if (rol.contains("DOKTOR")) return "Her gece birini seç; eğer vampir onu seçerse o kişi ölmez.";
    if (rol.contains("GÖZCÜ")) return "Her gece birinin kartına gizlice bakma hakkın var.";
    return "Gündüzleri vampiri bulmaya çalış, geceleri hayatta kal!";
  }

  void rolleriHazirla() {
    List<String> yeniRoller = [];

    // Dinamik Rol Dağıtım Mantığı
    yeniRoller.add("VAMPİR 🧛"); 
    if (oyuncuSayisi >= 8) yeniRoller.add("VAMPİR 🧛"); // 8+ oyuncuda 2. vampir
    
    yeniRoller.add("DOKTOR 🏥");
    yeniRoller.add("GÖZCÜ 👁️");

    while (yeniRoller.length < oyuncuSayisi) {
      yeniRoller.add("KÖYLÜ 👨‍🌾");
    }

    yeniRoller.shuffle(); 
    setState(() {
      roller = yeniRoller;
      sira = 0;
      rolGoster = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vampir Köylü - Rol Dağıtımı"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: roller.isEmpty ? kurulumEkrani() : oyunEkrani(),
      ),
    );
  }

  Widget kurulumEkrani() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group, size: 80, color: Colors.redAccent),
          const SizedBox(height: 20),
          Text("Oyuncu Sayısı: $oyuncuSayisi", 
               style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Slider(
            value: oyuncuSayisi.toDouble(),
            min: 4, max: 15, divisions: 11,
            activeColor: Colors.redAccent,
            onChanged: (v) => setState(() => oyuncuSayisi = v.toInt()),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              minimumSize: const Size(250, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: rolleriHazirla, 
            child: const Text("ROLLERİ DAĞIT", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget oyunEkrani() {
    // Tüm roller dağıtıldıktan sonra görünen rehber ekranı
    if (sira >= roller.length) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nights_stay, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text("Gece Akış Rehberi", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Divider(thickness: 2),
            ),
            _rehberAdimi("1. Herkes gözlerini kapatsın."),
            _rehberAdimi("2. Vampirler birbirini tanısın ve kurbanı seçsin."),
            _rehberAdimi("3. Doktor uyansın ve koruyacağı kişiyi seçsin."),
            _rehberAdimi("4. Gözcü uyansın ve birinin rolüne baksın."),
            _rehberAdimi("5. Herkes uyansın ve sabah olsun!"),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => setState(() => roller = []), 
              child: const Text("YENİ OYUN BAŞLAT", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    // Rollerin tek tek elden ele dağıtıldığı ekran
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("${sira + 1}. Oyuncu", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("Lütfen telefonu eline al", style: TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 40),
        Container(
          width: 280, height: 320,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)],
            border: Border.all(color: rolGoster ? _rolRengi(roller[sira]) : Colors.grey[300]!, width: 3),
          ),
          child: rolGoster 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(roller[sira], 
                       style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _rolRengi(roller[sira]))),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _rolAciklamasi(roller[sira]),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                  ),
                ],
              )
            : const Icon(Icons.help_outline, size: 100, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            minimumSize: const Size(200, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => setState(() => rolGoster = !rolGoster),
          child: Text(rolGoster ? "GİZLE" : "ROLÜMÜ GÖR", style: const TextStyle(color: Colors.white, fontSize: 18)),
        ),
        if (rolGoster)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextButton.icon(
              onPressed: () => setState(() { sira++; rolGoster = false; }), 
              icon: const Icon(Icons.arrow_forward, size: 30, color: Colors.green),
              label: const Text("SONRAKİ OYUNCU", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          )
      ],
    );
  }

  Widget _rehberAdimi(String metin) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
      child: Row(
        children: [
          const Icon(Icons.double_arrow, color: Colors.indigo, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(metin, style: const TextStyle(fontSize: 17))),
        ],
      ),
    );
  }
}