import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_in.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _canContinueFromIntro = false;
  Timer? _introDelayTimer;

  // Colors based on your Login screen
  final Color primaryYellow = const Color(0xFFFFC107);
  final Color textDark = Colors.black;
  final Color textGrey = Colors.black54;

  final List<Map<String, String>> _pages = [
    {'title': 'OffCourse', 'image': 'assets/pics/logo.png', 'type': 'intro'},
    {
      'title': 'Free for all',
      'description': 'OffCourse is free to all users. No paid features. Easily download the app and you are ready to learn!',
      'image': 'assets/pics/reel1.png',
      'type': 'reel',
    },
    {
      'title': 'Access anywhere',
      'description': 'OffCourse can be accessible anywhere you go without internet access. Boost your knowledge anywhere.',
      'image': 'assets/pics/reel2.png',
      'type': 'reel',
    },
    {
      'title': 'Research is fun',
      'description': 'OffCourse will help you boost knowledge about the Research subject. OffCourse will guide you how to write research paper.',
      'image': 'assets/pics/reel3.png',
      'type': 'reel',
    },
    {
      'title': 'Easy to use',
      'description': 'OffCourse is easy to use because of its friendly design layout. Users will be able to navigate the app freely.',
      'image': 'assets/pics/reel4.png',
      'type': 'reel',
    },
    {
      'title': 'Welcome to\nOffCourse!',
      'description': 'We give you limitless knowledge about research as you dive in OffCourse!',
      'image': 'assets/pics/welcome.png',
      'type': 'welcome',
    },
  ];

  int get _reelCount => _pages.where((p) => p['type'] == 'reel').length;
  int get _reelIndex => _currentPage - 1;

  @override
  void initState() {
    super.initState();
    _setupIntroDelay();
  }

  void _setupIntroDelay() {
    _introDelayTimer?.cancel();
    _canContinueFromIntro = false;
    _introDelayTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _currentPage == 0) setState(() => _canContinueFromIntro = true);
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      _navigateToSignIn();
    }
  }

  void _navigateToSignIn() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
  }

  @override
  void dispose() {
    _introDelayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Dots with clean black outlines or simple colors
  Widget _buildDots() {
    return Row(
      children: List.generate(_reelCount, (i) {
        final isActive = _reelIndex == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          width: isActive ? 20 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? primaryYellow : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black, width: 1.5),
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
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          if (index == 0) _setupIntroDelay();
        },
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          final page = _pages[index];
          if (page['type'] == 'intro') return _buildIntroPage(page);
          if (page['type'] == 'welcome') return _buildWelcomePage(page);
          return _buildReelPage(page);
        },
      ),
    );
  }

  // INTRO PAGE
  Widget _buildIntroPage(Map<String, String> page) {
    return GestureDetector(
      onTap: _canContinueFromIntro ? _nextPage : null,
      child: Container(
        color: primaryYellow,
        child: Stack(
          children: [
            Center(child: Image.asset(page['image']!, height: 180, fit: BoxFit.contain)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: AnimatedOpacity(
                  opacity: _canContinueFromIntro ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'TAP TO CONTINUE',
                    style: GoogleFonts.montserrat(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REEL PAGES (Matches Input Style)
  Widget _buildReelPage(Map<String, String> page) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            Center(child: Image.asset(page['image']!, height: 340, fit: BoxFit.contain)),
            const Spacer(flex: 2),
            Text(
              page['title']!,
              style: GoogleFonts.montserrat(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              page['description']!,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: textGrey,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDots(),
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: primaryYellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          )
                        ],
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.black, size: 28),
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

  // WELCOME PAGE
  Widget _buildWelcomePage(Map<String, String> page) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            const Spacer(flex: 2),

            // 2. TITLE SECTION
            Column(
              children: [
                Text(
                  'Welcome to',
                  style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),
                Stack(
                  children: [
                    Text(
                      'OffCourse!',
                      style: GoogleFonts.montserrat(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 6
                          ..color = Colors.black,
                      ),
                    ),
                    Text(
                      'OffCourse!',
                      style: GoogleFonts.montserrat(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        color: primaryYellow,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 3. IMAGE (Updated height to 340)
            Transform.translate(
  offset: const Offset(0, -10),
  child: Image.asset(
    page['image']!,
    height: 300, // Updated from 340 to 300
    fit: BoxFit.contain,
  ),
),

            const SizedBox(height: 30),

            // 4. DESCRIPTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                page['description']!,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  color: Colors.black.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),

            const Spacer(flex: 3),

            // 6. BUTTON
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                onTap: _navigateToSignIn,
                child: Container(
                  width: double.infinity,
                  height: 65,
                  decoration: BoxDecoration(
                    color: primaryYellow,
                    borderRadius: BorderRadius.circular(15), 
                    border: Border.all(color: Colors.black, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
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