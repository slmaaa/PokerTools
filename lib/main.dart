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
      home: StartPage(),
    );
  }
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
  int call(int amount) {
    if (chips < amount) return chips;
    chips -= (amount - currentCall);
    int amountAddToPool = amount - currentCall;
    currentRoundBet += amount - currentCall;
    currentCall = amount;
    return amountAddToPool;
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
  var players = [];
  int bottom = 200;
  int dealerIndex = -1;
  int playersStillInGame = 0;
  int bigBlind = 2;
  int smallBlind = 1;
  int currentCall = 0;
  int currentPool = 0;
  bool canCheck = true;
  int smallBlindIndex = 0;
  int bigBlindIndex = 0;
  int currentPlayerIndex = 0;
  int lastPlayerIndex = 0;
  var allInPlayersIndex = [];
  int cycleIndex = 0; //0: pre-start, 1: pre-flop, 2: flop , 3: turn , 4: river
  Game(int _bottom, int _sb)
      : smallBlind = _sb,
        bigBlind = _sb * 2,
        bottom = _bottom;
  void addPlayer(String _name, int index) {
    players.insert(index, Player(_name, bottom));
  }

  int returnPlayerIndex(String _name) {
    for (int i = 0; i < players.length; ++i) {
      if (players[i].name == _name) {
        return i + 1;
      }
    }
    return players.length;
  }

  String returnRoundText() {
    switch (cycleIndex) {
      case 1:
        return "Pre-flop";
      case 2:
        return "Flop";
      case 3:
        return "Turn";
      case 4:
        return "River";
      default:
        return "";
    }
  }

  void initializeRound() {
    cycleIndex = 1;
    playersStillInGame = players.length;
    dealerIndex = (dealerIndex + 1) % players.length;
    smallBlindIndex = (dealerIndex + 1) % players.length;
    players[smallBlindIndex].call(smallBlind);
    lastPlayerIndex = (dealerIndex + 2) % players.length;
    players[lastPlayerIndex].call(bigBlind);
    bigBlindIndex = lastPlayerIndex;
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
    int result = players[currentPlayerIndex].call(amount);
    currentCall = amount;
    currentPool += result;
    lastPlayerIndex = (currentPlayerIndex - 1) % players.length;
    nextPlayer();
    return true;
  }

  bool call() {
    int result = players[currentPlayerIndex].call(currentCall);
    currentPool += result;
    nextPlayer();
    return true;
  }

  void nextCycle() {
    if (cycleIndex == 4 || playersStillInGame == 1) {
      cycleIndex = 0;
    } else {
      cycleIndex++;
      currentCall = 0;
      for (Player element in players) {
        element.currentCall = 0;
      }
      currentPlayerIndex = (dealerIndex + 1) % players.length;
      lastPlayerIndex = dealerIndex;
      while (players[lastPlayerIndex].folded) {
        lastPlayerIndex = (lastPlayerIndex - 1) % players.length;
      }
      if (players[currentPlayerIndex].folded) {
        nextPlayer();
      }
    }
  }

  void endRound() {}
}

class StartPage extends StatefulWidget {
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final controllerName = TextEditingController();
  final controllerChips = TextEditingController();
  final controllerSB = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (controllerChips.text == "") {
      controllerChips.text = "200";
    }
    if (controllerSB.text == "") {
      controllerSB.text = "1";
    }
    return Scaffold(
        body: Center(
          child: Container(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Get started",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 22),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Host's name:",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        width: 150,
                        child: TextField(
                          controller: controllerName,
                        ))
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Num of chips:",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        width: 150,
                        child: TextField(
                          controller: controllerChips,
                          keyboardType: TextInputType.number,
                        ))
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Small blind:",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        width: 150,
                        child: TextField(
                          controller: controllerSB,
                          keyboardType: TextInputType.number,
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return MainScreen(
                  controllerName.text,
                  int.parse(controllerChips.text),
                  int.parse(controllerSB.text));
            }));
          },
          tooltip: 'Intialize game',
          child: const Icon(Icons.add),
        ));
  }
}

class MainScreen extends StatefulWidget {
  MainScreen(String _name, int _chips, int _sb, {Key? key}) : super(key: key) {
    game = Game(
      _chips,
      _sb,
    );
    game.addPlayer(_name, 0);
  }
  var game;
  bool canCheck() {
    if (game.currentCall == 0 ||
        (game.cycleIndex == 1 &&
            game.currentPlayerIndex == game.bigBlindIndex)) {
      return true;
    }
    return false;
  }
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final double LIST_HEIGHT = 700;
  final double LIST_WIDTH = 120;

