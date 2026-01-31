// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_live_events.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MatchEventsStream)
const matchEventsStreamProvider = MatchEventsStreamProvider._();

final class MatchEventsStreamProvider
    extends $StreamNotifierProvider<MatchEventsStream, List<IbyMatchEvent>> {
  const MatchEventsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchEventsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchEventsStreamHash();

  @$internal
  @override
  MatchEventsStream create() => MatchEventsStream();
}

String _$matchEventsStreamHash() => r'e6bbd8c8c40cb44faa90a808e99f9196a111966e';

abstract class _$MatchEventsStream
    extends $StreamNotifier<List<IbyMatchEvent>> {
  Stream<List<IbyMatchEvent>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<IbyMatchEvent>>, List<IbyMatchEvent>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<IbyMatchEvent>>, List<IbyMatchEvent>>,
              AsyncValue<List<IbyMatchEvent>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
