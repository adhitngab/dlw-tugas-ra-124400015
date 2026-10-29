// =====================================================================
// Template Laporan Tugas — Workshop Deep Learning (Teknik Telekomunikasi ITERA)
// Studi Ablasi RNN, LSTM, GRU vs ANN untuk Prediksi Trafik Seluler
//
// Format IEEE conference dua kolom (paket charged-ieee), MAKSIMAL 6 HALAMAN
// termasuk referensi.
// Compile: typst compile main.typ   (atau unggah folder ini ke typst.app)
// Bila muncul peringatan font "TeX Gyre Termes" saat compile lokal, pasang font TeX Gyre
// atau tambahkan --font-path ke folder font tersebut. Di typst.app font sudah tersedia.
//
// Teks abu-abu dalam #petunjuk[...] adalah petunjuk: HAPUS dan ganti dengan isi kalian.
// =====================================================================
#import "@preview/charged-ieee:0.1.4": ieee

#set text(lang: "id")
#let petunjuk(isi) = text(fill: gray.darken(20%))[[#isi]]

#show: ieee.with(
  title: [Studi Ablasi RNN, LSTM, dan GRU dibandingkan ANN untuk Prediksi Trafik Seluler Kota Milan],
  abstract: [
    Prediksi trafik internet per jam membantu operator memahami kebutuhan kapasitas jaringan. Penelitian ini membandingkan ANN, RNN, LSTM, dan GRU menggunakan data trafik seluler Milan dari Telecom Italia, pada kotak Duomo dan lokasi kelompok di Bandara Linate. Eksperimen ablasi menguji panjang jendela, ukuran hidden, jumlah lapisan, learning rate, kelompok fitur, dropout, fungsi loss, dan patience. Data dibagi kronologis menjadi train, validasi, test, dan periode Natal. Setiap konfigurasi final dievaluasi dengan tiga seed; pemilihan konfigurasi memakai MAE validasi, sedangkan test dan minggu Natal digunakan untuk evaluasi akhir. Pada Duomo, konfigurasi terpilih menurunkan test MAE LSTM dari $273.6 plus.minus 25.4$ menjadi $254.2 plus.minus 27.3$ dan ANN dari $309.9 plus.minus 5.9$ menjadi $303.2 plus.minus 21.9$. Perubahan konfigurasi RNN sedikit memperburuk test MAE, sedangkan peningkatan GRU kecil. Di Bandara Linate, model tetap mengungguli baseline naif nilai terakhir pada minggu test, tetapi tidak pada minggu Natal. Hasil menunjukkan bahwa pengaruh hyperparameter bergantung pada arsitektur; konfigurasi terpilih tidak selalu mengungguli acuan, sehingga seleksi berbasis validasi perlu dikonfirmasi pada beberapa seed dan periode uji.
  ],
  // Satu entri per anggota (maks. 3). Hapus yang tidak dipakai.
  authors: (
    (name: "Muhamad Aditia Dwi Pratama", department: [NIM 124400015], organization: [Teknik Telekomunikasi, ITERA], email: "muhamad.124400015@student.itera.ac.id"),
    (name: "Jonatan Kristian Sitorus", department: [NIM 124400067], organization: [Teknik Telekomunikasi, ITERA], email: "jonatan.124400067@student.itera.ac.id"),
  ),
  index-terms: ("prediksi trafik seluler", "RNN", "LSTM", "GRU", "studi ablasi"),
  bibliography: bibliography("references.bib", title: [Pustaka]),
  figure-supplement: [Gambar],
)

= Pendahuluan
Trafik seluler berubah menurut waktu dan lokasi, sehingga peramalan yang akurat dapat membantu perencanaan kapasitas jaringan. ANN menyediakan pembanding non-rekuren, sedangkan RNN, LSTM, dan GRU membaca urutan waktu; LSTM dirancang untuk membawa informasi jangka panjang @hochreiter1997lstm dan GRU menggunakan gerbang yang lebih ringkas @cho2014gru. Studi ablasi mengukur sensitivitas hasil terhadap perubahan satu faktor pada satu waktu. Kontribusi studi ini adalah membandingkan empat arsitektur, mengevaluasi konfigurasi ablasi, dan menguji konfigurasi terpilih di lokasi berbeda serta pada minggu Natal.

