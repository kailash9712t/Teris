import 'package:uuid/uuid.dart';

class UUID {
  static String generateId() {
    Uuid instance = Uuid();
    return instance.v1();
  }
}
