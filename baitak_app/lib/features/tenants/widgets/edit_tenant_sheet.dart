import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/tenant.dart';
import '../../../core/theme/colors.dart';
import '../repo/tenants_repository.dart';

class EditTenantSheet extends ConsumerStatefulWidget {
  const EditTenantSheet({
    super.key,
    required this.tenant,
    required this.isPaid,
    required this.rent,
  });

  final TenantWithContext tenant;
  final bool isPaid;
  final double rent;

  @override
  ConsumerState<EditTenantSheet> createState() => _EditTenantSheetState();
}

class _EditTenantSheetState extends ConsumerState<EditTenantSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _rentController;
  late DateTime _startDate;
  late bool _isPaid;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tenant.name);
    _phoneController = TextEditingController(text: widget.tenant.phone);
    _rentController =
        TextEditingController(text: widget.rent.toStringAsFixed(0));
    _startDate = widget.tenant.startDate;
    _isPaid = widget.isPaid;
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
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('من فضلك أدخل الاسم', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(tenantsRepositoryProvider);
      await repo.updateTenant(
        widget.tenant.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        startDate: _startDate,
      );

      if (!widget.isPaid && _isPaid) {
        await repo.markPaid(
          widget.tenant.id,
          month: currentMonth(),
          amount: double.tryParse(_rentController.text),
        );
      } else if (widget.isPaid && !_isPaid) {
        await repo.markUnpaid(widget.tenant.id, month: currentMonth());
      }

      if (mounted) {
        Navigator.of(context).pop(true);
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 16),
              Text(
                'تعديل بيانات الساكن',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                style: GoogleFonts.cairo(),
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon:
                      Icon(Icons.person_outline, color: AppColors.slate),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.cairo(),
                decoration: const InputDecoration(
                  labelText: 'رقم التليفون',
                  prefixIcon:
                      Icon(Icons.phone_outlined, color: AppColors.slate),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rentController,
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
                onTap: _pickDate,
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
                        DateFormat('d MMMM yyyy', 'ar').format(_startDate),
                        style: GoogleFonts.cairo(fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_outlined,
                          color: AppColors.slate, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'حالة الدفع',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPaid = true),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isPaid
                              ? AppColors.greenSurface
                              : Colors.white,
                          border: Border.all(
                            color: _isPaid
                                ? AppColors.green
                                : AppColors.divider,
                            width: _isPaid ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: _isPaid
                                    ? AppColors.green
                                    : AppColors.slate,
                                size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'مدفوع',
                              style: GoogleFonts.cairo(
                                color: _isPaid
                                    ? AppColors.green
                                    : AppColors.slate,
                                fontWeight: _isPaid
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPaid = false),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isPaid
                              ? AppColors.redSurface
                              : Colors.white,
                          border: Border.all(
                            color: !_isPaid
                                ? AppColors.red
                                : AppColors.divider,
                            width: !_isPaid ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel_outlined,
                                color: !_isPaid
                                    ? AppColors.red
                                    : AppColors.slate,
                                size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'متأخر',
                              style: GoogleFonts.cairo(
                                color: !_isPaid
                                    ? AppColors.red
                                    : AppColors.slate,
                                fontWeight: !_isPaid
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'حفظ التعديلات',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
