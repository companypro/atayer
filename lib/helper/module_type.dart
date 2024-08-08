enum ModuleType {
  grocery,
}

extension CatExtension on ModuleType {

  String? get type {
    switch (this) {


      case ModuleType.grocery:
        return 'grocery';

      default:
        return null;
    }
  }

}