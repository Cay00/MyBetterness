import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        //color: const Color.fromARGB(255, 134, 134, 134),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xffffffff),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Color(0xff03070c), size: 25),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xffffffff),
              shape: BoxShape.circle,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: const [
                Center(child: Icon(Icons.notifications_none)),
                Positioned(
                  top: 2,
                  right: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 10, height: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}