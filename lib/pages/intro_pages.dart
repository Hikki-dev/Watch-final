import 'package:appcounter/pages/home_page.dart';
import 'package:flutter/material.dart';

class IntroPages extends StatelessWidget {
  const IntroPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(25),
                child: Image.asset('lib/images/logo.png', height: 240),
              ),

              // Padding(
              //   padding: const EdgeInsets.all(25.0),
              //   child: Image.asset('lib/images/logo.png', height: 240),
              // ),
              const SizedBox(height: 48),
              Text(
                "You never actually own a Patek Philippe. You merely look after it for the next generation",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                "- Patek Philippe.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      "ShopNow",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
