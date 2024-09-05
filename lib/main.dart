import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyAppColors {
  static const darkBlue = Color.fromARGB(255, 83, 212, 19);
  static const lightBlue = Color.fromARGB(255, 40, 174, 211);
}

class MyAppThemes {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 41, 185, 238)),
      primaryColor: Color.fromARGB(255, 41, 185, 238),
    // brightness: Brightness.light,
  );

  static final darkTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 34, 41, 255),
          brightness: Brightness.dark,
        ),    
        primaryColor: Color.fromARGB(255, 34, 41, 255),
    brightness: Brightness.dark,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static _MyAppState of(BuildContext context) => 
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: MyAppThemes.lightTheme,
        darkTheme: MyAppThemes.darkTheme,
        themeMode: _themeMode, // Default mode
        home: const MyHomePage(),
      ),
    );
  }

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;;
    });
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();



  // Get the next WordPair
  void getNext() {
    discarded.insert(0, current); // Adding the passed word to the discarded array
    current = WordPair.random();
    notifyListeners();
  }

  // Adding favorites logic
  var favorites = <WordPair>[];

  // Adding discarded logic
  var discarded = <WordPair>[];

  // A darkMode
  var isDarkMode = false;



  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  bool isFavorite(WordPair pair) {
    return favorites.contains(pair);
  }
}




class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: constraints.maxWidth < 450
                    ? const SizedBox() // Empty SizedBox when width is small
                    : NavigationRail(
                        extended: constraints.maxWidth >= 600,
                        destinations: const [
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
                        trailing: Expanded(child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: IconButton(
                              onPressed: () {
                                MyApp.of(context).toggleTheme();
                              }, 
                              icon: Icon(MyApp.of(context)._themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode)),
                            ),
                        )),
                      ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
          bottomNavigationBar: constraints.maxWidth < 450
              ? BottomNavigationBar(
                  items: const [
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
                )
              : null,
        );
      },
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    if (appState.favorites.isEmpty) {
      return const Center(
        child: Text('No favorites yet.'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = max((width / 200).floor(), 1);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          padding: const EdgeInsets.all(16),
          itemCount: appState.favorites.length,
          itemBuilder: (context, index) {
            final pair = appState.favorites[index];
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: () {
                appState.removeFavorite(pair);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.delete),
                  Flexible(
                    child: Text(
                      pair.asLowerCase,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 24), // To balance the delete icon
                ],
              ),
            );
          },
        );
      },
    );
  }
}


class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // DiscardedPairslist takes up 30% of the available height
            const Expanded(
              child: DiscardedPairslist(),
            ),
            // BigCard section takes only the space it needs
            Flexible(
              fit: FlexFit.loose,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BigCard(pair: pair),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            appState.toggleFavorite();
                          },
                          icon: Icon(icon),
                          label: const Text('Like'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            appState.getNext();
                          },
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // This Spacer pushes the BigCard section to the center
            // const Spacer(flex: 3),
            const Expanded(child: SizedBox())
            //const SizedBox(height: 200),

          ],
        );
      },
    );
  }
}

class DiscardedPairslist extends StatelessWidget {
  const DiscardedPairslist({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var discarded = appState.discarded;



    if (discarded.isEmpty) {
      return const Center(child: Text('No discarded pairs yet.'));
    }

    // Use a ScrollController to track the scroll position
    ScrollController scrollController = ScrollController();

     return LayoutBuilder(
      builder: (context, constraints) {
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification) {
              (context as Element).markNeedsBuild();
            }
            return true;
          },
          child: ListView.builder(
            controller: scrollController,
            reverse: true,
            itemCount: discarded.length,
            itemBuilder: (context, index) {
              final pair = discarded[index];
              
              double itemExtent = 56.0;
              double itemPosition = index * itemExtent;
              double visibleHeight = constraints.maxHeight;
              double scrollOffset = scrollController.hasClients ? scrollController.offset : 0;
              
              double opacity = (itemPosition - scrollOffset) / visibleHeight;
              opacity = 1.0 - opacity.clamp(0.0, 0.9);
              
              return Opacity(
                opacity: opacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          appState.isFavorite(pair) ? Icons.favorite : Icons.favorite_border,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          appState.toggleFavorite(pair);
                        },
                      ),
                      Text(
                        pair.asLowerCase,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final boldStyle = style.copyWith(
      fontWeight: FontWeight.bold,
    );


    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pair.first,
              style: style,
            ),
            Text (
              pair.second,
              style: boldStyle,
            )
          ],
        ),      ),
    );
  }
}