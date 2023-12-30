import 'dart:async';

mixin Validator {
  static final RegExp _emailValidation = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

// validate the stream email
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if (_emailValidation.hasMatch(email)) {
        sink.add(email);
      } else {
        sink.addError('Enter a valid email!');
      }
    },
  );

  // validate the stream email
  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (password.length >= 8) {
        sink.add(password);
      } else {
        sink.addError('Password must be at least 7 characters!');
      }
    },
  );
}
