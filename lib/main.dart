import 'dart:ffi';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.brown,
      ),
      home: const MyHomePage(title: 'Flutter DDDmo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Player {
  String name = "";
  int chips = 0;
  int currentCall = 0;
  int currentRoundBet = 0;
  bool folded = false;
  Player(String n, int c) {
    //Contructor
    name = n;
    chips = c;
  }
  bool call(int amount) {
    if (chips < amount) return false;
    chips -= amount;
    currentCall = amount;
    return true;
  }

  void resetRound() {
    currentCall = 0;
    currentRoundBet = 0;
    folded = false;
  }

  void addChips(int amount) {
    chips += amount;
  }
}

class Game {
  var players = [Player("Evan", 200)];
  int bottom = 200;
  int dealerIndex = 0;
  int playersStillInGame = 0;
  int bigBlind = 2;
  int smallBlind = 1;
  int currentCall = 0;
  int currentPool = 0;
  int currentPlayerIndex = 0;
  int lastPlayerIndex = 0;
  int cycleIndex = 0; //0: pre-start, 1: pre-flop, 2: flop , 3: turn , 4: river
  void addPlayer(_name) {
    players.add(Player(_name, bottom));
  }

  void initailizeRound() {
    cycleIndex = 0;
    playersStillInGame = players.length;
    dealerIndex = (dealerIndex + 1) % players.length;
    players[(dealerIndex + 1) % players.length].call(smallBlind);
    lastPlayerIndex = (dealerIndex + 2) % players.length;
    players[lastPlayerIndex].call(bigBlind);
    currentCall = bigBlind;
    currentPool = bigBlind + smallBlind;
    currentPlayerIndex = (dealerIndex + 3) % players.length;
  }

  void nextPlayer() {
    if (currentPlayerIndex == lastPlayerIndex) {
      nextCycle();
    } else {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
      if (players[currentPlayerIndex].folded) nextPlayer();
    }
  }

  void fold() {
    players[currentPlayerIndex].folded = true;
    playersStillInGame--;
    nextPlayer();
  }

  void check() {
    nextPlayer();
  }

  bool raise(int amount) {
    bool result = players[currentPlayerIndex].call(amount);
    if (result) {
      currentPool += amount;
      lastPlayerIndex = (currentPlayerIndex - 1) % players.length;
      nextPlayer();
      return result;
    }
    return false;
  }

  bool call() {
    bool result = players[currentPlayerIndex].call(currentCall);
    if (result) {
      currentPool += currentCall;
      nextPlayer();
      return result;
    }
    return false;
  }

  void nextCycle() {
    if (cycleIndex == 4 || playersStillInGame == 1) {
      endRound();
    } else {
      cycleIndex++;
      currentCall = 0;
      for (Player element in players) {
        element.currentCall = 0;
      }
      currentPlayerIndex = (dealerIndex + 1) % players.length;
      lastPlayerIndex = (dealerIndex - 1) % players.length;
      if (players[currentPlayerIndex].folded) {
        nextPlayer();
      }
    }
  }

  void endRound() {}
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int num_of_players = 4;
  final int x_diff = 30;
  final int y_diff = 30;
  final double LIST_HEIGHT = 600;
  final double LIST_WIDTH = 100;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter += 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    Widget playerCircle = Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.red)],
        ));
    Widget playerList = Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [],
        ),
        width: LIST_WIDTH,
        height: LIST_HEIGHT,
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20))));

    return Scaffold(
      body: Row(
        children: [
          Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [playerList],
              )),
          Expanded(
              flex: 7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [SizedBox(width: 20), Text("Calling")],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Pool",
                                  textAlign: TextAlign.end,
                                ),
                                SizedBox(width: 20)
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 250,
                            height: 40,
                            child: LinearProgressIndicator(
                              value: 0.35, // percent filled
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.orange),
                              backgroundColor: Colors.red[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Color.fromARGB(255, 245, 245, 222)),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Evan",
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text("Chips: 120/200",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300)),
                            ],
                          ),
                          Text("Your bet in this round: 30",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w300)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 100.0,
                              width: 100.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.orange[200]),
                              child: TextButton(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.done,
                                      size: 40,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Check")
                                  ],
                                ),
                                onPressed: () {},
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              height: 100.0,
                              width: 100.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.lime),
                              child: TextButton(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone_in_talk_outlined,
                                      size: 40,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Call",
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ],
                                ),
                                onPressed: () {},
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 100.0,
                              width: 100.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.brown),
                              child: TextButton(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.highlight_off,
                                      size: 40,
                                      color: Colors.blueGrey[200],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Fold",
                                      style: TextStyle(
                                          color: Colors.blueGrey[200]),
                                    )
                                  ],
                                ),
                                onPressed: () {},
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              height: 100.0,
                              width: 100.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.redAccent),
                              child: TextButton(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      size: 40,
                                      color: Colors.yellowAccent[400],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Raise",
                                      style: TextStyle(
                                          color: Colors.yellowAccent[400]),
                                    )
                                  ],
                                ),
                                onPressed: () {},
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
