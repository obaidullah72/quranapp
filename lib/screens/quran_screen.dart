import 'package:flutter/material.dart';
import 'package:quranapp/screens/surahdetail.dart';
import 'package:quranapp/services/apiservices.dart';

import '../common/constants.dart';
import '../model/sajda.dart';
import '../model/surah.dart';
import '../widgets/sajda_custom_tile.dart';
import '../widgets/surah_custom_tile.dart';
import 'juz_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  ApiServices apiServices = ApiServices();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff1B202D),
          title: const Text('Quran', style: TextStyle(color: Colors.white),),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Surah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Sajdah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Juz',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            FutureBuilder<List<Surah>>(
              future: apiServices.getSurah(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Surah>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong due to network issue'),
                  );
                } else if (snapshot.hasData) {
                  List<Surah>? surah = snapshot.data;
                  return ListView.builder(
                    itemCount: surah!.length,
                    itemBuilder: (context, index) => SurahCustomListTile(
                      surah: surah[index],
                      context: context,
                      ontap: () {
                        setState(() {
                          Constants.surahIndex = (index+1);
                        });
                        Navigator.pushNamed(context, Surahdetail.id);
                      },
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('No data available'),
                  );
                }
              },
            ),
            FutureBuilder<SajdaList>(
              future: apiServices.getSajda(),
              builder:
                  (BuildContext context, AsyncSnapshot<SajdaList> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong due to network issue'),
                  );
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.sajdaAyahs.length,
                    itemBuilder: (context, index) => SajdaCustomTile(
                        snapshot.data!.sajdaAyahs[index], context),
                  );
                } else {
                  return const Center(
                    child: Text('No data available'),
                  );
                }
              },
            ),
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          Constants.juzIndex = (index + 1);
                        });
                        Navigator.pushNamed(context, JuzScreen.id);
                      },
                      child: Card(
                        elevation: 2,
                        color: Colors.blueGrey,
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
