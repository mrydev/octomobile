import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OctoMobile'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @terminal.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get terminal;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @temperatures.
  ///
  /// In en, this message translates to:
  /// **'Temperatures'**
  String get temperatures;

  /// No description provided for @nozzle.
  ///
  /// In en, this message translates to:
  /// **'Nozzle'**
  String get nozzle;

  /// No description provided for @bed.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get bed;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @printStatus.
  ///
  /// In en, this message translates to:
  /// **'Print Status'**
  String get printStatus;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @elapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get elapsed;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @movement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get movement;

  /// No description provided for @homeAll.
  ///
  /// In en, this message translates to:
  /// **'Home All Axes'**
  String get homeAll;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @extruder.
  ///
  /// In en, this message translates to:
  /// **'Extruder'**
  String get extruder;

  /// No description provided for @retract.
  ///
  /// In en, this message translates to:
  /// **'Retract'**
  String get retract;

  /// No description provided for @extrude.
  ///
  /// In en, this message translates to:
  /// **'Extrude'**
  String get extrude;

  /// No description provided for @tuning.
  ///
  /// In en, this message translates to:
  /// **'Tuning (Adjustments)'**
  String get tuning;

  /// No description provided for @feedrate.
  ///
  /// In en, this message translates to:
  /// **'Feedrate (Speed)'**
  String get feedrate;

  /// No description provided for @flowrate.
  ///
  /// In en, this message translates to:
  /// **'Flowrate (Extrusion)'**
  String get flowrate;

  /// No description provided for @resetValues.
  ///
  /// In en, this message translates to:
  /// **'Reset Values (100%)'**
  String get resetValues;

  /// No description provided for @emergencyStop.
  ///
  /// In en, this message translates to:
  /// **'Emergency Stop!'**
  String get emergencyStop;

  /// No description provided for @emergencyStopDesc.
  ///
  /// In en, this message translates to:
  /// **'The M112 command will be sent to the printer. This stops the printer immediately and may require a restart. Are you sure?'**
  String get emergencyStopDesc;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @stopSystem.
  ///
  /// In en, this message translates to:
  /// **'Stop Entire System'**
  String get stopSystem;

  /// No description provided for @emergencySent.
  ///
  /// In en, this message translates to:
  /// **'M112 Emergency Stop Command Sent!'**
  String get emergencySent;

  /// No description provided for @connectionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Connection not found.'**
  String get connectionNotFound;

  /// No description provided for @connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to OctoPrint'**
  String get connectedTo;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @terminalClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get terminalClear;

  /// No description provided for @terminalAutoScrollOn.
  ///
  /// In en, this message translates to:
  /// **'Auto Scroll On'**
  String get terminalAutoScrollOn;

  /// No description provided for @terminalAutoScrollOff.
  ///
  /// In en, this message translates to:
  /// **'Auto Scroll Off'**
  String get terminalAutoScrollOff;

  /// No description provided for @terminalHint.
  ///
  /// In en, this message translates to:
  /// **'Enter G-Code (e.g. G28, M105)'**
  String get terminalHint;

  /// No description provided for @commandFailed.
  ///
  /// In en, this message translates to:
  /// **'Command Failed'**
  String get commandFailed;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No Connection'**
  String get noConnection;

  /// No description provided for @connectToOctoprint.
  ///
  /// In en, this message translates to:
  /// **'Connect to OctoPrint'**
  String get connectToOctoprint;

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server Address (URL)'**
  String get serverUrl;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @connectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Connection Information'**
  String get connectionInfo;

  /// No description provided for @wsAddress.
  ///
  /// In en, this message translates to:
  /// **'WebSocket Address'**
  String get wsAddress;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @developedWithFlutter.
  ///
  /// In en, this message translates to:
  /// **'Developed with Flutter'**
  String get developedWithFlutter;

  /// No description provided for @noFilesFound.
  ///
  /// In en, this message translates to:
  /// **'No uploaded files found.'**
  String get noFilesFound;

  /// No description provided for @printStarted.
  ///
  /// In en, this message translates to:
  /// **'print has started.'**
  String get printStarted;

  /// No description provided for @fetchError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch files'**
  String get fetchError;

  /// No description provided for @headMovement.
  ///
  /// In en, this message translates to:
  /// **'Head Movement'**
  String get headMovement;

  /// No description provided for @setTemp.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setTemp;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn Off (0°)'**
  String get turnOff;

  /// No description provided for @cancelPrintTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Print'**
  String get cancelPrintTitle;

  /// No description provided for @cancelPrintDesc.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure?'**
  String get cancelPrintDesc;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @rpiTab.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get rpiTab;

  /// No description provided for @rpiHost.
  ///
  /// In en, this message translates to:
  /// **'Host (IP)'**
  String get rpiHost;

  /// No description provided for @rpiTailscaleIP.
  ///
  /// In en, this message translates to:
  /// **'Tailscale IP (Optional Fallback)'**
  String get rpiTailscaleIP;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @systemResources.
  ///
  /// In en, this message translates to:
  /// **'System Resources'**
  String get systemResources;

  /// No description provided for @sshTerminal.
  ///
  /// In en, this message translates to:
  /// **'SSH Terminal'**
  String get sshTerminal;

  /// No description provided for @connectSsh.
  ///
  /// In en, this message translates to:
  /// **'Connect via SSH'**
  String get connectSsh;

  /// No description provided for @rpiConnectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Server Connection'**
  String get rpiConnectionInfo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
