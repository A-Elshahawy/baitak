class OverviewStats {
  const OverviewStats({
    required this.apartments,
    required this.bedsTotal,
    required this.bedsOccupied,
    required this.bedsVacant,
    required this.revenueMonthly,
    required this.unpaidCount,
  });

  final int apartments;
  final int bedsTotal;
  final int bedsOccupied;
  final int bedsVacant;
  final double revenueMonthly;
  final int unpaidCount;

  double get occupancyRate =>
      bedsTotal > 0 ? bedsOccupied / bedsTotal : 0.0;

  factory OverviewStats.fromJson(Map<String, dynamic> json) => OverviewStats(
        apartments: json['apartments'] as int,
        bedsTotal: json['beds_total'] as int,
        bedsOccupied: json['beds_occupied'] as int,
        bedsVacant: json['beds_vacant'] as int,
        revenueMonthly: (json['revenue_monthly'] as num).toDouble(),
        unpaidCount: json['unpaid_count'] as int,
      );
}

class ApartmentStats {
  const ApartmentStats({
    required this.id,
    required this.name,
    required this.bedsTotal,
    required this.bedsOccupied,
    required this.revenueMonthly,
  });

  final int id;
  final String name;
  final int bedsTotal;
  final int bedsOccupied;
  final double revenueMonthly;

  int get bedsVacant => bedsTotal - bedsOccupied;

  factory ApartmentStats.fromJson(Map<String, dynamic> json) => ApartmentStats(
        id: json['id'] as int,
        name: json['name'] as String,
        bedsTotal: json['beds_total'] as int,
        bedsOccupied: json['beds_occupied'] as int,
        revenueMonthly: (json['revenue_monthly'] as num).toDouble(),
      );
}

class EarningsStats {
  const EarningsStats({
    required this.totalRevenue,
    required this.commissionRate,
    required this.commissionAmount,
    required this.apartments,
  });

  final double totalRevenue;
  final double commissionRate;
  final double commissionAmount;
  final List<ApartmentStats> apartments;

  factory EarningsStats.fromJson(Map<String, dynamic> json) => EarningsStats(
        totalRevenue: (json['total_revenue'] as num).toDouble(),
        commissionRate: (json['commission_rate'] as num).toDouble(),
        commissionAmount: (json['commission_amount'] as num).toDouble(),
        apartments: (json['apartments'] as List<dynamic>? ?? [])
            .map((a) => ApartmentStats.fromJson(a as Map<String, dynamic>))
            .toList(),
      );
}
