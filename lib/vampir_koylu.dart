import 'package:flutter/material.dart';

class VampirKoyluSayfasi extends StatefulWidget {
  const VampirKoyluSayfasi({super.key});

  @override
  State<VampirKoyluSayfasi> createState() => _VampirKoyluSayfasiState();
}

class _VampirKoyluSayfasiState extends State<VampirKoyluSayfasi> {
  int vampirSayisi = 1;
  int doktorSayisi = 1;
  int gozcuSayisi = 1;
  int koyluSayisi = 2;

  List<String> roller = [];
  List<String> oyuncuIsimleri = [];
  int sira = 0;
  bool rolGoster = false;
  List<TextEditingController> controllers = [];

  // Rollerin toplam sayısını veren yardımcı değişken
  int get toplamOyuncu => vampirSayisi + doktorSayisi + gozcuSayisi + koyluSayisi;

  final Map<String, String> rolBilgisi = {
    "Vampir": "Her gece bir köylüyü eler.",
    "Doktor": "Her gece birini seçer, vampir onu seçerse ölmez.",
    "Gözcü": "Her gece birinin rolüne bakma hakkı vardır.",
    "Köylü": "Gündüzleri vampiri bulmaya çalışır.",
  };

  @override
  void initState() {
    super.initState();
    _controllerlariGuncelle();
  }

  // Liste hatasını önleyen güvenli güncelleme fonksiyonu
  void _controllerlariGuncelle() {
    setState(() {
      int mevcutSayi = controllers.length;
      if (toplamOyuncu > mevcutSayi) {
        for (int i = mevcutSayi; i < toplamOyuncu; i++) {
          controllers.add(TextEditingController(text: "Oyuncu ${i + 1}"));
        }
      } else if (toplamOyuncu < mevcutSayi) {
        controllers.removeRange(toplamOyuncu, mevcutSayi);
      }
    });
  }

  void rolleriHazirla() {
    oyuncuIsimleri = controllers.map((c) => c.text).toList();
    List<String> yeniRoller = [];

    yeniRoller.addAll(List.generate(vampirSayisi, (index) => "VAMPİR 🧛"));
    yeniRoller.addAll(List.generate(doktorSayisi, (index) => "DOKTOR 🏥"));
    yeniRoller.addAll(List.generate(gozcuSayisi, (index) => "GÖZCÜ 👁️"));
    yeniRoller.addAll(List.generate(koyluSayisi, (index) => "KÖYLÜ 👨‍🌾"));

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
      appBar: AppBar(title: const Text("Vampir Köylü Ayarları"), backgroundColor: Colors.redAccent),
      body: roller.isEmpty ? kurulumEkrani() : oyunEkrani(),
    );
  }

  Widget kurulumEkrani() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(10)),
            child: const Text("💡 İdeal: 5 kişide 1, 8 kişide 2 vampir önerilir.", style: TextStyle(fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 20),
          _rolAyariRow("Vampir", vampirSayisi, (val) => setState(() => vampirSayisi = val), Colors.red, true),
          _rolAyariRow("Doktor", doktorSayisi, (val) => setState(() => doktorSayisi = val), Colors.blue, false),
          _rolAyariRow("Gözcü", gozcuSayisi, (val) => setState(() => gozcuSayisi = val), Colors.purple, false),
          _rolAyariRow("Köylü", koyluSayisi, (val) => setState(() => koyluSayisi = val), Colors.green, false),
          const Divider(height: 30),
          const Text("Oyuncu İsimleri", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...List.generate(controllers.length, (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TextField(
              controller: controllers[index],
              decoration: InputDecoration(labelText: "${index + 1}. Oyuncu", border: const OutlineInputBorder()),
            ),
          )),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 60)),
            onPressed: rolleriHazirla,
            child: const Text("OYUNU BAŞLAT", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _rolAyariRow(String isim, int deger, Function(int) onUpdate, Color renk, bool enAzBir) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isim, style: TextStyle(fontSize: 18, color: renk, fontWeight: FontWeight.bold)),
                Text(rolBilgisi[isim]!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline), 
            onPressed: () {
              if (deger > (enAzBir ? 1 : 0)) {
                onUpdate(deger - 1);
                _controllerlariGuncelle();
              }
            }
          ),
          Text("$deger", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline), 
            onPressed: () {
              onUpdate(deger + 1);
              _controllerlariGuncelle();
            }
          ),
        ],
      ),
    );
  }

  Widget oyunEkrani() {
    if (sira >= roller.length) {
      return Center(child: ElevatedButton(onPressed: () => setState(() => roller = []), child: const Text("Yeni Oyun Kur")));
    }
    
    String rolIsmi = roller[sira].split(" ")[0];
    String aciklama = rolBilgisi[rolIsmi.toLowerCase().contains("vampir") ? "Vampir" : 
                     rolIsmi.toLowerCase().contains("doktor") ? "Doktor" : 
                     rolIsmi.toLowerCase().contains("gözcü") ? "Gözcü" : "Köylü"]!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(oyuncuIsimleri[sira], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          const SizedBox(height: 20),
          Container(
            width: 300, height: 350,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: rolGoster ? Colors.redAccent : Colors.grey, width: 4),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: rolGoster 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(roller[sira], style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text(aciklama, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                  ],
                )
              : const Icon(Icons.help_center, size: 100, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: () => setState(() => rolGoster = !rolGoster), child: Text(rolGoster ? "GİZLE" : "ROLÜMÜ GÖR")),
          if (rolGoster) IconButton(icon: const Icon(Icons.arrow_circle_right, size: 50, color: Colors.green), onPressed: () => setState(() { sira++; rolGoster = false; })),
        ],
      ),
    );
  }
}