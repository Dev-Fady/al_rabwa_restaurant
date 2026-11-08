import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Inline dish video player used as the details page hero.
///
/// The video starts paused so mobile browsers allow it to play on tap; while it
/// loads, or when it cannot be played at all, [fallback] (the dish photo) is
/// shown instead.
class ItemVideoPlayer extends StatefulWidget {
  const ItemVideoPlayer({super.key, required this.url, required this.fallback});

  final String url;
  final Widget fallback;

  @override
  State<ItemVideoPlayer> createState() => _ItemVideoPlayerState();
}

class _ItemVideoPlayerState extends State<ItemVideoPlayer> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(ItemVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _replaceController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _replaceController() async {
    final previous = _controller;
    setState(() {
      _controller = null;
      _failed = false;
    });
    await previous?.dispose();
    await _initialize();
  }

  Future<void> _initialize() async {
    if (widget.url.trim().isEmpty) return;

    final uri = Uri.tryParse(widget.url);
    if (uri == null) {
      if (mounted) setState(() => _failed = true);
      return;
    }

    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();
      await controller.setLooping(false);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (_) {
      await controller?.dispose();
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      if (controller.value.position >= controller.value.duration) {
        await controller.seekTo(Duration.zero);
      }
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failed || widget.url.trim().isEmpty) return widget.fallback;

    if (controller == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          widget.fallback,
          const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
        ],
      );
    }

    final size = controller.value.size;
    final video = size.isEmpty
        ? AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          )
        : SizedBox(
            width: size.width,
            height: size.height,
            child: VideoPlayer(controller),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: Colors.black,
          child: FittedBox(fit: BoxFit.cover, child: video),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _togglePlayback,
            child: AnimatedOpacity(
              opacity: controller.value.isPlaying ? 0 : 1,
              duration: const Duration(milliseconds: 180),
              child: Center(child: _PlayBadge(icon: Icons.play_arrow_rounded)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.only(top: 8),
            colors: VideoProgressColors(
              playedColor: context.appColors.brandGreen,
              bufferedColor: Colors.white24,
              backgroundColor: Colors.white54,
            ),
          ),
        ),
        PositionedDirectional(
          end: 12,
          bottom: 18,
          child: Material(
            color: Colors.black.withValues(alpha: 0.45),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: _togglePlayback,
              tooltip: controller.value.isPlaying ? 'Pause' : 'Play',
              icon: Icon(
                controller.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 38),
    );
  }
}
