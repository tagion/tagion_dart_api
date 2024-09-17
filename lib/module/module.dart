import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/scope/scope_interface.dart';
import 'package:tagion_dart_api/scope/scope.dart';

/// The [Module] is an abstract class.
/// Contains a [Scope] object.
abstract class Module {
  final IScope scope;

  Module(IErrorMessage errorMessage) : scope = Scope(errorMessage);
}