= Data dan Metode

== Dataset
Eksperimen menggunakan versi agregat per jam dari data Telecom Italia Big Data Challenge @barlacchi2015milan yang disiapkan untuk prediksi trafik @zhang2021fedda. Data mencakup November–Desember 2013. Target adalah volume trafik internet (`net`); fitur tambahan meliputi trafik panggilan dan SMS serta representasi siklik jam dan hari. Eksperimen utama menggunakan kotak Duomo (5060), sedangkan generalisasi diuji pada lokasi kelompok kode 5, Bandara Linate (kotak 15). // CEK: pastikan 15 benar-benar ID kotak Linate di notebook; kalau bukan, hapus "(kotak 15)".

#figure(
  image("peta_lokasi_tugas.png", width: 85%),
  caption: [Rata-rata aktivitas internet per kotak di Milan. Lingkaran kuning: lokasi tugas (kode 0–9); lingkaran toska: Duomo.],
  placement: top,
) <fig:peta>

== Pembagian Data dan Praproses
Pembagian dilakukan kronologis: train 11 November–8 Desember, validasi 9–15 Desember, test 16–22 Desember, dan evaluasi Natal 23–29 Desember 2013. Fitur distandarisasi menggunakan statistik data sebelum validasi. Jendela sepanjang $W$ jam digunakan untuk memprediksi trafik satu jam berikutnya ($"horizon" = 1$). Pemisahan waktu dipertahankan agar informasi masa depan tidak bocor ke data train.

== Model dan Konfigurasi Acuan
ANN menerima jendela yang diratakan sebagai satu vektor; RNN, LSTM, dan GRU membaca fitur sebagai urutan waktu dan menggunakan representasi pada langkah terakhir untuk prediksi. Konfigurasi acuan menggunakan $W=24$, horizon satu jam, seluruh fitur, Adam dengan learning rate $10^(-3)$, batch 64, dan early stopping dengan patience 30. Ukuran hidden dan kedalaman tiap arsitektur ditampilkan pada @tab:acuan.

#figure(
  caption: [Konfigurasi acuan],
  placement: top,
  table(
    columns: 2,
    align: left,
    stroke: none,
    table.hline(),
    table.header([*Hyperparameter*], [*Nilai acuan*]),
    table.hline(stroke: 0.5pt),
    [Panjang jendela $W$], [24 jam],
    [Horizon], [1 jam],
    [Ukuran hidden], [ANN 32, RNN 68, LSTM 33, GRU 38],
    [Jumlah lapisan], [ANN 2, rekuren 1],
    [Fitur], [net, call, sms, jam, hari (7)],
    [Optimizer, _learning rate_], [Adam, $10^(-3)$],
    [_Batch size_], [64],
    [_Early stopping_], [_patience_ 30, maks. 300 epoch],
    table.hline(),
  ),
) <tab:acuan>

== Protokol Ablasi dan Evaluasi
Pada A1–A5, satu faktor diubah terhadap acuan: $W in {6, 12, 24, 48, 168}$, hidden ${16, 32, 64, 128}$, lapisan ${1, 2, 3}$, learning rate ${10^(-4), 10^(-3), 10^(-2)}$, serta empat kelompok fitur. Bagian B menguji dropout ${0, 0.2, 0.5}$, loss {MSE, MAE, Huber}, dan patience ${10, 30, 60}$. Hipotesis B2 adalah dropout sedang dapat mengurangi overfitting; B4 menguji apakah loss yang selaras dengan MAE meningkatkan metrik tersebut. Setiap konfigurasi final menggunakan tiga seed. MAE, RMSE, dan MAPE dihitung pada skala asli; konfigurasi dipilih berdasarkan rata-rata MAE validasi, bukan test. Eksperimen dijalankan pada CPU dengan PyTorch 2.14.1; total waktu training tercatat 89.9 menit untuk 420 run unik.

