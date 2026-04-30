// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$configServiceHash() => r'3a58b4e353f830684d7aae159613eb46326ab0ca';

/// Provider singleton para ConfigService
///
/// Copied from [configService].
@ProviderFor(configService)
final configServiceProvider = Provider<ConfigService>.internal(
  configService,
  name: r'configServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$configServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConfigServiceRef = ProviderRef<ConfigService>;
String _$apiServiceNotifierHash() =>
    r'759cf3be46114dff7837abbb0d4996b690be4193';

/// Provider singleton para ApiService (Notifier)
///
/// Copied from [ApiServiceNotifier].
@ProviderFor(ApiServiceNotifier)
final apiServiceNotifierProvider =
    NotifierProvider<ApiServiceNotifier, ApiService>.internal(
      ApiServiceNotifier.new,
      name: r'apiServiceNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$apiServiceNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ApiServiceNotifier = Notifier<ApiService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
