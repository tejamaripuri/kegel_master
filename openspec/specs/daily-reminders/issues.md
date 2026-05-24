# Issue 1: Basic Local Notification Infrastructure (Tracer Bullet)

## Parent
PRD: `openspec/specs/daily-reminders/spec.md`

## What to build
Implement the foundational local notifications infrastructure to prove end-to-end OS integration.
- Add `flutter_local_notifications` to `pubspec.yaml` and configure Android/iOS permissions.
- Create a `NotificationService` wrapper with `requestPermission()` and a temporary `scheduleTestNotification()` method.
- Add a temporary UI button to trigger a notification 5 seconds after tap.

## Acceptance criteria
- [x] `flutter_local_notifications` is successfully integrated into the project.
- [x] `NotificationService.requestPermission()` prompts the user for OS notification permission.
- [x] Tapping the temporary button successfully fires a local notification after 5 seconds on device/emulator.

## Blocked by
None - can start immediately

---

# Issue 2: Settings Toggle (Enabled/Disabled)

## Parent
PRD: `openspec/specs/daily-reminders/spec.md`

## What to build
Allow the user to toggle the daily reminder on and off, tying it to actual scheduled notifications.
- Add `isReminderEnabled` persistence in the Settings layer (Riverpod/SharedPreferences).
- Add a SwitchListTile to `SettingsScreen`.
- When toggled ON, call `NotificationService.requestPermission()` and schedule a notification for a hardcoded default time (e.g., 8:00 AM).
- When toggled OFF, call a new `NotificationService.cancelAllReminders()` method.
- Remove the temporary button from Issue 1.

## Acceptance criteria
- [x] State for `isReminderEnabled` persists across app restarts.
- [x] Toggling the switch ON requests permission if not granted and schedules a daily reminder.
- [x] Toggling the switch OFF cancels the reminder.
- [x] The temporary test button is removed.

## Blocked by
- Issue 1

---

# Issue 3: Settings Time Configuration

## Parent
PRD: `openspec/specs/daily-reminders/spec.md`

## What to build
Allow the user to specify the time of day their daily reminder will fire.
- Add `reminderTime` persistence in the Settings layer.
- Add a Time Picker UI to `SettingsScreen` (only visible/enabled when the reminder toggle is ON).
- When a new time is picked, invoke `NotificationService.scheduleDailyReminder(time)` to reschedule the notification.

## Acceptance criteria
- [x] The selected reminder time is persisted across app restarts.
- [x] The Time Picker is properly displayed in `SettingsScreen`.
- [x] Picking a new time correctly updates the scheduled notification in the OS.

## Blocked by
- Issue 2

---

# Issue 4: Tap to Route Home

## Parent
PRD: `openspec/specs/daily-reminders/spec.md`

## What to build
Ensure that tapping a delivered notification properly opens the app and routes the user to the correct screen.
- Implement the tap action payload handler inside the app's initialization (e.g., `main.dart` or `app.dart`).
- Regardless of whether the app was in the background or terminated, tapping the reminder must securely route the user to the Home screen using GoRouter.

## Acceptance criteria
- [ ] Tapping the notification while the app is in the background routes to the Home screen.
- [ ] Tapping the notification while the app is terminated launches the app and routes to the Home screen.

## Blocked by
- Issue 1

---

# Issue 5: Smart Suppression on Workout Completion

## Parent
PRD: `openspec/specs/daily-reminders/spec.md`

## What to build
Prevent unnecessary nagging by cancelling today's reminder if the user has already worked out.
- Add a `cancelTodayReminder()` method to `NotificationService`.
- Hook into the workout/session completion flow. When a session successfully completes, invoke this new method.

## Acceptance criteria
- [ ] Completing a workout session successfully invokes the cancellation logic.
- [ ] Today's scheduled reminder is cancelled, but tomorrow's remains active (or the daily schedule is maintained effectively).

## Blocked by
- Issue 2
