import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/apartment.dart';
import '../../../core/models/tenant.dart';
import '../../../core/theme/colors.dart';
import '../../tenants/widgets/add_tenant_sheet.dart';
import '../../tenants/widgets/tenant_detail_sheet.dart';
import '../repo/apartments_repository.dart';
import '../widgets/edit_apartment_sheet.dart';

class ApartmentDetailScreen extends ConsumerWidget {
  const ApartmentDetailScreen({super.key, required this.aptId});

  final int aptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aptAsync = ref.watch(apartmentDetailProvider(aptId));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: aptAsync.when(
        loading: () => const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppColors.gold)),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('خطأ'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.red, size: 48),
                const SizedBox(height: 12),
                Text('تعذر تحميل بيانات الشقة',
                    style: GoogleFonts.cairo(color: AppColors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(apartmentDetailProvider(aptId)),
                  child:
                      Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          ),
        ),
        data: (apt) => _AptDetailBody(apt: apt, ref: ref),
      ),
    );
  }
}

class _AptDetailBody extends StatelessWidget {
  const _AptDetailBody({required this.apt, required this.ref});

  final Apartment apt;
  final WidgetRef ref;

  void _refresh() {
    ref.invalidate(apartmentDetailProvider(apt.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.charcoal,
            leading: BackButton(
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              apt.name,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: AppColors.charcoal),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                child: Row(
                  children: [
                    Text(
                      '${apt.area} · الدور ${apt.floor}',
                      style: GoogleFonts.cairo(
                          color: AppColors.gold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () async {
                  final result = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => EditApartmentSheet(apt: apt),
                  );
                  if (result == true) _refresh();
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _OccupancyCard(apt: apt),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _RoomCard(
                room: apt.rooms[i],
                apt: apt,
                onChanged: _refresh,
              ),
              childCount: apt.rooms.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add_alt_1_rounded,
                  color: Colors.white),
              label: Text(
                'إضافة ساكن لهذه الشقة',
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () async {
                final result = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddTenantSheet(preselectedApt: apt),
                );
                if (result == true) _refresh();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  const _OccupancyCard({required this.apt});

  final Apartment apt;

  @override
  Widget build(BuildContext context) {
    final total = apt.totalBeds;
    final occupied = apt.occupiedBeds;
    final vacant = apt.vacantBeds;
    final occupancyPct =
        total > 0 ? (occupied / total * 100).round() : 0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإشغال',
                    style: GoogleFonts.cairo(
                        color: AppColors.slate, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? occupied / total : 0,
                      minHeight: 8,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.gold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$occupancyPct%',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 24),
            _OccupancyStat(
                value: occupied.toString(),
                label: 'مشغول',
                color: AppColors.green),
            const VerticalDivider(width: 24),
            _OccupancyStat(
                value: vacant.toString(),
                label: 'فاضي',
                color: AppColors.blue),
            const VerticalDivider(width: 24),
            _OccupancyStat(
                value: 'EGP ${apt.revenueMonthly.toStringAsFixed(0)}',
                label: 'إيراد',
                color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}

class _OccupancyStat extends StatelessWidget {
  const _OccupancyStat(
      {required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 11, color: AppColors.slate),
        ),
      ],
    );
  }
}

class _RoomCard extends StatefulWidget {
  const _RoomCard({
    required this.room,
    required this.apt,
    required this.onChanged,
  });

  final Room room;
  final Apartment apt;
  final VoidCallback onChanged;

  @override
  State<_RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<_RoomCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final occupied = room.occupiedBeds;
    final total = room.totalBeds;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.meeting_room_outlined,
                      color: AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      room.name,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  Text(
                    '$occupied/$total',
                    style: GoogleFonts.cairo(
                        color: AppColors.slate, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.slate),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Column(
              children: room.beds
                  .map((bed) => _BedCard(
                        bed: bed,
                        apt: widget.apt,
                        room: room,
                        onChanged: widget.onChanged,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _BedCard extends StatelessWidget {
  const _BedCard({
    required this.bed,
    required this.apt,
    required this.room,
    required this.onChanged,
  });

  final Bed bed;
  final Apartment apt;
  final Room room;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (bed.isOccupied) {
      return _OccupiedBedCard(
        bed: bed,
        apt: apt,
        room: room,
        onChanged: onChanged,
      );
    } else {
      return _VacantBedCard(
        bed: bed,
        apt: apt,
        room: room,
        onChanged: onChanged,
      );
    }
  }
}

class _OccupiedBedCard extends StatelessWidget {
  const _OccupiedBedCard({
    required this.bed,
    required this.apt,
    required this.room,
    required this.onChanged,
  });

  final Bed bed;
  final Apartment apt;
  final Room room;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tenant = bed.tenant!;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenant.name,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  '${bed.label} · EGP ${bed.priceMonthly}',
                  style: GoogleFonts.cairo(
                      color: AppColors.slate, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ساكن',
              style: GoogleFonts.cairo(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.visibility_outlined,
                color: AppColors.gold, size: 18),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) {
                  final tenantCtx =
                      _buildTenantWithContext(tenant, bed, room, apt);
                  return TenantDetailSheet(
                    tenant: tenantCtx,
                    isPaid: true,
                    rent: bed.priceMonthly.toDouble(),
                    onChanged: onChanged,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VacantBedCard extends StatelessWidget {
  const _VacantBedCard({
    required this.bed,
    required this.apt,
    required this.room,
    required this.onChanged,
  });

  final Bed bed;
  final Apartment apt;
  final Room room;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blueSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bed_outlined,
                color: AppColors.blue, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bed.label,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'فاضي · EGP ${bed.priceMonthly}/شهر',
                  style: GoogleFonts.cairo(
                      color: AppColors.blue, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded,
                color: AppColors.blue, size: 20),
            onPressed: () async {
              final result = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddTenantSheet(
                  preselectedApt: apt,
                  preselectedBed: bed,
                  preselectedRoom: room,
                ),
              );
              if (result == true) onChanged();
            },
          ),
        ],
      ),
    );
  }
}

// Helper to build TenantWithContext from local model data
TenantWithContext _buildTenantWithContext(
    TenantOut tenant, Bed bed, Room room, Apartment apt) {
  return TenantWithContext(
    id: tenant.id,
    name: tenant.name,
    phone: tenant.phone,
    startDate: tenant.startDate,
    active: tenant.active,
    bedId: bed.id,
    bedLabel: bed.label,
    roomName: room.name,
    aptId: apt.id,
    aptName: apt.name,
    rentAmount: bed.priceMonthly.toDouble(),
  );
}
