import 'package:equatable/equatable.dart';

/// A typed wrapper over a plain string, with no runtime cost.
///
/// An extension type is compile-time only: at runtime a `ServerId` *is* the
/// `String`. It stops a server id being passed where an incident id belongs,
/// which a bare `String` would allow. Equality and `hashCode` are the
/// string's own, so it needs no `Equatable`.
extension type const ServerId(String value);

/// A fixed set of named values. Dart enums are classes: they can carry
/// fields and methods, but every value is declared here.
enum ServerStatus { healthy, degraded, maintenance }

/// A value type. Two `Server`s with the same fields are equal.
///
/// Dart classes compare by identity unless told otherwise, so a Bloc that
/// emits a state equal in content but not `==` rebuilds the UI for nothing.
/// `Equatable` supplies `==` and `hashCode` from `props`. Every field is
/// `final` and the constructor is `const`, so an instance cannot change after
/// construction and can be a compile-time constant.
class Server extends Equatable {
  const new({
    required this.id,
    required this.name,
    this.status = ServerStatus.healthy,
  });

  final ServerId id;
  final String name;
  final ServerStatus status;

  @override
  List<Object?> get props => [id, name, status];
}