= Hasil

== Baseline Naif dan Acuan
Pada horizon satu jam di test Duomo, semua model acuan mengungguli tiga baseline naif. Namun, pada periode Natal, MAE beberapa model kembali lebih tinggi daripada baseline nilai terakhir.

#figure(
  caption: [MAE test baseline naif dan model acuan di Duomo, horizon satu jam.],
  placement: top,
  table(
    columns: 2,
    align: (left, right),
    stroke: none,
    table.hline(),
    table.header([*Metode*], [*Test MAE*]),
    table.hline(stroke: 0.5pt),
    [Naif: nilai terakhir], [600.9],
    [Naif: kemarin], [552.2],
    [Naif: minggu lalu], [467.6],
    [ANN acuan], [$309.9 plus.minus 5.9$],
    [RNN acuan], [$229.6 plus.minus 5.1$],
    [LSTM acuan], [$273.6 plus.minus 25.4$],
    [GRU acuan], [$237.2 plus.minus 9.3$],
    table.hline(),
  ),
) <tab:baseline>

== Ablasi Wajib
Pada A1, jendela lebih panjang tidak selalu membantu. ANN memperoleh validasi terbaik pada $W=6$ (MAE 212.4), sedangkan RNN terbaik pada $W=48$ (200.1); test MAE RNN pada $W=48$ adalah $224.5 plus.minus 11.7$. Pada ANN, $W=168$ memperbesar parameter menjadi 38,753 dan menghasilkan test MAE 402.0, menunjukkan risiko jendela terlalu panjang.

#figure(
  image("A1_W.png", width: 100%),
  caption: [Pengaruh panjang jendela terhadap MAE pada validasi dan test; garis menunjukkan rata-rata tiga seed.],
  placement: top,
) <fig:a1>

Pada A2, hidden 128 memberi validasi terbaik untuk GRU (188.7) dan LSTM (207.1), tetapi menambah parameter secara tajam. ANN juga membaik pada hidden 128 dibanding hidden 32, sementara RNN relatif stabil pada hidden 64–128. Pada A3, tiga lapisan memperburuk LSTM secara kuat (test MAE 412.6); RNN satu atau dua lapisan lebih baik daripada tiga lapisan. GRU dua lapisan sedikit menurunkan MAE validasi, tetapi tidak memperbaiki test.

A4 menunjukkan learning rate $10^(-4)$ tidak memadai: semua arsitektur menghasilkan validasi jauh lebih buruk. Learning rate $10^(-2)$ membantu LSTM dan GRU pada validasi, tetapi tidak menjadi pilihan terbaik untuk ANN atau RNN. @fig:a4 memperlihatkan efek ini.

#figure(
  image("A4_lr.png", width: 100%),
  caption: [Pengaruh learning rate terhadap MAE.],
  placement: top,
) <fig:a4>

Pada A5, `semua` menjadi fitur terbaik pada validasi untuk RNN (206.1), LSTM (230.5), dan GRU (207.5); ANN sedikit lebih baik dengan `net+waktu` (246.0) daripada `semua` (248.9). Artinya kontribusi fitur waktu dan trafik panggilan/SMS bergantung pada arsitektur.

== Ablasi Pilihan
Pada B2, dropout 0.5 memperburuk MAE untuk semua model. Dropout 0.2 hanya membantu GRU: validasi/test MAE menjadi 203.9/225.0 dibanding 207.5/237.2 pada dropout 0. Untuk ANN dan RNN, dropout 0 memberi validasi terbaik; LSTM juga hampir tidak berubah antara 0 dan 0.2. Dengan demikian, hipotesis bahwa regularisasi sedang membantu tidak berlaku umum.

