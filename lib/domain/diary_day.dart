/// A diary day runs from local 04:00 until the next local 04:00.
class DiaryDay {
  const DiaryDay(this.date);

  /// Date-only local calendar day (hour is always 0).
  final DateTime date;

  static const boundaryHour = 4;

  static DiaryDay from(DateTime local) {
    final shifted = local.hour < boundaryHour
        ? local.subtract(const Duration(days: 1))
        : local;
    return DiaryDay(DateTime(shifted.year, shifted.month, shifted.day));
  }

  /// The moment this day becomes sealed: the following calendar day at 04:00.
  DateTime get sealAt =>
      DateTime(date.year, date.month, date.day + 1, boundaryHour);

  String get key {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  static DiaryDay parse(String key) {
    final parts = key.split('-');
    return DiaryDay(
      DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
    );
  }

  bool isBefore(DiaryDay other) => date.isBefore(other.date);

  DiaryDay addDays(int days) => DiaryDay(date.add(Duration(days: days)));

  @override
  bool operator ==(Object other) => other is DiaryDay && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => key;
}

class WeekSpan {
  const WeekSpan(this.start, this.end);

  /// Monday, date-only.
  final DateTime start;

  /// Sunday, date-only.
  final DateTime end;

  bool contains(DiaryDay day) {
    final d = day.date;
    return !d.isBefore(start) && !d.isAfter(end);
  }
}

/// Monday 00:00 through Sunday of the week that contains [day].
WeekSpan weekContaining(DateTime day) {
  final date = DateTime(day.year, day.month, day.day);
  final monday = date.subtract(Duration(days: date.weekday - DateTime.monday));
  final sunday = monday.add(const Duration(days: 6));
  return WeekSpan(monday, sunday);
}

const weekdaysZh = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
const monthsZh = [
  '一月',
  '二月',
  '三月',
  '四月',
  '五月',
  '六月',
  '七月',
  '八月',
  '九月',
  '十月',
  '十一月',
  '十二月',
];

String formatMonthDay(DateTime d) => '${d.month}月${d.day}日';

String formatWeekday(DateTime d) => weekdaysZh[d.weekday - 1];

String formatHm(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String formatAppendLabel(DateTime saved, {bool drafting = false}) {
  final base = '补写于 ${formatMonthDay(saved)} ${formatHm(saved)}';
  return drafting ? '$base · 现在' : base;
}

String formatSealLabel(DateTime sealAt) =>
    '${formatMonthDay(sealAt)} ${formatHm(sealAt)} 已封存 · 原文不再改动';

String formatDateLine(DateTime day, {String? time}) {
  final base = '${formatMonthDay(day)} · ${formatWeekday(day)}';
  if (time == null) return base;
  return '$base · $time';
}

String monthGroupLabel(DateTime day) => monthsZh[day.month - 1];

String firstLine(String body) {
  for (final line in body.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}
