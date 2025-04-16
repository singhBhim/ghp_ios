import 'dart:async';
import 'package:ghp_society_management/constants/export.dart';
import 'package:ghp_society_management/controller/visitors/incoming_request/incoming_request_cubit.dart';
import 'package:ghp_society_management/model/incoming_visitors_request_model.dart';
import 'package:ghp_society_management/view/dashboard/bottom_nav_screen.dart';
import 'package:ghp_society_management/view/resident/onboarding/onboarding_screen.dart';
import 'package:ghp_society_management/view/resident/visitors/incomming_request.dart';
import 'package:ghp_society_management/view/security_staff/dashboard/bottom_navigation.dart';
import 'package:ghp_society_management/view/staff/bottom_nav_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SlidersCubit>().fetchSlidersAPI();
    context.read<IncomingRequestCubit>().fetchIncomingRequest();
    _startTimer();
  }

  void _startTimer() async {
    final onboarding = LocalStorage.localStorage.getString('onboarding');
    final societyId = LocalStorage.localStorage.getString('societyId');
    final role = LocalStorage.localStorage.getString('role');

    Timer(const Duration(seconds: 2), () {
      Widget nextScreen;

      // if (onboarding == null && societyId == null) {
      //   nextScreen = const OnboardingScreen();
      // } else if (onboarding != null && societyId == null) {
      //   nextScreen = const SelectSocietyScreen();
      // } else

      if (societyId != null) {
        switch (role) {
          case 'resident':
          case 'admin':
            nextScreen = const Dashboard();
            break;
          case 'staff':
            nextScreen = const StaffDashboard();
            break;
          case 'staff_security_guard':
            nextScreen = const SecurityGuardDashboard();
            break;
          default:
            nextScreen = const OnboardingScreen();
        }
      } else {
        nextScreen = const OnboardingScreen();
      }
      _navigateToNextScreen(nextScreen);
    });
  }

  void _navigateToNextScreen(Widget nextScreen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (builder) => nextScreen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<IncomingRequestCubit, IncomingRequestState>(
          listener: (context, state) {
            if (state is IncomingRequestLoaded) {
              print("Loading state triggered");
              IncomingVisitorsModel incomingVisitorsRequest =
                  state.incomingVisitorsRequest;
              if (incomingVisitorsRequest.lastCheckinDetail!.status ==
                  'requested') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisitorsIncomingRequestPage(
                      incomingVisitorsRequest: incomingVisitorsRequest,
                      fromForegroundMsg: true,
                      setPageValue: (value) {},
                    ),
                  ),
                );
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF020015),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Image.asset(
              ImageAssets.appLogo,
              height: 100.h,
            ),
          ),
        ),
      ),
    );
  }
}
