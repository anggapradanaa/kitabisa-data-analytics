# 📊 KITABISA DATA ANALYTICS PROJECT

This project is a comprehensive data analytics case study based on real-world business scenarios from Kitabisa. The objective is to analyze marketing performance, campaign quality, company health, and user acquisition behavior using SQL (BigQuery), visualization (Looker Studio), and Python. The project consists of four main tasks: evaluating ads performance, analyzing campaign complaints, building a company health dashboard, and exploring new user behavior to generate actionable, data-driven growth strategies.

# BAGIAN 1 — SOAL 1: Marketing Ads Performance

## Tujuan Query

Tim marketing Kitabisa setiap hari meluncurkan iklan baru untuk mendukung campaign yang sedang berjalan. Mereka membutuhkan data yang bisa menunjukkan seberapa efektif iklan tersebut dalam menghasilkan donasi. Query ini menggabungkan data dari 4 tabel berbeda — `donation`, `ads_spent`, `visit`, dan `user` — untuk menghasilkan satu tabel performa iklan yang komprehensif, di-breakdown per hari dan per campaign.

## Penjelasan Kolom Output

**`date`** — Tanggal kejadian. Satu baris merepresentasikan satu hari untuk satu campaign tertentu.

**`campaign_id` & `campaign_name`** — Identitas campaign yang sedang dianalisis.

**`donation_amount`** — Total rupiah donasi yang masuk ke campaign tersebut di hari itu. Hanya menghitung donasi dengan status VERIFIED (status = 4), yaitu donasi yang sudah dikonfirmasi valid oleh admin.

**`total_donation`** — Jumlah transaksi donasi, bukan dalam satuan rupiah melainkan jumlah kejadian donasi. Jika 3 orang berdonasi di hari yang sama ke campaign yang sama, nilainya 3.

**`total_donor`** — Jumlah user unik yang berdonasi. Berbeda dengan `total_donation` karena 1 user bisa berdonasi lebih dari sekali di hari yang sama ke campaign yang sama.

**`ads_spending`** — Total rupiah yang dikeluarkan untuk iklan campaign tersebut di hari itu. Kolom ini sering bernilai 0 karena tidak setiap hari ada iklan berbayar yang berjalan.

**`total_impression`** — Berapa kali iklan ditampilkan ke calon donatur. Semakin tinggi impression, semakin banyak orang yang melihat iklan tersebut.

**`total_pageview`** — Berapa kali halaman campaign dikunjungi di hari tersebut, bersumber dari tabel `visit`.

**`total_new_user`** — Berapa user baru yang mendaftar di hari tersebut. Ini adalah metrik level harian keseluruhan platform, bukan per campaign, karena user baru tidak bisa dikaitkan langsung ke satu campaign tertentu saat registrasi.

**`conversion_rate_pct`** — Persentase pengunjung yang akhirnya berdonasi, dihitung dengan rumus: (total_donation / total_pageview) × 100. Semakin tinggi nilainya, semakin efektif campaign dalam mengkonversi pengunjung menjadi donatur.

**`pct_spending_per_donation_amount`** — Persentase biaya iklan terhadap total donasi yang masuk, dihitung dengan: (ads_spending / donation_amount) × 100. Ini adalah indikator efisiensi iklan — semakin kecil nilainya, semakin efisien karena biaya iklan kecil namun donasi yang dihasilkan besar. Nilainya NULL ketika tidak ada donasi di hari tersebut.

## Temuan & Interpretasi

Dari 48 baris hasil query, mayoritas memiliki nilai 0 untuk kolom `ads_spending`, `total_pageview`, dan `total_impression`. Ini bukan error — melainkan mencerminkan kondisi nyata bahwa tidak setiap hari ada iklan yang berjalan, dan data iklan serta kunjungan memang tidak selalu tersinkron dengan data donasi di hari yang sama.

