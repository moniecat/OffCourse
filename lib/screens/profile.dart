import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/home.dart'; // Ensure this path is correct

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Exact Colors & Thickness
  static const Color brandYellow = Color(0xFFFFC21C);
  static const Color bgWhite = Colors.white;
  static const Color textBlack = Color(0xFF000000);
  static const Color textGrey = Color(0xFF6B6B6B);
  static const double thickBorder = 3.5; // Main container border
  static const double elementBorder = 2.5; // Button/Chip border

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _lrnController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Jane Doe');
    _bioController = TextEditingController(
        text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.');
    _lrnController = TextEditingController(text: '123456789');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _lrnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: brandYellow,
      resizeToAvoidBottomInset: false, // We handle height manually for the "shrinking" effect
      body: Column(
        children: [
          // 1. TOP YELLOW SECTION (Shrinks when keyboard is up)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            height: isKeyboardOpen ? size.height * 0.12 : size.height * 0.45,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Back Button remains visible in all states
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _buildCircularButton(
                        Icons.chevron_left,
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        ),
                      ),
                    ),
                  ),
                  
                  // Hide Avatar & Progress when typing (middle images in your reference)
                  if (!isKeyboardOpen) ...[
                    const Spacer(),
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: textBlack, width: 1.5),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://api.dicebear.com/7.x/avataaars/png?seed=Jane&hair=long&glasses=round&mouth=smile&backgroundColor=transparent',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildProgressSection(),
                    const SizedBox(height: 25),
                  ]
                ],
              ),
            ),
          ),

          // 2. BOTTOM WHITE SHEET
          Expanded(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              // Pushes the content up so it's visible above the keyboard
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgWhite,
                  // Heavy Black Border wrapping the top and sides
                  border: const Border(
                    top: BorderSide(color: textBlack, width: thickBorder),
                    left: BorderSide(color: textBlack, width: thickBorder),
                    right: BorderSide(color: textBlack, width: thickBorder),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(25, 12, 25, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 60,
                            height: 5,
                            decoration: BoxDecoration(
                              color: textBlack,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        // Edit Icon
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => setState(() => _isEditing = !_isEditing),
                            icon: Icon(
                                _isEditing ? Icons.check_circle_outline : Icons.edit_outlined,
                                color: textBlack,
                                size: 28),
                          ),
                        ),

                        // Name Row + Status Dot
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                enabled: _isEditing,
                                style: GoogleFonts.montserrat(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.5,
                                  color: textBlack,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _nameController.text == "Name" ? textBlack : brandYellow,
                                shape: BoxShape.circle,
                                border: Border.all(color: textBlack, width: 2),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // Bio Input
                        TextField(
                          controller: _bioController,
                          enabled: _isEditing,
                          maxLines: null,
                          style: GoogleFonts.montserrat(
                            fontSize: 17,
                            color: textGrey,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            border: _isEditing ? const UnderlineInputBorder() : InputBorder.none,
                            hintText: "Bionote",
                            isDense: true,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Notes Chip
                        _buildChip('Notes'),

                        const SizedBox(height: 40),

                        // LRN Input
                        Row(
                          children: [
                            Text(
                              'LRN: ',
                              style: GoogleFonts.montserrat(
                                color: textGrey,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _lrnController,
                                enabled: _isEditing,
                                style: GoogleFonts.montserrat(
                                  color: textGrey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 55),
      child: Column(
        children: [
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 8),
          Text('0%', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 18)),
          Text('Quarter 1', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 26, color: bgWhite)),
          Text('Progress', style: GoogleFonts.montserrat(color: bgWhite, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bgWhite,
          shape: BoxShape.circle,
          border: Border.all(color: textBlack, width: elementBorder),
        ),
        child: Icon(icon, color: textBlack, size: 28),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: textBlack, width: elementBorder),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }
}