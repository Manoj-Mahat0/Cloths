import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const Color _primaryBlue = Color(0xFF2E4DFF);

  final List<OnboardingPageData> _pages = const <OnboardingPageData>[
    OnboardingPageData(
      title: 'Capture the moment, own the spotlight!',
      subtitle:
          'Strike a pose, embrace the confidence—because fashion is all about attitude!',
    ),
    OnboardingPageData(
      title: 'Style that speaks!',
      subtitle:
          'Express your unique fashion sense with confidence—where every piece tells your story.',
    ),
    OnboardingPageData(
      title: 'Get started and achieve more!',
      subtitle:
          'Don’t waste time—unlock all the benefits instantly.',
    ),
  ];

  void _goNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() {
    _finish();
  }

  void _finish() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/auth/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: <Widget>[
                  if (_currentIndex > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'skip',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int index) => setState(() => _currentIndex = index),
                itemCount: _pages.length,
                itemBuilder: (BuildContext context, int index) {
                  final OnboardingPageData page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 12),
                        const Spacer(),
                        const Icon(Icons.checkroom, size: 120, color: _primaryBlue),
                        const Spacer(),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF858585),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _DotsIndicator(
                          count: _pages.length,
                          currentIndex: _currentIndex,
                          activeColor: _primaryBlue,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _goNext,
                            child: Text(
                              _currentIndex == _pages.length - 1 ? 'Get started' : 'Next',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.currentIndex,
    required this.activeColor,
  });

  final int count;
  final int currentIndex;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int i) {
        final bool isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : const Color(0xFFE3E7FF),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}


