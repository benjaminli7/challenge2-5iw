import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'HikeMate',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset('assets/images/intro-image.jpg',
                    height: 400, width: 400),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text:  TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.discover,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.groupJoin,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('intro_seen', true);
                      GoRouter.of(context).go('/home');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Color(0xFF0000FF),
                    ),
                    child:  Text(
                      AppLocalizations.of(context)!.login,
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: SvgPicture.asset(
              'assets/images/hike-icon.svg',
              height: 40,
              width: 40,
              color: Colors.white,
            ),
          ),
          Center(
            child: Text(
              dotenv.env['APP_VERSION'] ?? 'Env not loaded',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