Hanya ada 3 hari yang memiliki data iklan berbayar. Pada **25 Desember 2019**, Campaign GO-JEK Sehat mengeluarkan Rp 78.700 untuk iklan dengan 843.814 impression, namun donasi yang masuk di hari itu hanya Rp 15.000 dari 4 transaksi. Nilai `pct_spending_per_donation_amount` sebesar 52.467% menunjukkan biaya iklan jauh lebih besar dari donasi yang masuk di hari yang sama — namun ini tidak serta merta berarti iklannya tidak efektif, karena efek iklan bisa baru terasa beberapa hari kemudian (delayed conversion). Pada **5 Januari 2020**, Campaign #THR2 mengeluarkan Rp 57.552 dengan 409.286 impression dan donasi Rp 50.000 (pct spending 1.151%). Pada **9 Desember 2019**, Campaign R80 mengeluarkan Rp 35.526 dengan 157.387 impression dan donasi Rp 25.000 (pct spending 1.421%).

Satu-satunya conversion rate yang bisa dihitung ada pada **9 Desember 2019, Campaign #BisaSembuh** — satu-satunya hari yang memiliki data pageview (605 pageview) bersamaan dengan donasi (1 transaksi Rp 220.000). Conversion rate-nya 17%, artinya dari 605 pengunjung, 1 orang berdonasi. Dalam konteks crowdfunding yang sifatnya sukarela, angka ini masih dapat diterima.

Campaign yang paling aktif sepanjang periode adalah **GO-JEK Sehat (ID: 115501)**, muncul di 26 dari 48 baris. Ini menunjukkan campaign tersebut memiliki basis donatur yang loyal dan terus berdonasi hampir setiap hari sepanjang Desember 2019 – Januari 2020, meskipun dengan nominal yang relatif kecil, kebanyakan Rp 1.000–15.000 per hari.

---

# BAGIAN 2 — SOAL 2: Campaign Flag & Complaint Analysis

## Tujuan Query

Tim happiness agent (customer service) Kitabisa perlu memantau dua hal sekaligus: status flag setiap campaign untuk mengetahui jalur akuisisinya, dan apakah pembuat campaign pernah mengirim tiket komplain ke platform. Informasi ini digunakan untuk memprioritaskan penanganan dan memahami profil campaigner secara lebih komprehensif.

## Penjelasan Kolom Output

**`campaign_id` & `campaign_name`** — Identitas campaign.

**`total_donation_amount`** — Total rupiah donasi VERIFIED yang berhasil dikumpulkan campaign ini sepanjang periode data. Nilai 0 berarti campaign belum berhasil mendapatkan donasi apapun dalam periode data ini.

**`campaign_flag`** — Label akuisisi campaign dengan 3 nilai: `online_acquisition` (campaign didapat melalui jalur digital seperti iklan online dan media sosial), `offline_acquisition` (melalui jalur offline seperti event dan komunitas), dan `hospital_acquisition` (terkait akuisisi melalui rumah sakit atau institusi kesehatan).

**`is_complain`** — YES jika pembuat campaign pernah mengirim tiket ke tabel `ticket`. NO jika tidak pernah.

**`no_of_complain`** — Jumlah tiket yang pernah dikirim oleh pembuat campaign tersebut.

**`percentage_of_high_priority_ticket`** — Dari semua tiket yang dikirim, berapa persen yang ditandai sebagai prioritas tinggi. Nilai NULL berarti tidak ada tiket sama sekali.

## Temuan & Interpretasi

Dari 66 campaign yang dianalisis, 49 campaign (74%) pembuatnya pernah mengirim tiket komplain, sementara 17 campaign (26%) pembuatnya tidak pernah komplain. Angka 74% ini cukup tinggi dan bisa diinterpretasikan dua cara: campaigner yang aktif memang lebih vokal dan lebih sering berinteraksi dengan platform termasuk saat ada masalah, atau platform masih memiliki banyak friction point yang mendorong campaigner untuk menghubungi support.

