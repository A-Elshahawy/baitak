import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import '../apartments/widgets/add_apartment_sheet.dart';
import '../home/repo/home_repository.dart';
import '../tenants/widgets/add_tenant_sheet.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _locationToIndex(String location) {
    if (location.startsWith('/apartments')) return 1;
    if (location.startsWith('/clients')) return 3;
    if (location.startsWith('/earnings')) return 4;
    return 0; // /home
  }

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text(
              'إضافة جديد',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.goldSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.apartment_rounded, color: AppColors.gold),
              ),
              title: Text('إضافة شقة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              subtitle: Text('أضف شقة جديدة مع غرفها وأسرتها',
                  style: GoogleFonts.cairo(fontSize: 12, color: AppColors.slate)),
              onTap: () {
                Navigator.of(ctx).pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddApartmentSheet(),
                ).then((r) {
                  if (r == true) ref.invalidate(overviewProvider);
                });
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.greenSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_add_rounded, color: AppColors.green),
              ),
              title: Text('إضافة ساكن', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              subtitle: Text('أضف ساكن جديد لأحد الأسرة',
                  style: GoogleFonts.cairo(fontSize: 12, color: AppColors.slate)),
              onTap: () {
                Navigator.of(ctx).pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddTenantSheet(),
                ).then((r) {
                  if (r == true) ref.invalidate(overviewProvider);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    final unpaidCount = ref.watch(overviewProvider).maybeWhen(
          data: (s) => s.unpaidCount,
          orElse: () => 0,
        );

    return Scaffold(
      body: child,
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context, ref),
        backgroundColor: AppColors.gold,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.white,
        elevation: 8,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                selected: currentIndex == 0,
                onTap: () => context.go('/home'),
              ),
              _NavItem(
                icon: Icons.apartment_rounded,
                label: 'الشقق',
                selected: currentIndex == 1,
                onTap: () => context.go('/apartments'),
              ),
              const SizedBox(width: 56),
              _NavItem(
                icon: Icons.people_rounded,
                label: 'العملاء',
                selected: currentIndex == 3,
                badgeCount: unpaidCount,
                onTap: () => context.go('/clients'),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'الأرباح',
                selected: currentIndex == 4,
                onTap: () => context.go('/earnings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.gold : AppColors.slate;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 24),
                  if (badgeCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: color,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
