import 'package:one_app/app/bootstrap.dart';
import 'package:one_core/one_core.dart';

/// Entry point. Flavour and API origin come from `--dart-define`s; see the
/// workspace README.
Future<void> main() => bootstrap(OneConfig.fromEnvironment());
