import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBorder = Color(0xFF1A1C1E);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBorder),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Empty Page", 
          style: TextStyle(color: darkBorder, fontWeight: FontWeight.bold)
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty_rounded, size: 80, color: darkBorder),
            const SizedBox(height: 16),
            const Text(
              "Nothing here yet!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBorder,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: darkBorder,
                side: const BorderSide(color: darkBorder, width: 3),
                elevation: 0, // Set elevation to 0 here directly
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => Navigator.pop(context),
              // Fixed: Changed FontWeight.black to FontWeight.w900
              child: const Text(
                "GO BACK", 
                style: TextStyle(fontWeight: FontWeight.w900) 
              ),
            ),
          ],
        ),
      ),
    );
  }
}