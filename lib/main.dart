import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Stopwatch",
      home: Stopwatch(),
    );
  }
}

class Stopwatch extends StatefulWidget {
  const Stopwatch({Key? key}) : super(key: key);
  @override
  State createState() => _StopwatchState();
}

class _StopwatchState extends State<Stopwatch> {
  int milliseconds = 0;
  Timer? timer;
  final laps = <int>[];
  final itemHeight = 50.0;
  final scrollController = ScrollController();

  void _onTick(Timer timer) {
    setState(() {
      milliseconds += 100;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    // Prevent multiple timers from being created
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 100), _onTick);
    }
  }

  void stopTimer(BuildContext context) {
    timer?.cancel();
    final controller =
        showBottomSheet(context: context, builder: _buildRunCompleteSheet);
    Future.delayed(Duration(seconds: 5)).then((_) {
      controller.close();
    });
  }

  void resetTimer() {
    // stopTimer();
    laps.clear();
    setState(() {
      milliseconds = 0;
    });
  }

  Widget _buildRunCompleteSheet(BuildContext context) {
    final totalRuntime = laps.fold(milliseconds, (total, lap) => total + lap);
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
        child: Container(
      color: Colors.black.withOpacity(0.8),
      width: double.infinity,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Run Finished!',
                style: textTheme.headlineSmall?.copyWith(color: Colors.white)),
            Text(
              "Total Run Time is ${_secondsText(totalRuntime)}.",
              style: TextStyle(color: Colors.white),
            ),
          ])),
    ));
  }

  void _lap() {
    if (milliseconds == 0) return;
    setState(() {
      laps.add(milliseconds);
      milliseconds = 0;
    });
    scrollController.animateTo(
      itemHeight * laps.length,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  String _secondsText(int milliseconds) {
    final seconds = milliseconds / 1000;
    return '${seconds.toStringAsFixed(1)} seconds';
  }

  Widget _buildLapDisplay() {
    return Scrollbar(
        child: ListView.builder(
      controller: scrollController,
      itemExtent: itemHeight,
      itemCount: laps.length,
      itemBuilder: (context, index) {
        final milliseconds = laps[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 50),
          title: Text('Lap ${index + 1}'),
          trailing: Text(_secondsText(milliseconds)),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stopwatch"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 0, // This makes the container take up only required space
            child: Container(
              width: double.infinity, // Forces container to fill the width
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(
                  vertical: 20), // Adjusts the vertical padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Lap ${laps.length + 1}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    _secondsText(milliseconds),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(
                      height: 20), // Adds space between the text and buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: startTimer,
                        child: const Text(
                          'Start',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Builder(
                        builder: (context) => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => stopTimer(context),
                          child: const Text(
                            'Stop',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: resetTimer,
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                          ),
                          onPressed: _lap,
                          child: const Text(
                            'Lap',
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildLapDisplay(),
          ),
        ],
      ),
    );
  }
}
