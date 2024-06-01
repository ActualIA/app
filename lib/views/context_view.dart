import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/news_recognition.dart';
import 'package:actualia/views/loading_view.dart';
import 'package:actualia/widgets/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ContextView extends StatelessWidget {
  const ContextView({super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    NewsRecognitionViewModel nrvm =
        Provider.of<NewsRecognitionViewModel>(context);

    Widget body;
    if (nrvm.isProcessing) {
      return LoadingView(text: loc.ocrLoadingText);
    } else if (nrvm.hasError) {
      body = ErrorDisplayWidget(
          title: loc.errorTitle, description: nrvm.getErrorMessage(loc));
    } else if (nrvm.result == null) {
      nrvm.takePictureAndProcess();
      body = ErrorDisplayWidget(
          title: loc.errorTitle, description: loc.ocrErrorNoImage);
    } else {
      body = ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
              padding: const EdgeInsets.fromLTRB(
                  UNIT_PADDING * 2, UNIT_PADDING * 2, UNIT_PADDING * 2, 0),
              child: Text(
                loc.newsContextHeading,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(height: 1.2),
              )),
          Container(
              padding: const EdgeInsets.all(UNIT_PADDING * 2),
              child: Text(nrvm.result!,
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center)),
        ],
      );
    }

    return Container(
        padding: const EdgeInsets.all(UNIT_PADDING),
        child: Stack(
          children: [
            body,
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton.filledTonal(
                iconSize: 40,
                onPressed: () => nrvm.takePictureAndProcess(),
                icon: Container(
                    padding: const EdgeInsets.all(UNIT_PADDING / 4),
                    child: const Icon(Icons
                        .sync_outlined)), // Chosen because it represents the act of doing an action again, which here is the case because they have to take a new picture
                color: THEME_BUTTON,
              ),
            )
          ],
        ));
  }
}
