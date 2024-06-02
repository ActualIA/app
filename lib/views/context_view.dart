import 'dart:math';

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

    Text oldContextsTitle = Text(
      loc.newsOldContextsHeading,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(height: 1.2),
    );
    Widget body;
    Widget oldContextsHeader;
    Widget oldContexts;
    if (nrvm.isProcessing) {
      return LoadingView(text: loc.ocrLoadingText);
    } else if (nrvm.hasError) {
      body = ErrorDisplayWidget(description: nrvm.getErrorMessage(loc));
    } else if (nrvm.result == null) {
      oldContextsHeader = nrvm.contexts.isEmpty
          ? Text(loc.newsNoContextYet,
              style:
                  Theme.of(context).textTheme.titleLarge!.copyWith(height: 1.2))
          : oldContextsTitle;
      oldContexts = Container(
        padding: const EdgeInsets.symmetric(vertical: UNIT_PADDING),
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: max(nrvm.contexts.length * 2 - 1, 0),
            itemBuilder: (context, index) {
              return index.isOdd
                  ? const Divider(
                      height: UNIT_PADDING * 4,
                      thickness: 0.5,
                      indent: UNIT_PADDING * 3,
                      endIndent: UNIT_PADDING * 3,
                      color: THEME_GREY,
                    )
                  : Text(nrvm.contexts[index ~/ 2],
                      style: Theme.of(context).textTheme.displaySmall);
            }),
      );

      body = ListView(
          shrinkWrap: true, children: <Widget>[oldContextsHeader, oldContexts]);
    } else {
      oldContextsHeader =
          nrvm.contexts.length <= 1 ? const SizedBox() : oldContextsTitle;
      oldContexts = Container(
          padding: const EdgeInsets.symmetric(vertical: UNIT_PADDING),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            // We display a divider after each context, so we need to double the amount of items, and subtract one to not display a divider after the last context
            itemCount: max((nrvm.contexts.length - 1) * 2 - 1, 0),
            itemBuilder: (context, index) {
              // After each context, we display a divider to show the separation
              return index.isOdd
                  ? const Divider(
                      height: UNIT_PADDING * 4,
                      thickness: 0.5,
                      indent: UNIT_PADDING * 3,
                      endIndent: UNIT_PADDING * 3,
                      color: THEME_GREY,
                    )
                  // We do +1 because we don't want to display the last context, since it is already in the result
                  : Text(nrvm.contexts[index ~/ 2 + 1],
                      style: Theme.of(context).textTheme.displaySmall);
            },
          ));
      Widget currentContextHeader = Text(
        loc.newsContextHeading,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(height: 1.2),
      );
      Widget currentContext = Container(
          padding: const EdgeInsets.symmetric(vertical: UNIT_PADDING),
          child: Text(nrvm.result!,
              style: Theme.of(context).textTheme.displaySmall));

      body = ListView(
        shrinkWrap: true,
        children: <Widget>[
          currentContextHeader,
          currentContext,
          oldContextsHeader,
          oldContexts,
        ],
      );
    }

    return Container(
        padding: const EdgeInsets.all(UNIT_PADDING * 3), child: body);
  }
}
