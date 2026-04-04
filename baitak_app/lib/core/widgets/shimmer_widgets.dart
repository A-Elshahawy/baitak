import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/colors.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _sBox({
  double? width,
  double height = 16,
  double radius = 8,
}) =>
    Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

Shimmer _light({required Widget child}) => Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: const Color(0xFFF5F2ED),
      child: child,
    );

Shimmer _dark({required Widget child}) => Shimmer.fromColors(
      baseColor: const Color(0xFF2D2D44),
      highlightColor: const Color(0xFF3D3D58),
      child: child,
    );

// ─── Home Screen ─────────────────────────────────────────────────────────────

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _dark(child: _HomeHeaderContent())),
        SliverToBoxAdapter(
          child: _light(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sBox(width: 50, height: 13),
                      _sBox(width: 60, height: 13),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _sBox(width: double.infinity, height: 10),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _light(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _sBox(width: 60, height: 18),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => _light(child: _AptRowContent()),
            childCount: 4,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _HomeHeaderContent extends StatelessWidget {
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
                    _sBox(width: 140, height: 20),
                    const SizedBox(height: 6),
                    _sBox(width: 80, height: 14),
                  ],
                ),
              ),
              _sBox(width: 48, height: 48, radius: 24),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D44),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sBox(width: 120, height: 14),
                const SizedBox(height: 8),
                _sBox(width: 160, height: 32),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _sBox(width: 48, height: 40),
                    _sBox(width: 1, height: 32),
                    _sBox(width: 48, height: 40),
                    _sBox(width: 1, height: 32),
                    _sBox(width: 48, height: 40),
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

/// Standalone shimmer for a single apartment row — used in HomeScreen
/// when the overview is loaded but apartment stats are still fetching.
class AptRowShimmer extends StatelessWidget {
  const AptRowShimmer({super.key});

  @override
  Widget build(BuildContext context) => _light(child: _AptRowContent());
}

class _AptRowContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _sBox(width: 40, height: 40, radius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sBox(width: 120, height: 15),
                  const SizedBox(height: 8),
                  _sBox(width: 80, height: 8),
                ],
              ),
            ),
            _sBox(width: 70, height: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Apartments List Screen ───────────────────────────────────────────────────

class ApartmentsListShimmer extends StatelessWidget {
  const ApartmentsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _light(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(child: _sBox(height: 64, radius: 12)),
                const SizedBox(width: 10),
                Expanded(child: _sBox(height: 64, radius: 12)),
                const SizedBox(width: 10),
                Expanded(child: _sBox(height: 64, radius: 12)),
              ],
            ),
          ),
        ),
        ...List.generate(4, (_) => _light(child: _ApartmentCardContent())),
      ],
    );
  }
}

class _ApartmentCardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _sBox(width: 44, height: 44, radius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sBox(width: 130, height: 16),
                  const SizedBox(height: 6),
                  _sBox(width: 90, height: 13),
                  const SizedBox(height: 10),
                  _sBox(width: double.infinity, height: 6, radius: 4),
                  const SizedBox(height: 6),
                  _sBox(width: 100, height: 12),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _sBox(width: 32, height: 32, radius: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Clients Screen ──────────────────────────────────────────────────────────

class ClientsShimmer extends StatelessWidget {
  const ClientsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _light(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
            child: Row(
              children: [
                _sBox(width: 70, height: 24),
                const SizedBox(width: 8),
                _sBox(width: 28, height: 20, radius: 8),
                const Spacer(),
                _sBox(width: 100, height: 36, radius: 10),
              ],
            ),
          ),
        ),
        ...List.generate(7, (_) => _light(child: _TenantTileContent())),
      ],
    );
  }
}

class _TenantTileContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _sBox(width: 40, height: 40, radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sBox(width: 110, height: 14),
                const SizedBox(height: 6),
                _sBox(width: 160, height: 12),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _sBox(width: 70, height: 13),
              const SizedBox(height: 4),
              _sBox(width: 44, height: 20, radius: 8),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Earnings Screen ─────────────────────────────────────────────────────────

class EarningsShimmer extends StatelessWidget {
  const EarningsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _light(child: _sBox(width: 80, height: 24)),
          const SizedBox(height: 16),
          _dark(child: _EarningsCardContent()),
          const SizedBox(height: 16),
          _light(child: _sBox(width: 90, height: 16)),
          const SizedBox(height: 8),
          ...List.generate(3, (_) => _light(child: _EarningsAptCardContent())),
        ],
      ),
    );
  }
}

class _EarningsCardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sBox(width: 100, height: 14),
          const SizedBox(height: 12),
          _sBox(width: 200, height: 40),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D44),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sBox(width: 100, height: 13),
                      const SizedBox(height: 4),
                      _sBox(width: 120, height: 22),
                    ],
                  ),
                ),
                _sBox(width: 24, height: 24, radius: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsAptCardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _sBox(width: 36, height: 36, radius: 10),
                const SizedBox(width: 12),
                Expanded(child: _sBox(width: 110, height: 15)),
                _sBox(width: 70, height: 15),
              ],
            ),
            const SizedBox(height: 10),
            _sBox(width: double.infinity, height: 10),
            const SizedBox(height: 8),
            Row(
              children: [
                _sBox(width: 60, height: 12),
                const SizedBox(width: 8),
                _sBox(width: 8, height: 12),
                const SizedBox(width: 8),
                _sBox(width: 50, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
