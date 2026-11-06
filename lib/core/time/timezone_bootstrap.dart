import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

Future<void>? _bootstrapFuture;

Future<void> ensureTimezoneInitialized() {
  return _bootstrapFuture ??= _initializeTimezone();
}

Future<void> _initializeTimezone() async {
  try {
    // Decoding the embedded IANA database takes long enough to drop frames,
    // so it runs in a short-lived isolate and the decoded locations are
    // transferred back (Isolate.exit, no copy) into this isolate's database.
    final List<tz.Location> locations =
        await Isolate.run(_decodeTimezoneDatabase);
    locations.forEach(tz.timeZoneDatabase.add);
  } on Object catch (error) {
    debugPrint('[Timezone] Database initialization failed: $error');
    return;
  }

  String? timezoneName;
  try {
    timezoneName = await FlutterTimezone.getLocalTimezone();
  } on Object {
    timezoneName = null;
  }

  if (timezoneName != null && timezoneName.isNotEmpty) {
    try {
      tz.setLocalLocation(tz.getLocation(timezoneName));
      return;
    } on Object {
      // Ignore and fall back to UTC.
    }
  }

  tz.setLocalLocation(tz.UTC);
}

List<tz.Location> _decodeTimezoneDatabase() {
  tz_data.initializeTimeZones();
  return tz.timeZoneDatabase.locations.values.toList(growable: false);
}
