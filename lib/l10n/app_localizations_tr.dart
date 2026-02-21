// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'OctoMobile';

  @override
  String get dashboard => 'Kontrol Paneli';

  @override
  String get files => 'Dosyalar';

  @override
  String get terminal => 'Terminal';

  @override
  String get settings => 'Ayarlar';

  @override
  String get temperatures => 'Sıcaklıklar';

  @override
  String get nozzle => 'Nozzle';

  @override
  String get bed => 'Yatak';

  @override
  String get target => 'Hedef';

  @override
  String get printStatus => 'Baskı Durumu';

  @override
  String get state => 'Durum';

  @override
  String get file => 'Dosya';

  @override
  String get progress => 'İlerleme';

  @override
  String get elapsed => 'Geçen Süre';

  @override
  String get eta => 'Kalan Süre';

  @override
  String get pause => 'Duraklat';

  @override
  String get resume => 'Devam Et';

  @override
  String get cancel => 'İptal';

  @override
  String get movement => 'Hareket';

  @override
  String get homeAll => 'Tüm Eksenleri Sıfırla (Home)';

  @override
  String get distance => 'Mesafe';

  @override
  String get extruder => 'Ekstruder';

  @override
  String get retract => 'Geri Çek (Retract)';

  @override
  String get extrude => 'İt (Extrude)';

  @override
  String get tuning => 'Tuning (İnce Ayar)';

  @override
  String get feedrate => 'Yazdırma Hızı (Dış)';

  @override
  String get flowrate => 'Akış Hızı (İç)';

  @override
  String get resetValues => 'Değerleri Sıfırla (%100)';

  @override
  String get emergencyStop => 'Acil Durdurma!';

  @override
  String get emergencyStopDesc =>
      'Yazıcıya M112 komutu gönderilecek. Bu işlem yazıcıyı anında durdurur ve yeniden başlatmanızı gerektirebilir. Emin misiniz?';

  @override
  String get cancelAction => 'Vazgeç';

  @override
  String get stopSystem => 'Tüm Sistemi Durdur';

  @override
  String get emergencySent => 'M112 Acil Durdurma Komutu Gönderildi!';

  @override
  String get connectionNotFound => 'Bağlantı bulunamadı.';

  @override
  String get connectedTo => 'OctoPrint\'e Bağlanıldı';

  @override
  String get disconnected => 'Bağlantı Kesildi';

  @override
  String get terminalClear => 'Logları Temizle';

  @override
  String get terminalAutoScrollOn => 'Otomatik Kaydırma Açık';

  @override
  String get terminalAutoScrollOff => 'Otomatik Kaydırma Kapalı';

  @override
  String get terminalHint => 'G-Code girin (örn: G28, M105)';

  @override
  String get commandFailed => 'Komut Gönderilemedi';

  @override
  String get noConnection => 'Bağlantı Yok';

  @override
  String get connectToOctoprint => 'OctoPrint\'e Bağlan';

  @override
  String get serverUrl => 'Sunucu Adresi (URL)';

  @override
  String get apiKey => 'API Anahtarı';

  @override
  String get connect => 'Bağlan';

  @override
  String get connectionInfo => 'Bağlantı Bilgileri';

  @override
  String get wsAddress => 'WebSocket Adresi';

  @override
  String get disconnect => 'Bağlantıyı Kes';

  @override
  String get developedWithFlutter => 'Flutter ile Geliştirildi';

  @override
  String get noFilesFound => 'Yüklü dosya bulunamadı.';

  @override
  String get printStarted => 'yazdırma başlatıldı.';

  @override
  String get fetchError => 'Dosyalar alınamadı';

  @override
  String get headMovement => 'Kafa Hareketi';

  @override
  String get setTemp => 'Ayarla';

  @override
  String get turnOff => 'Kapat (0°)';

  @override
  String get cancelPrintTitle => 'Baskıyı İptal Et';

  @override
  String get cancelPrintDesc => 'Bu işlem geri alınamaz. Emin misiniz?';

  @override
  String get yesCancel => 'Evet, İptal Et';

  @override
  String get rpiTab => 'Sunucu';

  @override
  String get rpiHost => 'Host (IP)';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get password => 'Şifre';

  @override
  String get systemResources => 'Sistem Kaynakları';

  @override
  String get sshTerminal => 'SSH Terminali';

  @override
  String get connectSsh => 'SSH ile Bağlan';
}