#figure(
  image("B2_dropout.png", width: 100%),
  caption: [Pengaruh dropout terhadap MAE pada validasi dan test.],
  placement: top,
) <fig:b2>

Pada B4, pilihan loss terbaik menurut MAE validasi berbeda antar model: MAE untuk ANN (240.6) dan GRU (204.2), MSE untuk LSTM (230.5), sedangkan RNN hampir seri antara MSE (206.1) dan Huber (206.3). Evaluasi test tidak selalu mengikuti peringkat validasi sehingga tidak digunakan untuk memilih konfigurasi. B5 menunjukkan patience 10, 30, dan 60 juga tidak memiliki pemenang universal: 30 terbaik untuk validasi RNN, sedangkan 60 terbaik untuk LSTM dan GRU.

#figure(
  image("B4_loss.png", width: 100%),
  caption: [Perbandingan fungsi loss; pemilihan model tetap berdasarkan MAE validasi.],
  placement: top,
) <fig:b4>

== Konfigurasi Terbaik
Konfigurasi per model dipilih berdasarkan MAE validasi. ANN menggunakan $W=24$, hidden 128, dua lapisan, dan MSE; RNN menggunakan $W=24$, hidden 68, tiga lapisan, dan Huber; LSTM menggunakan $W=12$, hidden 64, satu lapisan, dan MSE; GRU menggunakan $W=6$, hidden 128, satu lapisan, dan Huber. Semua memakai fitur `semua`, dropout 0, dan learning rate yang terpilih pada ablasi.

@tab:c menunjukkan LSTM memperoleh penurunan test MAE terbesar, dari 273.6 menjadi 254.2. ANN dan GRU hanya membaik sedikit, sedangkan konfigurasi RNN terpilih sedikit lebih buruk daripada acuan. Hasil Natal membaik untuk ANN, RNN, dan GRU, tetapi simpangan baku LSTM meningkat.

#figure(
  caption: [Test MAE dan MAE Natal konfigurasi acuan dibandingkan konfigurasi terpilih; rata-rata $plus.minus$ simpangan baku tiga seed.],
  placement: top,
  table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Model*], [*Test acuan*], [*Test terpilih*], [*Natal acuan*], [*Natal terpilih*]),
    table.hline(stroke: 0.5pt),
    [ANN], [$309.9 plus.minus 5.9$], [$303.2 plus.minus 21.9$], [$680.1 plus.minus 52.0$], [$655.5 plus.minus 43.4$],
    [RNN], [$229.6 plus.minus 5.1$], [$233.0 plus.minus 12.3$], [$421.2 plus.minus 2.4$], [$416.4 plus.minus 9.4$],
    [LSTM], [$273.6 plus.minus 25.4$], [$254.2 plus.minus 27.3$], [$586.0 plus.minus 56.8$], [$530.5 plus.minus 71.8$],
    [GRU], [$237.2 plus.minus 9.3$], [$235.1 plus.minus 7.4$], [$468.2 plus.minus 21.8$], [$446.6 plus.minus 31.2$],
    table.hline(),
  ),
) <tab:c>

#figure(
  image("C_terbaik_vs_acuan.png", width: 100%),
  caption: [Perbandingan test MAE konfigurasi acuan dan terpilih di Duomo.],
  placement: top,
) <fig:c>

== Uji Generalisasi
Di Bandara Linate, baseline naif nilai terakhir menghasilkan test MAE 10.1 dan Natal 7.1. Semua model lebih baik daripada baseline pada minggu test, tetapi tidak pada Natal. Konfigurasi terpilih tidak memperbaiki semua arsitektur: GRU tetap sekitar 7.5, LSTM membaik tipis dari 8.2 ke 8.1, sedangkan ANN dan RNN memburuk. Perubahan ini memperlihatkan bahwa konfigurasi yang dipilih di Duomo tidak otomatis berpindah sempurna ke lokasi lain.

