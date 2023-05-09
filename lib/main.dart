import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];

  void getNext(){
    current= WordPair.random();
    history.insert(0, current);
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavourites(){
    if(favorites.contains(current)){
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  List<WordPair> getFavourites(){
    return favorites;
  }
}

class BigCard extends StatelessWidget{
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style  = theme.textTheme.displayMedium!.copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(padding: const EdgeInsets.all(20),
          child: Text(pair.asLowerCase, style: style,semanticsLabel: "${pair.first} ${pair.second}"))
      ,
    );

  }
}

class GeneratorPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var icon = Icons.favorite;

    if(appState.favorites.contains(pair)){
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return  Center(
        child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BigCard(pair : pair),
              SizedBox(height: 10,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(onPressed: (){
                    appState.getNext();
                  }, child: Text("Next")),
                  SizedBox(width: 10),
                  ElevatedButton.icon(onPressed: (){
                    appState.toggleFavourites();
                  }, icon: Icon(icon),
                      label:Text("Like") )
                ],
              )
            ]));
  }

}

class _MyHomePageState extends State<MyHomePage>{

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch(selectedIndex){
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavouritesPage();
        break;
      default:
        throw UnimplementedError("no Widget selected");
    }

    var mainArea = ColoredBox(color: Theme.of(context).colorScheme.primaryContainer,
      child: page,);

    return SafeArea(child: Scaffold(body:
    LayoutBuilder(
      builder: (context, constraints){
      if (constraints.maxWidth < 450) {
        return Column(
          children: [
            Expanded(child: mainArea),
            SafeArea(
              child: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: 'Favorites',
                  ),
                ],
                currentIndex: selectedIndex,
                onTap: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            )
          ],
        );
      } else {
        return Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(child: mainArea),
          ],
        );
      }
      },
    ),) );

  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();

  }

}

class FavouritesPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();

    return ListView(
      children: [
        Padding(padding: const EdgeInsets.all(20),
            child: Text("You have ${appState.getFavourites().length} favourites" )),
        for(var pair in appState.getFavourites())
          ListTile(leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),),
      ],
    );
  }
}