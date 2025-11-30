import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart';
import 'language_page.dart';
import 'chat_list_page.dart';
import 'enrolled_page.dart';

class ProfilePage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFFFF4B8B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: _ProfileHeader(uid: uid),
            ),

            const SizedBox(height: 16),

            // --- GRAND PANNEAU AVEC SECTIONS ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2933),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: _ProfileBody(uid: uid),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String? uid;

  const _ProfileHeader({Key? key, this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xFFFF4B8B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: uid == null
                        ? null
                        : FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data();
                      final name = (data?['name'] as String?) ?? 'Student';
                      return Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFF4B8B),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfilePage(),
                            ),
                          );
                        },
                        child: const Text('Edit Profile'),
                      ),
                      const SizedBox(width: 8),
                      if (uid != null) _LanguageLabel(uid: uid!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (uid != null) _StatsRow(uid: uid!),
      ],
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final String? uid;

  const _ProfileBody({Key? key, this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        const Text(
          'Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _profileTile(
          title: 'Edit Profile (name, email, password)',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfilePage(),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Activity & statistics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (uid != null) _ActivityStats(uid: uid!),
        const SizedBox(height: 24),
        const Text(
          'Notifications & settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (uid != null)
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() ?? {};
              final enabled = (data['notificationsEnabled'] as bool?) ?? true;

              return SwitchListTile(
                value: enabled,
                onChanged: (value) async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .set({'notificationsEnabled': value}, SetOptions(merge: true));
                },
                activeColor: const Color(0xFFFF4B8B),
                title: const Text(
                  'Notifications',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        _profileTile(
          title: 'Language',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LanguagePage(),
              ),
            );
          },
        ),
        _profileTile(
          title: 'Messages',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatListPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4B8B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String uid;

  const _StatsRow({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('enrolledCourses')
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final total = docs.length;
        int finished = 0;
        for (final d in docs) {
          final p = (d.data()['completedPercentage'] ?? 0).toDouble();
          if (p >= 0.99) finished++;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnrolledPage(),
                  ),
                );
              },
              child: _statItem(title: 'Enrolled', value: '$total'),
            ),
            Container(
              height: 36,
              width: 1,
              color: Colors.white24,
            ),
            _statItem(title: 'Completed', value: '$finished'),
          ],
        );
      },
    );
  }
}

class _ActivityStats extends StatelessWidget {
  final String uid;

  const _ActivityStats({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('enrolledCourses')
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final total = docs.length;
        int finished = 0;
        double sumProgress = 0;
        double sumQuiz = 0;
        int quizCount = 0;

        for (final d in docs) {
          final data = d.data();
          final p = (data['completedPercentage'] ?? 0).toDouble();
          sumProgress += p;
          if (p >= 0.99) finished++;

          final qs = data['quizScore'];
          if (qs is num) {
            sumQuiz += qs.toDouble();
            quizCount++;
          }
        }

        final avgProgress = total == 0 ? 0.0 : sumProgress / total;
        final avgQuiz = quizCount == 0 ? 0.0 : sumQuiz / quizCount;

        final lastLogin = user?.metadata.lastSignInTime;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Enrolled courses', '$total'),
            _infoRow('Completed courses', '$finished'),
            const SizedBox(height: 8),
            Text(
              'General progress: ${(avgProgress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: avgProgress,
              backgroundColor: Colors.white12,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFF4B8B)),
            ),
            const SizedBox(height: 12),
            Text(
              'Average quiz score: ${(avgQuiz * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            if (lastLogin != null)
              _infoRow('Last login', lastLogin.toLocal().toString()),
          ],
        );
      },
    );
  }
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

Widget _profileTile({required String title, VoidCallback? onTap}) {
  return Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
        onTap: onTap,
      ),
      const Divider(color: Colors.white12, height: 1),
    ],
  );
}

Widget _statItem({required String title, required String value}) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
    ],
  );
}

class _LanguageLabel extends StatelessWidget {
  final String uid;

  const _LanguageLabel({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data();
        final lang = data?['language'] as String?;

        if (lang == null || lang.isEmpty) {
          return const SizedBox.shrink();
        }

        return Text(
          'Language: $lang',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        );
      },
    );
  }
}
