import 'package:bharat_shikho/audio/audio_service.dart';
import 'package:bharat_shikho/audio/podcast_card.dart';
import 'package:bharat_shikho/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(text: "For You"),
    Tab(text: "News"),
    Tab(text: "StartUp"),
    Tab(text: "Motivation"),
    Tab(text: "Before"),
  ];

  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;
  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            brightness == Brightness.light ? Colors.white : Colors.black,
        elevation: 5,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorWeight: 3,
          indicatorColor: Colors.amber[900],
          labelColor: Colors.amber[900],
          tabs: tabs,
        ),
        title: Text(
          "Home",
          style: TextStyle(
              color:
                  brightness == Brightness.light ? Colors.black : Colors.white),
        ),
        backwardsCompatibility: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          color: brightness == Brightness.light ? Colors.black : Colors.white,
          onPressed: () async {
            await (await UserRepository.instance()).signOut();
          },
        ),
      ),
      body: TabBarView(controller: _tabController, children: [
        SingleChildScrollView(
          child: Text('Hello'),
        ),
        // SingleChildScrollView(child: Text("How are you?")),
        SingleChildScrollView(
          child: FutureBuilder<QuerySnapshot>(
            future: AudioService.newsPodcasts,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container(
                height: MediaQuery.of(context).size.height - 100,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return PodcastCard(snapshot: snapshot.data!.docs[index]);
                  },
                  itemCount: snapshot.data!.docs.length,
                ),
              );
            },
          ),
        ),
        SingleChildScrollView(child: Text("How do you do?")),
        SingleChildScrollView(
          child: Text("Working"),
        ),
        SingleChildScrollView(
          child: Text("Awesome"),
        )
      ]),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildBottomNavigationBar() {
    Brightness brightness = Theme.of(context).brightness;
    return BottomNavigationBar(
        backgroundColor:
            brightness == Brightness.light ? Colors.white : Colors.black,
        currentIndex: _selectedIndex,
        fixedColor:
            brightness == Brightness.light ? Colors.black : Colors.white,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
              ),
              label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.rss_feed_rounded,
            ),
            label: "Feed",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books_rounded), label: "Library"),
        ]);
  }
}
