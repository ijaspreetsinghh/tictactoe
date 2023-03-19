import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tictactoe/constants/colors.dart';
import 'package:tictactoe/constants/styles.dart';
import 'package:get/get.dart';

class GameScreen extends StatefulWidget {
  GameScreen({super.key});

  static const maxSeconds = 30;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  RxBool oTurn = true.obs;
  RxList matchedIndexes = [].obs;
  RxList<String> displayXO = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
  ].obs;

  RxString resultDeclaration = ''.obs;

  RxInt oScore = 0.obs;

  RxInt xScore = 0.obs;

  RxInt filledBoxes = 0.obs;
  RxInt attempts = 0.obs;

  RxBool winnerFound = false.obs;

  Timer? timer;

  RxInt seconds = GameScreen.maxSeconds.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColor.primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Expanded(
            flex: 1,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Player O',
                        style: whiteFontStyle,
                      ),
                      Obx(
                        () => Text(
                          oScore.value.toString(),
                          style: whiteFontStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Player X',
                        style: whiteFontStyle,
                      ),
                      Obx(
                        () => Text(
                          xScore.value.toString(),
                          style: whiteFontStyle,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  _tapped(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      border: Border.all(
                        color: MainColor.primaryColor,
                        width: 5,
                      ),
                      color: matchedIndexes.contains(index)
                          ? MainColor.accentColor
                          : MainColor.secondaryColor),
                  child: Center(
                    child: Obx(() => Text(
                          displayXO[index],
                          style: coinyFont.copyWith(
                              color: MainColor.primaryColor, fontSize: 64),
                        )),
                  ),
                ),
              ),
              itemCount: 9,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                      resultDeclaration.value,
                      style: whiteFontStyle,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildTimer(),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _tapped(int index) {
    final isRunning = timer == null ? false : timer!.isActive;

    if (isRunning) {
      if (oTurn.value && displayXO[index] == '') {
        displayXO[index] = 'O';
      } else if (!oTurn.value && displayXO[index] == '') {
        displayXO[index] = 'X';
      }
      filledBoxes.value++;
      oTurn.toggle();
      _checkWinner();
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        stopTimer();
      }
    });
    setState(() {});
  }

  void stopTimer() {
    resetTimer();
    setState(() {
      timer?.cancel();
    });
  }

  void resetTimer() {
    seconds.value = GameScreen.maxSeconds;
  }

  void _clearBoard() {
    for (int i = 0; i < 9; i++) {
      displayXO[i] = '';
    }

    resultDeclaration.value = '';
    filledBoxes.value = 0;
    winnerFound.value = false;
    matchedIndexes.clear();
  }

  Widget _buildTimer() {
    final isRunning = timer == null ? false : timer!.isActive;

    return isRunning
        ? SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Obx(
                  () => CircularProgressIndicator(
                    value: 1 - seconds.value / GameScreen.maxSeconds,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 8,
                    backgroundColor: MainColor.accentColor,
                  ),
                ),
                Obx(
                  () => Center(
                    child: Text(
                      seconds.value.toString(),
                      style: const TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : ElevatedButton(
            onPressed: () {
              startTimer();
              _clearBoard();
              attempts.value++;
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: Text(
              attempts.value == 0 ? 'Start' : 'Play Again!',
              style: coinyFont.copyWith(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          );
  }

  void _updateScore(String winner) {
    if (winner == 'O') {
      oScore.value++;
    } else if (winner == 'X') {
      xScore.value++;
    }
    winnerFound.value = true;
  }

  void _checkWinner() {
    //check 1st row
    if (displayXO[0] == displayXO[1] &&
        displayXO[0] == displayXO[2] &&
        displayXO[0] != '') {
      resultDeclaration.value = 'Player ${displayXO[0]} Wins!';
      matchedIndexes.addAll([0, 1, 2]);
      stopTimer();
      _updateScore(displayXO[0]);
    }

    //check 2nd row
    if (displayXO[3] == displayXO[4] &&
        displayXO[3] == displayXO[5] &&
        displayXO[3] != '') {
      resultDeclaration.value = 'Player ${displayXO[3]} Wins!';
      matchedIndexes.addAll([3, 4, 5]);
      stopTimer();
      _updateScore(displayXO[3]);
    }

    //check 3rd row
    if (displayXO[6] == displayXO[7] &&
        displayXO[6] == displayXO[8] &&
        displayXO[6] != '') {
      resultDeclaration.value = 'Player${displayXO[6]} Wins!';
      matchedIndexes.addAll([6, 7, 8]);
      stopTimer();
      _updateScore(displayXO[6]);
    }

    //check 1st column
    if (displayXO[0] == displayXO[3] &&
        displayXO[0] == displayXO[6] &&
        displayXO[0] != '') {
      resultDeclaration.value = 'Player ${displayXO[0]} Wins!';
      matchedIndexes.addAll([0, 3, 6]);
      stopTimer();
      _updateScore(displayXO[0]);
    }

    //check 2nd column
    if (displayXO[1] == displayXO[4] &&
        displayXO[1] == displayXO[7] &&
        displayXO[1] != '') {
      resultDeclaration.value = 'Player ${displayXO[1]} Wins!';
      matchedIndexes.addAll([1, 4, 7]);
      stopTimer();
      _updateScore(displayXO[1]);
    }

    //check 3rd column
    if (displayXO[2] == displayXO[5] &&
        displayXO[2] == displayXO[8] &&
        displayXO[2] != '') {
      resultDeclaration.value = 'Player ${displayXO[2]} Wins!';
      matchedIndexes.addAll([2, 5, 8]);
      stopTimer();
      _updateScore(displayXO[2]);
    }

    //check 1st diagonal
    if (displayXO[0] == displayXO[4] &&
        displayXO[0] == displayXO[8] &&
        displayXO[0] != '') {
      resultDeclaration.value = 'Player ${displayXO[0]} Wins!';
      matchedIndexes.addAll([0, 4, 8]);
      stopTimer();
      _updateScore(displayXO[0]);
    }

    //check 2nd diagonal
    if (displayXO[2] == displayXO[4] &&
        displayXO[2] == displayXO[6] &&
        displayXO[2] != '') {
      resultDeclaration.value = 'Player ${displayXO[2]} Wins!';
      matchedIndexes.addAll([2, 4, 6]);
      stopTimer();
      _updateScore(displayXO[2]);
    }
    if (!winnerFound.value && filledBoxes.value == 9) {
      resultDeclaration.value = 'Nobody Wins!';
      stopTimer();
    }
  }
}
