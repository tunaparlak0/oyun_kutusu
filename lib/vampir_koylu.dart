import 'package:flutter/material.dart';

class VampirKoyluSayfasi extends StatefulWidget {
  const VampirKoyluSayfasi({super.key});

  @override
  State<VampirKoyluSayfasi> createState() => _VampirKoyluSayfasiState();
}

class _VampirKoyluSayfasiState extends State<VampirKoyluSayfasi> {
  // Ayarlar
  int vampirSayisi = 1;
  int doktorSayisi = 1;
  int gozcuSayisi = 1;
  int koyluSayisi = 2;

  // Oyun Durumu
  List<String> roller = [];
  List<String> oyuncuIsimleri = [];
  List<bool> hayattaMi = [];
  int sira = 0;
  bool rolGoster = false;
  bool rolBakildiMi = false;
  List<TextEditingController> controllers = [];

  // Moderatörsüz Seçimler
  String? vampirSecimi;
  String? doktorSecimi;
  String? gozcuBilgisi;

  int get toplamOyuncu => vampirSayisi + doktorSayisi + gozcuSayisi + koyluSayisi;

  @override
  void initState() {
    super.initState();
    _controllerlariGuncelle();
  }

  // 1. SORUNUN ÇÖZÜMÜ: Sayı değiştikçe isim listesini anında günceller
  void _controllerlariGuncelle() {
    setState(() {
      if (controllers.length < toplamOyuncu) {
        int eklenecek = toplamOyuncu - controllers.length;
        for (int i = 0; i < eklenecek; i++) {
          controllers.add(TextEditingController(text: "Oyuncu ${controllers.length + 1}"));
        }
      } else if (controllers.length > toplamOyuncu) {
        controllers.removeRange(toplamOyuncu, controllers.length);
      }
    });
  }

