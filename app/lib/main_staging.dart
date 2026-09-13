import 'package:keeper/app/app.dart';
import 'package:keeper/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
