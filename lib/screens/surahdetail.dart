import 'package:flutter/material.dart';
import 'package:quranapp/common/constants.dart';
import 'package:quranapp/services/apiservices.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

import '../model/translations.dart';
import '../widgets/custom_translation_tile.dart';

enum Translation { urdu, hindi, english, spanish , german, persian}

class Surahdetail extends StatefulWidget {
  const Surahdetail({super.key});

  static const String id = 'surahDetail_screen';

  @override
  State<Surahdetail> createState() => _SurahdetailState();
}

class _SurahdetailState extends State<Surahdetail> {
  // SolidController _controller = SolidController();
  Translation? _translation = Translation.urdu;
  ApiServices _apiServices = ApiServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _apiServices.getTranslation(
            Constants.surahIndex!, _translation!.index),
        builder: (BuildContext context,
            AsyncSnapshot<SurahTranslationList> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 50.0,right: 10, left: 10),
              child: ListView.builder(
                itemCount: snapshot.data!.translationList.length,
                itemBuilder: (context, index) {
                  return TranslationTile(
                    index: index,
                    surahTranslation: snapshot.data!.translationList[index],
                  );
                },
              ),
            );
          } else
            return Center(
              child: Text('Translation Not found'),
            );
        },
      ),
      bottomSheet: SolidBottomSheet(
        headerBar: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          height: 50,
          child: Center(
            child: Text(
              'Swipe me!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: const Text('Urdu'),
                    leading: Radio<Translation>(
                      value: Translation.urdu,
                      groupValue: _translation,
                      onChanged: (Translation? value) {
                        setState(() {
                          _translation = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('English'),
                    leading: Radio<Translation>(
                      value: Translation.english,
                      groupValue: _translation,
                      onChanged: (Translation? value) {
                        setState(() {
                          _translation = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Hindi'),
                    leading: Radio<Translation>(
                      value: Translation.hindi,
                      groupValue: _translation,
                      onChanged: (Translation? value) {
                        setState(() {
                          _translation = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Spanish'),
                    leading: Radio<Translation>(
                      value: Translation.spanish,
                      groupValue: _translation,
                      onChanged: (Translation? value) {
                        setState(() {
                          _translation = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('German'),
                    leading: Radio<Translation>(
                      value: Translation.german,
                      groupValue: _translation,
                      onChanged: (Translation? value) {
                        setState(() {
                          _translation = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Persian'),
                    leading: Radio<Translation>(
                      value: Translation.persian,
                      groupValue: _translation,
                      onChanged: (Translation? value) {
                        setState(() {
                          _translation = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
