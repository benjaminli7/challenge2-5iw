import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

class HikeDetailsPage extends StatelessWidget {
  final Hike hike;

  const HikeDetailsPage({required this.hike, super.key});

  @override
  Widget build(BuildContext context) {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'API_KEY not found';

    return Scaffold(
      appBar: AppBar(title: const Text('Hike Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${hike.name}', style: const TextStyle(fontSize: 20)),
              Text('Description: ${hike.description}', style: const TextStyle(fontSize: 20)),
              Text('Duration: ${hike.duration}', style: const TextStyle(fontSize: 20)),
              Text('Difficulty: ${hike.difficulty}', style: const TextStyle(fontSize: 20)),
              Text('Is Valid: ${hike.isApproved.toString()}', style: const TextStyle(fontSize: 20)),
              SizedBox(
                width: 200,
                height: 200,
                child: Image.network(
                  Uri.parse("$baseUrl${hike.image}").toString(),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  if (userProvider.user != null) {
                    final token = userProvider.user!.token;
                    await context.read<AdminProvider>().deleteHike(token, hike.id);

                    context.pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete Hike'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
