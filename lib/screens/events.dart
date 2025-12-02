// pubspec.yaml dependencies (make sure you add these):
// hijri_date: ^1.0.0
// hijri_calendar: ^1.0.0

import 'package:flutter/material.dart';
import 'package:hijri_date/hijri.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';


class IslamicEventsApp extends StatelessWidget {
  const IslamicEventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the app's existing MaterialApp and theming; this just returns the screen.
    return const UpcomingEventsPage();
  }
}

class UpcomingEventsPage extends StatefulWidget {
  const UpcomingEventsPage({super.key});
  @override
  State<UpcomingEventsPage> createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  late final List<IslamicEvent> _events;
final calendar = HijriCalendarConfig();                                // create instance
// DateTime greg = calendar.hijriToGregorian(year, month, day);    
  @override
  void initState() {
    super.initState();
    // Get upcoming events for the next N months (adjust as needed)
    _events = IslamicEventsManager.getUpcomingEvents(monthsAhead: 12);
  }

  DateTime? _hijriToGregorianNext(IslamicEvent ev) {
  final nowHijri = HijriCalendarConfig.now();
  int year = nowHijri.hYear;

  int evMonth = ev.month;
  int evDay = ev.days.first;

  if (evMonth < nowHijri.hMonth ||
      (evMonth == nowHijri.hMonth && evDay < nowHijri.hDay)) {
    year += 1;
  }

    final calendar = HijriCalendarConfig();                              // instantiate
    try {
      return calendar.hijriToGregorian(year, evMonth, evDay);            // instance method
    } catch (e) {
      return null;
    }
  }

  String _formatHijriDate(IslamicEvent ev) {
    final days = ev.days.join(', ');
    return '$days / ${ev.month} AH';  // only day(s) and month
  }

  String _formatGregorianLong(DateTime? date) {
    if (date == null) return 'Date TBC';
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthName = monthNames[date.month - 1];
    return '${date.day} $monthName ${date.year}';
  }

  String _getEventTypeLabel(IslamicEvent ev) {
    final title = ev.getTitle('en').toLowerCase();

    if (title.contains('ramadan')) return 'Ramadan / Fasting';
    if (title.contains('eid al-adha') || title.contains('eid ul adha')) return 'Eid al-Adha';
    if (title.contains('eid al-fitr') || title.contains('eid ul fitr')) return 'Eid al-Fitr';
    if (title.contains('eid')) return 'Eid';
    if (title.contains('arafah')) return 'Day of Arafah';
    if (title.contains('ashura')) return 'Day of Ashura';
    if (title.contains('fast')) return 'Fasting';
    if (title.contains('hajj')) return 'Hajj';

    return 'Islamic Event';
  }

  IconData _getEventTypeIcon(IslamicEvent ev) {
    final title = ev.getTitle('en').toLowerCase();

    if (title.contains('eid')) return Icons.celebration_rounded;
    if (title.contains('ramadan') || title.contains('fast')) return Icons.brightness_3_rounded;
    if (title.contains('hajj') || title.contains('arafah')) return Icons.landscape_rounded;
    if (title.contains('ashura')) return Icons.water_drop_rounded;

    return Icons.star_border_rounded;
  }

