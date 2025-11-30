import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/course.dart';

class CourseQuizPage extends StatefulWidget {
  final Course course;

  const CourseQuizPage({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseQuizPage> createState() => _CourseQuizPageState();
}

class _CourseQuizPageState extends State<CourseQuizPage> {
  // Chaque question : texte, options, index de la bonne réponse
  late final List<_QuizQuestion> _questions;
  final Map<int, int> _answers = {}; // questionIndex -> selectedOptionIndex
  bool _submitting = false;
  double? _lastScore; // entre 0 et 1

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestionsForCourse(widget.course);
  }

  List<_QuizQuestion> _buildQuestionsForCourse(Course course) {
    final name = course.name.toLowerCase();
    final category = course.category.toLowerCase();

    if (name.contains('python')) {
      return [
        _QuizQuestion(
          text: 'Que signifie "print(\"Hello\")" en Python ? ',
          options: [
            'Déclare une variable',
            'Affiche un texte dans la console',
            'Crée une fonction',
            'Arrête le programme',
          ],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Quel type représente un nombre décimal ?',
          options: ['int', 'str', 'float', 'bool'],
          correctIndex: 2,
        ),
        _QuizQuestion(
          text: 'Quelle structure permet de répéter un bloc de code ?',
          options: ['if', 'for', 'try', 'def'],
          correctIndex: 1,
        ),
      ];
    }

    if (name.contains('flutter') || category == 'mobile') {
      return [
        _QuizQuestion(
          text: 'Flutter permet de créer des applications...',
          options: [
            'Uniquement iOS',
            'Uniquement Android',
            'iOS et Android avec un seul code',
            'Uniquement web',
          ],
          correctIndex: 2,
        ),
        _QuizQuestion(
          text: 'Quel langage est utilisé avec Flutter ? ',
          options: ['Java', 'Kotlin', 'Dart', 'Swift'],
          correctIndex: 2,
        ),
        _QuizQuestion(
          text: 'Un widget stateless est...',
          options: [
            'Un widget sans état interne',
            'Un widget avec un état modifiable',
            'Un plugin',
            'Une base de données',
          ],
          correctIndex: 0,
        ),
      ];
    }

    if (name.contains('kotlin')) {
      return [
        _QuizQuestion(
          text: 'Kotlin est principalement utilisé pour...',
          options: [
            'Le développement Android et backend',
            'La modélisation 3D',
            'Le design UX',
            'Les scripts système uniquement',
          ],
          correctIndex: 0,
        ),
        _QuizQuestion(
          text: 'Quel mot-clé permet de déclarer une variable immuable en Kotlin ?',
          options: ['var', 'val', 'let', 'const'],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Que permet l opérateur "?" dans un type Kotlin (ex: String?) ?',
          options: [
            'Rendre le type nullable',
            'Créer une classe abstraite',
            'Importer un module',
            'Étendre une interface',
          ],
          correctIndex: 0,
        ),
      ];
    }

    if (name.contains('java')) {
      return [
        _QuizQuestion(
          text: 'Quel mot-clé définit une classe en Java ?',
          options: ['def', 'class', 'struct', 'interface'],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Quel type permet de stocker un nombre entier ?',
          options: ['String', 'int', 'boolean', 'double'],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Que signifie JVM ?',
          options: [
            'Java Virtual Machine',
            'Java Variable Manager',
            'Json Visual Model',
            'Java Version Manager',
          ],
          correctIndex: 0,
        ),
      ];
    }

    if (name.contains('spring boot') || name.contains('springboot')) {
      return [
        _QuizQuestion(
          text: 'Spring Boot est un framework pour...',
          options: [
            'Applications mobiles uniquement',
            'Applications web et microservices en Java',
            'Bases de données relationnelles',
            'Interfaces utilisateur desktop uniquement',
          ],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Quel fichier contient en général la méthode main dans un projet Spring Boot ?',
          options: [
            'Une classe annotée avec @SpringBootApplication',
            'Un fichier .xml',
            'Un script shell',
            'Un fichier HTML',
          ],
          correctIndex: 0,
        ),
        _QuizQuestion(
          text: 'Quelle annotation est utilisée pour exposer un contrôleur REST ?',
          options: [
            '@Entity',
            '@RestController',
            '@Repository',
            '@Autowired',
          ],
          correctIndex: 1,
        ),
      ];
    }

    if (name.contains('angular')) {
      return [
        _QuizQuestion(
          text: 'Angular est un framework...',
          options: [
            'Backend Java',
            'Frontend TypeScript',
            'Base de données',
            'Outil de design',
          ],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Quel langage est principalement utilisé avec Angular ?',
          options: ['PHP', 'TypeScript', 'Python', 'Ruby'],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Un composant Angular contient...',
          options: [
            'Template + logiques + styles',
            'Uniquement HTML',
            'Uniquement CSS',
            'Uniquement TypeScript',
          ],
          correctIndex: 0,
        ),
      ];
    }

    if (name.contains('vue')) {
      return [
        _QuizQuestion(
          text: 'Quel est le rôle principal de Vue.js ?',
          options: [
            'Framework backend',
            'Framework frontend réactif',
            'SGBD relationnel',
            'Système d exploitation',
          ],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Comment s appelle le fichier principal d un composant Vue à fichier unique ?',
          options: ['*.html', '*.vue', '*.tsx', '*.dart'],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Que permet v-model dans Vue ?',
          options: [
            'La navigation entre pages',
            'Le binding bidirectionnel des données',
            'La gestion des routes backend',
            'La compilation du code',
          ],
          correctIndex: 1,
        ),
      ];
    }

    if (name.contains('react')) {
      return [
        _QuizQuestion(
          text: 'React est principalement utilisé pour...',
          options: [
            'Créer des API REST',
            'Créer des interfaces utilisateur',
            'Gérer une base de données',
            'Compiler du code Java',
          ],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Quel langage est généralement utilisé avec React ?',
          options: ['PHP', 'TypeScript / JavaScript', 'Python', 'C'],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Un composant React est...',
          options: [
            'Une fonction ou classe qui retourne du JSX',
            'Un serveur distant',
            'Une table SQL',
            'Un script shell',
          ],
          correctIndex: 0,
        ),
      ];
    }

    if (name.contains('php')) {
      return [
        _QuizQuestion(
          text: 'PHP est principalement utilisé pour...',
          options: [
            'Le développement backend web',
            'Le design graphique',
            'La modélisation 3D',
            'Les drivers matériels',
          ],
          correctIndex: 0,
        ),
        _QuizQuestion(
          text: 'Quel symbole précède les variables en PHP ?',
          options: ['#', '\$', '@', '%'],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Quel framework est populaire avec PHP ?',
          options: ['Laravel', 'Spring', 'Django', 'Angular'],
          correctIndex: 0,
        ),
      ];
    }

    if (name.contains('mongo') || category.contains('mongodb')) {
      return [
        _QuizQuestion(
          text: 'MongoDB est un SGBD...',
          options: [
            'Relationnel',
            'NoSQL orienté documents',
            'Hiérarchique',
            'Graphique uniquement',
          ],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Dans MongoDB, les données sont stockées dans...',
          options: ['Des tables', 'Des documents JSON-like', 'Des fichiers XML', 'Des fichiers texte'],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Quel outil graphique est souvent utilisé pour MongoDB ?',
          options: ['pgAdmin', 'Compass', 'PhpMyAdmin', 'SSMS'],
          correctIndex: 1,
        ),
      ];
    }

    if (name.contains('sql') || category.contains('database')) {
      return [
        _QuizQuestion(
          text: 'Que signifie SQL ?',
          options: [
            'Structured Query Language',
            'Simple Question Language',
            'System Query List',
            'Server Quick Language',
          ],
          correctIndex: 0,
        ),
        _QuizQuestion(
          text: 'Quelle commande permet de sélectionner des données ?',
          options: ['GET', 'SELECT', 'FETCH', 'PULL'],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Une clé primaire sert à...',
          options: [
            'Compresser les données',
            'Identifier de manière unique une ligne',
            'Crypter une colonne',
            'Créer un index externe',
          ],
          correctIndex: 1,
        ),
      ];
    }

    if (name.contains('html') || name.contains('css')) {
      return [
        _QuizQuestion(
          text: 'HTML sert principalement à...',
          options: [
            'Styliser la page',
            'Structurer le contenu',
            'Gérer la base de données',
            'Compiler le code',
          ],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'CSS sert principalement à...',
          options: [
            'Structurer la page',
            'Styliser et mettre en forme',
            'Gérer les sessions',
            'Créer des API',
          ],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Quel tag HTML définit un lien hypertexte ?',
          options: ['<p>', '<a>', '<h1>', '<div>'],
          correctIndex: 1,
        ),
      ];
    }

    if (name.contains('c#') || name.contains('c sharp')) {
      return [
        _QuizQuestion(
          text: 'C# est principalement utilisé avec...',
          options: ['.NET', 'JVM', 'Node.js', 'Laravel'],
          correctIndex: 0,
        ),
        _QuizQuestion(
          text: 'Quel type stocke un booléen en C# ?',
          options: ['int', 'string', 'bool', 'char'],
          correctIndex: 2,
        ),
        _QuizQuestion(
          text: 'Quel IDE est souvent utilisé pour C# ?',
          options: ['Visual Studio', 'Xcode', 'Android Studio', 'PyCharm'],
          correctIndex: 0,
        ),
      ];
    }

    if (name.contains('node') || name.contains('express')) {
      return [
        _QuizQuestion(
          text: 'Node.js est...',
          options: [
            'Un navigateur',
            'Un runtime JavaScript côté serveur',
            'Une base de données',
            'Un système d exploitation',
          ],
          correctIndex: 1,
        ),
        _QuizQuestion(
          text: 'Express.js est...',
          options: [
            'Un framework backend pour Node.js',
            'Un ORM SQL',
            'Un langage de script',
            'Une bibliothèque CSS',
          ],
          correctIndex: 0,
        ),
        _QuizQuestion(
          text: 'Quel format est souvent utilisé pour les API Node ?',
          options: ['XML uniquement', 'JSON', 'CSV', 'PDF'],
          correctIndex: 1,
        ),
      ];
    }

    // Par défaut : petit quiz générique
    return [
      _QuizQuestion(
        text: 'Pourquoi suivre ce cours ? ',
        options: [
          'Pour progresser',
          'Pour ne rien apprendre',
          'Pour supprimer mes connaissances',
          'Par hasard uniquement',
        ],
        correctIndex: 0,
      ),
      _QuizQuestion(
        text: 'Comment bien utiliser ce cours ?',
        options: [
          'Ne jamais pratiquer',
          'Regarder une seule leçon',
          'Pratiquer régulièrement et prendre des notes',
          'Ignorer les exercices',
        ],
        correctIndex: 2,
      ),
      _QuizQuestion(
        text: 'Que faire après le cours ? ',
        options: [
          'Appliquer dans un projet',
          'Tout oublier',
          'Ne plus coder',
          'Supprimer l app',
        ],
        correctIndex: 0,
      ),
    ];
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
    });

