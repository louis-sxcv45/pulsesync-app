# DECISIONS

## Pilihan State Management: Provider

Kasus ini hanya punya dua sumber state: stream telemetri (800 ms) dan antrean sinkronisasi. `ChangeNotifier` + Provider cukup, ringan, tanpa codegen. `TelemetryProvider` dan `QueueProvider` dipisah supaya tick 800 ms hanya me-rebuild kartu telemetri, bukan daftar antrean (`context.watch` hanya di widget kecil, `context.select` untuk header/toggle). BLoC/Riverpod terasa berlebihan untuk satu layar.

## Pencegahan Kebocoran Memori

- Stream dibuat dengan `StreamController` + `Timer.periodic`; `onCancel` membatalkan timer.
- `StreamSubscription` disimpan di `TelemetryProvider` dan di-`cancel()` pada `dispose()` (dipanggil otomatis oleh `ChangeNotifierProvider`).
- `TextEditingController` di bottom sheet di-dispose di `State.dispose()`.
- `QueueProvider` punya flag `_disposed` agar loop retry/drain berhenti dan tidak memanggil `notifyListeners` setelah dispose.
- Gauge & sparkline dibungkus `RepaintBoundary` supaya repaint terisolasi.

## Arsitektur Offline & Retry

- Layer: `domain` (entity + kontrak repository), `data` (SQLite, repository impl, service simulasi), `presentation` (provider, screen, widget, resources).
- Penyimpanan: SQLite (`sqflite`), asynchronous sehingga tidak memblokir main thread. Primary key = UUID v4 (idempoten, `ConflictAlgorithm.ignore`).
- Simpan bersifat optimistik: item masuk list in-memory dulu, bottom sheet langsung tertutup, baru ditulis ke DB. Jika gagal, item dibatalkan dan user diberi SnackBar.
- Drain: satu worker (`_draining`), urutan FIFO berdasarkan `created_at`. Gagal -> retry dengan backoff eksponensial 1s, 2s, 4s (+ jitter hingga 250 ms), maksimal 3 percobaan, lalu status `failed` (dead letter). Mode Offline menghentikan drain tanpa menghabiskan jatah retry. Beralih ke Online/Unstable memicu drain otomatis. Saat app dibuka ulang, item `pending/retrying` di SQLite dilanjutkan.

## Transparansi Penggunaan AI

Kerangka awal proyek dan implementasi dibantu oleh AI. Setiap file, alur aplikasi, dan perubahan logika telah ditinjau dan disesuaikan dengan kebutuhan pengujian; aplikasi dijalankan pada perangkat Android untuk memeriksa Provider, tampilan UI, pencatatan anomali, serta skenario jaringan Online, Unstable, dan Offline.
