import 'package:actualia/utils/themes.dart';
import 'package:actualia/views/interests_wizard_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PreOnBoardingPage extends StatefulWidget {
  const PreOnBoardingPage({super.key});

  @override
  PreOnBoardingPageState createState() => PreOnBoardingPageState();
}

class PreOnBoardingPageState extends State<PreOnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const InterestWizardView()),
    );
  }

  Widget _buildImage(String assetName, [double width = 250]) {
    return Image.asset('assets/img/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    var pageDecoration = PageDecoration(
      titleTextStyle: Theme.of(context).textTheme.titleMedium!,
      bodyTextStyle: Theme.of(context).textTheme.bodyMedium!,
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: THEME_LIGHTGRAY,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: THEME_LIGHTGRAY,
      // globalHeader: const TopAppBar(enableProfileButton: false), // if we want to enable header
      pages: [
        PageViewModel(
          title: loc.onboardingTitle1,
          body: loc.onboardingDescription1,
          image: _buildImage('onboarding1.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: loc.onboardingTitle2,
          body: loc.onboardingDescription2,
          image: _buildImage('onboarding2.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: loc.onboardingTitle3,
          body: loc.onboardingDescription3,
          image: _buildImage('onboarding3.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // We can override the onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: Text(loc.skip, style: const TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: Text(loc.done, style: const TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
