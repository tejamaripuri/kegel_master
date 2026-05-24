## Problem Statement

Users often struggle to maintain consistency with daily exercise habits like Kegels. Without a reliable nudge, they may forget to perform their exercises, slowing their progress and reducing engagement with the app.

## Solution

A Daily Reminder feature that sends a generic prompt to the user at a single, user-configured time of day. This acts as a gentle nudge to open the app and perform a session. It is implemented entirely via local notifications, ensuring it works offline and respects user privacy. Furthermore, the system includes smart suppression: if a user proactively completes a workout session before their reminder time, that day's reminder is cancelled to prevent unnecessary nagging.

## User Stories

1. As a user, I want to receive a daily notification reminding me to do my Kegels, so that I can build a consistent habit.
2. As a user, I want to configure the exact time of day my reminder fires, so that it fits into my personal daily routine.
3. As a user, I want to toggle the daily reminder on or off from the Settings screen, so that I have control over whether the app notifies me.
4. As a user, I want to be asked for notification permissions only when I first enable the reminder, so that I understand exactly why the app needs this permission.
5. As a privacy-conscious user, I want my reminders to be scheduled locally on my device, so that my data does not need to be sent to a remote server.
6. As an active user, I want the app to skip my reminder if I have already completed a workout session today, so that I am not nagged to do something I've already done.
7. As a user, I want tapping the notification to take me directly to the Home screen, so that I can easily start a session when I'm ready.

## Implementation Decisions

- **NotificationService**: We will build a new deep module `NotificationService` that wraps the `flutter_local_notifications` package. It will expose a clean interface: `requestPermission()`, `scheduleDailyReminder(TimeOfDay time)`, `cancelTodayReminder()`, and `cancelAllReminders()`.
- **Local Notifications**: We will use `flutter_local_notifications` to schedule recurring daily notifications entirely on-device, avoiding Firebase or backend dependencies.
- **Settings Integration**: We will modify `SettingsScreen` to include a `SwitchListTile` and a time picker for the reminder configuration. 
- **Settings State**: The enabled status and configured time will be persisted via the existing settings data layers (e.g., SharedPreferences).
- **Smart Suppression**: We will hook into the session/workout completion logic. Upon successful completion of a session, the app will invoke `NotificationService.cancelTodayReminder()` to prevent the notification from firing later that day.
- **App Launching**: The notification payload will be handled in `main.dart` or `app.dart` to ensure the user is routed to the Home screen when tapping the notification.

## Testing Decisions

- **What makes a good test**: Tests should focus on the external behavior of the modules. We will test that toggling the setting correctly requests permissions and schedules notifications, and that completing a workout triggers a cancellation.
- **Modules to be tested**:
  - `NotificationService`: Unit tests to verify that it correctly interacts with the underlying local notifications plugin (using a mock).
  - `SettingsController` / State: Unit tests to ensure the enabled state and time are correctly updated and persisted.
  - `SettingsScreen`: Widget tests to verify that the toggle and time picker are displayed correctly and interact correctly with the state.
- **Prior art**: We will follow existing patterns in the `test/features/settings` directory for widget tests and controller tests.

## Out of Scope

- Linking reminders to specific scheduled workouts or calendar events.
- Multiple reminders per day.
- Selecting specific days of the week (e.g., only weekdays).
- Remote push notifications (e.g., via Firebase Cloud Messaging).
- Customizing the text/content of the reminder message.

## Further Notes

- iOS and Android 13+ require explicit permission to send notifications. We must ensure the permission request is handled gracefully, specifically explaining to the user why we need it if they previously denied it.
