import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AutoVideoBanner extends StatefulWidget {
  final List<String> videoUrls;
  const AutoVideoBanner({super.key, required this.videoUrls});
  @override
  _AutoVideoBannerState createState() => _AutoVideoBannerState();
}

class _AutoVideoBannerState extends State<AutoVideoBanner> {
  // Cache for all controllers
  final Map<int, VideoPlayerController> _controllerCache = {};
  final Map<int, bool> _initializationStatus = {};
  final Map<int, bool> _errorStatus = {};

  VideoPlayerController? _currentController;
  int _currentIndex = 0;
  Timer? _autoChangeTimer;
  bool _isDisposed = false;
  bool _isChangingVideo = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializeAllVideos();
  }

  /// Initialize all videos at once for smooth playback
  Future<void> _initializeAllVideos() async {
    if (_isDisposed) return;

    _isInitializing = true;

    // Initialize all videos concurrently
    final List<Future<void>> initializationFutures = [];

    for (int i = 0; i < widget.videoUrls.length; i++) {
      initializationFutures.add(_initializeVideo(i));
    }

    // Wait for all videos to initialize (or fail)
    await Future.wait(initializationFutures);

    _isInitializing = false;

    // Start playing the first video once all are initialized
    if (!_isDisposed && mounted) {
      _setCurrentVideo();
      setState(() {});
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (_controllerCache.containsKey(index) || _isDisposed) return;

    try {
      _initializationStatus[index] = false;
      _errorStatus[index] = false;

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrls[index]),
      );

      _controllerCache[index] = controller;

      // Add listener for this controller
      controller.addListener(() => _onVideoStateChange(index));

      // Initialize controller
      await controller.initialize();

      if (!_isDisposed && mounted) {
        // Configure video settings
        controller.setLooping(false);
        controller.setVolume(0.5);

        // Ensure video is paused initially (only current video should play)
        if (index != _currentIndex) {
          controller.pause();
        }

        _initializationStatus[index] = true;
        print('Video $index initialized successfully');
      }
    } catch (e) {
      print('Error initializing video $index: $e');
      if (!_isDisposed && mounted) {
        _errorStatus[index] = true;
        _initializationStatus[index] = false;
      }
    }
  }

  void _setCurrentVideo() {
    if (_isDisposed) return;

    _currentController = _controllerCache[_currentIndex];

    if (_currentController != null &&
        _initializationStatus[_currentIndex] == true) {
      _playCurrentVideo();
    } else if (_errorStatus[_currentIndex] == true) {
      // Auto-skip to next video if current has error
      Future.delayed(Duration(seconds: 1), () {
        if (!_isDisposed && mounted) {
          _moveToNextVideo();
        }
      });
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
        Future.delayed(Duration(seconds: 1), () {
          if (!_isDisposed && mounted) {
            _moveToNextVideo();
          }
        });
      }
    }
  }

  void _playCurrentVideo() {
    if (_currentController == null ||
        _initializationStatus[_currentIndex] != true) {
      return;
    }

    // Pause ALL other videos first
    _pauseAllOtherVideos();

    // Reset current video to beginning and play
    _currentController!.seekTo(Duration.zero);
    _currentController!.play();

    // Start auto-change timer based on video duration
    _startAutoChangeTimer();

    print('Playing video $_currentIndex');
  }

  void _pauseAllOtherVideos() {
    _controllerCache.forEach((index, controller) {
      if (index != _currentIndex) {
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
        // Fallback timer for videos without clear duration
        _autoChangeTimer = Timer(Duration(seconds: 10), () {
          if (!_isDisposed && mounted) {
            _moveToNextVideo();
          }
        });
      }
    }
  }

  void _moveToNextVideo() {
    _changeVideo((_currentIndex + 1) % widget.videoUrls.length);
  }

  void _moveToPreviousVideo() {
    _changeVideo(
      (_currentIndex - 1 + widget.videoUrls.length) % widget.videoUrls.length,
    );
  }

  void _jumpToVideo(int index) {
    if (index == _currentIndex) return;
    _changeVideo(index);
  }

  void _changeVideo(int newIndex) {
    if (_isDisposed || _isChangingVideo) return;

    _isChangingVideo = true;
    _autoChangeTimer?.cancel();

    // Pause current video immediately
    if (_currentController != null) {
      _currentController!.pause();
    }

    setState(() {
      _currentIndex = newIndex;
    });

    // Set new current video and play
    _setCurrentVideo();

    _isChangingVideo = false;
  }

  Widget _buildIndicator(int index) {
    bool isActive = index == _currentIndex;
    bool isInitialized = _initializationStatus[index] == true;
    bool hasError = _errorStatus[index] == true;

    Color color;
    if (hasError) {
      color = Colors.red;
    } else if (isActive) {
      color = Colors.blue;
    } else if (isInitialized) {
      color = Colors.green.shade300; // Green indicates ready
    } else {
      color = Colors.grey.shade400; // Still loading
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

    if (!isInitialized || _currentController == null || _isInitializing) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              _isInitializing
                  ? 'Initializing videos...'
                  : 'Loading video ${_currentIndex + 1}...',
            ),
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
    _initializationStatus.clear();
    _errorStatus.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildVideoPlayer(),
        SizedBox(height: 12),
        // Progress indicators (green = ready, blue = current, red = error, grey = loading)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.videoUrls.length, _buildIndicator),
        ),
        SizedBox(height: 8),
        // Video counter
        // Text(
        //   'Video ${_currentIndex + 1} of ${widget.videoUrls.length}',
        //   style: TextStyle(fontSize: 12, color: Colors.grey),
        // ),
        // // Initialization status
        // if (_isInitializing)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 4),
        //     child: Text(
        //       'Initializing ${_initializationStatus.values.where((v) => v).length}/${widget.videoUrls.length} videos',
        //       style: TextStyle(fontSize: 10, color: Colors.grey),
        //     ),
        //   ),
      ],
    );
  }
}
