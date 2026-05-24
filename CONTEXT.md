# Kegel Master

The core domain language and relationships for the Kegel Master application.

## Language

**Reminder**:
A generic daily prompt sent to the user at a single configured time of day to encourage them to perform their exercises, not tied to a specific scheduled workout session.
_Avoid_: Notification, alarm

## Relationships

- A **Reminder** prompts the user to perform exercises generally.
- Completing a workout session cancels the **Reminder** for that specific day if it hasn't fired yet.

## Example dialogue

> **Dev:** "Does a **Reminder** fire only when a user has a workout scheduled for today?"
> **Domain expert:** "No — a **Reminder** is just a generic prompt to keep up the habit, it isn't linked to specific workout sessions."
