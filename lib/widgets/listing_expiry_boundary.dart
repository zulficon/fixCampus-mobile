import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// En yakın süre sınırında ve uygulamaya dönüldüğünde zamanı yeniden değerlendirir.
class ListingExpiryBoundary extends StatefulWidget {
  const ListingExpiryBoundary({
    super.key,
    required this.items,
    required this.builder,
    this.onExpiry,
    this.clock = DateTime.now,
  });
  final List<Ilan> items;
  final Widget Function(BuildContext, DateTime) builder;
  final Future<void> Function()? onExpiry;
  final DateTime Function() clock;
  @override
  State<ListingExpiryBoundary> createState() => _ListingExpiryBoundaryState();
}

class _ListingExpiryBoundaryState extends State<ListingExpiryBoundary>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime? _deadline;
  late DateTime _now;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = widget.clock();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant ListingExpiryBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    _now = widget.clock();
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final dates =
        widget.items
            .where((i) => i.tur == IlanTuru.sosyal)
            .map((i) => i.bulusmaTarihi)
            .whereType<DateTime>()
            .where((date) => date.isAfter(_now))
            .toList()
          ..sort();
    _deadline = dates.isEmpty ? null : dates.first;
    if (_deadline == null) return;
    final remaining = _deadline!.difference(_now);
    _timer = Timer(
      remaining > const Duration(minutes: 1)
          ? const Duration(minutes: 1)
          : remaining,
      _tick,
    );
  }

  void _tick({bool resumed = false}) {
    if (!mounted) return;
    final now = widget.clock();
    final crossed = _deadline != null && !now.isBefore(_deadline!);
    setState(() => _now = now);
    _schedule();
    if (crossed || resumed) {
      final callback = widget.onExpiry;
      if (callback != null) unawaited(callback());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick(resumed: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _now);
}