#figure(
  caption: [Test dan Natal MAE di Bandara Linate untuk acuan dan konfigurasi terpilih; rata-rata $plus.minus$ simpangan baku tiga seed.],
  placement: top,
  table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Model*], [*Test acuan*], [*Test terpilih*], [*Natal acuan*], [*Natal terpilih*]),
    table.hline(stroke: 0.5pt),
    [ANN], [$8.8 plus.minus 0.7$], [$9.1 plus.minus 0.6$], [$14.4 plus.minus 0.5$], [$14.1 plus.minus 1.1$],
    [RNN], [$7.5 plus.minus 0.1$], [$7.9 plus.minus 0.5$], [$10.8 plus.minus 0.1$], [$11.1 plus.minus 0.7$],
    [LSTM], [$8.2 plus.minus 0.2$], [$8.1 plus.minus 0.2$], [$12.8 plus.minus 0.8$], [$13.0 plus.minus 1.2$],
    [GRU], [$7.5 plus.minus 0.2$], [$7.5 plus.minus 0.2$], [$11.4 plus.minus 0.9$], [$11.0 plus.minus 0.8$],
    table.hline(),
  ),
) <tab:d>

#figure(
  image("D_pola_lokasi.png", width: 100%),
  caption: [Pola trafik internet per jam pada Duomo dan Bandara Linate.],
  placement: top,
) <fig:d>

= Pembahasan
Hasil ablasi memperlihatkan bahwa pengaruh hyperparameter bergantung pada arsitektur. Jendela panjang meningkatkan jumlah parameter ANN dan memperburuk hasilnya, sedangkan model rekuren relatif stabil pada beberapa panjang jendela. Penambahan lapisan sangat merugikan LSTM pada data yang terbatas. Dropout tinggi juga menambah bias dan menurunkan akurasi; manfaat dropout 0.2 hanya tampak pada GRU. Perubahan konfigurasi gabungan meningkatkan LSTM paling jelas, tetapi tidak memperbaiki RNN dan hanya sedikit mengubah ANN/GRU. Ini menegaskan bahwa memilih hyperparameter dari hasil satu faktor tidak menjamin kombinasi tersebut menjadi optimum.

Keterbatasan studi meliputi satu pembagian kronologis, rentang train sekitar empat minggu, satu kota utama, dan satu lokasi generalisasi. Evaluasi Natal menunjukkan perubahan pola musiman yang tidak seluruhnya ditangkap model. Karena itu, hasil lebih tepat dianggap sebagai perbandingan pada periode yang diuji, bukan jaminan performa untuk semua sel dan musim.

= Kesimpulan
Studi ini menunjukkan bahwa pengaruh ablasi berbeda antar arsitektur. Konfigurasi terpilih menurunkan test MAE LSTM di Duomo dari $273.6 plus.minus 25.4$ menjadi $254.2 plus.minus 27.3$, sementara RNN sedikit memburuk dan peningkatan ANN/GRU kecil. Semua model mengungguli baseline naif nilai terakhir pada test Bandara Linate, tetapi tidak pada periode Natal. Pemilihan konfigurasi sebaiknya dilakukan dengan MAE validasi dan diuji ulang pada beberapa seed serta periode.

#heading(numbering: none)[Kontribusi Anggota]
#table(
  columns: (auto, 1fr),
  stroke: none,
  [Muhamad Aditia Dwi Pratama], [Eksperimen, analisis, dan penyusunan laporan secara kolaboratif.],
  [Jonatan Kristian Sitorus], [Eksperimen, analisis, dan penyusunan laporan secara kolaboratif.],
)

#heading(numbering: none)[Pernyataan Penggunaan AI]
GitHub Copilot digunakan untuk membantu penyuntingan kode dan penyusunan draf bahasa laporan. Seluruh angka eksperimen diambil dari hasil run notebook kelompok.

#heading(numbering: none)[Kode dan Data]
Kode, notebook beserta output, dan seluruh hasil run disertakan dalam repositori proyek kelompok. Data bersumber dari Telecom Italia Big Data Challenge @barlacchi2015milan.