import 'dart:developer';
import 'package:actualia/models/news.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// View model for managing news data.
class NewsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  News? _news;
  News? get news => _news;

  /// Retrieves news for the specified date.
  ///
  /// If no news is found for the given date, it checks if the date is today.
  /// If it is today, it invokes a cloud function to generate news and fetches it again.
  /// If the news is still not found, it sets an error message.
  Future<void> getNews(DateTime date) async {
    await fetchNews(date);

    if (_news == null || _news!.paragraphs.isEmpty) {
      DateTime today = DateTime.now();
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        await invokeTranscriptFunction();
        await fetchNews(date);
        if (_news == null || _news!.paragraphs.isEmpty) {
          setNewsError(date, 'News generation failed and no news found.',
              'Something went wrong while generating news. Please try again later.');
        }
      } else {
        setNewsError(date, 'No news found for this date.',
            'There are no news for you on this date.');
      }
    }
    notifyListeners();
  }

  /// Fetches news for the specified date from the database.
  Future<void> fetchNews(DateTime date) async {
    var dateString = date.toString().substring(0, 10);
    try {
      final response = await supabase
          .from('news')
          .select()
          .eq('user', supabase.auth.currentUser!.id)
          .eq('date', dateString)
          .single();

      if (response['error'] != null || response.isEmpty) {
        _news = null;
        return;
      }

      List<dynamic> newsItems = response['transcript']['news'];
      List<Paragraph> paragraphs = newsItems.map((item) {
        return Paragraph(text: item['transcript'], source: item['titre']);
      }).toList();

      _news = News(
        title: response['title'],
        date: response['date'],
        paragraphs: paragraphs,
      );
      notifyListeners();
    } catch (e) {
      log("Error fetching news: $e");
      print('Error fetching news: $e');
      _news = null;
    }
  }

  /// Invokes a cloud function to generate news transcripts.
  ///
  /// This is a simulated function call and should be replaced with an actual cloud function call.
  Future<void> invokeTranscriptFunction() async {
    try {
      // Placeholder for invoking a cloud function
      //TODO: Replace this with actual cloud function call
      await Future.delayed(const Duration(seconds: 5));
      log("Cloud function 'transcript' invoked successfully.");
    } catch (e) {
      log("Error invoking cloud function: $e");
      throw Exception("Failed to invoke transcript function");
    }
  }

  /// Sets an error message for the news.
  void setNewsError(DateTime date, String title, String message) {
    _news = News(
      date: date.toString().substring(0, 10),
      title: title,
      paragraphs: [Paragraph(text: message, source: 'System')],
    );
  }
}
