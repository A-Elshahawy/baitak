import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/apartment.dart';
import '../../../core/theme/colors.dart';
import '../../auth/notifier/auth_notifier.dart';
import '../repo/apartments_repository.dart';
import '../widgets/edit_apartment_sheet.dart';

class ApartmentsListScreen extends ConsumerWidget {
  const ApartmentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aptsAsync = ref.watch(apartmentsListProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('الشقق'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async => ref.invalidate(apartmentsListProvider),
        child: aptsAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.gold)),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.red, size: 48),
                const SizedBox(height: 12),
                Text('حدث خطأ في تحميل الشقق',
                    style: GoogleFonts.cairo(color: AppColors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(apartmentsListProvider),
                  child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          ),
          data: (apts) {
            if (apts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.apartment_rounded,
                        color: AppColors.slate, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'مفيش شقق لحد دلوقتي',
                      style: GoogleFonts.cairo(
                          color: AppColors.slate, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اضغط + لإضافة شقة جديدة',
                      style: GoogleFonts.cairo(
                          color: AppColors.slate, fontSize: 13),
                    ),
                  ],
                ),
              );
            }

            final totalApts = apts.length;
            final totalOccupied =
                apts.fold(0, (s, a) => s + a.occupiedBeds);
            final totalVacant =
                apts.fold(0, (s, a) => s + a.vacantBeds);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                _SummaryRow(
                  totalApts: totalApts,
                  occupied: totalOccupied,
                  vacant: totalVacant,
                ),
                ...apts.map(
                  (apt) => _ApartmentCard(
                    apt: apt,
                    onTap: () =>
                        context.push('/apartments/${apt.id}'),
                    onEdit: () async {
                      final result =
                          await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) =>
                            EditApartmentSheet(apt: apt),
                      );
                      if (result == true) {
                        ref.invalidate(apartmentsListProvider);
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.totalApts,
    required this.occupied,
    required this.vacant,
  });

  final int totalApts;
  final int occupied;
  final int vacant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              value: totalApts.toString(),
              label: 'شقة',
              color: AppColors.charcoal,
              bgColor: AppColors.cream,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              value: occupied.toString(),
              label: 'مشغول',
              color: AppColors.green,
              bgColor: AppColors.greenSurface,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              value: vacant.toString(),
              label: 'فاضي',
              color: AppColors.blue,
              bgColor: AppColors.blueSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final String value;
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
                fontSize: 12, color: AppColors.slate),
          ),
        ],
      ),
    );
  }
}

class _ApartmentCard extends StatelessWidget {
  const _ApartmentCard({
    required this.apt,
    required this.onTap,
    required this.onEdit,
  });

  final Apartment apt;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final total = apt.totalBeds;
    final occupied = apt.occupiedBeds;
    final occupancyVal = total > 0 ? occupied / total : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.goldSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.apartment_rounded,
                    color: AppColors.gold, size: 24),
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
                        fontSize: 16,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      '${apt.area} · الدور ${apt.floor}',
                      style: GoogleFonts.cairo(
                          color: AppColors.slate, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: occupancyVal,
                        minHeight: 6,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.gold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$occupied مشغول',
                          style: GoogleFonts.cairo(
                              color: AppColors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          ' · ',
                          style: GoogleFonts.cairo(
                              color: AppColors.slate, fontSize: 12),
                        ),
                        Text(
                          '${apt.vacantBeds} فاضي',
                          style: GoogleFonts.cairo(
                              color: AppColors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.slate, size: 20),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
