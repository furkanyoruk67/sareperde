import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../constants/app_colors.dart';
import 'dart:async'; // Added for Timer

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final double height;
  final bool autoPlay;

  const VideoPlayerWidget({
    super.key,
    required this.videoPath,
    this.height = 300,
    this.autoPlay = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _hasError = false;
  String _errorMessage = '';
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _showControls = false;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      debugPrint('Initializing video player with path: ${widget.videoPath}');
      
      _controller = VideoPlayerController.asset(widget.videoPath);
      await _controller.initialize();
      
      // Set initial volume
      await _controller.setVolume(_isMuted ? 0.0 : 1.0);
      
      // Add listener for state changes
      _controller.addListener(_videoListener);
      
      setState(() {
        _isInitialized = true;
        _totalDuration = _controller.value.duration;
        _currentPosition = _controller.value.position;
      });
      
      debugPrint('Video player initialized successfully');
      
      // Start autoplay if enabled
      if (widget.autoPlay) {
        await _controller.play();
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      setState(() {
        _isInitialized = true;
        _hasError = true;
        _errorMessage = 'Video yüklenirken hata oluştu: ${e.toString()}';
      });
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
        _currentPosition = _controller.value.position;
        _totalDuration = _controller.value.duration;
      });
    }
  }

  void _togglePlayPause() {
    debugPrint('Toggle play/pause called. Current state: $_isPlaying');
    if (_isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _toggleMute() {
    debugPrint('Toggle mute called. Current state: $_isMuted');
    setState(() {
      _isMuted = !_isMuted;
    });
    _controller.setVolume(_isMuted ? 0.0 : 1.0);
  }

  void _seekTo(Duration position) {
    _controller.seekTo(position);
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleFullscreen() {
    if (!_isInitialized || _hasError) return;
    
    final wasPlaying = _isPlaying;
    final currentPosition = _currentPosition;
    
    debugPrint('Entering fullscreen. Was playing: $wasPlaying, Position: $currentPosition');
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenVideoPlayer(
          controller: _controller,
          wasPlaying: wasPlaying,
          onExit: (shouldResume) {
            if (shouldResume && wasPlaying && !_controller.value.isPlaying) {
              _controller.play();
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Video player
            if (_isInitialized && !_hasError)
              GestureDetector(
                onTap: _showControlsTemporarily,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else if (_hasError)
              _buildErrorWidget()
            else
              _buildLoadingWidget(),
            
            // Controls overlay
            if (_isInitialized && !_hasError && _showControls)
              _buildControlsOverlay(),
            
            // Always visible control buttons
            if (_isInitialized && !_hasError)
              _buildAlwaysVisibleControls(),
            
            // Video title overlay
            _buildVideoTitleOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.surfaceVariant),
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
                _initializeVideoPlayer();
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
      decoration: BoxDecoration(color: AppColors.surfaceVariant),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Column(
        children: [
          // Top controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildControlButton(
                  icon: Icons.fullscreen,
                  onPressed: _toggleFullscreen,
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Bottom controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress bar
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _totalDuration.inMilliseconds > 0
                        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                        : 0.0,
                    onChanged: (value) {
                      final newPosition = Duration(
                        milliseconds: (value * _totalDuration.inMilliseconds).round(),
                      );
                      _seekTo(newPosition);
                    },
                  ),
                ),
                
                // Control buttons
                Row(
                  children: [
                    _buildControlButton(
                      icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                      onPressed: _togglePlayPause,
                      size: 48,
                    ),
                    const SizedBox(width: 16),
                    _buildControlButton(
                      icon: _isMuted ? Icons.volume_off : Icons.volume_up,
                      onPressed: _toggleMute,
                    ),
                    const Spacer(),
                    Text(
                      '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')} / ${_totalDuration.inMinutes}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlwaysVisibleControls() {
    return Positioned(
      top: 16,
      right: 16,
      child: Row(
        children: [
          _buildControlButton(
            icon: Icons.fullscreen,
            onPressed: _toggleFullscreen,
          ),
          const SizedBox(width: 8),
          _buildControlButton(
            icon: _isMuted ? Icons.volume_off : Icons.volume_up,
            onPressed: _toggleMute,
          ),
          const SizedBox(width: 8),
          _buildControlButton(
            icon: _isPlaying ? Icons.pause : Icons.play_arrow,
            onPressed: _togglePlayPause,
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 40,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: AppColors.textPrimary,
          size: size * 0.5,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildVideoTitleOverlay() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Tanıtım Videosu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (_isInitialized && !_hasError)
              Text(
                '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')} / ${_totalDuration.inMinutes}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final bool wasPlaying;
  final Function(bool) onExit;

  const _FullscreenVideoPlayer({
    required this.controller,
    required this.wasPlaying,
    required this.onExit,
  });

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer> {
  bool _isPlaying = false;
  bool _isMuted = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;
    _isMuted = widget.controller.value.volume == 0.0;
    _currentPosition = widget.controller.value.position;
    _totalDuration = widget.controller.value.duration;
    
    widget.controller.addListener(_videoListener);
    _showControlsTemporarily();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.controller.value.isPlaying;
        _currentPosition = widget.controller.value.position;
        _totalDuration = widget.controller.value.duration;
      });
    }
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    widget.controller.setVolume(_isMuted ? 0.0 : 1.0);
  }

  void _seekTo(Duration position) {
    widget.controller.seekTo(position);
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _showControlsTemporarily,
          child: Stack(
            children: [
              // Fullscreen video
              Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: VideoPlayer(widget.controller),
                ),
              ),
              
              // Controls overlay
              if (_showControls)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top controls
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                widget.onExit(_isPlaying);
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.close, color: Colors.white, size: 24),
                            ),
                            Text(
                              'Tanıtım Videosu',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 48), // Balance the layout
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Bottom controls
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Progress bar
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                                thumbColor: AppColors.primary,
                                overlayColor: AppColors.primary.withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: _totalDuration.inMilliseconds > 0
                                    ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                                    : 0.0,
                                onChanged: (value) {
                                  final newPosition = Duration(
                                    milliseconds: (value * _totalDuration.inMilliseconds).round(),
                                  );
                                  _seekTo(newPosition);
                                },
                              ),
                            ),
                            
                            // Control buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: _togglePlayPause,
                                  icon: Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                IconButton(
                                  onPressed: _toggleMute,
                                  icon: Icon(
                                    _isMuted ? Icons.volume_off : Icons.volume_up,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Text(
                                  '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')} / ${_totalDuration.inMinutes}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 