/// Lifecycle state of a reminder.
///
/// `snoozed` is a distinct state from `pending` so the dashboard can
/// show "3 pending, 2 snoozed" at a glance. Cancelled reminders are
/// kept (not deleted) so the user sees an audit trail and can undo.
enum ReminderStatus {
  pending,
  fired,
  snoozed,
  cancelled,
}
