import 'dart:async';

import 'package:flutter/material.dart';

class AutoBannerSlider extends StatefulWidget {
  final List<String> urls;

  const AutoBannerSlider({super.key, required this.urls});
  @override
  _AutoBannerSliderState createState() => _AutoBannerSliderState();
}

class _AutoBannerSliderState extends State<AutoBannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      _goToNextPage();
    });
  }

  void _resetAndGoToPage(VoidCallback pageChange) {
    _timer?.cancel();
    pageChange();
    _startAutoSlide(); // Restart the timer after the user interaction
  }

  void _goToNextPage() {
    if (_currentPage < widget.urls.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() {});
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _currentPage--;
    } else {
      _currentPage = widget.urls.length - 1;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildIndicator(int index) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 16 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails details) {
            final width = MediaQuery.of(context).size.width;
            if (details.localPosition.dx < width / 2) {
              _resetAndGoToPage(_goToPreviousPage);
            } else {
              _resetAndGoToPage(_goToNextPage);
            }
          },
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.urls.length,
              onPageChanged: (index) {
                _currentPage = index;
                setState(() {});
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.urls[index],
                  fit: BoxFit.cover,

                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Text('Failed to load'));
                  },
                );
              },
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.urls.length, _buildIndicator),
        ),
      ],
    );
  }
}
