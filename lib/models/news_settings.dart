class NewsSettings {
  List<String> cities;
  List<String> countries;
  List<String> interests;
  bool wantsCities;
  bool wantsCountries;
  bool wantsInterests;

  // Predefined lists
  static List<String> predefinedCities = ['City 1', 'City 2', 'City 3'];
  static List<String> predefinedCountries = [
    'Country 1',
    'Country 2',
    'Country 3'
  ];
  static List<String> predefinedInterests = [
    'Interest 1',
    'Interest 2',
    'Interest 3'
  ];

  NewsSettings({
    required this.cities,
    required this.countries,
    required this.interests,
    required this.wantsCities,
    required this.wantsCountries,
    required this.wantsInterests,
  });

  factory NewsSettings.defaults() {
    return NewsSettings(
      cities: predefinedCities,
      countries: predefinedCountries,
      interests: predefinedInterests,
      wantsCities: false,
      wantsCountries: false,
      wantsInterests: false,
    );
  }
}
