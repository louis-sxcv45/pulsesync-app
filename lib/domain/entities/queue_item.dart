enum SyncStatus { pending, retrying, synced, failed }

enum NetworkMode { online, unstable, offline }

enum SignalLevel { normal, warning, critical }

SignalLevel signalLevelOf(double dbm) {
  if (dbm >= -22.0) return SignalLevel.normal;
  if (dbm >= -27.0) return SignalLevel.warning;
  return SignalLevel.critical;
}

class QueueItem {
  const QueueItem({
    required this.id,
    required this.odpId,
    required this.signalDbm,
    required this.category,
    required this.note,
    required this.status,
    required this.retryCount,
    required this.createdAt,
    this.syncedAt,
  });

  final String id;
  final String odpId;
  final double signalDbm;
  final String category;
  final String note;
  final SyncStatus status;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? syncedAt;

  bool get isOpen =>
      status == SyncStatus.pending || status == SyncStatus.retrying;

  QueueItem copyWith({
    SyncStatus? status,
    int? retryCount,
    DateTime? syncedAt,
  }) =>
      QueueItem(
        id: id,
        odpId: odpId,
        signalDbm: signalDbm,
        category: category,
        note: note,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        createdAt: createdAt,
        syncedAt: syncedAt ?? this.syncedAt,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'odp_id': odpId,
        'signal_dbm': signalDbm,
        'category': category,
        'note': note,
        'status': status.name,
        'retry_count': retryCount,
        'created_at': createdAt.millisecondsSinceEpoch,
        'synced_at': syncedAt?.millisecondsSinceEpoch,
      };

  factory QueueItem.fromMap(Map<String, Object?> m) => QueueItem(
        id: m['id'] as String,
        odpId: m['odp_id'] as String,
        signalDbm: (m['signal_dbm'] as num).toDouble(),
        category: m['category'] as String,
        note: m['note'] as String,
        status: SyncStatus.values.byName(m['status'] as String),
        retryCount: m['retry_count'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
        syncedAt: m['synced_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['synced_at'] as int),
      );
}
