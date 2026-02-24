import 'package:flutter/material.dart';
import 'dart:math';

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
  List<String> vampirSecimleri = []; // Vampirlerin tüm seçimlerini tutar
  String? doktorSecimi;
  String? gozcuBilgisi;

  int get toplamOyuncu => vampirSayisi + doktorSayisi + gozcuSayisi + koyluSayisi;

  @override
  void initState() {
    super.initState();
    _controllerlariGuncelle();
  }

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
      vampirSecimleri = [];
      doktorSecimi = null;
      gozcuBilgisi = null;
      rolBakildiMi = false;
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
      String suankiRol = roller[sira];
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(oyuncuIsimleri[sira], style: const TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              width: 320, height: 400,
              decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 2), borderRadius: BorderRadius.circular(20)),
              alignment: Alignment.center,
              child: rolGoster 
                ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(suankiRol, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        if (suankiRol == "VAMPİR") _vampirSecimAlani(),
                        if (suankiRol == "DOKTOR") _ozelSecim("Kimi Koruyacaksın?", doktorSecimi, (s) => setState(() => doktorSecimi = s)),
                        if (suankiRol == "GÖZCÜ") _gozcuSecimi(),
                        if (suankiRol == "KÖYLÜ") const Text("Masum köylüsün, hayatta kalmaya çalış!", textAlign: TextAlign.center),
                      ],
                    ),
                )
                : const Icon(Icons.help, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() {
                rolGoster = !rolGoster;
                if (rolGoster) rolBakildiMi = true;
              }), 
              child: Text(rolGoster ? "GİZLE" : "ROLÜ GÖR")
            ),
            if (rolBakildiMi) 
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward, size: 60, color: Colors.green), 
                  onPressed: () {
                    if (_secimYapildiMi()) {
                      setState(() { 
                        sira++; 
                        rolGoster = false; 
                        rolBakildiMi = false; 
                        gozcuBilgisi = null; 
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$suankiRol, lütfen seçimini yap!"), backgroundColor: Colors.orange),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      );
    }
    return geceSonucuEkrani();
  }

  bool _secimYapildiMi() {
    String rol = roller[sira];
    int suanaKadarkiVampirSayisi = roller.sublist(0, sira + 1).where((r) => r == "VAMPİR").length;
    
    if (rol == "VAMPİR" && vampirSecimleri.length < suanaKadarkiVampirSayisi) return false;
    if (rol == "DOKTOR" && doktorSecimi == null) return false;
    if (rol == "GÖZCÜ" && gozcuBilgisi == null) return false;
    return true;
  }

  Widget _vampirSecimAlani() {
    return Column(
      children: [
        if (vampirSecimleri.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text("Yoldaşlarının Seçimleri: ${vampirSecimleri.join(', ')}", 
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        _ozelSecim("Kimi Öldüreceksin?", null, (s) {
          setState(() {
            int suanaKadarkiVampirSayisi = roller.sublist(0, sira + 1).where((r) => r == "VAMPİR").length;
            if (vampirSecimleri.length < suanaKadarkiVampirSayisi) {
              vampirSecimleri.add(s);
            } else {
              vampirSecimleri[suanaKadarkiVampirSayisi - 1] = s;
            }
          });
        }),
      ],
    );
  }

  Widget _ozelSecim(String baslik, String? suankiSecim, Function(String) kaydet) {
    return Column(
      children: [
        Text(baslik, style: const TextStyle(fontWeight: FontWeight.w500)),
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
    String? finalVampirSecimi;

    if (vampirSecimleri.isNotEmpty) {
      // 1. Oyları saymak için Map oluştur
      Map<String, int> oySayilari = {};
      for (var isim in vampirSecimleri) {
        oySayilari[isim] = (oySayilari[isim] ?? 0) + 1;
      }

      // 2. En yüksek oy sayısını bul
      int enYuksekOy = 0;
      oySayilari.forEach((isim, oy) {
        if (oy > enYuksekOy) enYuksekOy = oy;
      });

      // 3. En yüksek oyu alanları listele
      List<String> enCokOyAlanlar = [];
      oySayilari.forEach((isim, oy) {
        if (oy == enYuksekOy) enCokOyAlanlar.add(isim);
      });

      // 4. Eşitlik durumunda rastgele, değilse çoğunluğa göre seç
      if (enCokOyAlanlar.length == 1) {
        finalVampirSecimi = enCokOyAlanlar.first;
      } else {
        finalVampirSecimi = enCokOyAlanlar[Random().nextInt(enCokOyAlanlar.length)];
      }
    }

    // Doktor korumasını kontrol et
    String sonuc = (finalVampirSecimi != null && finalVampirSecimi != doktorSecimi) 
        ? "$finalVampirSecimi gece saldırıya uğradı ve öldü!" 
        : "Bu gece kimse ölmedi!";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wb_sunny, size: 80, color: Colors.orange),
          const SizedBox(height: 10),
          const Text("SABAH OLDU", style: TextStyle(fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.w300)),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              sonuc, 
              textAlign: TextAlign.center, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent)
            ),
          ),
          const Divider(),
          const Text("Mezarlık ve Oylama", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded( // Uzun listelerde taşma olmaması için
            child: ListView.builder(
              itemCount: oyuncuIsimleri.length,
              itemBuilder: (context, i) {
                return ListTile(
                  leading: Icon(
                    hayattaMi[i] ? Icons.favorite : Icons.heart_broken, 
                    color: hayattaMi[i] ? Colors.green : Colors.red
                  ),
                  title: Text(
                    oyuncuIsimleri[i],
                    style: TextStyle(
                      fontSize: 18,
                      decoration: hayattaMi[i] ? null : TextDecoration.lineThrough,
                      color: hayattaMi[i] ? Colors.black : Colors.grey,
                    ),
                  ),
                  trailing: Switch(
                    activeColor: Colors.red,
                    value: hayattaMi[i], 
                    onChanged: (v) => setState(() => hayattaMi[i] = v)
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              minimumSize: const Size(250, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () => setState(() => roller = []), 
            child: const Text("YENİ TUR BAŞLAT", style: TextStyle(color: Colors.white, fontSize: 18))
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}