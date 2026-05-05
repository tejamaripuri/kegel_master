import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:kegel_master/features/progress/domain/training_calendar_index.dart';

typedef OnOpenTrainingDay = void Function(DateTime localDay);

// table_calendar encodes grid days as UTC y-m-d, not wall-clock instants like session `endedAt`.
DateTime _calendarCellLocalDay(DateTime d) =>
    DateTime(d.year, d.month, d.day);

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
    _focusedDay = _calendarCellLocalDay(n);
  }

  List<Object> _eventsForDay(DateTime day) {
    final key = _calendarCellLocalDay(day);
    if (widget.index.markedLocalDates.contains(key)) {
      return const [_Marked()];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(2020, 1, 1);
    final last = DateTime(2035, 12, 31);

    return TableCalendar<Object>(
      firstDay: first,
      lastDay: last,
      focusedDay: _focusedDay,
      eventLoader: _eventsForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      onPageChanged: (focused) {
        setState(() => _focusedDay = _calendarCellLocalDay(focused));
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() => _focusedDay = _calendarCellLocalDay(focusedDay));
        widget.onOpenDay(_calendarCellLocalDay(selectedDay));
      },
    );
  }
}

class _Marked {
  const _Marked();
}
