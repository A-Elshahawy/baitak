import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/stats.dart';
import '../../../core/theme/colors.dart';
import '../../auth/notifier/auth_notifier.dart';
import '../repo/earnings_repository.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  Future<void> _editCommission(
      BuildContext context, WidgetRef ref, double current) async {
    final controller = TextEditingController(
      text: (current * 100).toInt().toString(),
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تعديل نسبة العمولة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.cairo(),
          decoration: const InputDecoration(
            suffixText: '%',
            labelText: 'النسبة (0 - 100)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('حفظ', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final rate = double.tryParse(controller.text);
      if (rate != null && rate >= 0 && rate <= 100) {
        await ref
            .read(authNotifierProvider.notifier)
            .updateUser(commissionRate: rate / 100);
        ref.invalidate(earningsProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(earningsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: () async => ref.invalidate(earningsProvider),
          child: earningsAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold)),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.red, size: 48),
                  const SizedBox(height: 12),
                  Text('حدث خطأ في تحميل الأرباح',
                      style: GoogleFonts.cairo(color: AppColors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(earningsProvider),
                    child: Text('إعادة المحاولة',
                        style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            ),
            data: (earnings) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'الأرباح',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RevenueCard(
                    earnings: earnings,
                    onEditCommission: () => _editCommission(context, ref, earnings.commissionRate),
                  ),
                  const SizedBox(height: 16),
                  if (earnings.apartments.isNotEmpty) ...[
                    Text(
                      'تفصيل الشقق',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...earnings.apartments.map(
                        (a) => _ApartmentEarningsCard(apt: a)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.earnings, required this.onEditCommission});

  final EarningsStats earnings;
  final VoidCallback onEditCommission;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.charcoal, AppColors.mid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                'إيرادات شهرية',
                style: GoogleFonts.cairo(
                    color: AppColors.slate, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'EGP ${earnings.totalRevenue.toStringAsFixed(0)}',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عمولتك (${(earnings.commissionRate * 100).toInt()}%)',
                        style: GoogleFonts.cairo(
                            color: AppColors.gold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'EGP ${earnings.commissionAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.cairo(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded,
                      color: AppColors.gold, size: 20),
                  onPressed: onEditCommission,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApartmentEarningsCard extends StatelessWidget {
  const _ApartmentEarningsCard({required this.apt});

  final ApartmentStats apt;

  @override
  Widget build(BuildContext context) {
    final total = apt.bedsTotal;
    final occupied = apt.bedsOccupied;
    final vacant = apt.bedsVacant;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/apartments/${apt.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.goldSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.apartment_rounded,
                      color: AppColors.gold, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    apt.name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
                Text(
                  'EGP ${apt.revenueMonthly.toStringAsFixed(0)}',
                  style: GoogleFonts.cairo(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _MiniBedsBar(occupied: occupied, total: total),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '$occupied مشغول',
                  style: GoogleFonts.cairo(
                      color: AppColors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(
                  '·',
                  style: GoogleFonts.cairo(color: AppColors.slate),
                ),
                const SizedBox(width: 8),
                Text(
                  '$vacant فاضي',
                  style: GoogleFonts.cairo(
                      color: AppColors.slate, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _MiniBedsBar extends StatelessWidget {
  const _MiniBedsBar({required this.occupied, required this.total});

  final int occupied;
  final int total;

  @override
  Widget build(BuildContext context) {
    final vacant = total - occupied;
    return Row(
      children: [
        ...List.generate(
          occupied,
          (i) => Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        ...List.generate(
          vacant,
          (i) => Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$occupied/$total',
          style: GoogleFonts.cairo(fontSize: 12, color: AppColors.slate),
        ),
      ],
    );
  }
}
