import 'package:flutter/material.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/biology.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/earth_study.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/history.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/khmer_sub/khmer.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/math_sub/math.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/physic.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/technology.dart';

class CoursesView extends StatelessWidget {
  const CoursesView({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "Your Courses",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black, // stays black even in dark mode
          ),
        ),
        const SizedBox(height: 16),
        _courseCard(
          context: context,
          title: "Khmer Language",
          subtitle: "Learn the Khmer language from basics to advanced.",
          color: const Color(0xff6c5ce7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KhmerView(),
              ),
            );
          },
        ),
        _courseCard(
          context: context,
          title: "Mathematics",
          subtitle: "Explore the world of numbers and equations.",
          color: const Color(0xff6c5ce7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Mathview(),
              ),
            );
          },
        ),
        _courseCard(
          context: context,
          title: "Physics",
          subtitle: "Understand the laws that govern the universe.",
          color: const Color(0xff6c5ce7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Physicview(),
              ),
            );
          },
        ),
                _courseCard(
          context: context,
          title: "Biology",
          subtitle: "Study the science of life and living organisms.",
          color: const Color(0xff6c5ce7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Biologyview(),
              ),
            );
          },
        ),
        _courseCard(
          context: context,
          title: "Chemistry",
          subtitle: "Understand the substances that make up matter.",
          color: const Color(0xff6c5ce7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Historyview(),
              ),
            );
          },
        ),
        _courseCard(
          context: context,
          title: "Technology",
          subtitle: "Dive into the world of modern technology and innovation.",
          color: const Color(0xff6c5ce7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Technologyview(),
              ),
            );
          },
        ),
        _courseCard(
          context: context,
          title: "History",
          subtitle: "Explore the events that shaped our world.",
          color: const Color(0xff6c5ce7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Historyview(),
              ),
            );
          },
        ),
        _courseCard(
          context: context,
          title: "Geography",
          subtitle: "Discover the physical features of our planet.",
          color: const Color(0xff6c5ce7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Historyview(),
              ),
            );
          },
        ),
        _courseCard(
          context: context,
          title: "Ethics",
          subtitle: "Learn about moral principles and values.",
          color: const Color(0xff6c5ce7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Historyview(),
              ),
            );
          },
        ),
        _courseCard(
          context: context,
          title: "Earth Science",
          subtitle: "Explore the physical constitution of the Earth.",
          color: const Color(0xff6c5ce7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EarthStudyview(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _courseCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.school, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
