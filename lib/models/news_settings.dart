import 'package:country_list/country_list.dart';

class NewsSettings {
  List<String> cities;
  List<String> countries;
  List<String> interests;
  bool wantsCities;
  bool wantsCountries;
  bool wantsInterests;

  // Predefined lists
  List<String> predefinedCities = [
    'New York',
    'Mexico',
    'Toronto',
    'Basel',
    'Lausanne',
    'Paris',
    'Rome',
    'Berlin',
    'Moscow'
  ];
  List<String> predefinedCountries = Countries.list.map((c) => c.name).toList();
  List<String> predefinedInterests = [
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
  });

  factory NewsSettings.defaults() {
    return NewsSettings(
      cities: [],
      countries: [],
      interests: [],
      wantsCities: false,
      wantsCountries: false,
      wantsInterests: false,
    );
  }
}
