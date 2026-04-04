import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/menu_drawer.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  static const _faqs = [
    _FAQ('What is this app?', 'This app helps you manage your tasks easily.'),
    _FAQ('How do I reset my password?', 'Go to Settings > Account > Reset Password.'),
    _FAQ('Is my data secure?', 'Yes, all data is encrypted and stored securely.'),
    _FAQ('How do I contact support?', 'You can reach us via Settings > About > Contact.'),
  ];

  void openDrawer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black26,
        pageBuilder: (_, _, _) => const MenuDrawer(),
        transitionsBuilder: (_, animation, _, child) {
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
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () => openDrawer(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      width: 30,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 6),
                  Container(
                      width: 30,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2))),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                Text(
                  'FAQ',
                  style: GoogleFonts.montserrat(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -1.5,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                ..._faqs.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Color themeColor = idx % 2 == 0
                      ? const Color(0xFF2BB19B)
                      : const Color(0xFFFFC12F);
                  return _FAQTile(faq: entry.value, accentColor: themeColor);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
} // <--- THIS WAS MISSING: Closing brace for FAQPage

class _FAQ {
  final String question;
  final String answer;
  const _FAQ(this.question, this.answer);
}

class _FAQTile extends StatefulWidget {
  final _FAQ faq;
  final Color accentColor;
  const _FAQTile({required this.faq, required this.accentColor});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Container(
        transform: Matrix4.translationValues(-1, -6, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.black, width: 2.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            children: [
              Container(height: 12, color: widget.accentColor),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  onExpansionChanged: (val) => setState(() => _expanded = val),
                  trailing: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_right,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    widget.faq.question,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Text(
                        widget.faq.answer,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}