  final textController = TextEditingController();
  String newValue = "";
  @override
  MainScreen get widget => super.widget;
  String dropdownValue = "!";

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    void endDialog() {
      if (dropdownValue == "!") {
        dropdownValue = widget.game.players[0].name;
      }
      if (widget.game.playersStillInGame == 1) {
        var temp;
        for (Player i in widget.game.players) {
          if (!i.folded) {
            temp = i;
            break;
          }
        }
        temp.addChips(widget.game.currentPool);
        final snackBar = SnackBar(
          content: Text(
            temp.name + "wins!!",
            style: TextStyle(fontSize: 16),
          ),
        );

        // Find the ScaffoldMessenger in the widget tree
        // and use it to show a SnackBar.
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else
        showDialog<String>(
            context: context,
            builder: (BuildContext context) =>
                StatefulBuilder(builder: (context, StateSetter _setState) {
                  return AlertDialog(
                    title: const Text('Who win?'),
                    content: Flexible(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Name: ",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              DropdownButton<String>(
                                value: dropdownValue,
                                items: widget.game.players
                                    .map<DropdownMenuItem<String>>(
                                        (value) => DropdownMenuItem<String>(
                                              value: value.name,
                                              child: Text(value.name),
                                            ))
                                    .toList(),
                                onChanged: (changedValue) {
                                  dropdownValue = changedValue!;
                                  _setState(() {
                                    dropdownValue;
                                  });
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          setState(() {
                            widget
                                .game
                                .players[widget.game
                                    .returnPlayerIndex(dropdownValue)]
                                .addChips(widget.game.currentPool);
                          });
                          Navigator.pop(context, 'OK');
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  );
                }));
    }

    Widget playerCard(Player player) {
      return Container(
        width: 250,
        height: 250,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color: Color.fromARGB(255, 245, 245, 222)),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.game.players[widget.game.currentPlayerIndex].name,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text("Chips: " + player.chips.toString(),
                    textAlign: TextAlign.start,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
              ],
            ),
            Text(
                "You will lose: " +
                    player.currentRoundBet.toString() +
                    " if you fold",
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
            Text(
                "You need to add: " +
                    (widget.game.currentCall - player.currentCall).toString() +
                    " if you call",
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300))
          ],
        ),
      );
    }

    Widget poolIndicator() {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(width: 20),
                  Text("Calling " + widget.game.currentCall.toString())
                ],
              ),
              Row(
                children: [
                  Text(
                    "Pool " + widget.game.currentPool.toString(),
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
                value: widget.game.currentCall /
                    widget.game.currentPool, // percent filled
                color: Colors.orange,
                backgroundColor: Colors.red[600],
              ),
            ),
          ),
        ],
      );
    }

    Widget playerCircle(Player player) {
      var circle = Container(
          width: 50,
          height: 50,
          margin: EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                player.name.length < 3
                    ? player.name
                    : player.name.substring(0, 3),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              )
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueGrey, width: 2),
          ));
      if (widget.game.cycleIndex > 0) {
        var temp;
        if (widget.game.players[widget.game.currentPlayerIndex] == player) {
          temp = Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.amber[200],
                ),
              ),
              circle,
            ],
          );
        } else
          temp = circle;
        if (widget.game.players[widget.game.dealerIndex] == player) {
          return Stack(children: [temp, Text("D")]);
        } else if (widget.game.players[widget.game.smallBlindIndex] == player) {
          return Stack(children: [temp, Text("SB")]);
        } else if (widget.game.players[widget.game.bigBlindIndex] == player) {
          return Stack(children: [temp, Text("BB")]);
        }
        return temp;
      }
      return circle;
    }

    List<Widget> playerCircles = widget.game.players
        .map<Widget>((player) => Row(children: [
              Text(
                player.chips.toString(),
                style: TextStyle(
                    color: player.chips >= widget.game.bottom
                        ? Colors.lightGreen[500]
                        : Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              playerCircle(player),
            ]))
        .toList();
    Widget playerList = Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: playerCircles,
        ),
        width: LIST_WIDTH,
        height: LIST_HEIGHT,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20))));

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                child: (widget.game.cycleIndex == 0)
                    ? Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.red[500]),
                        width: 150,
                        height: 150,
                        child: TextButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(CircleBorder())),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: Colors.greenAccent,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text("Start",
                                  style: TextStyle(color: Colors.greenAccent))
                            ],
                          ),
                          onPressed: () {
                            widget.game.initializeRound();
                            setState(() {});
                          },
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.game.returnRoundText(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 28),
                          ),
                          SizedBox(height: 20),
                          poolIndicator(),
                          SizedBox(height: 20),
                          playerCard(widget
                              .game.players[widget.game.currentPlayerIndex]),
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
                                        color: widget.canCheck()
                                            ? Colors.orange[200]
                                            : Colors.grey),
                                    child: TextButton(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
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
                                      onPressed: widget.canCheck()
                                          ? () {
                                              setState(() {
                                                widget.game.check();
                                              });
                                              if (widget.game.cycleIndex == 0) {
                                                endDialog();
                                                setState(() {});
                                              }
                                            }
                                          : null,
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
                                        color: widget.game.currentCall ==
                                                widget
                                                    .game
                                                    .players[widget.game
                                                        .currentPlayerIndex]
                                                    .currentCall
                                            ? Colors.grey
                                            : Colors.lime),
                                    child: TextButton(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
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
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                      onPressed: widget.game.currentCall ==
                                              widget
                                                  .game
                                                  .players[widget
                                                      .game.currentPlayerIndex]
                                                  .currentCall
                                          ? null
                                          : () {
                                              setState(() {
                                                widget.game.call();
                                              });
                                              if (widget.game.cycleIndex == 0) {
                                                endDialog();
                                                setState(() {});
                                              }
                                            },
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                      onPressed: () {
                                        setState(() {
                                          widget.game.fold();
                                        });
                                        if (widget.game.cycleIndex == 0) {
                                          endDialog();
                                          setState(() {});
                                        }
                                      },
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                color:
                                                    Colors.yellowAccent[400]),
                                          )
                                        ],
                                      ),
                                      onPressed: () {
                                        showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                StatefulBuilder(builder:
                                                    (context,
                                                        StateSetter _setState) {
                                                  return AlertDialog(
                                                    title: const Text('Raise'),
                                                    content: SizedBox(
                                                      height: 100,
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                "Amount:",
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                              SizedBox(
                                                                  width: 150,
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        textController,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          textController
                                                              .clear();
                                                          Navigator.pop(context,
                                                              'Cancel');
                                                        },
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            widget.game.raise(
                                                                int.parse(
                                                                    textController
                                                                        .text));
                                                          });
                                                          textController
                                                              .clear();
                                                          Navigator.pop(
                                                              context, 'OK');
                                                        },
                                                        child: const Text(
                                                            'Confirm'),
                                                      ),
                                                    ],
                                                  );
                                                }));
                                        setState(() {});
                                        if (widget.game.cycleIndex == 0) {
                                          endDialog();
                                          setState(() {});
                                        }
                                      },
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
        onPressed: () {
          if (dropdownValue == "!") {
            dropdownValue = widget.game.players[0].name;
          }
          showDialog<String>(
              context: context,
              builder: (BuildContext context) =>
                  StatefulBuilder(builder: (context, StateSetter _setState) {
                    return AlertDialog(
                      title: const Text('Add Player'),
                      content: SizedBox(
                        height: 100,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Name:",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                SizedBox(
                                    width: 150,
                                    child: TextField(
                                      controller: textController,
                                    ))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Insert after:",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                DropdownButton<String>(
                                  value: dropdownValue,
                                  icon: const Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  elevation: 16,
                                  style:
                                      const TextStyle(color: Colors.deepPurple),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  items: widget.game.players
                                      .map<DropdownMenuItem<String>>(
                                          (value) => DropdownMenuItem<String>(
                                                value: value.name,
                                                child: Text(value.name),
                                              ))
                                      .toList(),
                                  onChanged: (changedValue) {
                                    dropdownValue = changedValue!;
                                    _setState(() {
                                      dropdownValue;
                                    });
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            textController.clear();
                            Navigator.pop(context, 'Cancel');
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              widget.game.addPlayer(textController.text,
                                  widget.game.returnPlayerIndex(dropdownValue));
                            });
                            textController.clear();
                            Navigator.pop(context, 'OK');
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    );
                  }));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
