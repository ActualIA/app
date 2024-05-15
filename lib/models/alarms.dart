class Alarms {
  bool enabled;
  int id;

  Alarms({
    required this.enabled,
    required this.id,
  });

  factory Alarms.defaults() {
    return Alarms(
      enabled: false,
      id: 1,
    );
  }
}
