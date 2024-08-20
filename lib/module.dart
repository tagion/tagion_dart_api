import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/scope.dart';

/// The [Module] is an abstract class.
/// Contains a [Scope] object.
abstract class Module {
  final Scope scope;

  Module(
    IPointerManager pointerManager,
    IErrorMessage errorMessage,
  ) : scope = Scope(
          pointerManager,
          errorMessage,
        );
}
