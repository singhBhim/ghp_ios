import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ghp_society_management/constants/app_theme.dart';
import 'package:ghp_society_management/controller/privacy_policy/privacy_policy_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PrivacyPolicyCubit>().fetchPrivacyPolicyAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                child: Row(children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white)),
                  SizedBox(width: 10.w),
                  Text('Privacy Policy',
                      style: GoogleFonts.nunitoSans(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600)))
                ])),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: BlocBuilder<PrivacyPolicyCubit, PrivacyPolicyState>(
                    builder: (context, state) {
                      if (state is PrivacyPolicyLoading) {
                        return const Center(
                            child: CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.deepPurpleAccent));
                      } else if (state is PrivacyPolicyLoaded) {
                        final htmlData = state.privacyPolicyModel.data;
                        return SingleChildScrollView(
                            child: Html(
                              data:  htmlData.privacyPolicy.content.toString()));
                      } else if (state is PrivacyPolicyFailed) {
                        return Center(
                            child: Text(state.errorMessage.toString(),
                                style: const TextStyle(color: Colors.red)));
                      } else if (state is PrivacyPolicyInternetError) {
                        return Center(
                            child: Text(state.errorMessage.toString(),
                                style: const TextStyle(color: Colors.red)));
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
