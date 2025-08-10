import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class StickyVideoPlayer extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final double initialHeight;
  final double stickyHeight;
  final double stickyWidth;
  final ScrollController? scrollController;
  final double stickyStartOffset;

  const StickyVideoPlayer({
    super.key,
    required this.videoId,
    this.autoPlay = false,
    this.initialHeight = 250,
    this.stickyHeight = 150,
    this.stickyWidth = 250,
    this.scrollController,
    this.stickyStartOffset = 0,
  });

  @override
  State<StickyVideoPlayer> createState() => _StickyVideoPlayerState();
}

class _StickyVideoPlayerState extends State<StickyVideoPlayer>
    with TickerProviderStateMixin {
  late final AnimationController _sizeController;
  late final AnimationController _opacityController;
  late final Animation<double> _sizeAnimation;
  YoutubePlayerController? _controller;
  bool _isSticky = false;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeYouTubePlayer();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _sizeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _opacityController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _sizeAnimation = Tween<double>(
      begin: widget.initialHeight,
      end: widget.stickyHeight,
    ).animate(CurvedAnimation(parent: _sizeController, curve: Curves.easeInOut));


  }

  void _initializeYouTubePlayer() {
    if (_controller != null) return; // Zaten oluşturulmuşsa tekrar oluşturma

    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: widget.autoPlay,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        enableCaption: false,
        showVideoAnnotations: false,
      ),
    );



    setState(() {
      _isInitialized = true;
      _hasError = false;
    });
  }

  void _setupScrollListener() {
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(() {
        final scrollOffset = widget.scrollController!.offset;
        final shouldBeSticky = scrollOffset > widget.stickyStartOffset;

        if (shouldBeSticky != _isSticky) {
          setState(() => _isSticky = shouldBeSticky);

          if (shouldBeSticky) {
            _sizeController.forward();
          } else {
            _sizeController.reverse();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.close();
    _sizeController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isSticky ? Alignment.bottomRight : Alignment.topCenter,
      child: AnimatedBuilder(
        animation: _sizeAnimation,
        builder: (context, child) {
          return Container(
            width: _isSticky ? widget.stickyWidth : double.infinity,
            height: _sizeAnimation.value,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(_isSticky ? 12 : 0),
            ),
            child: _buildVideoPlayer(),
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return const Center(
        child: Text(
          'Video yüklenemedi',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return YoutubePlayer(
      controller: _controller!,
      aspectRatio: 16 / 9,
    );
  }
}
