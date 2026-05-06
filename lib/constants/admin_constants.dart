import 'package:flutter/material.dart';

/// Admin UI Constants
class AdminColors {
  // OffCourse Brand Colors
  static const Color courseColor = Color(0xFFFFBC1F);
  static const Color moduleColor = Color(0xFFFFBC1F); 
  static const Color questionColor = Color(0xFFFFBC1F); 

  // User Management Colors
  static const Color adminColor = Color(0xFFFFBC1F); // Brand Gold/Orange
  static const Color studentColor = Color(0xFFFFBC1F); 
}

/// Admin UI Icons
class AdminIcons {
  // Content Management Icons
  static const IconData courseIcon = Icons.menu_book_rounded;
  static const IconData moduleIcon = Icons.layers_rounded;
  static const IconData questionIcon = Icons.help_center_rounded;

  // User Management Icons
  static const IconData adminIcon = Icons.admin_panel_settings_rounded;
  static const IconData studentIcon = Icons.school_rounded;

  // Action Icons
  static const IconData addCourseIcon = Icons.library_add_rounded;
  static const IconData addModuleIcon = Icons.post_add_rounded;
  static const IconData addQuestionIcon = Icons.quiz_rounded;

  static const IconData manageCourseIcon = Icons.folder_open_rounded;
  static const IconData manageModuleIcon = Icons.edit_rounded;
  static const IconData manageQuestionIcon = Icons.help_outline_rounded;

  static const IconData manageUsersIcon = Icons.people_rounded;
}
