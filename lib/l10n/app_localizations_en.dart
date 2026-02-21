// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OctoMobile';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get files => 'Files';

  @override
  String get terminal => 'Terminal';

  @override
  String get settings => 'Settings';

  @override
  String get temperatures => 'Temperatures';

  @override
  String get nozzle => 'Nozzle';

  @override
  String get bed => 'Bed';

  @override
  String get target => 'Target';

  @override
  String get printStatus => 'Print Status';

  @override
  String get state => 'State';

  @override
  String get file => 'File';

  @override
  String get progress => 'Progress';

  @override
  String get elapsed => 'Elapsed';

  @override
  String get eta => 'ETA';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get cancel => 'Cancel';

  @override
  String get movement => 'Movement';

  @override
  String get homeAll => 'Home All Axes';

  @override
  String get distance => 'Distance';

  @override
  String get extruder => 'Extruder';

  @override
  String get retract => 'Retract';

  @override
  String get extrude => 'Extrude';

  @override
  String get tuning => 'Tuning (Adjustments)';

  @override
  String get feedrate => 'Feedrate (Speed)';

  @override
  String get flowrate => 'Flowrate (Extrusion)';

  @override
  String get resetValues => 'Reset Values (100%)';

  @override
  String get emergencyStop => 'Emergency Stop!';

  @override
  String get emergencyStopDesc =>
      'The M112 command will be sent to the printer. This stops the printer immediately and may require a restart. Are you sure?';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get stopSystem => 'Stop Entire System';

  @override
  String get emergencySent => 'M112 Emergency Stop Command Sent!';

  @override
  String get connectionNotFound => 'Connection not found.';

  @override
  String get connectedTo => 'Connected to OctoPrint';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get terminalClear => 'Clear Logs';

  @override
  String get terminalAutoScrollOn => 'Auto Scroll On';

  @override
  String get terminalAutoScrollOff => 'Auto Scroll Off';

  @override
  String get terminalHint => 'Enter G-Code (e.g. G28, M105)';

  @override
  String get commandFailed => 'Command Failed';

  @override
  String get noConnection => 'No Connection';

  @override
  String get connectToOctoprint => 'Connect to OctoPrint';

  @override
  String get serverUrl => 'Server Address (URL)';

  @override
  String get apiKey => 'API Key';

  @override
  String get connect => 'Connect';

  @override
  String get connectionInfo => 'Connection Information';

  @override
  String get wsAddress => 'WebSocket Address';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get developedWithFlutter => 'Developed with Flutter';

  @override
  String get noFilesFound => 'No uploaded files found.';

  @override
  String get printStarted => 'print has started.';

  @override
  String get fetchError => 'Failed to fetch files';

  @override
  String get headMovement => 'Head Movement';

  @override
  String get setTemp => 'Set';

  @override
  String get turnOff => 'Turn Off (0°)';

  @override
  String get cancelPrintTitle => 'Cancel Print';

  @override
  String get cancelPrintDesc => 'This action cannot be undone. Are you sure?';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get rpiTab => 'Server';

  @override
  String get rpiHost => 'Host (IP)';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get systemResources => 'System Resources';

  @override
  String get sshTerminal => 'SSH Terminal';

  @override
  String get connectSsh => 'Connect via SSH';
}
