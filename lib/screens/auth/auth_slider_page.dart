import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';

class AuthSlider extends StatefulWidget {
  const AuthSlider({super.key});

  @override
  State<AuthSlider> createState() => _AuthSliderState();
}

class _AuthSliderState extends State<AuthSlider> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  void _goTo(int index) {
    setState(() => _pageIndex = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  BorderRadius _getLoginBorderRadius(bool isActive) {
    return const BorderRadius.only(
      topLeft: Radius.circular(0),
      bottomLeft: Radius.circular(0),
      topRight: Radius.circular(40),
      bottomRight: Radius.circular(40),
    );
  }

  BorderRadius _getRegisterBorderRadius(bool isActive) {
    return const BorderRadius.only(
      topLeft: Radius.circular(40),
      bottomLeft: Radius.circular(40),
      topRight: Radius.circular(0),
      bottomRight: Radius.circular(0),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4C7FFF);
    const darkBlue = Color(0xFF3357A4);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 420,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: -250,
                  left: -80,
                  right: -80,
                  child: Container(
                    height: 500,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(400),
                        bottomRight: Radius.circular(400),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 80,
                  child: CircleAvatar(
                    radius: 140,
                    backgroundColor: Colors.blue,
                    child: ClipOval(
                      child: Image.asset(
                        'images/Profile.png',

                        width: 1000,
                        height: 1000,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () => _goTo(0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),

                      width: _pageIndex == 0 ? 180 : 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _pageIndex == 0 ? primaryColor : darkBlue,

                        borderRadius: _getLoginBorderRadius(_pageIndex == 0),
                        boxShadow: _pageIndex == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),

                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Visibility(
                            visible: _pageIndex == 0,
                            maintainSize: false,
                            maintainAnimation: false,
                            maintainState: false,
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          Positioned(
                            right: _pageIndex == 0 ? 8 : 7.5,
                            child: Container(
                              width: 35,
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                _pageIndex == 0
                                    ? Icons.arrow_back_ios_new
                                    : Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 0,
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () => _goTo(1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),

                      width: _pageIndex == 1 ? 180 : 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _pageIndex == 1 ? primaryColor : darkBlue,

                        borderRadius: _getRegisterBorderRadius(_pageIndex == 1),
                        boxShadow: _pageIndex == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),

                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: _pageIndex == 1 ? 8 : 7.5,
                            child: Container(
                              width: 35,
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                _pageIndex == 1
                                    ? Icons.arrow_forward_ios
                                    : Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),

                          Visibility(
                            visible: _pageIndex == 1,
                            maintainSize: false,
                            maintainAnimation: false,
                            maintainState: false,
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) => setState(() => _pageIndex = index),
              physics: const NeverScrollableScrollPhysics(),
              children: const [SignInPage(), SignUpPage()],
            ),
          ),
        ],
      ),
    );
  }
}