  void rolleriHazirla() {
    oyuncuIsimleri = controllers.map((c) => c.text).toList();
    hayattaMi = List.generate(toplamOyuncu, (index) => true);
    List<String> yeniRoller = [];
    yeniRoller.addAll(List.generate(vampirSayisi, (i) => "VAMPİR"));
    yeniRoller.addAll(List.generate(doktorSayisi, (i) => "DOKTOR"));
    yeniRoller.addAll(List.generate(gozcuSayisi, (i) => "GÖZCÜ"));
    yeniRoller.addAll(List.generate(koyluSayisi, (i) => "KÖYLÜ"));
    yeniRoller.shuffle();
    setState(() {
      roller = yeniRoller;
      sira = 0;
      vampirSecimi = null;
      doktorSecimi = null;
      gozcuBilgisi = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vampir Köylü (Moderatörsüz)"), backgroundColor: Colors.redAccent),
      body: roller.isEmpty ? kurulumEkrani() : oyunEkrani(),
    );
  }

  Widget kurulumEkrani() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _rolAyar("Vampir", vampirSayisi, (v) => setState(() {vampirSayisi = v; _controllerlariGuncelle();}), true),
          _rolAyar("Doktor", doktorSayisi, (v) => setState(() {doktorSayisi = v; _controllerlariGuncelle();}), false),
          _rolAyar("Gözcü", gozcuSayisi, (v) => setState(() {gozcuSayisi = v; _controllerlariGuncelle();}), false),
          _rolAyar("Köylü", koyluSayisi, (v) => setState(() {koyluSayisi = v; _controllerlariGuncelle();}), false),
          const Divider(),
          ...List.generate(controllers.length, (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TextField(controller: controllers[i], decoration: InputDecoration(labelText: "${i + 1}. Oyuncu")),
          )),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: rolleriHazirla, child: const Text("OYUNU BAŞLAT")),
        ],
      ),
    );
  }

  Widget _rolAyar(String ad, int deger, Function(int) degis, bool enAz) {
    return Row(children: [
      Expanded(child: Text(ad)),
      IconButton(icon: const Icon(Icons.remove), onPressed: () => deger > (enAz ? 1 : 0) ? degis(deger - 1) : null),
      Text("$deger"),
      IconButton(icon: const Icon(Icons.add), onPressed: () => degis(deger + 1)),
    ]);
  }

  Widget oyunEkrani() {
    if (sira < roller.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(oyuncuIsimleri[sira], style: const TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              width: 320, height: 380,
              decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 2), borderRadius: BorderRadius.circular(20)),
              alignment: Alignment.center,
              child: rolGoster 
                ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(roller[sira], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        if (roller[sira] == "VAMPİR") _ozelSecim("Kimi Öldüreceksin?", vampirSecimi, (s) => setState(() => vampirSecimi = s)),
                        if (roller[sira] == "DOKTOR") _ozelSecim("Kimi Koruyacaksın?", doktorSecimi, (s) => setState(() => doktorSecimi = s)),
                        if (roller[sira] == "GÖZCÜ") _gozcuSecimi(),
                      ],
                    ),
                )
                : const Icon(Icons.help, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() {
                rolGoster = !rolGoster;
                if (rolGoster) rolBakildiMi = true; // Oyuncu en az bir kez baktı
              }), 
              child: Text(rolGoster ? "GİZLE" : "ROLÜ GÖR")
            ),
            // DÜZELTME: rolGoster yerine rolBakildiMi kontrolü yapıyoruz
            if (rolBakildiMi) 
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward, size: 60, color: Colors.green), 
                  onPressed: () => setState(() { 
                    sira++; 
                    rolGoster = false; 
                    rolBakildiMi = false; // Yeni oyuncu için sıfırlıyoruz
                    gozcuBilgisi = null; 
                  }),
                ),
              ),
          ],
        ),
      );
    }
    return geceSonucuEkrani();
  }

  Widget _ozelSecim(String baslik, String? suankiSecim, Function(String) kaydet) {
    return Column(
      children: [
        Text(baslik),
        DropdownButton<String>(
          value: suankiSecim,
          isExpanded: true,
          items: oyuncuIsimleri.where((isim) => isim != oyuncuIsimleri[sira]).map((isim) {
            return DropdownMenuItem(value: isim, child: Text(isim));
          }).toList(),
          onChanged: (val) { if (val != null) kaydet(val); },
          hint: const Text("Seçim Yap"),
        )
      ],
    );
  }

  Widget _gozcuSecimi() {
    return Column(
      children: [
        const Text("Kimin rolüne bakacaksın?"),
        DropdownButton<String>(
          isExpanded: true,
          items: oyuncuIsimleri.where((isim) => isim != oyuncuIsimleri[sira]).map((isim) {
            int idx = oyuncuIsimleri.indexOf(isim);
            return DropdownMenuItem(value: roller[idx], child: Text(isim));
          }).toList(),
          onChanged: (val) { if (val != null) setState(() => gozcuBilgisi = val); },
          hint: const Text("Birini Seç"),
        ),
        if (gozcuBilgisi != null) 
          Text("Rolü: $gozcuBilgisi", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple))
      ],
    );
  }

  Widget geceSonucuEkrani() {
    String sonuc = (vampirSecimi != null && vampirSecimi != doktorSecimi) 
        ? "$vampirSecimi öldü!" : "Kimse ölmedi!";
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(sonuc, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Divider(),
          ...List.generate(oyuncuIsimleri.length, (i) => ListTile(
            leading: Icon(hayattaMi[i] ? Icons.favorite : Icons.heart_broken, color: hayattaMi[i] ? Colors.green : Colors.red),
            title: Text(oyuncuIsimleri[i]),
            trailing: Switch(value: hayattaMi[i], onChanged: (v) => setState(() => hayattaMi[i] = v)),
          )),
          ElevatedButton(onPressed: () => setState(() => roller = []), child: const Text("Yeni Oyun")),
        ],
      ),
    );
  }
}