import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AutoVideoBanner extends StatefulWidget {
  final List<String> videoUrls;
  const AutoVideoBanner({super.key, required this.videoUrls});
  @override
  AutoVideoBannerState createState() => AutoVideoBannerState();
}

class AutoVideoBannerState extends State<AutoVideoBanner>
    with WidgetsBindingObserver {
  // Cache for all controllers
  final Map<int, VideoPlayerController> _controllerCache = {};
  final Map<int, bool> _initializationStatus = {};
  final Map<int, bool> _errorStatus = {};

  VideoPlayerController? _currentController;
  int _currentIndex = 0;
  Timer? _autoChangeTimer;
  Timer? _visibilityCheckTimer;
  bool _isDisposed = false;
  bool _isChangingVideo = false;
  bool _isInitializing = false;
  bool _isWidgetVisible = false;
  bool _isAppInForeground = true;

  // For visibility detection
  final GlobalKey _widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAllVideos();
    _startVisibilityCheck();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        // print('App resumed');
        _handleFocusChange();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _isAppInForeground = false;
        // print('App paused/inactive');
        _handleFocusChange();
        break;
    }
  }

  /// Start periodic visibility checking
  void _startVisibilityCheck() {
    _visibilityCheckTimer = Timer.periodic(Duration(milliseconds: 500), (
      timer,
    ) {
      if (!mounted || _isDisposed) {
        timer.cancel();
        return;
      }
      _checkVisibility();
    });
  }

  /// Check if widget is visible on screen
  void _checkVisibility() {
    if (!mounted) return;

    try {
      final RenderBox? renderBox =
          _widgetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);
      final screenSize = MediaQuery.of(context).size;

      // Check if widget is visible on screen
      final bool isVisible =
          position.dy < screenSize.height &&
          (position.dy + size.height) > 0 &&
          position.dx < screenSize.width &&
          (position.dx + size.width) > 0;

      // Calculate how much of the widget is visible
      double visibleFraction = 0.0;
      if (isVisible) {
        final visibleTop = position.dy < 0 ? 0.0 : position.dy;
        final visibleBottom = (position.dy + size.height) > screenSize.height
            ? screenSize.height
            : (position.dy + size.height);
        final visibleHeight = visibleBottom - visibleTop;
        visibleFraction = visibleHeight / size.height;
      }

      final wasVisible = _isWidgetVisible;
      _isWidgetVisible = visibleFraction > 0.6; // At least 60% visible

      if (wasVisible != _isWidgetVisible) {
        // print(
        //   'Visibility changed: $_isWidgetVisible (fraction: ${visibleFraction.toStringAsFixed(2)})',
        // );
        _handleFocusChange();
      }
    } catch (e) {
      debugPrint('Error checking visibility: $e');
    }
  }

  /// Handle visibility changes and play/pause accordingly
  void _handleFocusChange() {
    final shouldPlay = _isWidgetVisible && _isAppInForeground;

    // print(
    //   'Focus change - Should play: $shouldPlay (visible: $_isWidgetVisible, foreground: $_isAppInForeground)',
    // );

    if (shouldPlay) {
      // Resume playback if widget is visible and app is in foreground
      if (_currentController != null &&
          _initializationStatus[_currentIndex] == true &&
          !_currentController!.value.isPlaying) {
        _playCurrentVideo();
      }
    } else {
      // Pause playback if widget is not visible or app is in background
      _pauseCurrentVideo();
    }

    if (mounted) {
      setState(() {}); // Update UI to show pause overlay
    }
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

    // Start playing the first video once all are initialized (if visible)
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

        // Ensure video is paused initially
        controller.pause();

        _initializationStatus[index] = true;
        // print('Video $index initialized successfully');
      }
    } catch (e) {
      debugPrint('Error initializing video $index: $e');
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
      // Only play if widget is in focus
      if (_isWidgetVisible && _isAppInForeground) {
        _playCurrentVideo();
      }
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
      // print('Video $index error: ${controller.value.errorDescription}');
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
        _initializationStatus[_currentIndex] != true ||
        !_isWidgetVisible ||
        !_isAppInForeground) {
      return;
    }

    // Pause ALL other videos first
    _pauseAllOtherVideos();

    // Reset current video to beginning and play
    _currentController!.seekTo(Duration.zero);
    _currentController!.play();

    // Start auto-change timer based on video duration
    _startAutoChangeTimer();

    // print(' Playing video $_currentIndex (in focus)');
  }

  void _pauseCurrentVideo() {
    _autoChangeTimer?.cancel();

    if (_currentController != null && _currentController!.value.isPlaying) {
      _currentController!.pause();
      // print(' Paused video $_currentIndex (out of focus)');
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

    // Only start timer if widget is visible and app is in foreground
    if (!_isWidgetVisible || !_isAppInForeground) return;

    if (_currentController != null && _currentController!.value.isInitialized) {
      final duration = _currentController!.value.duration;
      if (duration.inMilliseconds > 0) {
        _autoChangeTimer = Timer(duration, () {
          if (!_isDisposed &&
              mounted &&
              _isWidgetVisible &&
              _isAppInForeground) {
            _moveToNextVideo();
          }
        });
      } else {
        // Fallback timer for videos without clear duration
        _autoChangeTimer = Timer(Duration(seconds: 10), () {
          if (!_isDisposed &&
              mounted &&
              _isWidgetVisible &&
              _isAppInForeground) {
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

    // Set new current video and play (if in focus)
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
      // Show different blue shades based on play state
      if (_isWidgetVisible && _isAppInForeground) {
        color = Colors.blue; // Playing
      } else {
        color = Colors.blue.shade300; // Paused
      }
    } else if (isInitialized) {
      color = Colors.green.shade300; // Ready
    } else {
      color = Colors.grey.shade400; // Loading
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
    // final isPlaying = _currentController?.value.isPlaying ?? false;
    // final shouldShowPauseOverlay = !_isWidgetVisible || !_isAppInForeground;

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
          _moveToPreviousVideo();
        } else {
          _moveToNextVideo();
        }
      },
      child: Stack(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: _currentController!.value.aspectRatio,
              child: VideoPlayer(_currentController!),
            ),
          ),

          // Pause overlay when not in focus
          // if (shouldShowPauseOverlay)
          //   Container(
          //     height: 200,
          //     width: double.infinity,
          //     color: Colors.black54,
          //     child: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(
          //             Icons.play_circle_outline,
          //             size: 64,
          //             color: Colors.white,
          //           ),
          //           SizedBox(height: 12),
          //           Container(
          //             padding: EdgeInsets.symmetric(
          //               horizontal: 16,
          //               vertical: 8,
          //             ),
          //             decoration: BoxDecoration(
          //               color: Colors.black45,
          //               borderRadius: BorderRadius.circular(20),
          //             ),
          //             child: Text(
          //               !_isAppInForeground
          //                   ? 'Paused • App in background'
          //                   : 'Paused • Not in view',
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 12,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),

          // Debug info (remove in production)
          // Positioned(
          //   top: 8,
          //   right: 8,
          //   child: Container(
          //     padding: EdgeInsets.all(4),
          //     decoration: BoxDecoration(
          //       color: Colors.black54,
          //       borderRadius: BorderRadius.circular(4),
          //     ),
          //     child: Text(
          //       'Playing: $isPlaying\nVisible: $_isWidgetVisible\nForeground: $_isAppInForeground',
          //       style: TextStyle(color: Colors.white, fontSize: 8),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoChangeTimer?.cancel();
    _visibilityCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

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
    return Container(
      key: _widgetKey, // Important: This key is used for visibility detection
      child: Column(
        children: [
          _buildVideoPlayer(),
          SizedBox(height: 12),
          // Progress indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.videoUrls.length, _buildIndicator),
          ),
          SizedBox(height: 8),
          // Video counter and status
          // Column(
          //   children: [
          //     Text(
          //       'Video ${_currentIndex + 1} of ${widget.videoUrls.length}',
          //       style: TextStyle(fontSize: 12, color: Colors.grey),
          //     ),
          //     if (!_isWidgetVisible || !_isAppInForeground) ...[
          //       SizedBox(height: 4),
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(Icons.pause_circle_outline, size: 12, color: Colors.orange),
          //           SizedBox(width: 4),
          //           Text(
          //             !_isAppInForeground ? 'Background' : 'Not visible',
          //             style: TextStyle(fontSize: 10, color: Colors.orange),
          //           ),
          //         ],
          //       ),
          //     ],
          //     // if (_isInitializing) ...[
          //     //   SizedBox(height: 4),
          //     //   Text(
          //     //     'Initializing ${_initializationStatus.values.where((v) => v).length}/${widget.videoUrls.length} videos',
          //     //     style: TextStyle(fontSize: 10, color: Colors.grey),
          //     //   ),
          //     // ],
          //   ],
          // ),
        ],
      ),
    );
  }
}
