import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:kegel_master/features/progress/domain/streak_calculator.dart';
import 'package:kegel_master/features/progress/domain/training_calendar_index.dart';

typedef OnOpenTrainingDay = void Function(DateTime localDay);

class TrainingCalendarCard extends StatefulWidget {
  const TrainingCalendarCard({
    super.key,
    required this.index,
    required this.onOpenDay,
  });

  final TrainingCalendarIndex index;
  final OnOpenTrainingDay onOpenDay;

  @override
  State<TrainingCalendarCard> createState() => _TrainingCalendarCardState();
}

class _TrainingCalendarCardState extends State<TrainingCalendarCard> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _focusedDay = dateOnlyLocal(n);
  }

  DateTime _normalizeDay(DateTime d) => dateOnlyLocal(d);

  List<Object> _eventsForDay(DateTime day) {
    final key = _normalizeDay(day);
    if (widget.index.markedLocalDates.contains(key)) {
      return const [_Marked()];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime.utc(2020, 1, 1);
    final last = DateTime.utc(2035, 12, 31);

    return TableCalendar<Object>(
      firstDay: first,
      lastDay: last,
      focusedDay: _focusedDay,
      eventLoader: _eventsForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      onPageChanged: (focused) {
        setState(() => _focusedDay = _normalizeDay(focused));
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() => _focusedDay = _normalizeDay(focusedDay));
        widget.onOpenDay(_normalizeDay(selectedDay));
      },
    );
  }
}

class _Marked {
  const _Marked();
}
