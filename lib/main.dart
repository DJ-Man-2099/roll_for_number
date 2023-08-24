import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bliss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Bliss'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController slideController;
  late Animation<Offset> slideAnimation;
  bool isAnimating = false, isInitial = true;
  List<int> allNumbers = List.generate(30, (index) => index + 1),
      animationNumbers = List.filled(40, 0);
  int animatingIndex = 0, chosen = 0;
  double previous = 0;

  @override
  void initState() {
    super.initState();
    slideController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));
    setAnimationNumbers();
  }

  void setAnimationNumbers() {
    allNumbers.shuffle();
    var other = min(20, allNumbers.length);
    animationNumbers = allNumbers.take(1 + other).toList();
    chosen = animationNumbers.last;
    var list = List.generate(
      other * 2,
      (index) => index + 1,
    )
        .map(
          (
            index,
          ) =>
              index % 2 == 1
                  ? TweenSequenceItem(
                      tween: Tween(
                        begin: const Offset(0, 0),
                        end: const Offset(0, 1),
                      ),
                      weight: (index + 1 / 2) * 2,
                    )
                  : TweenSequenceItem(
                      tween: Tween(
                        begin: const Offset(0, -1),
                        end: const Offset(0, 0),
                      ),
                      weight: (index / 2) * 2,
                    ),
        )
        .toList();
    slideAnimation = TweenSequence<Offset>(list).animate(
        CurvedAnimation(parent: slideController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {
          if (slideAnimation.value.dy < previous && animatingIndex < 20) {
            animatingIndex++;
          }
          previous = slideAnimation.value.dy;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          allNumbers.remove(chosen);
        }
      });
  }

  void resetAnimationNumbers() {
    allNumbers.shuffle();
    animatingIndex = 0;
    var other = min(20, allNumbers.length);
    animationNumbers = [chosen, ...allNumbers.take(other).toList()];
    chosen = animationNumbers.last;
    var list = List.generate(
      other * 2,
      (index) => index + 1,
    )
        .map(
          (
            index,
          ) =>
              index % 2 == 1
                  ? TweenSequenceItem(
                      tween: Tween(
                        begin: const Offset(0, 0),
                        end: const Offset(0, 1),
                      ),
                      weight: (index + 1 / 2) * 2,
                    )
                  : TweenSequenceItem(
                      tween: Tween(
                        begin: const Offset(0, -1),
                        end: const Offset(0, 0),
                      ),
                      weight: (index / 2) * 2,
                    ),
        )
        .toList();
    slideAnimation = TweenSequence<Offset>(list).animate(
        CurvedAnimation(parent: slideController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {
          if (slideAnimation.value.dy < previous && animatingIndex < 20) {
            animatingIndex++;
          }
          previous = slideAnimation.value.dy;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          allNumbers.remove(chosen);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    var number = animationNumbers[animatingIndex].toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Container(
            width: 500,
            height: 500,
            decoration: const BoxDecoration(color: Colors.white),
            child: SlideTransition(
              position: slideAnimation,
              child: isAnimating
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: 1,
                        sigmaY: 10,
                      ),
                      child: Container(
                        color:
                            animatingIndex % 2 == 0 ? Colors.blue : Colors.red,
                        child: Center(
                          child: Text(
                            number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 200,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 200,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!isInitial) {
            resetAnimationNumbers();
          }
          setState(() {
            isAnimating = true;
          });
          slideController.reset();
          slideController.forward().then((value) => setState(() {
                isAnimating = false;
                isInitial = false;
              }));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
