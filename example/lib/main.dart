import 'package:flutter/material.dart';
import 'package:video_appbar/video_appbar.dart';

void main() {
  runApp(const MainApp());
}

const characters = ['brimstone', 'phoenix', 'sage', 'sova', 'vyper', 'cypher'];

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        'home': (context) => const HomeScreen(),
        'second': (context) => const SecondScreen(),
      },
      initialRoute: 'home',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const mainColor = Color(0xFFff4655);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: VideoAppBar(
          source: VideoAppBarSource.asset(dataSource: 'res/video/video_01.mp4'),
          height: 260,
          volume: 1,

          // Custom unmute button for web
          unmuteButtonBuilder: (context, isMuted, onPressed) {
            return ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
              label: Text(isMuted ? 'Activate' : 'Mute'),
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                elevation: 4,
              ),
            );
          },

          actions: [
            IconButton(
              onPressed: null,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: HomeScreen.mainColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.person, size: 22, color: Colors.white),
              ),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.25), Colors.black],
          ),
          body: Center(
            child: Text(
              'VideoAppBar body',
              style: TextStyle(
                fontSize: 26,
                color: HomeScreen.mainColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: size.height * 0.3,
                    mainAxisExtent: size.height * 0.38,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: characters.length,
                  itemBuilder: (_, index) {
                    return CharacterItem(character: characters[index]);
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

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: VideoAppBar(
          source: VideoAppBarSource.asset(dataSource: 'res/video/video_02.mp4'),
          height: 54,
        ),
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go to home', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

class CharacterItem extends StatelessWidget {
  const CharacterItem({super.key, required this.character});
  final String character;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, 'second');
      },
      child: Column(
        children: [
          Expanded(
            child: Image.asset('res/img/$character.webp', fit: BoxFit.cover),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: Text(
                    character.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
