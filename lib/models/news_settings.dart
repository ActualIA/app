import 'package:country_list/country_list.dart';

class NewsSettings {
  List<String> cities;
  List<String> countries;
  List<String> interests;
  bool wantsCities;
  bool wantsCountries;
  bool wantsInterests;

  bool onboardingNeeded;

  // Predefined lists
  static List<String> predefinedCities = ['City 1', 'City 2', 'City 3'];
  static List<String> predefinedCountries =
      Countries.list.map((c) => c.name).toList();
  static List<String> predefinedInterests = [
    'Sports',
    'Music',
    'Politics',
    'Gaming',
    'E-sports',
    'Research',
    'Physics',
    'Biology',
    'Math',
    'People',
    'Events',
  ];

  NewsSettings({
    required this.cities,
    required this.countries,
    required this.interests,
    required this.wantsCities,
    required this.wantsCountries,
    required this.wantsInterests,
    required this.onboardingNeeded,
  });

  factory NewsSettings.defaults() {
    return NewsSettings(
      cities: predefinedCities,
      countries: predefinedCountries,
      interests: predefinedInterests,
      wantsCities: false,
      wantsCountries: false,
      wantsInterests: false,
      onboardingNeeded: false, // wait before setting this to true
    );
  }
}
