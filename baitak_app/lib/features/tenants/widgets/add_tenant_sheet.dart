import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/apartment.dart';
import '../../../core/theme/colors.dart';
import '../../apartments/repo/apartments_repository.dart';
import '../repo/tenants_repository.dart';

class AddTenantSheet extends ConsumerStatefulWidget {
  const AddTenantSheet({
    super.key,
    this.preselectedApt,
    this.preselectedBed,
    this.preselectedRoom,
  });

  final Apartment? preselectedApt;
  final Bed? preselectedBed;
  final Room? preselectedRoom;

  @override
  ConsumerState<AddTenantSheet> createState() => _AddTenantSheetState();
}

class _AddTenantSheetState extends ConsumerState<AddTenantSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rentController = TextEditingController();

  late int _currentStep;
  Apartment? _selectedApt;
  Room? _selectedRoom;
  Bed? _selectedBed;
  DateTime _startDate = DateTime.now();
  bool _markPaid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedApt = widget.preselectedApt;
    _selectedBed = widget.preselectedBed;
    _selectedRoom = widget.preselectedRoom;

    if (widget.preselectedBed != null) {
      _rentController.text = widget.preselectedBed!.priceMonthly.toString();
    }

    // Always start with personal info; skip steps after it if preselected
    _currentStep = 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _submit() async {
    if (_selectedBed == null) return;
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final rentAmount =
          double.tryParse(_rentController.text) ??
              _selectedBed!.priceMonthly.toDouble();
      await ref.read(tenantsRepositoryProvider).assignTenant(
            bedId: _selectedBed!.id,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            startDate: _startDate,
            rentAmount: rentAmount,
            month: currentMonth(),
            markPaid: _markPaid,
          );
      if (mounted) Navigator.of(context).pop(true);
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _Header(
              currentStep: _currentStep,
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(
              child: _buildStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _PersonalInfoStep(
          nameController: _nameController,
          phoneController: _phoneController,
          onNext: () {
            if (_nameController.text.trim().isNotEmpty &&
                _phoneController.text.trim().isNotEmpty) {
              if (widget.preselectedApt != null && widget.preselectedBed != null) {
                setState(() => _currentStep = 3);
              } else if (widget.preselectedApt != null) {
                setState(() => _currentStep = 2);
              } else {
                setState(() => _currentStep = 1);
              }
            }
          },
        );
      case 1:
        return _PickAptStep(
          onSelect: (apt) {
            setState(() {
              _selectedApt = apt;
              _selectedBed = null;
              _selectedRoom = null;
              _currentStep = 2;
            });
          },
        );
      case 2:
        return _PickBedStep(
          apt: _selectedApt!,
          onSelect: (room, bed) {
            setState(() {
              _selectedRoom = room;
              _selectedBed = bed;
              _rentController.text = bed.priceMonthly.toString();
              _currentStep = 3;
            });
          },
          onChangeApt: widget.preselectedApt == null
              ? () => setState(() => _currentStep = 1)
              : null,
        );
      case 3:
        return _HousingDetailsStep(
          name: _nameController.text,
          phone: _phoneController.text,
          apt: _selectedApt!,
          room: _selectedRoom,
          bed: _selectedBed!,
          rentController: _rentController,
          startDate: _startDate,
          onPickDate: _pickDate,
          markPaid: _markPaid,
          onMarkPaidChanged: (v) => setState(() => _markPaid = v),
          isLoading: _isLoading,
          onSubmit: _submit,
        );
      default:
        return const SizedBox();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.currentStep, required this.onClose});

  final int currentStep;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const SizedBox(width: 32),
          const Spacer(),
          Row(
            children: List.generate(4, (i) {
              final isActive = i <= currentStep;
              final isCurrent = i == currentStep;
              return Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isCurrent ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.gold : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  if (i < 3) const SizedBox(width: 4),
                ],
              );
            }),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.slate),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoStep extends StatelessWidget {
  const _PersonalInfoStep({
    required this.nameController,
    required this.phoneController,
    required this.onNext,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بيانات الساكن',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            style: GoogleFonts.cairo(),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon:
                  Icon(Icons.person_outline, color: AppColors.slate),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.cairo(),
            decoration: const InputDecoration(
              labelText: 'رقم التليفون',
              prefixIcon:
                  Icon(Icons.phone_outlined, color: AppColors.slate),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 57,
            child: ElevatedButton(
              onPressed: onNext,
              child: Text('التالي',
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickAptStep extends ConsumerWidget {
  const _PickAptStep({required this.onSelect});

  final void Function(Apartment apt) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aptsAsync = ref.watch(apartmentsListProvider);

    return aptsAsync.when(
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: AppColors.gold),
      )),
      error: (e, _) => Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('حدث خطأ في تحميل الشقق',
            style: GoogleFonts.cairo(color: AppColors.red)),
      )),
      data: (apts) {
        final vacantApts = apts.where((a) => a.vacantBeds > 0).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Text(
                'اختر الشقة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            if (vacantApts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'مفيش أسرة فاضية في أي شقة',
                  style: GoogleFonts.cairo(color: AppColors.slate),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shrinkWrap: true,
                  itemCount: vacantApts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final apt = vacantApts[i];
                    return Card(
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.goldSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.apartment_rounded,
                              color: AppColors.gold),
                        ),
                        title: Text(apt.name,
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(apt.area,
                            style: GoogleFonts.cairo(
                                color: AppColors.slate, fontSize: 12)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.blueSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${apt.vacantBeds} فاضي',
                            style: GoogleFonts.cairo(
                                color: AppColors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        onTap: () => onSelect(apt),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _PickBedStep extends StatelessWidget {
  const _PickBedStep({
    required this.apt,
    required this.onSelect,
    this.onChangeApt,
  });

  final Apartment apt;
  final void Function(Room room, Bed bed) onSelect;
  final VoidCallback? onChangeApt;

  @override
  Widget build(BuildContext context) {
    final vacantBeds = <({Room room, Bed bed})>[];
    for (final room in apt.rooms) {
      for (final bed in room.beds) {
        if (!bed.isOccupied) {
          vacantBeds.add((room: room, bed: bed));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'اختر السرير — ${apt.name}',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              if (onChangeApt != null)
                TextButton(
                  onPressed: onChangeApt,
                  child: Text('تغيير الشقة',
                      style: GoogleFonts.cairo(color: AppColors.gold)),
                ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          child: vacantBeds.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'مفيش أسرة فاضية في هذه الشقة',
                    style: GoogleFonts.cairo(color: AppColors.slate),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  shrinkWrap: true,
                  itemCount: vacantBeds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final item = vacantBeds[i];
                    return Card(
                      color: AppColors.blueSurface,
                      child: ListTile(
                        leading: const Icon(Icons.bed_outlined,
                            color: AppColors.blue),
                        title: Text(
                            '${item.room.name} · ${item.bed.label}',
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'EGP ${item.bed.priceMonthly} / شهر',
                            style: GoogleFonts.cairo(
                                color: AppColors.blue, fontSize: 12)),
                        onTap: () => onSelect(item.room, item.bed),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HousingDetailsStep extends StatelessWidget {
  const _HousingDetailsStep({
    required this.name,
    required this.phone,
    required this.apt,
    required this.room,
    required this.bed,
    required this.rentController,
    required this.startDate,
    required this.onPickDate,
    required this.markPaid,
    required this.onMarkPaidChanged,
    required this.isLoading,
    required this.onSubmit,
  });

  final String name;
  final String phone;
  final Apartment apt;
  final Room? room;
  final Bed bed;
  final TextEditingController rentController;
  final DateTime startDate;
  final VoidCallback onPickDate;
  final bool markPaid;
  final ValueChanged<bool> onMarkPaidChanged;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تفاصيل السكن',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.goldSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'الاسم', value: name),
                  const SizedBox(height: 4),
                  _InfoRow(label: 'التليفون', value: phone),
                  const SizedBox(height: 4),
                  _InfoRow(label: 'الشقة', value: apt.name),
                  if (room != null) ...[
                    const SizedBox(height: 4),
                    _InfoRow(label: 'الغرفة', value: room!.name),
                  ],
                  const SizedBox(height: 4),
                  _InfoRow(label: 'السرير', value: bed.label),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rentController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.cairo(),
              decoration: const InputDecoration(
                labelText: 'الإيجار الشهري (EGP)',
                prefixIcon:
                    Icon(Icons.money_outlined, color: AppColors.slate),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: onPickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.slate, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('d MMMM yyyy', 'ar').format(startDate),
                      style: GoogleFonts.cairo(fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_outlined,
                        color: AppColors.slate, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('تم الدفع؟', style: GoogleFonts.cairo(fontSize: 14)),
                  Switch(
                    value: markPaid,
                    onChanged: onMarkPaidChanged,
                    activeColor: AppColors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 57,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'حفظ',
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.cairo(
              fontSize: 13, color: AppColors.slate),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ],
    );
  }
}
