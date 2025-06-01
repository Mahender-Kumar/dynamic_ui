import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AutoVideoBanner extends StatefulWidget {
  @override
  _AutoVideoBannerState createState() => _AutoVideoBannerState();
}

class _AutoVideoBannerState extends State<AutoVideoBanner> {
  final List<String> _videoUrls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
  ];

  // Cache for all controllers
  final Map<int, VideoPlayerController> _controllerCache = {};
  final Map<int, bool> _initializationStatus = {};
  final Map<int, bool> _errorStatus = {};

  VideoPlayerController? _currentController;
  int _currentIndex = 0;
  Timer? _autoChangeTimer;
  bool _isDisposed = false;
  bool _isChangingVideo = false;

  @override
  void initState() {
    super.initState();
    _preloadVideos();
  }

  Future<void> _preloadVideos() async {
    // Start with current video
    await _loadVideo(_currentIndex);
    _setCurrentVideo();

    // Preload next and previous videos in background
    _preloadAdjacentVideos();
  }

  Future<void> _loadVideo(int index) async {
    if (_controllerCache.containsKey(index) || _isDisposed) return;

    try {
      _initializationStatus[index] = false;
      _errorStatus[index] = false;

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(_videoUrls[index]),
      );

      _controllerCache[index] = controller;

      // Add listener for this controller
      controller.addListener(() => _onVideoStateChange(index));

      // Initialize controller
      await controller.initialize();

      if (!_isDisposed && mounted) {
        controller.setLooping(false);
        controller.setVolume(0.5);

        _initializationStatus[index] = true;
        print('Video $index cached successfully');

        // If this is the current video and we're ready, start playing
        if (index == _currentIndex && _currentController == controller) {
          _playCurrentVideo();
        }
      }
    } catch (e) {
      print('Error caching video $index: $e');
      if (!_isDisposed && mounted) {
        _errorStatus[index] = true;
      }
    }
  }

  void _preloadAdjacentVideos() {
    // Preload next video
    final nextIndex = (_currentIndex + 1) % _videoUrls.length;
    if (!_controllerCache.containsKey(nextIndex)) {
      _loadVideo(nextIndex);
    }

    // Preload previous video
    final prevIndex =
        (_currentIndex - 1 + _videoUrls.length) % _videoUrls.length;
    if (!_controllerCache.containsKey(prevIndex)) {
      _loadVideo(prevIndex);
    }
  }

  void _setCurrentVideo() {
    _currentController = _controllerCache[_currentIndex];
    if (_currentController != null &&
        _initializationStatus[_currentIndex] == true) {
      _playCurrentVideo();
    }
  }

  void _onVideoStateChange(int index) {
    final controller = _controllerCache[index];
    if (controller == null || _isDisposed) return;

    // Only handle events for the current video
    if (index != _currentIndex) return;

    // Handle video completion
    if (controller.value.position >= controller.value.duration &&
        controller.value.duration.inMilliseconds > 0) {
      _moveToNextVideo();
    }

    // Handle errors
    if (controller.value.hasError) {
      print('Video $index error: ${controller.value.errorDescription}');
      if (!_isDisposed && mounted) {
        setState(() {
          _errorStatus[index] = true;
        });
        // Auto-skip to next video after error
        Future.delayed(Duration(seconds: 2), () {
          if (!_isDisposed && mounted) {
            _moveToNextVideo();
          }
        });
      }
    }
  }

  void _playCurrentVideo() {
    if (_currentController != null &&
        _initializationStatus[_currentIndex] == true) {
      // Pause all other videos
      _pauseAllOtherVideos();

      // Reset and play current video
      _currentController!.seekTo(Duration.zero);
      _currentController!.play();

      // Start auto-change timer
      _startAutoChangeTimer();

      print('Playing video $_currentIndex');
    }
  }

  void _pauseAllOtherVideos() {
    _controllerCache.forEach((index, controller) {
      if (index != _currentIndex && controller.value.isPlaying) {
        controller.pause();
      }
    });
  }

  void _startAutoChangeTimer() {
    _autoChangeTimer?.cancel();

    if (_currentController != null && _currentController!.value.isInitialized) {
      final duration = _currentController!.value.duration;
      if (duration.inMilliseconds > 0) {
        _autoChangeTimer = Timer(duration, () {
          if (!_isDisposed && mounted) {
            _moveToNextVideo();
          }
        });
      } else {
        // Fallback timer
        _autoChangeTimer = Timer(Duration(seconds: 10), () {
          if (!_isDisposed && mounted) {
            _moveToNextVideo();
          }
        });
      }
    }
  }

  void _moveToNextVideo() {
    if (_isDisposed || _isChangingVideo) return;

    _isChangingVideo = true;
    _autoChangeTimer?.cancel();

    setState(() {
      _currentIndex = (_currentIndex + 1) % _videoUrls.length;
    });

    _changeToVideo(_currentIndex);
  }

  void _moveToPreviousVideo() {
    if (_isDisposed || _isChangingVideo) return;

    _isChangingVideo = true;
    _autoChangeTimer?.cancel();

    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _videoUrls.length) % _videoUrls.length;
    });

    _changeToVideo(_currentIndex);
  }

  void _jumpToVideo(int index) {
    if (_isDisposed || index == _currentIndex || _isChangingVideo) return;

    _isChangingVideo = true;
    _autoChangeTimer?.cancel();

    setState(() {
      _currentIndex = index;
    });

    _changeToVideo(index);
  }

  Future<void> _changeToVideo(int index) async {
    // If video is already cached, switch immediately
    if (_controllerCache.containsKey(index) &&
        _initializationStatus[index] == true) {
      _setCurrentVideo();
      _isChangingVideo = false;

      // Preload adjacent videos for smooth navigation
      _preloadAdjacentVideos();
    } else {
      // Load the video if not cached
      await _loadVideo(index);
      _setCurrentVideo();
      _isChangingVideo = false;

      // Preload adjacent videos
      _preloadAdjacentVideos();
    }

    if (mounted) setState(() {});
  }

  Widget _buildIndicator(int index) {
    bool isActive = index == _currentIndex;
    bool isCached =
        _controllerCache.containsKey(index) &&
        _initializationStatus[index] == true;
    bool hasError = _errorStatus[index] == true;

    Color color;
    if (hasError) {
      color = Colors.red;
    } else if (isActive) {
      color = Colors.blue;
    } else if (isCached) {
      color = Colors.green.shade300; // Green indicates cached
    } else {
      color = Colors.grey.shade400;
    }

    return GestureDetector(
      onTap: () => _jumpToVideo(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 4),
        height: 8,
        width: isActive ? 16 : 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final hasError = _errorStatus[_currentIndex] == true;
    final isInitialized = _initializationStatus[_currentIndex] == true;
    final isCached = _controllerCache.containsKey(_currentIndex);

    if (hasError) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 8),
            Text(
              'Error loading video ${_currentIndex + 1}',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _moveToNextVideo,
              child: Text('Skip to Next'),
            ),
          ],
        ),
      );
    }

    if (!isCached || !isInitialized || _currentController == null) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading video ${_currentIndex + 1}...'),
          ],
        ),
      );
    }

    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        final tapPosition = details.globalPosition.dx;

        if (tapPosition < screenWidth / 2) {
          // Left side tap - previous video
          _moveToPreviousVideo();
        } else {
          // Right side tap - next video
          _moveToNextVideo();
        }
      },
      child: Container(
        height: 200,
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: _currentController!.value.aspectRatio,
          child: VideoPlayer(_currentController!),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoChangeTimer?.cancel();

    // Dispose all cached controllers
    _controllerCache.forEach((index, controller) {
      controller.removeListener(() => _onVideoStateChange(index));
      controller.dispose();
    });
    _controllerCache.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildVideoPlayer(),
        SizedBox(height: 12),
        // Progress indicators (green = cached, blue = current, grey = not loaded)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_videoUrls.length, _buildIndicator),
        ),
        // SizedBox(height: 8),
        // // Video info and controls
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text(
        //       'Video ${_currentIndex + 1} of ${_videoUrls.length}',
        //       style: TextStyle(fontSize: 12, color: Colors.grey),
        //     ),
        //     Row(
        //       children: [
        //         IconButton(
        //           onPressed: _moveToPreviousVideo,
        //           icon: Icon(Icons.skip_previous),
        //           iconSize: 20,
        //         ),
        //         IconButton(
        //           onPressed: _moveToNextVideo,
        //           icon: Icon(Icons.skip_next),
        //           iconSize: 20,
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
        // Cache status
        SizedBox(height: 4),
        // Text(
        //   'Cached: ${_controllerCache.length}/${_videoUrls.length} videos',
        //   style: TextStyle(fontSize: 10, color: Colors.grey),
        // ),
      ],
    );
  }
}
