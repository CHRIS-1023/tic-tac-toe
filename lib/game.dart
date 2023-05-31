import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/authservice.dart';
import 'package:tic_tac_toe/login.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  AuthService authService = AuthService();
  String player1 = 'X';
  String player2 = 'O';

  late String currentPlayer;
  late bool endGame;
  late List<String> occupied;
  late List<bool> tappedBoxes;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference gameRef;

  initializeGame() {
    currentPlayer = player1;
    endGame = false;
    occupied = ["", "", "", "", "", "", "", "", ""];
    tappedBoxes = List<bool>.filled(9, false);

    // Get a reference to the game data in the Realtime Database
    gameRef = database.ref().child('games').push();
  }

  deleteGameData() async {
    // Delete the game data from the Realtime Database
    await gameRef.remove();

    // Reinitialize the game
    setState(() {
      initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () async {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.exit_to_app),
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                flex: 1,
                child: Text(
                  "TIC TAC TOE",
                  style: TextStyle(color: Colors.purple, fontSize: 30),
                ),
              ),
              Expanded(
                child: Text(
                  "$currentPlayer turn",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      crossAxisCount: 3,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, int index) {
                      return squares(index);
                    },
                  ),
                ),
              ),
              StreamBuilder(
                stream: gameRef.child('moves').onValue,
                builder: (context, AsyncSnapshot snapshot) {
                  print("update");

                  if (snapshot.hasData) {
                    if (snapshot.data!.snapshot.value != null) {
                      // Retrieve the moves from the database
                      Map<dynamic, dynamic> moves = Map<dynamic, dynamic>.from(
                          snapshot.data!.snapshot.value);

                      // Update the game state based on the retrieved moves
                      moves.forEach((key, value) {
                        String player = value['player'];
                        int index = value['index'];

                        if (!tappedBoxes[index]) {
                          setState(() {
                            tappedBoxes[index] = true;
                            occupied[index] = player;
                            nextPlayer();
                            winnerCheck();
                            drawCheck();
                          });
                        }
                      });
                    }
                  }
                  return Container();
                },
              ),
              Center(
                child: IconButton(
                  onPressed: deleteGameData,
                  icon: const Icon(Icons.restart_alt),
                  iconSize: 70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget squares(int index) {
    return GestureDetector(
      onTap: () {
        if (endGame || tappedBoxes[index]) {
          return; // Don't update if the game is over or the box has already been tapped
        }

        // Record the move in the Firebase Realtime Database
        gameRef.child('moves').push().set({
          'index': index,
          'player': currentPlayer,
        });

        setState(() {
          tappedBoxes[index] = true;
          occupied[index] = currentPlayer;
          nextPlayer();
          winnerCheck();
          drawCheck();
        });
      },
      child: Container(
        color: occupied[index].isEmpty
            ? Colors.black26
            : occupied[index] == player1
                ? Colors.amber
                : Colors.purple,
        child: Center(
          child: Text(
            occupied[index],
            style: const TextStyle(fontSize: 50),
          ),
        ),
      ),
    );
  }

  nextPlayer() {
    if (currentPlayer == player1) {
      currentPlayer = player2;
    } else {
      currentPlayer = player1;
    }
  }

  winnerCheck() {
    List<List<int>> winnerList = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var winPos in winnerList) {
      String playerPos0 = occupied[winPos[0]];
      String playerPos1 = occupied[winPos[1]];
      String playerPos2 = occupied[winPos[2]];

      if (playerPos0.isNotEmpty) {
        if (playerPos0 == playerPos1 && playerPos0 == playerPos2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Game over player: $playerPos0 won")),
          );
          endGame = true;
          return;
        }
      }
    }
  }

  drawCheck() {
    if (endGame) {
      return;
    }

    bool draw = true;
    for (var occPlayer in occupied) {
      if (occPlayer.isEmpty) {
        draw = false;
      }
    }

    if (draw) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Game over \n DRAW")),
      );
      endGame = true;
    }
  }
}
