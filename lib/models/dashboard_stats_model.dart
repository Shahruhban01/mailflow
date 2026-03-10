class ChartPoint {
  final String date;
  final String label;
  final int count;
  const ChartPoint({required this.date, required this.label, required this.count});

  factory ChartPoint.fromJson(Map<String, dynamic> j) => ChartPoint(
    date:  j['date']  as String,
    label: j['label'] as String,
    count: int.parse(j['count'].toString()),
  );
}

class RecentEmail {
  final int id;
  final String subject;
  final String receiverEmail;
  final String status;
  final String createdAt;

  const RecentEmail({
    required this.id, required this.subject,
    required this.receiverEmail, required this.status,
    required this.createdAt,
  });

  factory RecentEmail.fromJson(Map<String, dynamic> j) => RecentEmail(
    id:            int.parse(j['id'].toString()),
    subject:       j['subject']        as String,
    receiverEmail: j['receiver_email'] as String,
    status:        j['status']         as String,
    createdAt:     j['created_at']     as String,
  );
}

class DashboardStats {
  final int total, sent, draft, failed;
  final int today, thisWeek, thisMonth;
  final double successRate;
  final int templates;
  final List<ChartPoint> chart;
  final List<RecentEmail> recent;

  const DashboardStats({
    required this.total,    required this.sent,
    required this.draft,    required this.failed,
    required this.today,    required this.thisWeek,
    required this.thisMonth, required this.successRate,
    required this.templates, required this.chart,
    required this.recent,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
    total:       int.parse(j['total'].toString()),
    sent:        int.parse(j['sent'].toString()),
    draft:       int.parse(j['draft'].toString()),
    failed:      int.parse(j['failed'].toString()),
    today:       int.parse(j['today'].toString()),
    thisWeek:    int.parse(j['this_week'].toString()),
    thisMonth:   int.parse(j['this_month'].toString()),
    successRate: double.parse(j['success_rate'].toString()),
    templates:   int.parse(j['templates'].toString()),
    chart:  (j['chart']  as List).map((e) => ChartPoint.fromJson(e)).toList(),
    recent: (j['recent'] as List).map((e) => RecentEmail.fromJson(e)).toList(),
  );
}
