import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:quranapp/model/aya_of_the_day.dart';
import 'package:quranapp/services/apiservices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiServices _apiServices = ApiServices();

  void setData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("alreadyUsed", true);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
  }

  // AyaOfTheDay? data;

  @override
  Widget build(BuildContext context) {
    HijriCalendar.setLocal('ar');
    var _hijri = HijriCalendar.now();
    var day = DateTime.now();
    var format = DateFormat('EEE , d MMM yyyy');
    var formatted = format.format(day);
    var _size = MediaQuery.of(context).size;

    // _apiServices.getAyaofTheDay().then((value) => data = value);

    return SafeArea(
        child: Scaffold(
      body: Column(children: [
        Container(
          height: _size.height * 0.22,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_img.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatted,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: <InlineSpan>[
                      WidgetSpan(
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            _hijri.hDay.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            _hijri.longMonthName,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '${_hijri.hYear} AH',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.only(
            top: 10,
            bottom: 20,
          ),
          child: Column(
            children: [
              FutureBuilder<AyaOfTheDay>(
                future: _apiServices.getAyaOfTheDay(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Icon(Icons.sync_problem);
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return CircularProgressIndicator();
                    case ConnectionState.done:
                      if (snapshot.hasData && snapshot.data != null) {
                        final ayaData = snapshot.data!;
                        return Container(
                          margin: EdgeInsetsDirectional.all(16),
                          padding: EdgeInsetsDirectional.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 3,
                                spreadRadius: 1,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Quran Aya of the Day",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Divider(
                                color: Colors.black,
                                thickness: 0.5,
                              ),
                              Text(
                                ayaData.arText ?? 'No Arabic text available',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                ayaData.enTran ?? 'No translation available',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: <InlineSpan>[
                                    WidgetSpan(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          ayaData.surNumber?.toString() ??
                                              'N/A',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          ayaData.surEnName ?? 'Unknown Surah',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Text('No data available');
                      }
                  }
                },
              )
            ],
          ),
        )),
      ]),
    ));
  }
}