    int correct = 0;
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final selected = _answers[i];
      if (selected != null && selected == q.correctIndex) {
        correct++;
      }
    }

    final score = _questions.isEmpty ? 0.0 : correct / _questions.length;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('enrolledCourses')
          .doc(widget.course.id);

      await ref.set(
        {
          'quizScore': score,
          'quizCorrectAnswers': correct,
          'quizTotalQuestions': _questions.length,
        },
        SetOptions(merge: true),
      );
    }

    setState(() {
      _submitting = false;
      _lastScore = score;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Score du quiz : $correct/${_questions.length}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4B8B),
        title: Text(widget.course.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mini quiz (3-5 questions)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Répondez aux questions ci-dessous puis validez pour voir votre score.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            if (_lastScore != null) ...[
              Text(
                'Dernier score : ${(_lastScore! * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return Card(
                    color: const Color(0xFF1F2933),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}. ${q.text}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(q.options.length, (optIndex) {
                            return RadioListTile<int>(
                              activeColor: const Color(0xFFFF4B8B),
                              value: optIndex,
                              groupValue: _answers[index],
                              onChanged: (val) {
                                setState(() {
                                  _answers[index] = val!;
                                });
                              },
                              title: Text(
                                q.options[optIndex],
                                style: const TextStyle(color: Colors.white70),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4B8B),
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Valider le quiz',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;

  _QuizQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}
