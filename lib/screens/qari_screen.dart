import 'package:flutter/material.dart';

import '../model/qari.dart';
import '../services/apiservices.dart';
import '../widgets/qari_custom_tile.dart';
import 'audiosurahscreen.dart';

class QariListScreen extends StatefulWidget {
  const QariListScreen({Key? key}) : super(key: key);

  @override
  _QariListScreenState createState() => _QariListScreenState();
}

class _QariListScreenState extends State<QariListScreen> {
  ApiServices apiServices = ApiServices();
  TextEditingController searchController = TextEditingController();
  List<Qari> _qariList = [];
  List<Qari> _filteredQariList = [];

  @override
  void initState() {
    super.initState();
    _fetchQariList();
    searchController.addListener(_onSearchChanged);
  }

  void _fetchQariList() async {
    List<Qari> qaris = await apiServices.getQariList();
    setState(() {
      _qariList = qaris;
      _filteredQariList = qaris;  // Initially show all Qaris
    });
  }

  void _onSearchChanged() {
    String query = searchController.text.toLowerCase();
    setState(() {
      _filteredQariList = _qariList.where((qari) {
        return qari.name?.toLowerCase().contains(query) ?? false;
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff1B202D),
          title: Text('Qari\'s', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 12, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 1,
                      spreadRadius: 0.0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search Qari',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Icon(Icons.search),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _filteredQariList.isEmpty
                    ? Center(
                  child: Text('No Qari found'),
                )
                    : ListView.builder(
                  itemCount: _filteredQariList.length,
                  itemBuilder: (context, index) {
                    return QariCustomTile(
                      qari: _filteredQariList[index],
                      ontap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AudioSurahScreen(
                              qari: _filteredQariList[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
