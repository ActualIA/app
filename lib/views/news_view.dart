import 'package:flutter/material.dart';
import 'package:actualia/widgets/news_text.dart';
import 'package:actualia/widgets/top_app_bar.dart';

class NewsView extends StatelessWidget {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    String title =
        'Breaking News in AGEPoly: Lecoeur démission. Longue Vie A l\'AVPSAO.'; // Replace value with actual data
    String date = 'Fri, February 23rd'; // Replace value with actual data
    String text1 =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce sit amet metus nibh. Nam ultricies lectus vitae tortor consectetur, quis elementum neque molestie. In vitae neque sollicitudin felis blandit fringilla. Nunc id tempus metus. Donec vitae hendrerit odio. Nunc sagittis sit amet libero a auctor. Duis quis mollis velit. Nulla semper auctor augue, id bibendum est vulputate et. Integer in est in justo rutrum viverra. Nullam vestibulum suscipit dictum. Etiam in pretium sapien. Ut quis fermentum metus, quis luctus ligula. Morbi magna dolor, rhoncus non diam eu, ornare placerat nunc. Aenean et libero porttitor, malesuada quam et, imperdiet tortor. Mauris tincidunt leo quis erat semper lacinia.'; // Replace value with actual data
    String text2 =
        'Integer faucibus diam magna, non ornare mauris commodo sed. Nullam posuere convallis est id viverra. Donec tincidunt enim eget arcu feugiat condimentum. In eleifend in lorem vel congue. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin consequat scelerisque tincidunt. Maecenas tempor erat non faucibus tincidunt.';
    String text3 =
        'Etiam orci urna, faucibus vitae imperdiet eget, condimentum eget ligula. Pellentesque non sapien nec erat interdum luctus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque euismod, ipsum id commodo ultricies, orci sem luctus dolor, sed sodales nibh nisl non ante. Sed laoreet, elit ut tincidunt cursus, augue dui sodales erat, in tristique libero magna pharetra odio. Etiam lorem metus, euismod eu nulla non, malesuada gravida velit. Nam odio tortor, luctus eget sodales in, laoreet in neque. Quisque congue a ligula ut efficitur. Ut pulvinar commodo hendrerit. Nulla facilisi. Vivamus sit amet augue nulla. Vivamus porta faucibus mauris nec mattis. Aliquam dignissim rhoncus magna, eget cursus nisi commodo et.';

    List<Map<String, dynamic>> newsList = [
      {
        'title': title,
        'date': date,
        'paragraphs': [
          Paragraph(text: text1, source: 'source1'),
          Paragraph(text: text2, source: 'source2'),
          Paragraph(text: text3, source: 'source3')
        ],
      },
      {
        'title': 'A second title but shorter this time.',
        'date': date,
        'paragraphs': [
          Paragraph(text: text3, source: 'source3'),
          Paragraph(text: text2, source: 'source2')
        ],
      },
    ];

    bool gotNews = newsList.isNotEmpty;

    Widget body = gotNews
        ? ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              var news = newsList[index];
              return NewsText(
                title: news['title']!,
                date: news['date']!,
                paragraphs: news['paragraphs'] as List<Paragraph>,
              );
            },
          )
        : const Center(
            child: Text(
              'You don\'t have any news yet',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: 'EB Garamond',
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          );

    return Scaffold(
      appBar: const TopAppBar(),
      body: body,
    );
  }
}
