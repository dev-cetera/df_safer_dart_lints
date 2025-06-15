// import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

// @mustHandleReturn
String whatIsYourName() {
  return 'Tony';
}

void main() {
  whatIsYourName(); // triggers a warning!
  print(whatIsYourName());
}
