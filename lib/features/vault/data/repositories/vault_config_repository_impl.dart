import 'package:isar/isar.dart';

import 'package:marky/features/vault/domain/repositories/vault_config_repository.dart';
import 'package:marky/shared/models/vault_config.dart';

/// Isar-backed implementation of [VaultConfigRepository].
///
/// Expects [isar] to be an open database instance that includes
/// [VaultConfigSchema].
class VaultConfigRepositoryImpl implements VaultConfigRepository {
  VaultConfigRepositoryImpl({required Isar isar}) : _isar = isar;

  final Isar _isar;

  static const Id _configId = 0;

  @override
  Future<VaultConfig?> getConfig() async {
    return _isar.vaultConfigs.get(_configId);
  }

  @override
  Future<void> saveConfig(VaultConfig config) async {
    config.id = _configId;
    await _isar.writeTxn(() async {
      await _isar.vaultConfigs.put(config);
    });
  }

  @override
  Future<void> deleteConfig() async {
    await _isar.writeTxn(() async {
      await _isar.vaultConfigs.delete(_configId);
    });
  }
}