Pola menarik yang muncul adalah mayoritas campaigner yang pernah komplain mengirim tepat 2 tiket. Ini mengindikasikan kemungkinan bahwa masalah pertama tidak terselesaikan dengan baik sehingga campaigner mengirim tiket kedua sebagai follow-up — sebuah sinyal adanya gap dalam kualitas penanganan tiket pertama.

Campaign-campaign dengan donasi tertinggi — GO-JEK Sehat, #BisaSembuh, dan #THR2 — pembuatnya tetap pernah komplain meskipun campaign mereka sukses secara finansial. Ini menunjukkan bahwa friksi dengan platform tidak hanya dialami oleh campaigner yang gagal, tetapi juga oleh mereka yang berhasil.

Sebagian besar dari 66 campaign memiliki `total_donation_amount = 0`, yang berarti campaign-campaign tersebut tidak berhasil menarik donasi apapun dalam periode data. Ini bisa disebabkan oleh campaign yang sudah tidak aktif, atau campaign yang baru dibuat dan belum sempat mendapatkan donasi.

---

# BAGIAN 3 — SOAL 3: Company Health Dashboard

## Tujuan Dashboard

Dashboard dibuat di Looker Studio untuk memberikan gambaran kesehatan bisnis Kitabisa secara keseluruhan. Semua metrik penting tersaji dalam satu halaman yang interaktif dan dapat difilter berdasarkan periode waktu.

## Penjelasan Setiap Metrik (Periode 1 Des 2019 – 31 Jan 2020)

**Total GDV: Rp 1.785.000.** Gross Donation Value adalah total rupiah donasi yang berhasil terverifikasi dalam periode ini. Ini adalah ukuran paling fundamental dari performa bisnis Kitabisa sebagai platform crowdfunding.

**Total Donations: 77.** Jumlah transaksi donasi yang berhasil diverifikasi. Berbeda dengan GDV yang mengukur nilai uang, ini mengukur frekuensi transaksi.

**Total Donors: 58.** Jumlah user unik yang berdonasi. Selisih antara 77 transaksi dan 58 donor menunjukkan bahwa sekitar 19 donasi berasal dari donor yang berdonasi lebih dari sekali dalam periode ini.

**New Users: 11.** Jumlah user baru yang mendaftar dalam periode 1 Des 2019 – 31 Jan 2020. Angka ini kecil karena mayoritas user baru (177 orang) masuk di Februari 2020 yang berada di luar rentang filter default dashboard.

**Campaigns Launched: 32.** Jumlah campaign yang dibuat dalam periode ini, mencerminkan tingkat aktivitas di sisi campaigner.

**New Donors (First-time): 18.** Jumlah user yang baru pertama kali berdonasi dalam periode ini. Ini berbeda dari "New Users" karena bisa saja user lama yang baru pertama kali berdonasi, atau user baru yang langsung berdonasi.

**Avg. Donation: Rp 9.678.** Rata-rata nilai per transaksi donasi, memberikan gambaran tentang willingness to pay donatur Kitabisa.

**Success Rate: 17,47%.** Persentase donasi yang berhasil diverifikasi dari total donasi yang masuk, termasuk yang masih pending dan cancelled. Angka ini berarti dari semua donasi yang diinisiasi, hanya sekitar 1 dari 6 yang berhasil terverifikasi — perlu ditelusuri lebih lanjut apakah mayoritas gagal di proses pembayaran atau statusnya hanya belum diperbarui.

**Total Pageviews: 118.798.** Total kunjungan ke halaman campaign dalam periode ini. Dibandingkan dengan 77 donasi, conversion rate keseluruhan platform sangat kecil — sekitar 0,065%, artinya dari 1.000 pengunjung hanya sekitar 1 yang berdonasi.

**Total Tickets: 15.** Jumlah tiket support yang masuk dalam periode ini.

## Fitur Dashboard

