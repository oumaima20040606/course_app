import 'package:flutter/material.dart';

class PdfSummaryPage extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PdfSummaryPage({Key? key, required this.title, required this.pdfUrl})
      : super(key: key);

  @override
  State<PdfSummaryPage> createState() => _PdfSummaryPageState();
}

class _PdfSummaryPageState extends State<PdfSummaryPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Simulation d un appel IA : petit délai puis affichage d un résumé fictif
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4B8B),
        title: Text(
          'Résumé automatique',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4B8B)),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Résumé généré automatiquement (démo)',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Ce résumé est un exemple simulé. Dans une version future, l application utilisera une IA pour analyser réellement le contenu du PDF et produire un résumé personnalisé.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Résumé global',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Le document présente les concepts clés du sujet, en partant des bases jusqu aux éléments plus avancés. Il met l accent sur la compréhension progressive, illustrée par des exemples concrets, des schémas et des explications pas à pas.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Points clés',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _BulletPoint(text: 'Introduction claire au sujet et aux objectifs du document.'),
                    const _BulletPoint(text: 'Explications progressives avec exemples simples et concrets.'),
                    const _BulletPoint(text: 'Mise en avant des bonnes pratiques et des erreurs à éviter.'),
                    const _BulletPoint(text: 'Récapitulatif final pour aider à mémoriser les notions essentielles.'),
                    const SizedBox(height: 24),
                    const Text(
                      'Remarque',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Pour la démo, le résumé ne dépend pas encore réellement du PDF sélectionné, mais l interface est prête pour connecter une vraie API d IA.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '\u2022 ',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
