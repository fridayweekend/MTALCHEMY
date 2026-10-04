class Course {
  final String id;
  final String title;
  final String shortDescription;
  final String instructor;
  final String duration;
  final String level;
  final double rating;
  final double price;
  final List<String> modules;
  final int progress;

  const Course({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.instructor,
    required this.duration,
    required this.level,
    required this.rating,
    required this.price,
    required this.modules,
    this.progress = 0,
  });
}

const List<Course> mockCourses = [
  Course(
    id: 'ei-fundamentals',
    title: 'Emotional Intelligence Fundamentals',
    shortDescription:
        'Build self-awareness, emotional regulation, empathy, and stronger interpersonal skills.',
    instructor: 'MT Alchemy Learning Team',
    duration: '6 weeks',
    level: 'Beginner',
    rating: 4.8,
    price: 499.0,
    progress: 65,
    modules: [
      'Introduction to Emotional Intelligence',
      'Self-Awareness',
      'Emotional Regulation',
      'Empathy and Social Awareness',
      'Building Better Relationships',
    ],
  ),
  Course(
    id: 'mindfulness',
    title: 'Mindfulness at Work',
    shortDescription:
        'Learn practical mindfulness techniques for focus, resilience, and workplace well-being.',
    instructor: 'MT Alchemy Learning Team',
    duration: '4 weeks',
    level: 'Beginner',
    rating: 4.7,
    price: 399.0,
    modules: [
      'Introduction to Mindfulness',
      'Breathing and Attention',
      'Managing Workplace Stress',
      'Mindful Communication',
      'Building a Daily Practice',
    ],
  ),
  Course(
    id: 'leadership',
    title: 'Leadership Essentials',
    shortDescription:
        'Develop practical leadership skills for communication, decision-making, and team growth.',
    instructor: 'MT Alchemy Learning Team',
    duration: '8 weeks',
    level: 'Intermediate',
    rating: 4.9,
    price: 699.0,
    modules: [
      'Foundations of Leadership',
      'Leading Yourself',
      'Leading Teams',
      'Decision-Making',
      'Creating High-Performing Teams',
    ],
  ),
];