Dashboard dirancang dengan tiga fitur utama sesuai requirement: default view yang selalu menampilkan data bulan berjalan (This Month) sehingga manajemen selalu melihat data terkini saat membuka dashboard, filter tanggal yang tampil di area judul sehingga periode yang sedang dilihat langsung terlihat tanpa harus mencari, dan kemampuan download data dalam format CSV melalui tabel raw data di halaman kedua dashboard.

---

# BAGIAN 4 — SOAL 4: User Acquisition Analysis

## Tujuan Analisis

Analisis ini bertujuan memahami perilaku user baru Kitabisa berdasarkan data historis yang tersedia, mencakup tren pertumbuhan, sebaran geografis, pola konversi ke donasi pertama, platform yang digunakan, kategori campaign yang efektif, dan tingkat retensi donatur. Temuan dari analisis ini kemudian digunakan sebagai basis rekomendasi strategis untuk mengakuisisi user baru secara lebih efektif.

---

## Query A: Tren Pertumbuhan User Baru per Bulan

Selama periode 2014–2019, rata-rata hanya 1 user baru per bulan yang tercatat dalam dataset ini. Perlu dicatat bahwa angka ini mencerminkan data sample, bukan kondisi aktual Kitabisa secara keseluruhan, sehingga harus dibaca sebagai "dari sample yang ada, hanya 1-2 user yang tercatat" bukan sebagai gambaran pertumbuhan riil platform.

Januari 2020 mencatat 11 user baru — lonjakan signifikan dari periode-periode sebelumnya yang mengindikasikan dimulainya periode kampanye akuisisi yang lebih intensif. Kemudian terjadi lonjakan masif di Februari 2020 dengan 177 user baru dalam satu bulan, naik 1.509% dari Januari. Seluruh 177 user baru ini berjenis PERSONAL — tidak ada satupun ORGANISASI — yang kemungkinan besar dipicu oleh kampanye akuisisi digital masif atau sebuah viral moment.

Ada pergeseran demografis yang menarik: di periode 2014–2019, sekitar 40% user baru adalah ORGANISASI. Namun di 2020, 100% user baru adalah PERSONAL. Ini mencerminkan pergeseran fokus akuisisi dari entitas organisasi ke individu, yang sejalan dengan tren platform crowdfunding modern yang semakin personal dan berbasis komunitas.

---

## Query B: Distribusi Geografis User

Dari 198 user dalam dataset, 103 orang (52,02%) tidak memiliki data provinsi yang valid — dikategorikan sebagai "Tidak Diketahui". Ini adalah masalah data quality yang signifikan karena lebih dari separuh data tidak bisa digunakan untuk analisis geografis. Kemungkinan penyebabnya adalah form registrasi yang tidak mewajibkan isian provinsi, atau adanya inkonsistensi dalam sistem penyimpanan data.

Dari user yang teridentifikasi, DKI Jakarta sangat mendominasi dengan 64 user (32,32% dari total, atau 67% dari yang teridentifikasi). Ini masuk akal mengingat Kitabisa adalah startup berbasis Jakarta yang kemungkinan besar memulai akuisisi dari ekosistem startup dan komunitas urban di ibu kota. Selain Jakarta, semua provinsi yang teridentifikasi berada di Pulau Jawa (Yogyakarta 12, Jawa Barat 9, Jawa Timur 4, Jawa Tengah 4, Banten 1), kecuali Aceh (1). Ini menunjukkan penetrasi Kitabisa di luar Jawa masih sangat terbatas, padahal Indonesia memiliki 38 provinsi dengan populasi besar di Sumatera, Kalimantan, dan Sulawesi yang belum tersentuh sama sekali dalam data ini.

---

## Query C: Konversi User Baru ke Donasi Pertama

Sebelum analisis, ditemukan 17 user (8,6%) dengan tanggal donasi lebih awal dari tanggal registrasi — sesuatu yang secara logika tidak mungkin terjadi. Ini kemungkinan merupakan kasus guest donation: user berdonasi tanpa akun terlebih dahulu, lalu membuat akun belakangan, namun donasinya tetap dikaitkan ke user_id tersebut. Data ini dieksklusi dari analisis untuk menjaga akurasi.

