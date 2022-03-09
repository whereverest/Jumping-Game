import 'dart:async';

import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jumping_syllables/game/gameloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AssetManager(bundleAsset: BundleAsset.jumpingSyllables).initialize(
    force: false,
    localArchive: true,
    progressCallback: (percent) {
      print('LOAD ASSETS PERCENT: $percent');
    },
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(
      ScreenUtilInit(
        child: FabProviderScope(
            child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: JumpingSyllablesGame(
            bundleAsset: BundleAsset.jumpingSyllables,
            onStart: () {},
            onEnd: () {},
            onClose: () {},
            bonusCardVideoUrlLoader: Future.delayed(
              const Duration(seconds: 1),
              () =>
                  'https://storage.googleapis.com/edu-public-dev/bnous_card/__bonus_card_ep_1_fab_is_turning.mp4',
            ),
          ),
        )),
      ),
    );
  });
}
