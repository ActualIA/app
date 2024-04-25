import 'package:actualia/views/source_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Check every element of source view is present and working",
      (tester) async {
    const String article =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in"
        " reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in "
        "culpa qui officia deserunt mollit anim id est laborum.Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque "
        "laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. "
        "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione "
        "voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia"
        " non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum "
        "exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in "
        "ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?At vero eos et accusamus "
        "et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati "
        "cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis "
        "est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, "
        "omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et "
        "voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias "
        "consequatur aut perferendis doloribus asperiores repellat.In efficitur diam eget felis mollis ornare. Quisque lacinia iaculis consectetur. Etiam et ante"
        " rhoncus, faucibus nisi consectetur, vulputate purus. Pellentesque sem ex, venenatis vitae lobortis sed, aliquet vitae justo. Suspendisse sodales arcu "
        "sed nisl laoreet, ac fermentum ex blandit. Morbi commodo laoreet erat et feugiat.Vivamus non aliquam nibh, placerat maximus dolor. Aenean sit amet "
        "facilisis sem. In massa urna, rutrum eu turpis a";
    const String title = "lorem ipsum dolor sit amet, consectetur";
    const String newsPaper = "https://dummy.com";
    const String date = "1111-11-11";

    //init SourceView
    await tester.pumpWidget(MaterialApp(
        title: 'ActualIA',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SourceView(
            article: article, title: title, date: date, newsPaper: newsPaper)));

    //check topBar
    expect(find.text("ActualIA"), findsOne);

    //check article origin
    expect(find.text("Article from $newsPaper,"), findsOne);
    expect(find.text("Published on $date"), findsOne);

    //check title
    expect(find.text("Title of the article : $title"), findsOne);

    //check article is present and scrollable
    await tester.scrollUntilVisible(find.text(article), 5, scrollable: null);
  });
}
