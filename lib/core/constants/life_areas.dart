import 'package:flutter/material.dart';

/// [LifeArea] represents the core domain areas of focus in HabitFlow.
/// 
/// These areas categorize habits, goals, and rewards across the application.
enum LifeArea {
  health(
    name: 'Health',
    icon: Icons.favorite_rounded,
    color: Color(0xFFEF4444), // Red
  ),
  learning(
    name: 'Learning',
    icon: Icons.school_rounded,
    color: Color(0xFF3B82F6), // Blue
  ),
  discipline(
    name: 'Discipline',
    icon: Icons.timer_rounded,
    color: Color(0xFF6B7280), // Gray
  ),
  family(
    name: 'Family',
    icon: Icons.family_restroom_rounded,
    color: Color(0xFF10B981), // Emerald
  ),
  finance(
    name: 'Finance',
    icon: Icons.payments_rounded,
    color: Color(0xFF22C55E), // Green
  ),
  fitness(
    name: 'Fitness',
    icon: Icons.fitness_center_rounded,
    color: Color(0xFFF97316), // Orange
  ),
  spiritual(
    name: 'Spiritual',
    icon: Icons.self_improvement_rounded,
    color: Color(0xFF8B5CF6), // Purple
  ),
  creativity(
    name: 'Creativity',
    icon: Icons.palette_rounded,
    color: Color(0xFFF59E0B), // Amber
  ),
  social(
    name: 'Social',
    icon: Icons.group_rounded,
    color: Color(0xFF14B8A6), // Teal
  );

  const LifeArea({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;
}