Dari 181 user yang tersisa, 180 orang (99,45%) belum pernah berdonasi sama sekali. Angka ini tampak mengkhawatirkan, namun perlu dikontekstualisasikan: mayoritas user baru (177 orang) baru mendaftar di Februari 2020, dan window data yang tersedia juga hanya sampai Februari 2020. Wajar jika mereka belum sempat berdonasi dalam rentang waktu yang sangat pendek tersebut.

Satu-satunya user yang terkonversi (user ID 487866) membutuhkan waktu 761 hari — lebih dari dua tahun — dari registrasi di November 2017 hingga donasi pertama di Desember 2019. Ini adalah outlier yang tidak bisa dijadikan patokan. Yang lebih penting dari angka ini adalah implikasinya: ada gap nyata antara "mendaftar" dan "berdonasi" yang perlu dijembatani dengan strategi onboarding yang aktif.

---

## Query D: Platform Donasi Pertama

Dari 18 donatur baru yang berhasil dianalisis, PWA (Progressive Web App) mendominasi dengan 9 donatur (50%), diikuti Desktop 4 donatur (22,22%), Android 3 donatur (16,67%), dan iOS 2 donatur (11,11%).

Dominasi PWA sangat signifikan. PWA adalah versi website yang dioptimalkan untuk mobile dan bisa diakses langsung dari browser tanpa perlu menginstal aplikasi. Fakta bahwa separuh donatur baru pertama kali berdonasi via PWA menunjukkan bahwa hambatan "harus install app dulu" adalah penghalang nyata bagi banyak calon donatur. Jika dijumlahkan, donasi via browser (PWA + Desktop) mencapai 72% sementara via app native (Android + iOS) hanya 28% — mengindikasikan bahwa optimasi pengalaman donasi via web jauh lebih berdampak dibandingkan pengembangan fitur app mobile.

---

## Query E: Kategori Campaign yang Efektif untuk Konversi

Bantuan Medis & Kesehatan sangat mendominasi dengan 15 dari 18 donatur baru (83,33%) melakukan donasi pertama mereka ke kategori ini, menghasilkan total donasi Rp 1.228.000. Hadiah & Apresiasi berada di posisi kedua dengan 2 donatur (11,11%) dan total donasi Rp 440.000, sementara Produk & Inovasi menyumbang 1 donatur (5,56%) dengan Rp 25.000.

Dominasi kategori kesehatan bukan kebetulan. Campaign kesehatan mengandung elemen emosional yang kuat — seseorang sakit dan membutuhkan bantuan segera — yang mendorong orang untuk bertindak cepat. Urgensi dan empati adalah dua driver utama donasi pertama, dan keduanya paling kuat ada di kategori kesehatan.

Menariknya, kategori Hadiah & Apresiasi memiliki nilai donasi per donor yang jauh lebih tinggi: rata-rata Rp 220.000 per donor, dibandingkan kategori kesehatan yang rata-ratanya Rp 81.867 per donor. Ini menunjukkan bahwa meskipun kesehatan lebih efektif dalam volume konversi, kategori hadiah/apresiasi menarik donatur dengan kapasitas finansial lebih tinggi.

Dari semua kategori campaign yang ada, hanya 3 yang berhasil mengonversi donatur baru dalam periode ini. Kategori lain seperti pendidikan, lingkungan, dan sosial tidak berhasil menarik donasi pertama — perlu dievaluasi apakah ini karena kualitas campaign, visibilitas di platform, atau preferensi alami donatur baru.

---

## Query F: Retensi dan Loyalitas Donatur

Dari 18 donatur yang pernah berdonasi, 7 orang (38,89%) hanya berdonasi 1 kali (one-time donor), 4 orang (22,22%) berdonasi 2 kali, 4 orang (22,22%) berdonasi 3–5 kali, dan 3 orang (16,67%) berdonasi 6 kali atau lebih.

