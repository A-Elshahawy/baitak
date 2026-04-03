import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/stats.dart';
import '../../../core/theme/colors.dart';
import '../../auth/notifier/auth_notifier.dart';
import '../../auth/widgets/profile_sheet.dart';
import '../repo/home_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);
    final aptsStatsAsync = ref.watch(apartmentsStatsProvider);
    final user = ref.watch(authNotifierProvider).valueOrNull;

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () async {
        ref.invalidate(overviewProvider);
        ref.invalidate(apartmentsStatsProvider);
      },
      child: overviewAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 48),
              const SizedBox(height: 16),
              Text('حدث خطأ في تحميل البيانات',
                  style: GoogleFonts.cairo(color: AppColors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(overviewProvider),
                child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
              ),
            ],
          ),
        ),
        data: (overview) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                    userName: user?.name ?? '', overview: overview),
              ),
              SliverToBoxAdapter(
                child: _OccupancyBar(overview: overview),
              ),
              if (overview.unpaidCount > 0)
                SliverToBoxAdapter(
                  child: _UnpaidBanner(count: overview.unpaidCount),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'شققك',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ),
              aptsStatsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.gold)),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('تعذر تحميل الشقق',
                        style: GoogleFonts.cairo(color: AppColors.red)),
                  ),
                ),
                data: (apts) {
                  if (apts.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Icon(Icons.apartment_rounded,
                                color: AppColors.slate, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              'مفيش شقق لحد دلوقتي',
                              style: GoogleFonts.cairo(
                                  color: AppColors.slate, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _AptRow(apt: apts[i]),
                      childCount: apts.length,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.userName, required this.overview});

  final String userName;
  final OverviewStats overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أهلاً، ${userName.isEmpty ? 'بيتك' : userName}!',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'إدارة شققك',
                      style: GoogleFonts.cairo(
                        color: AppColors.gold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const ProfileSheet(),
                ),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userName.isEmpty
                          ? 'ب'
                          : userName.characters.first,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.gold.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.gold, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'الإيرادات الشهرية',
                      style: GoogleFonts.cairo(
                          color: AppColors.slate, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'EGP ${overview.revenueMonthly.toStringAsFixed(0)}',
                  style: GoogleFonts.cairo(
                    color: AppColors.charcoal,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(
                    color: AppColors.gold.withOpacity(0.2),
                    height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip(
                        value: overview.apartments.toString(),
                        label: 'شقة'),
                    _Divider(),
                    _StatChip(
                        value: overview.bedsOccupied.toString(),
                        label: 'مشغول'),
                    _Divider(),
                    _StatChip(
                        value: overview.bedsVacant.toString(),
                        label: 'فاضي'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.gold.withOpacity(0.2),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
              fontSize: 11, color: AppColors.slate),
        ),
      ],
    );
  }
}

class _OccupancyBar extends StatelessWidget {
  const _OccupancyBar({required this.overview});

  final OverviewStats overview;

  @override
  Widget build(BuildContext context) {
    final pct = overview.bedsTotal > 0
        ? (overview.bedsOccupied / overview.bedsTotal * 100).round()
        : 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإشغال',
                style: GoogleFonts.cairo(
                    fontSize: 13, color: AppColors.slate),
              ),
              Row(
                children: [
                  Text(
                    '$pct%',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${overview.bedsOccupied}/${overview.bedsTotal}',
                    style: GoogleFonts.cairo(
                        fontSize: 12, color: AppColors.slate),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: overview.bedsTotal > 0
                  ? overview.bedsOccupied / overview.bedsTotal
                  : 0,
              minHeight: 10,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnpaidBanner extends StatelessWidget {
  const _UnpaidBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/clients'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.redSurface,
          border: Border.all(color: AppColors.red.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.red, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'لديك $count إيجار متأخر',
                style: GoogleFonts.cairo(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.red, size: 14),
          ],
        ),
      ),
    );
  }
}

class _AptRow extends StatelessWidget {
  const _AptRow({required this.apt});

  final ApartmentStats apt;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/apartments/${apt.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.goldSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.apartment_rounded,
                  color: AppColors.gold, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apt.name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _MiniBedsBar(
                      occupied: apt.bedsOccupied, total: apt.bedsTotal),
                ],
              ),
            ),
            Text(
              'EGP ${apt.revenueMonthly.toStringAsFixed(0)}',
              style: GoogleFonts.cairo(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
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
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        ...List.generate(
          vacant,
          (i) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$occupied/$total',
          style: GoogleFonts.cairo(fontSize: 11, color: AppColors.slate),
        ),
      ],
    );
  }
}
