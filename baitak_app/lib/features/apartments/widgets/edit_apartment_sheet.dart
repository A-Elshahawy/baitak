import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/apartment.dart';
import '../../../core/theme/colors.dart';
import '../repo/apartments_repository.dart';

class EditApartmentSheet extends ConsumerStatefulWidget {
  const EditApartmentSheet({super.key, required this.apt});

  final Apartment apt;

  @override
  ConsumerState<EditApartmentSheet> createState() =>
      _EditApartmentSheetState();
}

class _EditApartmentSheetState extends ConsumerState<EditApartmentSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _floorController;
  late String _selectedArea;
  bool _isLoading = false;

  // Rooms editing state
  late List<_EditableRoom> _rooms;

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
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController(text: widget.apt.name);
    _addressController = TextEditingController(text: widget.apt.address);
    _floorController =
        TextEditingController(text: widget.apt.floor.toString());
    _selectedArea = _areas.contains(widget.apt.area)
        ? widget.apt.area
        : _areas.first;
    _rooms = widget.apt.rooms
        .map((r) => _EditableRoom.fromRoom(r))
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _floorController.dispose();
    for (final r in _rooms) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(apartmentsRepositoryProvider);

      // Update apt info
      await repo.updateApartment(
        widget.apt.id,
        name: _nameController.text.trim(),
        area: _selectedArea,
        address: _addressController.text.trim(),
        floor: int.tryParse(_floorController.text) ?? widget.apt.floor,
      );

      // Process room changes
      for (final editRoom in _rooms) {
        if (editRoom.isNew) {
          final roomData = await repo.createRoom(
            widget.apt.id,
            name: editRoom.nameController.text.trim(),
            orderIndex: editRoom.orderIndex,
          );
          final roomId = roomData['id'] as int;
          for (final editBed in editRoom.beds) {
            if (editBed.isNew) {
              await repo.createBed(roomId,
                  label: editBed.labelController.text.trim(),
                  priceMonthly:
                      int.tryParse(editBed.priceController.text) ?? 0);
            }
          }
        } else {
          if (editRoom.nameController.text.trim() != editRoom.originalName) {
            await repo.updateRoom(editRoom.id!,
                name: editRoom.nameController.text.trim());
          }
          for (final editBed in editRoom.beds) {
            if (editBed.isNew) {
              await repo.createBed(editRoom.id!,
                  label: editBed.labelController.text.trim(),
                  priceMonthly:
                      int.tryParse(editBed.priceController.text) ?? 0);
            } else if (editBed.toDelete) {
              await repo.deleteBed(editBed.id!);
            } else {
              if (editBed.labelController.text.trim() !=
                      editBed.originalLabel ||
                  editBed.priceController.text != editBed.originalPrice) {
                await repo.updateBed(editBed.id!,
                    label: editBed.labelController.text.trim(),
                    priceMonthly:
                        int.tryParse(editBed.priceController.text));
              }
            }
          }
        }
      }

      // Handle deleted rooms
      for (final deletedRoomId in _deletedRoomIds) {
        await repo.deleteRoom(deletedRoomId);
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

  final List<int> _deletedRoomIds = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        'تعديل الشقة',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.slate),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.gold,
                  unselectedLabelColor: AppColors.slate,
                  indicatorColor: AppColors.gold,
                  labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: GoogleFonts.cairo(),
                  tabs: const [
                    Tab(text: 'البيانات الأساسية'),
                    Tab(text: 'الغرف والأسرة'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AptInfoTab(
                  nameController: _nameController,
                  addressController: _addressController,
                  floorController: _floorController,
                  selectedArea: _selectedArea,
                  areas: _areas,
                  onAreaChanged: (v) =>
                      setState(() => _selectedArea = v!),
                ),
                _RoomsTab(
                  rooms: _rooms,
                  onAddRoom: () {
                    setState(() {
                      _rooms.add(_EditableRoom.newRoom(
                        name: 'غرفة ${_rooms.length + 1}',
                        orderIndex: _rooms.length,
                      ));
                    });
                  },
                  onDeleteRoom: (i) {
                    setState(() {
                      final room = _rooms[i];
                      if (!room.isNew && room.id != null) {
                        _deletedRoomIds.add(room.id!);
                      }
                      room.dispose();
                      _rooms.removeAt(i);
                    });
                  },
                  onAddBed: (roomIdx) {
                    setState(() {
                      _rooms[roomIdx].beds.add(_EditableBed.newBed(
                          label: 'سرير جديد', price: 1000));
                    });
                  },
                  onDeleteBed: (roomIdx, bedIdx) {
                    setState(() {
                      final bed = _rooms[roomIdx].beds[bedIdx];
                      if (!bed.isNew) {
                        bed.toDelete = true;
                      } else {
                        bed.dispose();
                        _rooms[roomIdx].beds.removeAt(bedIdx);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              height: 57,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('حفظ التعديلات',
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _EditableRoom {
  final int? id;
  final bool isNew;
  final String originalName;
  final int orderIndex;
  final TextEditingController nameController;
  final List<_EditableBed> beds;

  _EditableRoom({
    this.id,
    required this.isNew,
    required this.originalName,
    required this.orderIndex,
    required this.nameController,
    required this.beds,
  });

  factory _EditableRoom.fromRoom(Room room) {
    return _EditableRoom(
      id: room.id,
      isNew: false,
      originalName: room.name,
      orderIndex: room.orderIndex,
      nameController: TextEditingController(text: room.name),
      beds: room.beds.map((b) => _EditableBed.fromBed(b)).toList(),
    );
  }

  factory _EditableRoom.newRoom({required String name, required int orderIndex}) {
    return _EditableRoom(
      id: null,
      isNew: true,
      originalName: name,
      orderIndex: orderIndex,
      nameController: TextEditingController(text: name),
      beds: [_EditableBed.newBed(label: 'سرير أ', price: 1000)],
    );
  }

  void dispose() {
    nameController.dispose();
    for (final b in beds) {
      b.dispose();
    }
  }
}

class _EditableBed {
  final int? id;
  final bool isNew;
  final String originalLabel;
  final String originalPrice;
  final TextEditingController labelController;
  final TextEditingController priceController;
  bool toDelete;

  _EditableBed({
    this.id,
    required this.isNew,
    required this.originalLabel,
    required this.originalPrice,
    required this.labelController,
    required this.priceController,
    this.toDelete = false,
  });

  factory _EditableBed.fromBed(Bed bed) {
    return _EditableBed(
      id: bed.id,
      isNew: false,
      originalLabel: bed.label,
      originalPrice: bed.priceMonthly.toString(),
      labelController: TextEditingController(text: bed.label),
      priceController:
          TextEditingController(text: bed.priceMonthly.toString()),
    );
  }

  factory _EditableBed.newBed({required String label, required int price}) {
    return _EditableBed(
      id: null,
      isNew: true,
      originalLabel: label,
      originalPrice: price.toString(),
      labelController: TextEditingController(text: label),
      priceController: TextEditingController(text: price.toString()),
    );
  }

  void dispose() {
    labelController.dispose();
    priceController.dispose();
  }
}

class _AptInfoTab extends StatelessWidget {
  const _AptInfoTab({
    required this.nameController,
    required this.addressController,
    required this.floorController,
    required this.selectedArea,
    required this.areas,
    required this.onAreaChanged,
  });

  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController floorController;
  final String selectedArea;
  final List<String> areas;
  final ValueChanged<String?> onAreaChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            style: GoogleFonts.cairo(),
            decoration: const InputDecoration(labelText: 'اسم الشقة'),
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
            decoration: const InputDecoration(labelText: 'العنوان'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: floorController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.cairo(),
            decoration: const InputDecoration(labelText: 'رقم الدور'),
          ),
        ],
      ),
    );
  }
}

class _RoomsTab extends StatelessWidget {
  const _RoomsTab({
    required this.rooms,
    required this.onAddRoom,
    required this.onDeleteRoom,
    required this.onAddBed,
    required this.onDeleteBed,
  });

  final List<_EditableRoom> rooms;
  final VoidCallback onAddRoom;
  final void Function(int roomIndex) onDeleteRoom;
  final void Function(int roomIndex) onAddBed;
  final void Function(int roomIndex, int bedIndex) onDeleteBed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...rooms.asMap().entries.map((entry) {
          final i = entry.key;
          final room = entry.value;
          final visibleBeds =
              room.beds.where((b) => !b.toDelete).toList();
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: room.nameController,
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            labelText: 'اسم الغرفة',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.red, size: 18),
                        onPressed: () => onDeleteRoom(i),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...visibleBeds.asMap().entries.map((bEntry) {
                    final bi = bEntry.key;
                    final bed = bEntry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.bed_outlined,
                              color: AppColors.slate, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: bed.labelController,
                              style: GoogleFonts.cairo(fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: 'اسم السرير',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: bed.priceController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.cairo(fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: 'السعر',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppColors.red, size: 16),
                            onPressed: () => onDeleteBed(i, bi),
                          ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: () => onAddBed(i),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('إضافة سرير',
                        style:
                            GoogleFonts.cairo(fontSize: 13)),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.blue),
                  ),
                ],
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: const BorderSide(color: AppColors.gold),
            minimumSize: const Size.fromHeight(49),
          ),
          icon: const Icon(Icons.add),
          label: Text('إضافة غرفة', style: GoogleFonts.cairo()),
          onPressed: onAddRoom,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
