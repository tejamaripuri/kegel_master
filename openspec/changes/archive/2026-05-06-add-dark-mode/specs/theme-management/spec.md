## ADDED Requirements

### Requirement: Theme Mode Persistence
The system SHALL persist the user's selected theme mode locally so it is retained across app sessions.

#### Scenario: User changes theme mode
- **WHEN** the user selects a specific theme mode (Light or Dark)
- **THEN** the system saves this preference to local storage

#### Scenario: App restart restores theme
- **WHEN** the app starts
- **THEN** the system applies the previously saved theme mode, or defaults to System if none is saved

### Requirement: Tri-State Theme Selection
The system SHALL provide a tri-state theme preference: Light, Dark, and System Default.

#### Scenario: User selects System Default
- **WHEN** the user sets their preference to System
- **THEN** the app's theme matches the operating system's current theme (light or dark)

#### Scenario: User selects explicit Dark Mode
- **WHEN** the user sets their preference to Dark
- **THEN** the app forces the dark theme, regardless of the operating system's theme

#### Scenario: User selects explicit Light Mode
- **WHEN** the user sets their preference to Light
- **THEN** the app forces the light theme, regardless of the operating system's theme
