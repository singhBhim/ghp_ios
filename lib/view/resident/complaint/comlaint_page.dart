import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ghp_app/constants/app_theme.dart';
import 'package:ghp_app/view/resident/complaint/complaint_category.dart';
import 'package:ghp_app/view/resident/complaint/get_all_complaints.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  @override
  void initState() {
    super.initState();
  }

  List<String> filterTypes = ["All Category", "Complaint History"];
  int selectedFilter = 0;

  List pagesList = const [ComplaintCategoryPage(), GetAllComplaintScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 10.w),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white)),
                SizedBox(width: 10.w),
                Padding(
                    padding:
                        EdgeInsets.only(top: 20.h, left: 12.h, bottom: 20.h),
                    child: Text('Complaints',
                        style: GoogleFonts.nunitoSans(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600)))),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Column(
                  children: [
                    Row(
                      children: List.generate(
                        filterTypes.length,
                        (index) => Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFilter = index;
                              });
                            },
                            child: AnimatedContainer(
                              width: MediaQuery.sizeOf(context).width,
                              duration: const Duration(milliseconds: 800),
                              margin: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                  color: selectedFilter == index
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: selectedFilter == index
                                          ? AppTheme.primaryColor
                                          : Colors.grey.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(5.r)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0.w, vertical: 12),
                                child: Center(
                                  child: Text(
                                    filterTypes[index].toString(),
                                    style: GoogleFonts.nunitoSans(
                                      color: selectedFilter == index
                                          ? Colors.white
                                          : Colors.black54,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    pagesList[selectedFilter]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
