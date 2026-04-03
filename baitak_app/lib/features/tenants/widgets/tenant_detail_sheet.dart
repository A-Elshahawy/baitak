import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/tenant.dart';
import '../../../core/theme/colors.dart';
import '../repo/tenants_repository.dart';
import 'edit_tenant_sheet.dart';

class TenantDetailSheet extends ConsumerStatefulWidget {
  const TenantDetailSheet({
    super.key,
    required this.tenant,
    required this.isPaid,
    required this.rent,
    this.onChanged,
  });

  final TenantWithContext tenant;
  final bool isPaid;
  final double rent;
  final VoidCallback? onChanged;

  @override
  ConsumerState<TenantDetailSheet> createState() => _TenantDetailSheetState();
}

class _TenantDetailSheetState extends ConsumerState<TenantDetailSheet> {
  bool _isVacating = false;

  Future<void> _vacate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تأكيد إخلاء السرير',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد إخلاء ${widget.tenant.name} من السرير؟ لن يتم حذف بياناته.',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.slate)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('إخلاء', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isVacating = true);
    try {
      await ref.read(tenantsRepositoryProvider).vacateTenant(widget.tenant.id);
      if (mounted) {
        widget.onChanged?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e',
                style: GoogleFonts.cairo(color: Colors.white)),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isVacating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = widget.tenant;
    final breadcrumb =
        '${tenant.aptName ?? '—'} · ${tenant.roomName ?? '—'} · ${tenant.bedLabel ?? '—'}';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tenant.name,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              breadcrumb,
              style: GoogleFonts.cairo(fontSize: 13, color: AppColors.slate),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _DetailRow(
              icon: Icons.phone_outlined,
              text: tenant.phone,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              text: DateFormat('d MMMM yyyy', 'ar').format(tenant.startDate),
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.account_balance_wallet_outlined,
              text: 'EGP ${widget.rent.toStringAsFixed(0)} / شهر',
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.isPaid
                      ? AppColors.greenSurface
                      : AppColors.redSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isPaid ? AppColors.green : AppColors.red,
                  ),
                ),
                child: Text(
                  widget.isPaid ? 'مدفوع' : 'متأخر',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: widget.isPaid ? AppColors.green : AppColors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.chat, size: 18),
                    label: Text('واتساب',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      final p = tenant.phone.replaceAll(RegExp(r'[^0-9+]'), '');
                      await launchUrl(Uri.parse('https://wa.me/$p'),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: Text('اتصال',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      await launchUrl(Uri.parse('tel:${tenant.phone}'),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.blue,
                      side: const BorderSide(color: AppColors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text('تعديل',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                    onPressed: () async {
                      final result = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => EditTenantSheet(
                          tenant: tenant,
                          isPaid: widget.isPaid,
                          rent: widget.rent,
                        ),
                      );
                      if (result == true && mounted) {
                        widget.onChanged?.call();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: _isVacating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: AppColors.red, strokeWidth: 2))
                        : const Icon(Icons.exit_to_app_rounded, size: 18),
                    label: Text('إخلاء السرير',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                    onPressed: _isVacating ? null : _vacate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.slate, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(fontSize: 14, color: AppColors.charcoal),
          ),
        ),
      ],
    );
  }
}
