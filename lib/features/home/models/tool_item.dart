import 'package:flutter/material.dart';

class ToolItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color softColor;
  final String route;
  final String category; // 'popular', 'edit', 'convert', 'utilities'
  final String tag;

  const ToolItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.softColor,
    required this.route,
    required this.category,
    required this.tag,
  });
}
