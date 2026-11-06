/// How often a reminder re-fires after its scheduled date.
///
/// `none` is the MVP baseline (one-shot). Daily/weekly/monthly use
/// `flutter_local_notifications`' built-in `DateTimeComponents` so
/// the logic stays entirely native and survives timezone shifts —
/// no custom cron needed.
enum ReminderRepeatMode {
  none,
  daily,
  weekly,
  monthly,
}
