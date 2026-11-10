# Roster System — Code Wiki

## 1) Purpose
Roster System is a Flutter application for managing **staff members**, **rosters**, and **duty assignments** in a weekly Day × Shift grid. Data is stored locally using ObjectBox (entities/relations) and Hive (simple settings like dark mode).

## 2) Tech Stack
- **Flutter / Dart** (SDK constraint: `^3.10.3`) ([pubspec.yaml](file:///c:/Users/Adn/Desktop/projects/roster_system/pubspec.yaml#L6-L7))
- **Persistence**
  - **ObjectBox** for entities, relations, and reactive queries ([pubspec.yaml](file:///c:/Users/Adn/Desktop/projects/roster_system/pubspec.yaml#L20-L22), [database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart#L20-L58))
  - **Hive** for simple key/value settings (dark mode) ([main.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/main.dart#L15-L20), [database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart#L10-L19))
- **UI icons/assets**: `forui_assets` / Lucide icons (e.g. [application_shell.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/application_shell.dart#L1-L41))

Note: `redux` / `flutter_redux` are declared in dependencies ([pubspec.yaml](file:///c:/Users/Adn/Desktop/projects/roster_system/pubspec.yaml#L18-L19)) but are not used by the current `lib/` code.

## 3) Repository Layout
- **lib/**: application source
  - **lib/main.dart**: app entrypoint, initializes Hive + ObjectBox store, starts UI ([main.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/main.dart#L14-L59))
  - **lib/api/**: domain + persistence helpers (entities, enums, DB wiring, navigation)
  - **lib/features/**: UI pages, dialogs, widgets grouped by feature
  - **lib/objectbox.g.dart**: generated ObjectBox bindings
  - **lib/objectbox-model.json**: ObjectBox schema model snapshot
- **android/ ios/ macos/ linux/ windows/ web/**: Flutter platform runners/build scaffolding
- **pubspec.yaml**: dependencies and build config

## 4) High-Level Architecture

### 4.1 Layering
The codebase is organized into lightweight layers:

- **Presentation layer** (`lib/features/**`)
  - Flutter widgets (pages, dialogs, cards) that render and mutate state via the DB wrappers.
- **Domain layer** (`lib/api/{roster,staff,roster_entry,day,shift}.dart`)
  - ObjectBox entities (`@Entity`) and domain helpers (e.g., building a Day×Shift grid).
- **Persistence + reactive glue** (`lib/api/database.dart`)
  - Global ObjectBox `Store`, global CRUD helpers, and a Hive-backed `Dark` setting.

### 4.2 Data Flow (typical)
1. UI triggers a mutation (e.g., “Add Staff”, “Assign staff to shift”).
2. UI calls `staffs.put(...)`, `rosters.put(...)`, or `entries.put(...)` ([database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart#L56-L58)).
3. ObjectBox updates the underlying boxes.
4. Reactive listeners rebuild UI:
   - Some pages subscribe to `Crud.watch()` streams and `setState()` on events (e.g., [staffs_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/staffs/staffs_page.dart#L23-L31)).
   - Some widgets use `ListenableBuilder` directly on the `Crud<T>` notifier (e.g., [roster_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/roster_page.dart#L37-L40)).

### 4.3 Architecture Diagram (conceptual)
```text
┌─────────────────────────────┐
│        Flutter UI            │  lib/features/**
│  Pages / Dialogs / Widgets   │
└──────────────┬──────────────┘
               │ calls put/remove/getAll
               v
┌─────────────────────────────┐
│   Crud<T> + global boxes     │  lib/api/database.dart
│  rosters / staffs / entries  │
└──────────────┬──────────────┘
               │ ObjectBox Store + Boxes
               v
┌─────────────────────────────┐
│        ObjectBox DB          │  Entities: Staff / Roster / RosterEntry
└─────────────────────────────┘

┌─────────────────────────────┐
│   Hive Box (settings only)   │  Dark mode key: "dark"
└─────────────────────────────┘
```

## 5) Core Domain Model (ObjectBox Entities)

### 5.1 Staff
File: [staff.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/staff.dart)
- `Staff`
  - Fields: `id`, `name`, optional `dutyPlace` ([staff.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/staff.dart#L6-L14))
  - Backlink: `entries` (`ToMany<RosterEntry>`) from `RosterEntry.staff` ([staff.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/staff.dart#L10-L12))
  - Computed: `totalHours` sums assigned entry hours across all rosters ([staff.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/staff.dart#L20-L26))

### 5.2 Roster
File: [roster.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster.dart)
- `Roster`
  - Fields: `id`, `name` ([roster.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster.dart#L7-L13))
  - Backlink: `entries` (`ToMany<RosterEntry>`) from `RosterEntry.roster` ([roster.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster.dart#L11-L13))
- `RosterX` extension (domain helpers)
  - `generateEntries()`: ensures the roster has a full **Day × Shift** grid of `RosterEntry` objects ([roster.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster.dart#L15-L34))
  - `getEntry(day, shift)`: retrieves a roster cell entry ([roster.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster.dart#L36-L40))
  - `getStaffHours(staffId)`: hours assigned to a specific staff within this roster ([roster.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster.dart#L42-L55))
  - `validateEntries()`: sanity-check expected entry count ([roster.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster.dart#L57-L64))

### 5.3 RosterEntry (join entity)
File: [roster_entry.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster_entry.dart)
- `RosterEntry`
  - Links a specific **day + shift** to a `Staff` and a `Roster`
  - Relations: `ToOne<Staff> staff`, `ToOne<Roster> roster` ([roster_entry.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster_entry.dart#L11-L13))
  - Fields: `dayIndex` and `shiftIndex` store enum indices; `day` and `shift` are computed getters/setters ([roster_entry.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster_entry.dart#L14-L20))
- `RosterEntryExtension.isAssigned`: true when `staff.target != null` ([roster_entry.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster_entry.dart#L23-L25))

### 5.4 Enums: Day, Shift
- `Day` enum + `code` string used in the roster grid UI ([day.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/day.dart#L1-L20))
- `Shift` enum + extensions:
  - `code` (MOR/EVE/NIG), `hours` (6/6/12), `icon`, `color` ([shift.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/shift.dart#L4-L38))

## 6) Persistence and Reactivity

### 6.1 Bootstrapping (Hive + ObjectBox Store)
File: [main.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/main.dart)
- `main()`:
  - calls `Hive.initFlutter()` and opens Hive box `roster_system` ([main.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/main.dart#L15-L18))
  - opens ObjectBox store at `<app documents>/roster_system` ([main.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/main.dart#L18-L20))
  - starts `runApp(App())` ([main.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/main.dart#L22-L23))

### 6.2 Global DB API (`Crud<T>`)
File: [database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart)
- Global handles:
  - `late Box hive;` and `late Store objects;` ([database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart#L10-L21))
  - `final rosters = Crud<Roster>();`, `final staffs = Crud<Staff>();`, `final entries = Crud<RosterEntry>();` ([database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart#L56-L58))
- `Crud<T>` responsibilities:
  - Simple CRUD: `put`, `remove`, `getAll`, etc. ([database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart#L29-L40))
  - Reactivity:
    - `watch()` uses `box.query().watch(triggerImmediately: true)` to emit the full list on any change ([database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart#L41-L46))
    - constructor subscribes to `.watch()` and calls `notifyListeners()` for widget rebuilds via `ListenableBuilder` ([database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart#L22-L27))

### 6.3 Dark Mode (Hive-backed setting)
File: [database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart)
- `Dark`:
  - stores `dark` preference in Hive key `"dark"` ([database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart#L60-L83))
  - `watch()` exposes a stream that reacts to Hive changes ([database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart#L80-L83))
- `App` listens to `dark.watch()` and rebuilds the `MaterialApp` theme mode accordingly ([main.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/main.dart#L33-L58))

## 7) Navigation Utilities
File: [navigation.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/navigation.dart)
- Uses a global `navigatorKey` (`navigator`) and helper methods:
  - `navigateTo(widget)` push route ([navigation.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/navigation.dart#L6-L10))
  - `navigateBack([result])` pop route ([navigation.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/navigation.dart#L12-L13))
  - `navigateToDialog(widget)` show dialog via global context ([navigation.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/navigation.dart#L14-L18))

## 8) UI Modules (Features)

### 8.1 Application Shell
File: [application_shell.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/application_shell.dart)
- `ApplicationShell`: bottom navigation between **Staffs** and **Rosters** pages ([application_shell.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/application_shell.dart#L6-L41))

### 8.2 Staffs Feature
Folder: `lib/features/staffs/`
- `StaffsPage`
  - Displays total staff count + list of staff records ([staffs_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/staffs/staffs_page.dart#L42-L184))
  - Subscribes to both `staffs.watch()` and `rosters.watch()`; rebuilds on changes ([staffs_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/staffs/staffs_page.dart#L23-L31))
  - Toggles dark mode via `dark.toggle()` ([staffs_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/staffs/staffs_page.dart#L48-L55))
- `NewStaffDialog`
  - Creates a `Staff` object and persists via `staffs.put(staff)` ([new_staff_dialog.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/staffs/new_staff_dialog.dart#L14-L35))
- `StaffPage`
  - Shows profile + computed `staff.totalHours` and assignment count (`staff.entries.length`) ([staff_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/staffs/staff_page.dart#L125-L193))
  - Allows delete (`staffs.remove(staff.id)`) and edit (`StaffEditDialog`) ([staff_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/staffs/staff_page.dart#L18-L24), [staff_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/staffs/staff_page.dart#L202-L270))

### 8.3 Rosters Feature
Folder: `lib/features/rosters/`
- `RostersPage`
  - Lists rosters from `rosters` and navigates to `RosterPage(roster)` ([rosters_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/rosters_page.dart#L118-L146))
  - “Add Roster” opens `NewRosterDialog()` ([rosters_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/rosters_page.dart#L40-L44))
- `NewRosterDialog`
  - Creates a `Roster`, calls `roster.generateEntries()` to seed a full grid, then persists (`rosters.put(roster)`) ([new_roster_dialog.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/new_roster_dialog.dart#L20-L25))
- `RosterPage`
  - Renders a Day × Shift grid using `Roster.getEntry(day, shift)` ([roster_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/roster_page.dart#L109-L163))
  - On cell tap:
    - ensures a `RosterEntry` exists (creates and `entries.put(entry)` if missing) ([roster_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/roster_page.dart#L145-L156))
    - opens `DutyAssignementDialog(entry)` to assign/unassign staff ([roster_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/roster_page.dart#L156-L159))
  - Shows “Staff Hours Summary” computed from the roster’s entries in real time ([roster_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/roster_page.dart#L18-L28), [roster_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/roster_page.dart#L170-L218))
  - “Delete Roster” flow uses `RosterRemovalDialog` and then navigates back on success ([roster_page.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/roster_page.dart#L44-L52))
- `DutyAssignementDialog`
  - Lists all staff and assigns `entry.staff.target = staff` + persists via `entries.put(entry)` ([duty_assignement_dialog.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/duty_assignement_dialog.dart#L71-L84))
  - “Unassign” sets `entry.staff.target = null` + persists ([duty_assignement_dialog.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/duty_assignement_dialog.dart#L105-L112))
- “Who is on duty now”
  - `WhoIsInNowFeatureView` mounts a `WhoIsInNowController` that polls time and finds the assigned `RosterEntry` matching current day/shift ([onduty_staff.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/onduty_staff.dart#L256-L293))
  - `RosterStatusRepository.getStaffOnDuty(...)` checks `entries.getAll()` and returns the first matching `entry.staff.target` ([onduty_staff.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/onduty_staff.dart#L36-L47))

## 9) Dependency Relationships

### 9.1 Internal module dependencies (simplified)
```text
lib/main.dart
  ├─ lib/api/database.dart
  ├─ lib/api/navigation.dart
  └─ lib/features/application_shell.dart
       ├─ lib/features/staffs/**
       │    └─ lib/api/database.dart, lib/api/navigation.dart, lib/api/staff.dart
       └─ lib/features/rosters/**
            └─ lib/api/database.dart, lib/api/navigation.dart, lib/api/{roster,roster_entry,day,shift,staff}.dart
```

### 9.2 External packages (from `pubspec.yaml`)
- Runtime:
  - `objectbox`, `objectbox_flutter_libs`: embedded database
  - `hive_flutter`: Hive storage + Flutter integration
  - `path_provider`, `path`: locate and join platform document directory path
  - `forui_assets`: icon pack (Lucide)
  - `uuid`, `faker`: declared; usage not present in current `lib/` sources
- Dev:
  - `build_runner`, `objectbox_generator`: code generation for ObjectBox bindings

## 10) How to Run

### 10.1 Prerequisites
- Install Flutter compatible with the repo’s SDK constraint (`^3.10.3`) ([pubspec.yaml](file:///c:/Users/Adn/Desktop/projects/roster_system/pubspec.yaml#L6-L7))
- Install platform toolchains as needed:
  - Android Studio / SDK (Android)
  - Xcode (iOS/macOS)
  - Visual Studio Build Tools (Windows desktop)

### 10.2 Install dependencies
```bash
flutter pub get
```

### 10.3 Generate ObjectBox bindings (when model changes)
ObjectBox uses code generation. If you change entity definitions in `lib/api/*.dart`, regenerate:
```bash
flutter pub run build_runner build
```

If codegen conflicts occur:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 10.4 Run the app
```bash
flutter run
```

Entrypoint is `lib/main.dart` ([main.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/main.dart#L14-L23)).

## 11) Common Extension Points
- **Add new shift types**: update `Shift` enum and extension methods ([shift.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/shift.dart#L4-L38)), then ensure `Roster.generateEntries()` still matches expectations ([roster.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/roster.dart#L15-L34)).
- **Change shift schedule logic (“Who is in now”)**: edit `RosterStatusRepository.calculateShiftFromHour` ([onduty_staff.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/features/rosters/onduty_staff.dart#L49-L53)).
- **Replace global singletons**: `rosters/staffs/entries` are global `Crud<T>` instances ([database.dart](file:///c:/Users/Adn/Desktop/projects/roster_system/lib/api/database.dart#L56-L58)); moving to DI/state-management would centralize lifecycle and improve testability.

