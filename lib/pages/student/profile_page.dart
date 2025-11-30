import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart';
import 'language_page.dart';

class ProfilePage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? "User";
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER AVATAR + TEXTE + STATS ---
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
              child: Column(
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
                            Text(
                              "Hello,",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Edit your profile",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (uid != null)
                              _LanguageLabel(uid: uid),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem(title: "Finished", value: "30"),
                      Container(
                        height: 36,
                        width: 1,
                        color: Colors.white24,
                      ),
                      _statItem(title: "Ongoing", value: "11"),
                    ],
                  ),
                ],
              ),
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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    children: [
                      const Text(
                        "Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _profileTile(
                        title: "Edit Profile",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfilePage(),
                            ),
                          );
                        },
                      ),
                      _profileTile(title: "Privacy"),

                      const SizedBox(height: 24),
                      const Text(
                        "General",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _profileTile(
                        title: "Language",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LanguagePage(),
                            ),
                          );
                        },
                      ),
                      _profileTile(title: "Help"),
                      _profileTile(title: "Privacy Policy"),
                      _profileTile(title: "Terms of Service"),

                      const SizedBox(height: 32),
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
                            Navigator.pushReplacementNamed(context, "/login");
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
