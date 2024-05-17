class Secret {
  final String secret;
  final String sign;

  const Secret({
    required this.secret,
    required this.sign,
  });

  Map<String, Object?> toMap() {
    return {
      'secret': secret,
      'sign': sign,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'items{secret: $secret, sign: $sign}';
  }
}