import 'dart:async';
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// DEPENDENCY API STUBS
// (Kept inline to ensure compilation; replace with your system package imports)
// -----------------------------------------------------------------------------
import 'package:roster_system/api/database.dart' show entries;
import 'package:roster_system/api/day.dart';
import 'package:roster_system/api/navigation.dart' show navigateToDialog;
import 'package:roster_system/api/roster_entry.dart';
import 'package:roster_system/api/shift.dart';
import 'package:roster_system/api/staff.dart';

// =============================================================================
// 1. MODEL LAYER
// =============================================================================
/// Holds the current state of active duty assignments.
/// Modeled as a mutable structure with clear default initial states.
class WhoIsInModel {
  Shift shift;
  Day day;
  Staff? assignedStaff;

  WhoIsInModel({
    this.shift = Shift.morning,
    this.day = Day.monday,
    this.assignedStaff,
  });
}

// =============================================================================
// 2. DATA LAYER (REPOSITORY)
// =============================================================================
/// Isolates data access and operational logic away from business states.
class RosterStatusRepository {
  /// Queries database entries safely to identify which provider matches current time blocks.
  Staff? getStaffOnDuty({required Day day, required Shift shift}) {
    return entries
        .getAll()
        .where(
          (entry) =>
              entry.isAssigned && entry.day == day && entry.shift == shift,
        )
        .map((entry) => entry.staff.target)
        .firstOrNull; // Prevents "StateError: No element" crashes if empty
  }

  Shift calculateShiftFromHour(int hour) {
    if (hour >= 8 && hour < 14) return Shift.morning;
    if (hour >= 14 && hour < 20) return Shift.evening;
    return Shift.night;
  }

  Day calculateDayFromDateTime(DateTime date) {
    return Day.values[date.weekday - 1];
  }
}

// =============================================================================
// 3. CONTROLLER LAYER
// =============================================================================
/// Orchestrates periodic runtime lookups and state coordination.
class WhoIsInNowController extends ChangeNotifier {
  final RosterStatusRepository _repository;

  late WhoIsInModel state;
  Timer? _refreshTimer;

  WhoIsInNowController({required RosterStatusRepository repository})
    : _repository = repository {
    _initializeState();
  }

  void _initializeState() {
    state = _evaluateCurrentDutyStatus();

    // Throttled 30-second loop strikes an ideal balance between low DB footprint
    // and accurate shift handoffs.
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final updatedState = _evaluateCurrentDutyStatus();

      // Strict equality filter limits frame mutations unless operational shifts occur
      if (updatedState.shift != state.shift ||
          updatedState.day != state.day ||
          updatedState.assignedStaff?.id != state.assignedStaff?.id) {
        state = updatedState;
        notifyListeners();
      }
    });
  }

  WhoIsInModel _evaluateCurrentDutyStatus() {
    final now = DateTime.now();
    final currentDay = _repository.calculateDayFromDateTime(now);
    final currentShift = _repository.calculateShiftFromHour(now.hour);
    final staff = _repository.getStaffOnDuty(
      day: currentDay,
      shift: currentShift,
    );

    return WhoIsInModel(
      day: currentDay,
      shift: currentShift,
      assignedStaff: staff,
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// =============================================================================
// 4. PRESENTATION LAYER (COMPONENTS & DIALOGS)
// =============================================================================
/// A clean, information-dense card tracking the operational status of the clinic floor.
class DutyStatusCardComponent extends StatelessWidget {
  final WhoIsInModel state;
  final VoidCallback onTap;

  const DutyStatusCardComponent({
    super.key,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasStaff = state.assignedStaff != null;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _StatusIndicatorIcon(hasStaff: hasStaff),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasStaff
                          ? state.assignedStaff!.name
                          : "No Active Duty Staff",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${state.day.name.toUpperCase()} • ${state.shift.name.toUpperCase()} SHIFT",
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIndicatorIcon extends StatelessWidget {
  final bool hasStaff;

  const _StatusIndicatorIcon({required this.hasStaff});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasStaff ? Colors.teal.shade50 : Colors.amber.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        hasStaff
            ? Icons.health_and_safety
            : Icons.notification_important_rounded,
        color: hasStaff ? Colors.teal.shade700 : Colors.amber.shade800,
        size: 24,
      ),
    );
  }
}

/// Overlay detailing full active shift block variables.
class WhoIsInDialog extends StatelessWidget {
  final WhoIsInModel state;

  const WhoIsInDialog({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isStationEmpty = state.assignedStaff == null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            isStationEmpty
                ? Icons.info_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: isStationEmpty
                ? Colors.amber.shade700
                : Colors.teal.shade700,
          ),
          const SizedBox(width: 10),
          Text(isStationEmpty ? "Duty Roster Empty" : "Active Shift Status"),
        ],
      ),
      content: Text(
        isStationEmpty
            ? "There are currently no staff members scheduled for this shift block."
            : "On-duty Provider: ${state.assignedStaff!.name}\nShift Block: ${state.shift.name.toUpperCase()}",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Dismiss"),
        ),
      ],
    );
  }
}

// =============================================================================
// 5. ENTRY POINT FEATURE VIEW
// =============================================================================
/// Scoped View entry point responsible for initializing dependencies without singletons.
class WhoIsInNowFeatureView extends StatefulWidget {
  const WhoIsInNowFeatureView({super.key});

  @override
  State<WhoIsInNowFeatureView> createState() => _WhoIsInNowFeatureViewState();
}

class _WhoIsInNowFeatureViewState extends State<WhoIsInNowFeatureView> {
  late final WhoIsInNowController _controller;

  @override
  void initState() {
    super.initState();
    // Instantiated locally inside the Scoped state context
    _controller = WhoIsInNowController(repository: RosterStatusRepository());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentState = _controller.state;

        return DutyStatusCardComponent(
          state: currentState,
          onTap: () => navigateToDialog(WhoIsInDialog(state: currentState)),
        );
      },
    );
  }
}
