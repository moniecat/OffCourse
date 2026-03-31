import 'package:flutter/material.dart';
import 'sign_in.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'OffCourse',
      'description': 'Tap to continue',
      'image': 'https://thumb.ac-illust.com/15/15da8e1df76c043895b5e7066c30ef37_t.jpeg',
      'type': 'intro',
    },
    {
      'title': 'Free for all',
      'description': 'OffCourse is free to all users. No subscriptions. Easily download the app and you are ready to learn!',
      'image': 'https://thumb.ac-illust.com/15/15da8e1df76c043895b5e7066c30ef37_t.jpeg',
      'type': 'reel',
    },
    {
      'title': 'Access anywhere',
      'description': 'OffCourse can be accessed anywhere you go without internet access. Boost your knowledge on-the-go.',
      'image': 'https://thumb.ac-illust.com/15/15da8e1df76c043895b5e7066c30ef37_t.jpeg',
      'type': 'reel',
    },
    {
      'title': 'Research is fun',
      'description': 'OffCourse will help you finish knowledge about the Research subject. OffCourse will guide you from research paper to its fundamental topics.',
      'image': 'https://thumb.ac-illust.com/15/15da8e1df76c043895b5e7066c30ef37_t.jpeg',
      'type': 'reel',
    },
    {
      'title': 'Easy to use',
      'description': 'OffCourse is easy to use because of its friendly design layout. Users will be able to navigate the app freely.',
      'image': 'https://thumb.ac-illust.com/15/15da8e1df76c043895b5e7066c30ef37_t.jpeg',
      'type': 'reel',
    },
    {
      'title': 'Welcome to\nOffCourse!',
      'description': 'We give you limitless knowledge about research as you dive in OffCourse!',
      'image': 'https://thumb.ac-illust.com/15/15da8e1df76c043895b5e7066c30ef37_t.jpeg',
      'type': 'welcome',
    },
  ];

  int get _reelCount => _pages.where((p) => p['type'] == 'reel').length;
  int get _reelIndex => _currentPage - 1;

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_reelCount, (i) {
        final isActive = _reelIndex == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 10),
          width: isActive ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF4B400) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          final page = _pages[index];
          final type = page['type']!;
          if (type == 'intro') return _buildIntroPage(page);
          if (type == 'welcome') return _buildWelcomePage(page);
          return _buildReelPage(page);
        },
      ),
    );
  }

  Widget _buildIntroPage(Map<String, String> page) {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        color: const Color(0xFFF4B400),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                page['image']!,
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 100, color: Colors.white),
              ),
              const SizedBox(height: 40),
              const Text(
                'OffCourse',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 80),
              Text(
                'Tap to continue →',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReelPage(Map<String, String> page) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Center(
              child: Image.network(
                page['image']!,
                height: 260,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 120, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              page['title']!,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              page['description']!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDots(),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4B400),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF4B400).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _nextPage,
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(Map<String, String> page) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              page['image']!,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 120, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Welcome to\n',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: 'OffCourse!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF4B400),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              page['description']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4B400),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: const Color(0xFFF4B400).withOpacity(0.4),
                ),
                onPressed: _nextPage,
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}