import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:watchtower/watchtower.dart';

class _MockIncidentRepository extends Mock implements IncidentRepository;

void main() {
  group(IncidentInboxBloc, () {
    const server = Server(id: ServerId('web-1'), name: 'web-1');
    final earlier = DateTime.utc(2026, 9, 13, 9);
    final later = DateTime.utc(2026, 9, 13, 10);

    Incident incident(String id, Severity severity, DateTime raisedAt) =>
        Incident(
          id: IncidentId(id),
          server: server,
          raisedAt: raisedAt,
          spikes: [
            Spike(
              serverId: server.id,
              metric: Metric.latencyMs,
              startedAt: raisedAt,
              extent: (
                magnitude: switch (severity) {
                  Severity.low => 3.5,
                  Severity.medium => 5,
                  Severity.high => 7,
                },
                duration: 3,
              ),
            ),
          ],
        );

    late IncidentRepository repository;

    setUp(() {
      repository = _MockIncidentRepository();
    });

    test('starts in the loading state', () {
      expect(
        IncidentInboxBloc(repository: repository).state,
        const IncidentInboxLoading(),
      );
    });

    blocTest<IncidentInboxBloc, IncidentInboxState>(
      'emits loaded with an empty list when there are no incidents',
      setUp: () {
        when(() => repository.fetchIncidents()).thenAnswer((_) async => []);
      },
      build: () => IncidentInboxBloc(repository: repository),
      act: (bloc) => bloc.add(const IncidentInboxLoadRequested()),
      expect: () => const [IncidentInboxLoading(), IncidentInboxLoaded([])],
    );

    blocTest<IncidentInboxBloc, IncidentInboxState>(
      'emits failure when the repository throws',
      setUp: () {
        when(() => repository.fetchIncidents()).thenThrow(Exception('down'));
      },
      build: () => IncidentInboxBloc(repository: repository),
      act: (bloc) => bloc.add(const IncidentInboxLoadRequested()),
      expect: () => const [IncidentInboxLoading(), IncidentInboxLoadFailure()],
    );

    blocTest<IncidentInboxBloc, IncidentInboxState>(
      'orders by severity then raised-at then id',
      setUp: () {
        when(() => repository.fetchIncidents()).thenAnswer(
          (_) async => [
            incident('b', Severity.high, earlier),
            incident('a', Severity.high, earlier),
            incident('c', Severity.low, later),
            incident('d', Severity.high, later),
          ],
        );
      },
      build: () => IncidentInboxBloc(repository: repository),
      act: (bloc) => bloc.add(const IncidentInboxLoadRequested()),
      expect: () => [
        const IncidentInboxLoading(),
        IncidentInboxLoaded([
          incident('d', Severity.high, later),
          incident('a', Severity.high, earlier),
          incident('b', Severity.high, earlier),
          incident('c', Severity.low, later),
        ]),
      ],
    );
  });
}
