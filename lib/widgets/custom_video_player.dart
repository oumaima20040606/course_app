import 'package:course_app/constants/icons.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final VoidCallback? onFinished;

  const CustomVideoPlayer({Key? key, this.videoUrl, this.onFinished})
      : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? _controller;
  YoutubePlayerController? _ytController;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final url = widget.videoUrl?.isNotEmpty == true
        ? widget.videoUrl!
        : 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
    final ytId = YoutubePlayerController.convertUrlToId(url);

    // --- Cas 1 : URL YouTube -> utiliser YoutubePlayer ---
    if (ytId != null) {
      _ytController = YoutubePlayerController.fromVideoId(
        videoId: ytId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          playsInline: true,
        ),
      );

      setState(() {
        isReady = true;
      });
      return;
    }

    // --- Cas 2 : URL directe (MP4, etc.) -> VideoPlayer ---
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          isReady = true;
        });
      });

    _controller!.addListener(() {
      if (!mounted) return;
      setState(() {});

      // notifier quand la vidéo est terminée
      if (_controller!.value.isInitialized &&
          _controller!.value.position >= _controller!.value.duration &&
          widget.onFinished != null) {
        widget.onFinished!();
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      final url = widget.videoUrl ?? '';
      final ytId = YoutubePlayerController.convertUrlToId(url);

      // Si c'est une URL YouTube et qu'on a déjà un contrôleur, on charge juste la nouvelle vidéo
      if (ytId != null) {
        if (_ytController != null) {
          _ytController!.loadVideoById(videoId: ytId);
          return;
        } else {
          // pas encore de contrôleur YouTube -> on l'initialise
          _ytController = YoutubePlayerController.fromVideoId(
            videoId: ytId,
            autoPlay: false,
            params: const YoutubePlayerParams(
              showFullscreenButton: true,
              playsInline: true,
            ),
          );
          setState(() => isReady = true);
          return;
        }
      }

      // Sinon, on reset le player vidéo classique
      _ytController?.close();
      _ytController = null;
      _controller?.dispose();
      _controller = null;
      isReady = false;
      _initController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _ytController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    // Si on a un contrôleur YouTube, on affiche YoutubePlayer
    if (_ytController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(controller: _ytController!),
      );
    }

    // Sinon, on utilise le player vidéo classique
    final controller = _controller!;
    final isFinished = controller.value.position >= controller.value.duration;

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller),

          // --- PLAY / PAUSE BUTTON ---
          GestureDetector(
            onTap: () {
              if (isFinished) {
                controller.seekTo(Duration.zero);
                controller.play();
              } else if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            },
            child: Image.asset(
              controller.value.isPlaying ? icPause : icLearning,
              height: 55,
            ),
          ),
        ],
      ),
    );
  }
}
