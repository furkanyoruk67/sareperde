import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../constants/app_colors.dart';

class StickyVideoPlayer extends StatefulWidget {
  final String videoId;
  final double initialHeight;
  final double stickyHeight;
  final bool autoPlay;
  final ScrollController? scrollController;

  const StickyVideoPlayer({
    super.key,
    required this.videoId,
    this.initialHeight = 300,
    this.stickyHeight = 180,
    this.autoPlay = true,
    this.scrollController,
  });

  @override
  State<StickyVideoPlayer> createState() => _StickyVideoPlayerState();
}

class _StickyVideoPlayerState extends State<StickyVideoPlayer> 
    with TickerProviderStateMixin {
  late YoutubePlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isSticky = false;
  bool _isVisible = true;
  bool _isMinimized = false;
  
  // Animation controllers for smooth transitions
  late AnimationController _sizeController;
  late AnimationController _opacityController;
  
  // Animations
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeYouTubePlayer();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    // Size animation controller
    _sizeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Opacity animation controller
    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Size animation: from 1.0 (full size) to 0.6 (sticky size)
    _sizeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _sizeController,
      curve: Curves.easeInOutCubic,
    ));
    
    // Opacity animation for smooth fade in/out
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _opacityController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupScrollListener() {
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(() {
        final scrollOffset = widget.scrollController!.offset;
        final shouldBeSticky = scrollOffset > widget.initialHeight * 0.5; // Start sticky after 50% of initial height
        
        if (shouldBeSticky != _isSticky) {
          setState(() {
            _isSticky = shouldBeSticky;
          });
          
          // Animate to sticky position
          if (shouldBeSticky) {
            _sizeController.forward();
            _opacityController.forward();
          } else {
            _sizeController.reverse();
            _opacityController.reverse();
          }
        }
      });
    }
  }

  void _initializeYouTubePlayer() {
    try {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          enableCaption: false,
          showVideoAnnotations: false,
        ),
      );
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Video başlatılırken hata oluştu: $error';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.close();
    _sizeController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
    
    if (_isVisible) {
      _opacityController.forward();
    } else {
      _opacityController.reverse();
    }
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
    
    if (_isMinimized) {
      _sizeController.forward();
    } else {
      _sizeController.reverse();
    }
  }

  void _closeVideo() {
    setState(() {
      _isVisible = false;
      _isSticky = false;
      _isMinimized = false;
    });
    
    _sizeController.reverse();
    _opacityController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return _buildMinimizedButton();
    }

    // If not sticky, show the full video player at the top
    if (!_isSticky) {
      return _buildFullVideoPlayer();
    }

    // If sticky, show the sticky video player
    return _buildStickyVideoPlayer();
  }

  Widget _buildFullVideoPlayer() {
    return Container(
      width: double.infinity,
      height: widget.initialHeight,
      child: Stack(
        children: [
          // Full YouTube Player Instance
          if (_isInitialized && !_hasError)
            Container(
              width: double.infinity,
              height: double.infinity,
              child: YoutubePlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
            )
          else if (_hasError)
            _buildErrorWidget()
          else
            _buildLoadingWidget(),
          
          // Minimize button for full mode
          if (!_isMinimized)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _toggleMinimize,
                  icon: const Icon(
                    Icons.minimize,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStickyVideoPlayer() {
    return AnimatedBuilder(
      animation: Listenable.merge([_sizeController, _opacityController]),
      builder: (context, child) {
        // Calculate position based on animation
        final isSticky = _isSticky;
        final size = _sizeAnimation.value;
        
        // Calculate dimensions
        final width = isSticky 
            ? MediaQuery.of(context).size.width * 0.35 * size // 35% of screen width when sticky
            : MediaQuery.of(context).size.width;
        final height = isSticky 
            ? widget.stickyHeight * size
            : widget.initialHeight;
        
        // Calculate position
        final left = isSticky 
            ? MediaQuery.of(context).size.width - width - 20.0 // 20px from right edge
            : 0.0;
        final top = isSticky ? 20.0 : 0.0; // 20px from top when sticky
        
        return Positioned(
          top: top,
          left: left,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Transform.scale(
              scale: _isMinimized ? 0.8 : 1.0,
              child: Container(
                width: width,
                height: _isMinimized ? 80 : height,
                child: Stack(
                  children: [
                    // Single YouTube Player Instance - NEVER RECREATED
                    if (_isInitialized && !_hasError)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isSticky ? 16 : 0),
                          boxShadow: isSticky ? [
                            BoxShadow(
                              color: AppColors.shadowStrong.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                              spreadRadius: 2,
                            ),
                          ] : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(isSticky ? 16 : 0),
                          child: YoutubePlayer(
                            controller: _controller,
                            aspectRatio: 16 / 9,
                          ),
                        ),
                      )
                    else if (_hasError)
                      _buildErrorWidget()
                    else
                      _buildLoadingWidget(),
                    
                    // Control buttons
                    if (isSticky && !_isMinimized)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Minimize button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                onPressed: _toggleMinimize,
                                icon: const Icon(
                                  Icons.minimize,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Close button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                onPressed: _closeVideo,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimizedButton() {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Positioned(
          top: 20,
          right: 20,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowStrong.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _toggleVisibility,
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_isSticky ? 16 : 0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Video yüklenemedi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isInitialized = false;
                  _hasError = false;
                  _errorMessage = '';
                });
                _initializeYouTubePlayer();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_isSticky ? 16 : 0),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
} 