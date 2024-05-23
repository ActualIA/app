import 'package:actualia/utils/themes.dart';
import 'package:actualia/views/interests_wizard_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class PreOnBoardingPage extends StatefulWidget {
  const PreOnBoardingPage({super.key});

  @override
  PreOnBoardingPageState createState() => PreOnBoardingPageState();
}

class PreOnBoardingPageState extends State<PreOnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) =>
              const InterestWizardView()), // For testing purposes, we can replace this with HomePage()
    );
  }

  Widget _buildImage(String assetName, [double width = 250]) {
    return Image.asset('assets/img/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
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
          title: "Welcome to ActualIA",
          body:
              "Get your own 1 minute daily summary of news that you choose, tailored to your needs.",
          image: _buildImage('onboarding1.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Personalized news feed",
          body:
              "Wake up with the latest in tech, politics, society, or any subject you’d like. ",
          image: _buildImage('onboarding2.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Stay informed, always",
          body:
              "You can listen to your customized news feed, read a transcript, and always look into the original sources of the headlines that caught your eye.",
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
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
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
