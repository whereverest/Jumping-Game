import 'dart:math';

class SyllableData {
  List<SyllableDataItem> oneSyllableData = [];
  List<SyllableDataItem> twoSyllableData = [];
  List<SyllableDataItem> threeSyllableData = [];
  List<SyllableDataItem> finalSyllableData = [];

  SyllableData(bool isFirstRun) {
    List<String> oneSD        = ['bag', 'bear', 'bed', 'bun', 'cloud', 'dog', 'fox', 'hat', 'hen', 'lock', 'mat', 'mouse', 'owl', 'six', 'star', 'sun', 'tree'];
    List<String> twoSD        = ['cobweb', 'jacket', 'lion', 'monkey', 'panda', 'picture', 'rabbit', 'rocket', 'ticket', 'window'];
    List<String> thrSD        = ['banana', 'butterfly', 'coconut', 'computer', 'dinosaur', 'elephant', 'eleven', 'kangaroo', 'microphone', 'octopus', 'piano', 'potato', 'tomato'];
    List<String> twoStructure = ['cob-web', 'jack-et', 'li-on', 'mon-key', 'pan-da', 'pic-ture', 'rab-bit', 'rock-et', 'tick-et', 'win-dow'];
    List<String> thrStructure = ['ba-na-na', 'but-ter-fly', 'co-co-nut', 'com-pu-ter', 'di-no-saur', 'el-e-phant', 'e-lev-en', 'kan-ga-roo', 'mi-cro-phone', 'oc-to-pus', 'pi-a-no', 'po-ta-to', 'to-ma-to'];

    for (var item in oneSD) {
      oneSyllableData.add(
          SyllableDataItem(
              word: item,
              syllable: 1,
              structure: item
          )
      );
    }
    for (int i = 0; i < twoSD.length; ++ i) {
      twoSyllableData.add(
          SyllableDataItem(
              word: twoSD[i],
              syllable: 2,
              structure: twoStructure[i]
          )
      );
    }
    for (int i = 0; i < thrSD.length; ++ i) {
      threeSyllableData.add(
          SyllableDataItem(
              word: thrSD[i],
              syllable: 3,
              structure: thrStructure[i]
          )
      );
    }
    
    List<List<SyllableDataItem>> sDPackage = [];
    sDPackage.add(getSyllableItemPackageWithParam(1));
    sDPackage.add(getSyllableItemPackageWithParam(2));
    sDPackage.add(getSyllableItemPackageWithParam(3));
    
    if (isFirstRun) {
      finalSyllableData.add(sDPackage[1][0]);
      finalSyllableData.add(sDPackage[1][1]);
      finalSyllableData.add(sDPackage[1][2]);
      finalSyllableData.add(sDPackage[0][0]);
      finalSyllableData.add(sDPackage[1][3]);
      finalSyllableData.add(sDPackage[2][0]);
      finalSyllableData.add(sDPackage[0][1]);
      finalSyllableData.add(sDPackage[1][4]);
      finalSyllableData.add(sDPackage[2][1]);
    } else {
      for (int i = 0; i < 3; ++ i) {
        for (int j = 0; j < 3; ++j) {
          finalSyllableData.add(sDPackage[j][i]);
        }
      }
    }
  }

  List<SyllableDataItem> getSyllableItemPackageWithParam(int syllable) {
    List<SyllableDataItem> randomSD = [];
    List<int> flags = [];

    var now = new DateTime.now();
    Random random = new Random(now.millisecondsSinceEpoch);

    if (syllable == 1) {
      for (int i = 0; i < 5; ++ i) {
        int itemIndex = 0;
        while (true) {
          itemIndex = random.nextInt(1000) % oneSyllableData.length;
          if (flags.contains(itemIndex)) continue;
          break;
        }
        flags.add(itemIndex);
        randomSD.add(oneSyllableData[itemIndex]);
      }

      return randomSD;
    }
    else if (syllable == 2) {
      for (int i = 0; i < 5; ++ i) {
        int itemIndex = 0;
        while (true) {
          itemIndex = random.nextInt(1000) % twoSyllableData.length;
          if (flags.contains(itemIndex)) continue;
          break;
        }
        flags.add(itemIndex);
        randomSD.add(twoSyllableData[itemIndex]);
      }

      return randomSD;
    }
    else {
      for (int i = 0; i < 5; ++ i) {
        int itemIndex = 0;
        while (true) {
          itemIndex = random.nextInt(1000) % threeSyllableData.length;
          if (flags.contains(itemIndex)) continue;
          break;
        }
        flags.add(itemIndex);
        randomSD.add(threeSyllableData[itemIndex]);
      }

      return randomSD;
    }
  }
}

class SyllableDataItem {
  final String word;
  final String structure;
  final int syllable;
  double fontSize = 19;

  SyllableDataItem({required this.word, required this.syllable, required this.structure}) {
    if (word.length < 8) fontSize = 18;
    else fontSize = fontSize - (word.length - 7);
  }

  String getWord() { return word; }
  int getSyllable() { return syllable; }
  String getStructure() { return structure; }
}