  Widget _buildEventTypeTag(
    IslamicEvent ev,
    Color textColor,
    Color accentColor,
  ) {
    final label = _getEventTypeLabel(ev);
    final icon = _getEventTypeIcon(ev);

    return Container
    (
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: accentColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDark = appProvider.isDarkMode;
        final textColor = isDark ? AppTheme.textLight : AppTheme.textDark;
        final accentColor = appProvider.accentColor;

        return Container
          (
          decoration: AppTheme.gradientBackground(appProvider.themeMode),
          child: SafeArea(
            child: Scaffold(
              
              backgroundColor: Colors.transparent,
              appBar:  AppBar(
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Text('Upcoming Islamic Events'),
              ),
              body: _events.isEmpty
                  ? Center(
                      child: Text(
                        'No upcoming events found.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Featured upcoming event (first one)
                          _buildFeaturedEventCard(_events.first, textColor, accentColor),
                          const SizedBox(height: 0),
                          if (_events.length > 1)
                            // Text(
                            //   'All upcoming events',
                            //   style: TextStyle(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.w700,
                            //     color: textColor,
                            //   ),
                            // ),
                            
                          if (_events.length > 1) ...[
                            const SizedBox(height: 0),
                            ..._buildAllUpcomingSections(
                              _events.sublist(1),
                              textColor,
                              accentColor,
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAllUpcomingSections(
    List<IslamicEvent> events,
    Color textColor,
    Color accentColor,
  ) {
    if (events.isEmpty) return const [];

    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final sortedEvents = List<IslamicEvent>.from(events)
      ..sort((a, b) {
        final aDate = _hijriToGregorianNext(a);
        final bDate = _hijriToGregorianNext(b);

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return aDate.compareTo(bDate);
      });

    final Map<String, List<IslamicEvent>> grouped = {};

    for (final ev in sortedEvents) {
      final date = _hijriToGregorianNext(ev);
      if (date == null) continue;

      final monthLabel = '${monthNames[date.month - 1]} ${date.year}';
      grouped.putIfAbsent(monthLabel, () => []).add(ev);
    }

    final widgets = <Widget>[];

    grouped.forEach((monthLabel, monthEvents) {
      widgets.add(const SizedBox(height: 16));
      widgets.add(
        // Text(
        //   monthLabel,
        //   style: TextStyle(
        //     fontSize: 15,
        //     fontWeight: FontWeight.w700,
        //     color: textColor.withOpacity(0.9),
        //   ),
        // ),
        Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.2),
                      accentColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month,
                  color: accentColor,
                  size: 20,
                ),
              ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$monthLabel',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                  // Text(
                  //   ' • ${appProvider.selectedLanguage}',
                  //   style: TextStyle(
                  //     fontSize: 11,
                  //     fontWeight: FontWeight.w600,
                  //     color: appProvider.accentColor.withOpacity(0.8),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
          // Verses count
          // Text(
          //   '25 verses',
          //   style: TextStyle(
          //     fontSize: 12,
          //     fontWeight: FontWeight.w600,
          //     color: appProvider.accentColor,
          //   ),
          // ),
            ],
          ),
      );
      widgets.add(const SizedBox(height: 8));

      for (final ev in monthEvents) {
        widgets.add(_buildEventCard(ev, textColor, accentColor));
      }
    });

    return widgets;
  }

  Widget _buildFeaturedEventCard(
    IslamicEvent ev,
    Color textColor,
    Color accentColor,
  ) {
    final title = ev.getTitle('en');
    final daysUntil = ev.daysUntilEvent();
    final isToday = ev.isToday();
    final gregorian = _hijriToGregorianNext(ev);
    final gregorianLong = _formatGregorianLong(gregorian);
    final hijriStr = _formatHijriDate(ev);

    return GlassCard(
      borderRadius: 24,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Important Event',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: accentColor.withOpacity(0.6),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 0),
          _buildEventTypeTag(ev, textColor, accentColor),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                gregorianLong,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.event_note,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              // Text(
              //   'Hijri: $hijriStr',
              //   style: TextStyle(
              //     fontSize: 14,
              //     color: textColor,
              //   ),
              // ),
               Text(
            daysUntil == 0
                ? 'Happening today'
                : 'In $daysUntil day${daysUntil > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          
            ],
          ),
          // const SizedBox(height: 8),
          // Text(
          //   daysUntil == 0
          //       ? 'Happening today'
          //       : 'In $daysUntil day${daysUntil > 1 ? 's' : ''}',
          //   style: TextStyle(
          //     fontSize: 13,
          //     fontWeight: FontWeight.w600,
          //     color: accentColor,
          //   ),
          // ),
          
        ],
      ),
    );
  }

  Widget _buildEventCard(
    IslamicEvent ev,
    Color textColor,
    Color accentColor,
  ) {
    final title = ev.getTitle('en');
    final daysUntil = ev.daysUntilEvent();
    final isToday = ev.isToday();
    final gregorian = _hijriToGregorianNext(ev);
    final gregorianLong = _formatGregorianLong(gregorian);

    return GlassCard(
      borderRadius: 20,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: accentColor.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
          _buildEventTypeTag(ev, textColor, accentColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                gregorianLong,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.event_note,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              Text(
            daysUntil == 0
                ? 'Happening today'
                : 'In $daysUntil day${daysUntil > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
              // Text(
              //   'Hijri: ${ev.days.join(', ')} / ${ev.month}',
              //   style: TextStyle(
              //     fontSize: 14,
              //     color: textColor,
              //   ),
              // ),
            ],
          ),
          // const SizedBox(height: 6),
          // Text(
          //   daysUntil == 0
          //       ? 'Happening today'
          //       : 'In $daysUntil day${daysUntil > 1 ? 's' : ''}',
          //   style: TextStyle(
          //     fontSize: 13,
          //     fontWeight: FontWeight.w600,
          //     color: accentColor,
          //   ),
          // ),
        ],
      ),
    );
  }
}
