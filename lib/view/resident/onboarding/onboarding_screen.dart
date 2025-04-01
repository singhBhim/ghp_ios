import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ghp_app/constants/app_images.dart';
import 'package:ghp_app/constants/app_theme.dart';
import 'package:ghp_app/constants/local_storage.dart';
import 'package:ghp_app/controller/sliders/sliders_cubit.dart';
import 'package:ghp_app/view/silder_management/sliders.dart';
import 'package:ghp_app/view/society/select_society_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  late SlidersCubit _slidersCubit;

  @override
  void initState() {
    super.initState();
    _slidersCubit = SlidersCubit()..fetchSlidersAPI();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 100.h),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                          padding: EdgeInsets.all(8.w),
                          child:
                              Image.asset(ImageAssets.appLogo, height: 60.h)),
                      SizedBox(height: 5.h),
                      const Expanded(
                          child: SlidersManagement(forOnBoarding: true)),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () {
                          LocalStorage.localStorage
                              .setString('onboarding', 'true');
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) =>
                                  const SelectSocietyScreen()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 15),
                          child: Container(
                            width: double.infinity,
                            height: 50.h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border:
                                    Border.all(color: AppTheme.primaryColor)),
                            child: Center(
                              child: Text('Skip To Main Content ',
                                  style:GoogleFonts.nunitoSans(
                                    textStyle: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