Segmen 3–5x adalah yang paling valuable dengan rata-rata total donasi Rp 185.250 per user — tertinggi di antara semua segmen. Mereka sudah cukup loyal untuk berdonasi berulang dan setiap donasinya bernilai cukup besar. Segmen ini idealnya diperlakukan sebagai prioritas dalam program retensi.

Ada paradoks menarik di segmen 6x+: donatur paling loyal justru memiliki rata-rata total donasi terendah (Rp 44.667), bahkan lebih rendah dari one-time donor. Ini mengindikasikan bahwa segmen ini berdonasi dalam nominal yang sangat kecil namun sangat konsisten — kemungkinan berdonasi Rp 1.000–5.000 setiap minggu atau bulan. Mereka adalah komunitas inti yang paling loyal, namun karakteristiknya sangat berbeda dari segmen 3–5x.

Ada pola menarik: dari 1x ke 3–5x, rata-rata total donasi meningkat seiring frekuensi, mencerminkan efek "familiarity" — semakin seseorang terbiasa berdonasi di Kitabisa, semakin besar totalnya. Namun pola ini berhenti di 6x+ karena segmen tersebut adalah donatur nominal kecil yang konsisten, bukan donatur besar.

---

# BAGIAN 5 — REKOMENDASI STRATEGIS

## Rekomendasi 1: User Acquisition Strategy

### Expand Beyond Java
Saat ini 94% user yang teridentifikasi berasal dari Pulau Jawa, dengan DKI Jakarta mendominasi. Potensi akuisisi di luar Jawa masih sangat besar dan belum disentuh. Strategi yang dapat dilakukan adalah memfokuskan ekspansi ke provinsi dengan populasi besar dan penetrasi internet tinggi seperti Sumatera Utara (Medan) dan Sulawesi Selatan (Makassar), membangun kemitraan dengan komunitas lokal dan institusi setempat, serta mengembangkan campaign yang relevan dengan isu-isu lokal di masing-masing daerah.

### Optimize PWA as Main Acquisition Channel
Dengan 72% donasi pertama terjadi via browser (PWA + Desktop), investasi pada optimasi pengalaman web jauh lebih berdampak dibanding pengembangan fitur app native. Prioritas yang perlu dilakukan adalah memastikan pengalaman donasi via PWA dan web semudah dan secepat mungkin, serta memanfaatkan SEO dan Google Ads untuk mengarahkan traffic ke halaman campaign secara organik maupun berbayar.

### Improve Data Quality for Targeting
52% user tidak memiliki data provinsi yang valid, membuat geo-targeting menjadi tidak akurat. Perbaikan data quality dimulai dari menambahkan validasi wajib untuk field lokasi saat registrasi, standarisasi nama platform dan data lainnya, serta investigasi lebih lanjut kasus anomali data seperti donasi sebelum registrasi. Data yang bersih adalah fondasi untuk semua analisis dan keputusan bisnis selanjutnya, termasuk kemampuan melakukan geo-based campaign targeting yang lebih presisi.

---

## Rekomendasi 2: User Activation & Retention

### 72-Hour Onboarding Program
Dengan 99,45% user yang belum pernah berdonasi, dibutuhkan program onboarding yang aktif dan terstruktur dalam 72 jam pertama setelah registrasi. Di hari pertama, tampilkan campaign kesehatan yang sedang trending kepada user baru. Di hari kedua, kirim push notification berbasis urgensi untuk mendorong aksi. Di hari ketiga, gunakan social proof messaging seperti "ribuan orang sudah membantu campaign ini" untuk membangun kepercayaan dan mendorong donasi pertama.

### First Donation Trigger
Hambatan psikologis untuk berdonasi pertama kali bisa dikurangi dengan menyediakan campaign starter — campaign khusus dengan nominal donasi rendah (Rp 10.000–50.000) yang dirancang sebagai entry point bagi user baru. Dengan menurunkan barrier ini, lebih banyak user baru yang diharapkan dapat melakukan donasi pertama mereka.

