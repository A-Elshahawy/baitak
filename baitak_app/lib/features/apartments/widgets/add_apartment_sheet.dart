import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../repo/apartments_repository.dart';

class AddApartmentSheet extends ConsumerStatefulWidget {
  const AddApartmentSheet({super.key});

  @override
  ConsumerState<AddApartmentSheet> createState() => _AddApartmentSheetState();
}

class _RoomEntry {
  String name;
  int bedCount;
  int price;
  TextEditingController nameController;
  TextEditingController priceController;

  _RoomEntry({
    required this.name,
    required this.bedCount,
    required this.price,
  })  : nameController = TextEditingController(text: name),
        priceController = TextEditingController(text: price.toString());

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}

class _AddApartmentSheetState extends ConsumerState<AddApartmentSheet> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _floorController = TextEditingController(text: '1');

  int _currentStep = 0;
  String _selectedArea = 'الحي السادس';
  final List<_RoomEntry> _rooms = [];
  bool _isLoading = false;

  static const List<String> _areas = [
    'الحي السادس',
    'الحي الأول',
    'دريم لاند',
    'المحور',
    'بيفرلي هيلز',
    'أرابيلا',
    'الشيخ زايد',
  ];

  @override
  void initState() {
    super.initState();
    _rooms.add(_RoomEntry(name: 'غرفة ١', bedCount: 2, price: 1000));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _floorController.dispose();
    for (final r in _rooms) {
      r.dispose();
    }
    super.dispose();
  }

  int get _totalBeds => _rooms.fold(0, (s, r) => s + r.bedCount);
  int get _totalRevenue => _rooms.fold(
      0, (s, r) => s + r.bedCount * (int.tryParse(r.priceController.text) ?? r.price));

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(apartmentsRepositoryProvider);
      final apt = await repo.createApartment(
        name: _nameController.text.trim(),
        area: _selectedArea,
        address: _addressController.text.trim(),
        floor: int.tryParse(_floorController.text) ?? 1,
      );

      for (var i = 0; i < _rooms.length; i++) {
        final room = _rooms[i];
        final roomData = await repo.createRoom(
          apt.id,
          name: room.nameController.text.trim(),
          orderIndex: i,
        );
        final roomId = roomData['id'] as int;
        for (var j = 0; j < room.bedCount; j++) {
          final bedLabels = ['أ', 'ب', 'ج', 'د', 'هـ', 'و'];
          final label =
              j < bedLabels.length ? 'سرير ${bedLabels[j]}' : 'سرير ${j + 1}';
          await repo.createBed(roomId,
              label: label,
              priceMonthly: int.tryParse(room.priceController.text) ?? room.price);
        }
      }

      ref.invalidate(apartmentsListProvider);
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            currentStep: _currentStep,
            onClose: () => Navigator.of(context).pop(),
            onBack: _currentStep > 0
                ? () => setState(() => _currentStep--)
                : null,
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
        return _AptInfoStep(
          nameController: _nameController,
          addressController: _addressController,
          floorController: _floorController,
          selectedArea: _selectedArea,
          areas: _areas,
          onAreaChanged: (v) => setState(() => _selectedArea = v!),
          onNext: () {
            if (_nameController.text.trim().isNotEmpty) {
              setState(() => _currentStep = 1);
            }
          },
        );
      case 1:
        return _RoomsStep(
          rooms: _rooms,
          totalBeds: _totalBeds,
          totalRevenue: _totalRevenue,
          onPriceChange: (i, price) => setState(() => _rooms[i].price = price),
          onAddRoom: () {
            setState(() {
              final n = _rooms.length + 1;
              final labels = ['١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
              final label = n <= labels.length ? labels[n - 1] : n.toString();
              _rooms.add(_RoomEntry(
                  name: 'غرفة $label', bedCount: 2, price: 1000));
            });
          },
          onRemoveRoom: _rooms.length > 1
              ? (i) {
                  setState(() {
                    _rooms[i].dispose();
                    _rooms.removeAt(i);
                  });
                }
              : null,
          onBedCountChange: (i, count) {
            setState(() => _rooms[i].bedCount = count);
          },
          onReview: () => setState(() => _currentStep = 2),
        );
      case 2:
        return _ReviewStep(
          name: _nameController.text.trim(),
          area: _selectedArea,
          address: _addressController.text.trim(),
          floor: int.tryParse(_floorController.text) ?? 1,
          rooms: _rooms,
          totalRevenue: _totalRevenue,
          isLoading: _isLoading,
          onSave: _save,
        );
      default:
        return const SizedBox();
    }
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.currentStep,
    required this.onClose,
    this.onBack,
  });

  final int currentStep;
  final VoidCallback onClose;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
              onPressed: onBack,
              color: AppColors.slate,
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          Row(
            children: List.generate(3, (i) {
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
                  if (i < 2) const SizedBox(width: 4),
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

class _AptInfoStep extends StatelessWidget {
  const _AptInfoStep({
    required this.nameController,
    required this.addressController,
    required this.floorController,
    required this.selectedArea,
    required this.areas,
    required this.onAreaChanged,
    required this.onNext,
  });

  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController floorController;
  final String selectedArea;
  final List<String> areas;
  final ValueChanged<String?> onAreaChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بيانات الشقة',
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
              labelText: 'اسم الشقة *',
              prefixIcon:
                  Icon(Icons.apartment_rounded, color: AppColors.slate),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedArea,
            decoration: InputDecoration(
              labelText: 'المنطقة',
              labelStyle: GoogleFonts.cairo(color: AppColors.slate),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.gold, width: 2),
              ),
            ),
            items: areas
                .map((a) => DropdownMenuItem(
                    value: a,
                    child: Text(a, style: GoogleFonts.cairo())))
                .toList(),
            onChanged: onAreaChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: addressController,
            style: GoogleFonts.cairo(),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'العنوان',
              prefixIcon:
                  Icon(Icons.location_on_outlined, color: AppColors.slate),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: floorController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.cairo(),
            decoration: const InputDecoration(
              labelText: 'رقم الدور',
              prefixIcon:
                  Icon(Icons.layers_outlined, color: AppColors.slate),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
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

class _RoomsStep extends StatelessWidget {
  const _RoomsStep({
    required this.rooms,
    required this.totalBeds,
    required this.totalRevenue,
    required this.onAddRoom,
    required this.onRemoveRoom,
    required this.onBedCountChange,
    required this.onPriceChange,
    required this.onReview,
  });

  final List<_RoomEntry> rooms;
  final int totalBeds;
  final int totalRevenue;
  final VoidCallback onAddRoom;
  final void Function(int index)? onRemoveRoom;
  final void Function(int index, int count) onBedCountChange;
  final void Function(int index, int price) onPriceChange;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            shrinkWrap: true,
            itemCount: rooms.length,
            itemBuilder: (ctx, i) {
              final room = rooms[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: room.nameController,
                              style: GoogleFonts.cairo(),
                              decoration: InputDecoration(
                                labelText: 'اسم الغرفة',
                                labelStyle: GoogleFonts.cairo(
                                    color: AppColors.slate,
                                    fontSize: 12),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.divider),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.divider),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.gold, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          if (onRemoveRoom != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.red, size: 20),
                              onPressed: () => onRemoveRoom!(i),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('عدد السراير: ',
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: AppColors.slate)),
                          ...List.generate(4, (j) {
                            final count = j + 1;
                            final selected = room.bedCount == count;
                            return GestureDetector(
                              onTap: () => onBedCountChange(i, count),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 150),
                                margin: const EdgeInsets.only(left: 6),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.gold
                                      : Colors.white,
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.gold
                                        : AppColors.divider,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '$count',
                                    style: GoogleFonts.cairo(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.charcoal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: room.priceController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.cairo(),
                        onChanged: (v) => onPriceChange(i, int.tryParse(v) ?? 0),
                        decoration: InputDecoration(
                          labelText: 'سعر السرير / شهر (EGP)',
                          labelStyle: GoogleFonts.cairo(
                              color: AppColors.slate, fontSize: 12),
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppColors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppColors.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.gold, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gold,
              side: const BorderSide(color: AppColors.gold, style: BorderStyle.solid),
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add),
            label: Text('إضافة غرفة', style: GoogleFonts.cairo()),
            onPressed: onAddRoom,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.goldSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${rooms.length} غرف · $totalBeds سرير · EGP $totalRevenue/شهر',
                style: GoogleFonts.cairo(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onReview,
              child: Text('مراجعة',
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.name,
    required this.area,
    required this.address,
    required this.floor,
    required this.rooms,
    required this.totalRevenue,
    required this.isLoading,
    required this.onSave,
  });

  final String name;
  final String area;
  final String address;
  final int floor;
  final List<_RoomEntry> rooms;
  final int totalRevenue;
  final bool isLoading;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'مراجعة البيانات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ReviewRow(label: 'الاسم', value: name),
                  _ReviewRow(label: 'المنطقة', value: area),
                  _ReviewRow(label: 'العنوان', value: address.isEmpty ? '—' : address),
                  _ReviewRow(label: 'الدور', value: floor.toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...rooms.map((r) {
            final price = int.tryParse(r.priceController.text) ?? r.price;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.meeting_room_outlined,
                    color: AppColors.gold),
                title: Text(
                    r.nameController.text.isEmpty
                        ? r.name
                        : r.nameController.text,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    '${r.bedCount} سرير · EGP $price/شهر',
                    style: GoogleFonts.cairo(
                        color: AppColors.slate, fontSize: 12)),
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greenSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up_rounded,
                    color: AppColors.green, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إيراد شهري متوقع',
                        style: GoogleFonts.cairo(
                            color: AppColors.green, fontSize: 12)),
                    Text(
                      'EGP $totalRevenue',
                      style: GoogleFonts.cairo(
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('حفظ الشقة',
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                  fontSize: 13, color: AppColors.slate),
            ),
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
      ),
    );
  }
}
