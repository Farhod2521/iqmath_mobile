class AuthPageArgs {
  const AuthPageArgs();
  factory AuthPageArgs.initial() {
    return AuthPageArgs();
  }
}

class OtpPageArgs {
  final String phoneNumber;
  final bool reset;

  const OtpPageArgs({required this.phoneNumber, required this.reset});
}