### Leverage Health Campaign as Entry Point
83% donatur baru pertama kali berdonasi ke campaign kesehatan, menjadikan kategori ini sebagai entry point yang paling terbukti efektif. Campaign kesehatan perlu dijadikan konten utama yang ditampilkan kepada user baru, baik di halaman utama, dalam email onboarding, maupun dalam push notification — karena urgensi dan empati yang kuat di kategori ini terbukti mendorong keputusan donasi pertama lebih efektif dibanding kategori lainnya.

### Retention Program
Untuk mempertahankan donatur yang sudah ada, diperlukan beberapa pendekatan berbeda sesuai segmen. "Second donation nudge" — notifikasi campaign serupa 7 hari setelah donasi pertama — untuk mendorong one-time donor agar kembali berdonasi. Program loyalitas khusus seperti akses early campaign dan laporan dampak personal untuk donatur 3–5x yang merupakan segmen paling valuable. Dan fitur donasi rutin (subscription) untuk donatur 6x+ agar mereka bisa berdonasi secara otomatis tanpa perlu aktif setiap kali.

---

## Rekomendasi 3: Campaign & Ads Optimization

### Improve Ads Effectiveness
Dari data yang tersedia, hanya 3 hari dalam periode analisis yang memiliki data iklan berbayar, dan ketiganya menunjukkan nilai `pct_spending_per_donation_amount` yang tinggi jika dievaluasi hanya dari hari yang sama. Namun evaluasi iklan tidak bisa dilakukan hanya dari satu hari karena ada efek delayed conversion. Diperlukan A/B testing yang lebih terstruktur antara iklan berbayar dan konten organik untuk mengukur incremental impact yang sesungguhnya dari setiap rupiah yang diinvestasikan ke iklan.

### Complaint-Based Campaign Monitoring
74% pembuat campaign pernah mengirim tiket komplain, dan mayoritas mengirim 2 tiket yang mengindikasikan penanganan tiket pertama yang belum memuaskan. Happiness agent perlu memprioritaskan tiket-tiket dari campaigner yang masih aktif (status LIVE), terutama yang bertanda high priority. Implementasi sistem SLA (Service Level Agreement) untuk penanganan tiket berdasarkan tingkat prioritas akan membantu memastikan tidak ada komplain yang jatuh di antara celah.

### Diversify Campaign Categories
Ketergantungan yang sangat tinggi pada kategori Bantuan Medis & Kesehatan (36 dari 66 campaign, dan 83% konversi donatur baru) merupakan risiko konsentrasi yang perlu dimitigasi untuk pertumbuhan jangka panjang. Diversifikasi kategori penting agar platform tidak terlalu bergantung pada satu jenis campaign. Kategori Beasiswa & Pendidikan dan Kegiatan Sosial memiliki potensi yang belum dioptimalkan dan dapat dikembangkan melalui program campaign incubator yang membantu campaigner di luar kategori kesehatan untuk membuat campaign yang lebih menarik dan efektif.

---

## Kesimpulan

Analisis data Kitabisa periode 2013–Februari 2020 menunjukkan bahwa platform ini memiliki potensi pertumbuhan user yang besar — terlihat dari lonjakan 177 user baru di Februari 2020 — namun masih menghadapi tantangan serius dalam konversi dan retensi. Tiga prioritas utama yang perlu dijalankan adalah program aktivasi user baru dengan health campaign sebagai entry point, ekspansi geografis ke luar Jawa disertai perbaikan kualitas data, dan program retensi donatur berbasis segmentasi frekuensi donasi.

Seluruh analisis ini didukung oleh query BigQuery untuk performa iklan dan monitoring complaint (Soal 1 & 2), dashboard Looker Studio untuk pemantauan kesehatan perusahaan secara real-time (Soal 3), serta query dan visualisasi Python untuk eksplorasi perilaku user baru (Soal 4).

---
