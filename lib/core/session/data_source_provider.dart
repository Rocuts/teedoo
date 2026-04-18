// Riverpod provider for the currently selected [DataSource].
//
// Scope: session-only. Value is reset to [DataSource.mongo] on every cold
// start — we DO NOT persist it to disk. Rationale: the selector is a demo
// tool ("served by X"), and a stale persisted value could mislead a user on
// first load. If persistence is required later, do it behind a feature flag.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data_source.dart';

/// In-memory active backend. Default: [DataSource.mongo].
///
/// Reads:
///   final ds = ref.watch(dataSourceProvider);
///
/// Writes:
///   ref.read(dataSourceProvider.notifier).state = DataSource.postgres;
final dataSourceProvider = StateProvider<DataSource>(
  (ref) => DataSource.mongo,
);
