import 'package:test/test.dart';
import 'package:watchtower/watchtower.dart';

void main() {
  group(Server, () {
    test('is equal to another server with the same fields', () {
      const a = Server(id: ServerId('web-1'), name: 'web-1');
      const b = Server(id: ServerId('web-1'), name: 'web-1');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('differs when a field differs', () {
      const a = Server(id: ServerId('web-1'), name: 'web-1');
      const b = Server(
        id: ServerId('web-1'),
        name: 'web-1',
        status: ServerStatus.degraded,
      );
      expect(a, isNot(equals(b)));
    });

    test('defaults to healthy', () {
      const server = Server(id: ServerId('web-1'), name: 'web-1');
      expect(server.status, ServerStatus.healthy);
    });
  });

  group(ServerId, () {
    test('compares by its underlying string', () {
      expect(const ServerId('a'), equals(const ServerId('a')));
      expect(const ServerId('a'), isNot(equals(const ServerId('b'))));
    });
  });
}
