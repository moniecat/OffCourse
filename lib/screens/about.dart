import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // ── Contact Us dialog ──────────────────────────────────────────────────────
void _showContactDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.black, width: 2.5),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      title: Row(
        children: [
          const Icon(
            Icons.email_outlined,
            color: Color(0xFFFFB82E),
            size: 26,
          ),
          const SizedBox(width: 10),
          Text(
            'Contact Us',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need help or have feedback?',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.mail, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'offcourse.support@gmail.com',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Reach out to us anytime and we’ll do our best to respond promptly.',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(0, 3)),
              ],
            ),
            child: Text(
              'Close',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  // ── Privacy Policy bottom sheet ────────────────────────────────────────────
  void _showPrivacyPolicy(BuildContext context) {
    _showPolicySheet(
      context: context,
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      content: '''Last updated: April 2026

1. Information We Collect
OffCourse collects only the information you provide when creating an account — your name, email address, and LRN (Learner Reference Number). We also store your learning progress and preferences to personalize your experience.

2. How We Use Your Information
Your information is used solely to operate and improve the OffCourse app. We do not sell, trade, or share your personal data with third parties.

3. Data Storage
All data is securely stored using Google Firebase, which complies with international data protection standards.

4. Your Rights
You may update or delete your account and personal information at any time through the app's Settings page.

5. Children's Privacy
OffCourse is intended for use by students. We do not knowingly collect data from children under 13 without parental consent.

6. Changes to This Policy
We may update this policy from time to time. Continued use of the app after changes constitutes your acceptance of the updated policy.

7. Contact
For privacy concerns, reach us at offcourse.support@gmail.com.''',
    );
  }

  // ── Terms of Service bottom sheet ─────────────────────────────────────────
  void _showTermsOfService(BuildContext context) {
    _showPolicySheet(
      context: context,
      title: 'Terms of Service',
      icon: Icons.article_outlined,
      content: '''Last updated: April 2026

1. Acceptance of Terms
By using OffCourse, you agree to these Terms of Service. If you do not agree, please do not use the app.

2. Use of the App
OffCourse is provided for educational purposes. You agree to use the app only for lawful, personal, and non-commercial purposes.

3. Account Responsibility
You are responsible for maintaining the confidentiality of your account credentials. You are liable for all activities that occur under your account.

4. Intellectual Property
All content within OffCourse — including modules, exercises, and interface design — is the property of the OffCourse team and may not be reproduced without permission.

5. Limitation of Liability
OffCourse is provided "as is." We are not liable for any loss of data, academic results, or damages arising from use of the app.

6. Termination
We reserve the right to suspend or terminate accounts that violate these terms.

7. Changes to Terms
We may revise these terms at any time. Continued use of the app implies acceptance of any updated terms.

8. Contact
For questions regarding these terms, contact us at offcourse.support@gmail.com.''',
    );
  }

  void _showPolicySheet({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(color: Colors.black, width: 3),
                left: BorderSide(color: Colors.black, width: 3),
                right: BorderSide(color: Colors.black, width: 3),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Drag handle
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                // Title row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(icon, size: 26, color: const Color(0xFFFFB82E)),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(color: Colors.black, thickness: 2),
                ),
                // Scrollable content
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    children: [
                      Text(
                        content,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          Text(
            'About',
            style: GoogleFonts.montserrat(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 32),

          // Logo
          Center(
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black, width: 3),
      boxShadow: const [
        BoxShadow(color: Colors.black, offset: Offset(4, 4)),
      ],
    ),
    child: const CircleAvatar(
      radius: 46,
      backgroundImage: AssetImage('assets/pics/logo3.png'),
      backgroundColor: Colors.white,
    ),
  ),
),

          const SizedBox(height: 32),

          _SectionCard(
            child: Text(
              'OffCourse is a learning companion designed to help students stay on track with their modules, manage their schedule, and track their academic progress — quarter by quarter.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 24),

          _SectionLabel(label: 'WHAT YOU CAN DO'),
          const SizedBox(height: 12),

          _FeatureTile(
            icon: Icons.menu_book_rounded,
            color: Colors.teal,
            title: 'Browse Modules',
            description: 'Access learning materials organized by quarter.',
          ),
          const SizedBox(height: 12),
          _FeatureTile(
            icon: Icons.lightbulb_outline_rounded,
            color: themeYellow,
            title: 'Brainstorming Tools',
            description: 'Interactive exercises to sharpen critical thinking.',
          ),
          const SizedBox(height: 12),
          _FeatureTile(
            icon: Icons.person_outline_rounded,
            color: Colors.black,
            title: 'Your Profile',
            description: 'Track your progress and manage your student info.',
          ),

          const SizedBox(height: 32),

          _SectionLabel(label: 'GET IN TOUCH'),
          const SizedBox(height: 12),

          _AboutTile(
            icon: Icons.email_outlined,
            label: 'Contact Us',
            subtitle: 'offcourse.support@gmail.com',
            themeYellow: themeYellow,
            onTap: () => _showContactDialog(context),
          ),
          _AboutTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            themeYellow: themeYellow,
            onTap: () => _showPrivacyPolicy(context),
          ),
          _AboutTile(
            icon: Icons.article_outlined,
            label: 'Terms of Service',
            themeYellow: themeYellow,
            onTap: () => _showTermsOfService(context),
          ),

          const SizedBox(height: 32),

          Center(
            child: Text(
              'Made with ❤️ for Students',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Reusable dialog text field ─────────────────────────────────────────────
class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _DialogTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.montserrat(
            color: Colors.black38, fontSize: 14, fontWeight: FontWeight.w500),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2.5),
        ),
      ),
    );
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Colors.black,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: child,
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _FeatureTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
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
          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: themeYellow, size: 28),
        title: Text(
          label,
          style:
              GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: GoogleFonts.montserrat(
                    fontSize: 13, fontWeight: FontWeight.w500),
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.black, size: 18),
        onTap: onTap,
      ),
    );
  }
}
