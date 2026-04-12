import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure google_fonts is in pubspec.yaml
import '../widgets/menu_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  final Color themeYellow = const Color(0xFFFFB82E);

  void _openDrawer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black26,
        pageBuilder: (_, __, ___) => const MenuDrawer(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // --- CUSTOM TWO-LINE MENU ICON ---
          GestureDetector(
            onTap: () => _openDrawer(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 24, top: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 30,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Styled Title
          Text(
            'About',
            style: GoogleFonts.montserrat(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 32),

          // Logo with Brutalist Border
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(4, 4))
                ],
              ),
              child: Image.asset(
                'assets/pics/logo2.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              'MyApp',
              style: GoogleFonts.montserrat(
                fontSize: 26, 
                fontWeight: FontWeight.w900
              ),
            ),
          ),

          Center(
            child: Text(
              'Version 1.0.0',
              style: GoogleFonts.montserrat(
                fontSize: 14, 
                fontWeight: FontWeight.w600,
                color: Colors.black54
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Description in a stylized card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Text(
              'MyApp is a beautifully simple tool built to help you stay productive and organized every day.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 15, 
                fontWeight: FontWeight.w500,
                color: Colors.black, 
                height: 1.6
              ),
            ),
          ),

          const SizedBox(height: 32),

          _AboutTile(
            icon: Icons.email_outlined,
            label: 'Contact Us',
            subtitle: 'support@myapp.com',
            themeYellow: themeYellow,
            onTap: () {},
          ),
          _AboutTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            themeYellow: themeYellow,
            onTap: () {},
          ),
          _AboutTile(
            icon: Icons.article_outlined,
            label: 'Terms of Service',
            themeYellow: themeYellow,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color themeYellow;

  const _AboutTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    required this.themeYellow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: themeYellow, size: 28),
        title: Text(
          label, 
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800, 
            fontSize: 16
          )
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!, 
                style: GoogleFonts.montserrat(
                  fontSize: 13, 
                  fontWeight: FontWeight.w500
                )
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 18),
        onTap: onTap,
      ),
    );
  }
}