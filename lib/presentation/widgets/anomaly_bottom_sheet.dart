import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/queue_item.dart';
import '../providers/queue_provider.dart';
import '../providers/telemetry_provider.dart';
import '../resources/colors_manager.dart';
import '../resources/font_manager.dart';
import '../resources/values_manager.dart';

Future<void> showAnomalySheet(BuildContext context) {
  final snapshot = context.read<TelemetryProvider>().value;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ColorsManager.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => AnomalySheet(snapshot: snapshot),
  );
}

class AnomalySheet extends StatefulWidget {
  const AnomalySheet({super.key, required this.snapshot});
  final double snapshot;

  @override
  State<AnomalySheet> createState() => _AnomalySheetState();
}

class _AnomalySheetState extends State<AnomalySheet> {
  final _formKey = GlobalKey<FormState>();
  final _odpCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _category;

  @override
  void dispose() {
    _odpCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final queue = context.read<QueueProvider>();
    final odp = _odpCtrl.text.trim();
    final note = _noteCtrl.text.trim();
    final category = _category!;
    Navigator.of(context).pop();
    queue.add(
      odpId: odp,
      signalDbm: widget.snapshot,
      category: category,
      note: note,
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = signalLevelOf(widget.snapshot);
    final color = ColorsManager.forLevel(level);
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSize.s16, AppSize.s16, AppSize.s16,
          MediaQuery.of(context).viewInsets.bottom + AppSize.s16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Catat Anomali Lapangan', style: FontManager.title),
              const SizedBox(height: AppSize.s16),
              TextFormField(
                controller: _odpCtrl,
                textCapitalization: TextCapitalization.characters,
                style: FontManager.monoSmall,
                decoration: const InputDecoration(
                    labelText: 'ID ODP / PERANGKAT',
                    hintText: 'ODP-MDN-042',
                    border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().length < 4)
                    ? 'Minimal 4 karakter'
                    : null,
              ),
              const SizedBox(height: AppSize.s12),
              InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'NILAI REDAMAN TERKUNCI (STREAM SNAPSHOT)',
                    border: OutlineInputBorder()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${widget.snapshot.toStringAsFixed(1)} dBm',
                        style: FontManager.monoSmall.copyWith(color: color)),
                    Text(level.name.toUpperCase(),
                        style: FontManager.label.copyWith(color: color)),
                  ],
                ),
              ),
              const SizedBox(height: AppSize.s12),
              DropdownButtonFormField<String>(
                value: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: 'KATEGORI KERUSAKAN / ANOMALI',
                    border: OutlineInputBorder()),
                items: [
                  for (final c in AppStrings.categories)
                    DropdownMenuItem(value: c, child: Text(c))
                ],
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: AppSize.s12),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'CATATAN LAPANGAN',
                    border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Catatan teknis wajib diisi'
                    : null,
              ),
              const SizedBox(height: AppSize.s16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Simpan ke Antrean Lokal (Auto-Sync)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
