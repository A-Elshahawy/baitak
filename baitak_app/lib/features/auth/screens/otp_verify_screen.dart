import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/phone_utils.dart';
import '../notifier/auth_notifier.dart';
import '../repo/auth_repository.dart';

class OTPVerifyScreen extends ConsumerStatefulWidget {
  const OTPVerifyScreen({
    super.key,
    required this.phone,
  });

  final String phone;

  @override
  ConsumerState<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends ConsumerState<OTPVerifyScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  int _countdown = 60;
  Timer? _timer;
  String? _name;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .verifyOtp(widget.phone, code, name: _name);

      if (result.isNewUser && (_name == null || _name!.trim().isEmpty)) {
        if (mounted) {
          _showNameDialog();
        }
        return;
      }

      if (mounted) {
        await ref.read(authNotifierProvider.notifier).loginWithOtp(
              widget.phone,
              code,
              name: _name,
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('كود غلط أو منتهي الصلاحية',
                style: GoogleFonts.cairo(color: Colors.white)),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final nameCtrl = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('أدخل اسمك', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: nameCtrl,
            style: GoogleFonts.cairo(),
            decoration: const InputDecoration(
              labelText: 'الاسم',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.slate),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.of(ctx).pop();
                setState(() => _name = name);
                setState(() => _isLoading = true);
                try {
                  await ref.read(authNotifierProvider.notifier).loginWithOtp(
                        widget.phone,
                        _codeController.text,
                        name: name,
                      );
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
              },
              child: Text('متابعة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resend() async {
    if (_countdown > 0) return;
    try {
      await ref.read(authRepositoryProvider).requestOtp(widget.phone);
      if (mounted) {
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إعادة إرسال الكود', style: GoogleFonts.cairo()),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ', style: GoogleFonts.cairo(color: Colors.white)),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayPhone = PhoneUtils.normalize(widget.phone);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'تحقق من واتساب على $displayPhone',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'بعتنالك كود على الواتساب',
                style: GoogleFonts.cairo(fontSize: 14, color: AppColors.slate),
              ),
              const SizedBox(height: 32),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _codeController,
                keyboardType: TextInputType.number,
                textStyle: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 52,
                  fieldWidth: 44,
                  activeColor: AppColors.gold,
                  selectedColor: AppColors.gold,
                  inactiveColor: AppColors.divider,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                ),
                enableActiveFill: true,
                animationType: AnimationType.fade,
                animationDuration: const Duration(milliseconds: 200),
                onCompleted: (_) => _verify(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 57,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
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
                          'تأكيد الكود',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لم يصلك الكود؟',
                    style: GoogleFonts.cairo(color: AppColors.slate, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: _countdown > 0 ? null : _resend,
                    child: Text(
                      _countdown > 0 ? 'إعادة الإرسال ($_countdown)' : 'إعادة الإرسال',
                      style: GoogleFonts.cairo(
                        color: _countdown > 0 ? AppColors.divider : AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
