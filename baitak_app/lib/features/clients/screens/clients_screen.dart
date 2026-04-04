import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/tenant.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/utils/phone_utils.dart';
import '../../tenants/repo/tenants_repository.dart';
import '../../tenants/widgets/add_tenant_sheet.dart';
import '../../tenants/widgets/tenant_detail_sheet.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTenantsAsync = ref.watch(tenantsListProvider);
    final unpaidAsync = ref.watch(unpaidTenantsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: () async {
            ref.invalidate(tenantsListProvider);
            ref.invalidate(unpaidTenantsProvider);
          },
          child: allTenantsAsync.when(
            loading: () => const ClientsShimmer(),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.red, size: 48),
                  const SizedBox(height: 12),
                  Text('حدث خطأ في تحميل العملاء',
                      style: GoogleFonts.cairo(color: AppColors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(tenantsListProvider);
                      ref.invalidate(unpaidTenantsProvider);
                    },
                    child: Text('إعادة المحاولة',
                        style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            ),
            data: (allTenants) {
              final unpaid = unpaidAsync.valueOrNull ?? [];
              final unpaidIds = unpaid.map((t) => t.id).toSet();

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  _ClientsHeader(
                    count: allTenants.length,
                    onAddTenant: () async {
                      final result =
                          await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const AddTenantSheet(),
                      );
                      if (result == true) {
                        ref.invalidate(tenantsListProvider);
                        ref.invalidate(unpaidTenantsProvider);
                      }
                    },
                  ),
                  if (unpaid.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.redSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.red.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '‼ إيجارات متأخرة (${unpaid.length})',
                              style: GoogleFonts.cairo(
                                color: AppColors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...unpaid.map((t) => _UnpaidCard(
                                  tenant: t,
                                  onPaid: () {
                                    ref.invalidate(tenantsListProvider);
                                    ref.invalidate(
                                        unpaidTenantsProvider);
                                  },
                                  ref: ref,
                                )),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'كل السكان',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  if (allTenants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(Icons.people_outline,
                              color: AppColors.slate, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'مفيش سكان لحد دلوقتي',
                            style: GoogleFonts.cairo(
                                color: AppColors.slate, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  else
                    ...allTenants.map((t) => _TenantCard(
                          tenant: t,
                          isPaid: !unpaidIds.contains(t.id),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useRootNavigator: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => TenantDetailSheet(
                                tenant: t,
                                isPaid: !unpaidIds.contains(t.id),
                                rent: t.rentAmount ?? 0,
                                onChanged: () {
                                  ref.invalidate(tenantsListProvider);
                                  ref.invalidate(unpaidTenantsProvider);
                                },
                              ),
                            );
                          },
                        )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ClientsHeader extends StatelessWidget {
  const _ClientsHeader({
    required this.count,
    required this.onAddTenant,
  });

  final int count;
  final VoidCallback onAddTenant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
      child: Row(
        children: [
          Text(
            'العملاء',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.cairo(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gold,
              side: const BorderSide(color: AppColors.gold),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
            label: Text('إضافة ساكن',
                style: GoogleFonts.cairo(fontSize: 12)),
            onPressed: onAddTenant,
          ),
        ],
      ),
    );
  }
}

class _UnpaidCard extends StatefulWidget {
  const _UnpaidCard({
    required this.tenant,
    required this.onPaid,
    required this.ref,
  });

  final TenantWithContext tenant;
  final VoidCallback onPaid;
  final WidgetRef ref;

  @override
  State<_UnpaidCard> createState() => _UnpaidCardState();
}

class _UnpaidCardState extends State<_UnpaidCard> {
  bool _isPaying = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tenant;
    final initial =
        t.name.isNotEmpty ? t.name.characters.first : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.red,
                child: Text(
                  initial,
                  style: GoogleFonts.cairo(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      t.breadcrumb,
                      style: GoogleFonts.cairo(
                          color: AppColors.slate, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (t.rentAmount != null)
                Text(
                  'EGP ${t.rentAmount!.toStringAsFixed(0)}',
                  style: GoogleFonts.cairo(
                    color: AppColors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _SmallButton(
                label: 'واتساب',
                color: AppColors.green,
                icon: Icons.chat,
                onTap: () async {
                  final p = PhoneUtils.toWhatsApp(t.phone);
                  await launchUrl(Uri.parse('https://wa.me/$p'),
                      mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(width: 6),
              _SmallButton(
                label: 'اتصال',
                color: AppColors.gold,
                icon: Icons.phone_rounded,
                onTap: () async {
                  await launchUrl(Uri.parse('tel:${t.phone}'),
                      mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(width: 6),
              _SmallButton(
                label: 'دفع',
                color: AppColors.charcoal,
                icon: Icons.payments_outlined,
                isLoading: _isPaying,
                onTap: () async {
                  setState(() => _isPaying = true);
                  try {
                    await widget.ref
                        .read(tenantsRepositoryProvider)
                        .markPaid(t.id, month: currentMonth());
                    widget.onPaid();
                  } catch (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('حدث خطأ',
                              style: GoogleFonts.cairo(
                                  color: Colors.white)),
                          backgroundColor: AppColors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isPaying = false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  const _TenantCard({
    required this.tenant,
    required this.isPaid,
    required this.onTap,
  });

  final TenantWithContext tenant;
  final bool isPaid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = tenant.name.isNotEmpty
        ? tenant.name.characters.first
        : '?';

    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.gold,
        child: Text(
          initial,
          style: GoogleFonts.cairo(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        tenant.name,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          color: AppColors.charcoal,
        ),
      ),
      subtitle: Text(
        tenant.breadcrumb,
        style: GoogleFonts.cairo(color: AppColors.slate, fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (tenant.rentAmount != null)
            Text(
              'EGP ${tenant.rentAmount!.toStringAsFixed(0)}',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
                fontSize: 13,
              ),
            ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:
                  isPaid ? AppColors.greenSurface : AppColors.redSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isPaid ? 'مدفوع' : 'متأخر',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isPaid ? AppColors.green : AppColors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
