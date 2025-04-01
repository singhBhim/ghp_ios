import 'package:ghp_app/constants/dialog.dart';
import 'package:ghp_app/constants/export.dart';
import 'package:ghp_app/controller/daliy_helps_member/daily_helps_checkouts_History_details/daily_help_checkouts_history_cubit.dart';
import 'package:ghp_app/controller/resident_checkout_log/resident_check-in/resident_check_in_cubit.dart';
import 'package:ghp_app/controller/resident_checkout_log/resident_check-out/resident_checkout_cubit.dart';
import 'package:ghp_app/view/dashboard/bottom_nav_screen.dart';
import 'package:ghp_app/view/security_staff/dashboard/bottom_navigation.dart';
import 'package:intl/intl.dart';
import '../../../model/daily_help_member_checkout_details_modal.dart';

class DailyHelpProfileDetails extends StatefulWidget {
  bool forQRPage;
  bool fromResidentPage;
  final Map<String, dynamic>? dailyHelpId;
  DailyHelpProfileDetails(
      {super.key,
      this.dailyHelpId,
      this.forQRPage = false,
      this.fromResidentPage = false});

  @override
  State<DailyHelpProfileDetails> createState() =>
      DailyHelpProfileDetailsState();
}

class DailyHelpProfileDetailsState extends State<DailyHelpProfileDetails> {
  late DailyHelpHistoryDetailsCubit _dailyHelpHistoryDetailsCubit;

  @override
  void initState() {
    super.initState();
    _dailyHelpHistoryDetailsCubit = DailyHelpHistoryDetailsCubit();
    fetchDetails();
  }

  fetchDetails() {
    if (widget.dailyHelpId!.containsKey('daily_help_id')) {
      _dailyHelpHistoryDetailsCubit.fetchDailyHelpHistoryDetailsApi(
          userId: widget.dailyHelpId!['daily_help_id'].toString());
    } else {
      print("Error: id not found in visitorsId.");
    }
  }

  late BuildContext dialogueContext;

  Future<bool> onCallBack() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => widget.fromResidentPage
                ? const Dashboard()
                : const SecurityGuardDashboard()),
        (route) => false);
    return true;
  }

  void onBack(BuildContext buildContext) {
    Future.delayed(Duration.zero, () {
      Navigator.pushAndRemoveUntil(
          buildContext,
          MaterialPageRoute(
              builder: (_) => widget.fromResidentPage
                  ? const Dashboard()
                  : const SecurityGuardDashboard()),
          (route) => false);
    });
  }

  /// verify the user
  void verifyTheUser(
      BuildContext buildContext, DailyHelpUser userInfo, List<Log> logsData,
      {bool forResidentSide = false}) {
    Map<String, String> checkInData = {
      "user_id": userInfo.id.toString(),
      "type": "daily_help"
    };

    if (!forResidentSide) {
      var lastCheckInDetail = userInfo.lastCheckinDetail;

      if (lastCheckInDetail == null ||
          lastCheckInDetail.status == 'checked_out') {
        buildContext
            .read<ResidentCheckInCubit>()
            .checkInAPI(statusBody: checkInData);
      } else if (lastCheckInDetail.status == 'checked_in') {
        buildContext
            .read<ResidentCheckOutCubit>()
            .checkOutApi(statusBody: checkInData);
      }
      return; // No need to check further
    } else {
      // For non-staff side (logsData processing)
      if (logsData.isNotEmpty) {
        var lastLog = logsData.first.memberLogs!.isNotEmpty
            ? logsData.first.memberLogs!.first
            : null;
        print('-------------ooooooooooo$lastLog');

        if (lastLog != null) {
          if (lastLog.checkinAt == null || lastLog.status == 'out') {
            buildContext
                .read<ResidentCheckInCubit>()
                .checkInAPI(statusBody: checkInData);
          } else if (lastLog.status == 'in') {
            buildContext
                .read<ResidentCheckOutCubit>()
                .checkOutApi(statusBody: checkInData);
          }
          return; // Exit after first valid log check
        }
      }
    }
  }

  String? fromDate;
  String? toDate;

  Future<void> selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015, 8),
      lastDate: lastDayOfMonth,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDateRange:
          DateTimeRange(start: now, end: now.add(const Duration(days: 3))),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              headerForegroundColor: Colors.white,
              headerBackgroundColor: AppTheme.primaryColor,
              dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppTheme.primaryColor;
                }
                return Colors.white;
              }),
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 100), // Removed extra bottom padding
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: child ?? const SizedBox(),
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        fromDate = DateFormat('yyyy-MM-dd').format(picked.start);
        toDate = DateFormat('yyyy-MM-dd').format(picked.end);
      });

      _dailyHelpHistoryDetailsCubit.fetchDailyHelpHistoryDetailsApi(
          userId: widget.dailyHelpId!['daily_help_id'].toString(),
          fromDate: fromDate,
          toDate: toDate);
    }
  }

  Future onRefresh() async {
    fromDate = null;
    toDate = null;
    if (widget.forQRPage) {
      fetchDetails();
    } else {
      _dailyHelpHistoryDetailsCubit.fetchDailyHelpHistoryDetailsApi(
          userId: widget.dailyHelpId!['daily_help_id'].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ResidentCheckInCubit, ResidentCheckInState>(
          listener: (_, state) {
            if (state is ResidentCheckInLoading) {
              showLoadingDialog(context, (ctx) {
                dialogueContext = ctx;
              });
            } else if (state is ResidentCheckInSuccessfully) {
              snackBar(context, state.successMsg.toString(), Icons.done,
                  AppTheme.guestColor);
              Navigator.of(dialogueContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onBack(context); // Delay navigation
              });
            } else if (state is ResidentCheckInFailed) {
              snackBar(context, state.errorMsg.toString(), Icons.warning,
                  AppTheme.redColor);
              Navigator.of(dialogueContext).pop();
              onBack(context);
            }
          },
        ),
        BlocListener<ResidentCheckOutCubit, ResidentCheckOutState>(
            listener: (_, state) {
          if (state is ResidentCheckOutLoading) {
            showLoadingDialog(context, (ctx) {
              dialogueContext = ctx;
            });
          } else if (state is ResidentCheckOutSuccessfully) {
            snackBar(context, state.successMsg.toString(), Icons.done,
                AppTheme.guestColor);
            Navigator.of(dialogueContext).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onBack(context);
            });
          } else if (state is ResidentCheckOutFailed) {
            snackBar(context, state.errorMsg.toString(), Icons.warning,
                AppTheme.redColor);
            Navigator.of(dialogueContext).pop();
            onBack(context);
          }
        }),
      ],
      child: WillPopScope(
        onWillPop: onCallBack,
        child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                    padding:
                        EdgeInsets.only(top: 20.h, left: 6.h, bottom: 20.h),
                    child: Row(children: [
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white)),
                      SizedBox(width: 10.w),
                      Text('Profile Details',
                          style: GoogleFonts.nunitoSans(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600))),
                    ])),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: RefreshIndicator(
                      onRefresh: onRefresh,
                      child: BlocBuilder<DailyHelpHistoryDetailsCubit,
                              DailyHelpHistoryDetailsState>(
                          bloc: _dailyHelpHistoryDetailsCubit,
                          builder: (context, state) {
                            if (state is DailyHelpHistoryDetailsLoading) {
                              return const Center(
                                  child: CircularProgressIndicator.adaptive(
                                      backgroundColor:
                                          Colors.deepPurpleAccent));
                            } else if (state is DailyHelpHistoryDetailsLoaded) {
                              Data? usersData =
                                  state.dailyHelpMemberDetailsModal.data;
                              if (widget.forQRPage) {
                                verifyTheUser(
                                    context, usersData!.user!, usersData.logs!,
                                    forResidentSide: widget.fromResidentPage);
                              }
                              return SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10.h),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(0.1))),
                                        child: Row(
                                          children: [
                                            usersData!.user!.image != null
                                                ? CircleAvatar(
                                                    radius: 35.h,
                                                    backgroundImage:
                                                        NetworkImage(usersData
                                                            .user!.image
                                                            .toString()),
                                                    onBackgroundImageError: (error,
                                                            stack) =>
                                                        const AssetImage(
                                                            'assets/images/default.jpg'))
                                                : CircleAvatar(
                                                    radius: 35.h,
                                                    backgroundImage:
                                                        const AssetImage(
                                                            'assets/images/default.jpg')),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    capitalizeWords(usersData
                                                        .user!.name
                                                        .toString()),
                                                    style: GoogleFonts.nunitoSans(
                                                        textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))),
                                                Text(
                                                    "Role Type : ${usersData.user!.role.toString().replaceAll('_', ' ')}",
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                            textStyle: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize:
                                                                    14.sp))),
                                                Text(
                                                    "Sift Time : ${usersData.user!.staff!.shiftFrom != null ? formatShiftTime(usersData.user!.staff!.shiftFrom!.toString()) : ''} - ${usersData.user!.staff!.shiftTo != null ? formatShiftTime(usersData.user!.staff!.shiftTo.toString()) : ''}",
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                            textStyle: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize:
                                                                    14.sp))),
                                              ],
                                            ),
                                            const SizedBox(width: 5)
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(0.1))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('Date Of Joining : ',
                                                      style: GoogleFonts.nunitoSans(
                                                          textStyle: TextStyle(
                                                              color: Colors
                                                                  .black45,
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                  Text(
                                                      formatDateOnly(usersData
                                                          .user!
                                                          .staff!
                                                          .dateOfJoin
                                                          .toString()),
                                                      style: GoogleFonts.nunitoSans(
                                                          textStyle: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)))
                                                ]),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3),
                                                child: Divider(
                                                    color: Colors.grey
                                                        .withOpacity(0.1))),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('End Of Contract : ',
                                                      style: GoogleFonts.nunitoSans(
                                                          textStyle: TextStyle(
                                                              color: Colors
                                                                  .black45,
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                  Text(
                                                      formatDateOnly(usersData
                                                          .user!
                                                          .staff!
                                                          .contractEndDate
                                                          .toString()),
                                                      style: GoogleFonts.nunitoSans(
                                                          textStyle: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)))
                                                ]),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3),
                                                child: Divider(
                                                    color: Colors.grey
                                                        .withOpacity(0.1))),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('Mobile Number : ',
                                                      style: GoogleFonts.nunitoSans(
                                                          textStyle: TextStyle(
                                                              color: Colors
                                                                  .black45,
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                  Text(
                                                      '+91 ${usersData.user!.phone.toString()}',
                                                      style: GoogleFonts.nunitoSans(
                                                          textStyle: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)))
                                                ]),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3),
                                                child: Divider(
                                                    color: Colors.grey
                                                        .withOpacity(0.1))),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('Gender :',
                                                      style: GoogleFonts.nunitoSans(
                                                          textStyle: TextStyle(
                                                              color: Colors
                                                                  .black45,
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                  Text(
                                                      usersData
                                                          .user!.staff!.gender
                                                          .toString()
                                                          .toUpperCase(),
                                                      style: GoogleFonts.nunitoSans(
                                                          textStyle: TextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)))
                                                ]),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3),
                                                child: Divider(
                                                    color: Colors.grey
                                                        .withOpacity(0.1))),
                                            const SizedBox(height: 15),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Center(
                                                    child: Text("Checkout info",
                                                        style: GoogleFonts.nunitoSans(
                                                            textStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)))),
                                                GestureDetector(
                                                  onTap: () {
                                                    selectDateRange(context);
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5, bottom: 5),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xFFD9D9D9)),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.r)),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  10.0.w,
                                                              vertical: 8),
                                                      child: Center(
                                                          child: Text(
                                                        fromDate == null
                                                            ? 'YY-MM-DD  to  YY-MM-DD'
                                                            : "${formatDateOnly(fromDate.toString())} - ${formatDateOnly(toDate.toString())}",
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: const Color
                                                              .fromARGB(255,
                                                              102, 101, 101),
                                                          fontSize: 11.sp,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      usersData.logs!.isEmpty
                                          ? const Center(
                                              child: Text(
                                                  'Check-out History Not Found!',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors
                                                          .deepPurpleAccent)))
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemCount: usersData.logs!.length,
                                              itemBuilder: (_, index) {
                                                List<LastCheckinDetail>
                                                    staffLog = usersData
                                                        .logs![index]
                                                        .securityStaffLogs!;
                                                List<LastCheckinDetail>
                                                    memberLogs = usersData
                                                        .logs![index]
                                                        .memberLogs!;

                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: Colors.grey
                                                              .withOpacity(
                                                                  0.2))),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              "Check-out by Staff ",
                                                              style: GoogleFonts.nunitoSans(
                                                                  textStyle: TextStyle(
                                                                      color: Colors
                                                                          .deepPurpleAccent,
                                                                      fontSize:
                                                                          14.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500))),
                                                          Text(
                                                              formatCheckoutDate(
                                                                  staffLog[0]
                                                                      .checkinAt
                                                                      .toString()),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14))
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        itemCount:
                                                            staffLog.length,
                                                        itemBuilder:
                                                            (_, staffIndex) {
                                                          checkOut() {
                                                            DateTime outTime;
                                                            if (staffLog[
                                                                        staffIndex]
                                                                    .checkoutAt !=
                                                                null) {
                                                              outTime = DateTime
                                                                  .parse(staffLog[
                                                                          staffIndex]
                                                                      .checkoutAt
                                                                      .toString());
                                                              return formatTime(
                                                                  outTime);
                                                            } else {
                                                              return 'N/A';
                                                            }
                                                          }

                                                          checkIn() {
                                                            DateTime inTime;
                                                            if (staffLog[
                                                                        staffIndex]
                                                                    .checkinAt !=
                                                                null) {
                                                              inTime = DateTime
                                                                  .parse(staffLog[
                                                                          staffIndex]
                                                                      .checkinAt!
                                                                      .toString());
                                                              return formatTime(
                                                                  inTime);
                                                            } else {
                                                              return 'N/A';
                                                            }
                                                          }

                                                          return Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 5),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.2))),
                                                            child: ListTile(
                                                              dense: true,
                                                              title: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      'Check-IN : ${checkIn()}'
                                                                          .toUpperCase(),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12)),
                                                                  Text(
                                                                    'Check-OUT : ${checkOut()}'
                                                                        .toUpperCase(),
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                  "Check-out by Resident ",
                                                                  style: GoogleFonts.nunitoSans(
                                                                      textStyle: TextStyle(
                                                                          color: Colors
                                                                              .deepPurpleAccent,
                                                                          fontSize: 14
                                                                              .sp,
                                                                          fontWeight:
                                                                              FontWeight.w500))),
                                                              Text(
                                                                  formatCheckoutDate(
                                                                      staffLog[
                                                                              0]
                                                                          .checkinAt
                                                                          .toString()),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14))
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            itemCount:
                                                                memberLogs
                                                                    .length,
                                                            itemBuilder: (_,
                                                                residentIndex) {
                                                              checkOut() {
                                                                DateTime
                                                                    outTime;
                                                                if (memberLogs[
                                                                            residentIndex]
                                                                        .checkoutAt !=
                                                                    null) {
                                                                  outTime = DateTime.parse(memberLogs[
                                                                          residentIndex]
                                                                      .checkoutAt
                                                                      .toString());
                                                                  return formatTime(
                                                                      outTime);
                                                                } else {
                                                                  return 'N/A';
                                                                }
                                                              }

                                                              checkIn() {
                                                                DateTime inTime;
                                                                if (memberLogs[
                                                                            residentIndex]
                                                                        .checkinAt !=
                                                                    null) {
                                                                  inTime = DateTime.parse(memberLogs[
                                                                          residentIndex]
                                                                      .checkinAt!
                                                                      .toString());
                                                                  return formatTime(
                                                                      inTime);
                                                                } else {
                                                                  return 'N/A';
                                                                }
                                                              }

                                                              return Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.2))),
                                                                child: ListTile(
                                                                  dense: true,
                                                                  title: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                          'IN-Time : ${checkIn()}'
                                                                              .toUpperCase(),
                                                                          style:
                                                                              const TextStyle(fontSize: 12)),
                                                                      Text(
                                                                        'OUT-Time : ${checkOut()}'
                                                                            .toUpperCase(),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  subtitle:
                                                                      Column(
                                                                    children: [
                                                                      Divider(
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.2)),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              Text(memberLogs[residentIndex].dailyHelpMemberDetails!.name.toString(), style: GoogleFonts.ptSans(textStyle: TextStyle(color: Colors.black, fontSize: 11.sp, fontWeight: FontWeight.w600))),
                                                                              Text("Name", style: GoogleFonts.ptSans(textStyle: TextStyle(color: Colors.black54, fontSize: 12.sp, fontWeight: FontWeight.w400))),
                                                                            ],
                                                                          ),
                                                                          Column(
                                                                            children: [
                                                                              Text("+91 ${memberLogs[residentIndex].dailyHelpMemberDetails!.phone}", style: GoogleFonts.ptSans(textStyle: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w600))),
                                                                              Text("Phone", style: GoogleFonts.ptSans(textStyle: TextStyle(color: Colors.black54, fontSize: 11.sp, fontWeight: FontWeight.w400))),
                                                                            ],
                                                                          ),
                                                                          Column(
                                                                            children: [
                                                                              Text("${memberLogs[residentIndex].dailyHelpMemberDetails!.member!.blockName.toString()}, ${memberLogs[residentIndex].dailyHelpMemberDetails!.member!.aprtNo.toString()}", style: GoogleFonts.ptSans(textStyle: TextStyle(color: Colors.black, fontSize: 11.sp, fontWeight: FontWeight.w600))),
                                                                              Text("Tower Name", style: GoogleFonts.ptSans(textStyle: TextStyle(color: Colors.black54, fontSize: 12.sp, fontWeight: FontWeight.w400))),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            )
                                    ],
                                  ),
                                ),
                              );
                            } else if (state is DailyHelpHistoryDetailsError) {
                              if (widget.forQRPage) {
                                onBack(context);
                              }
                              return Center(
                                  child: Text(state.errorMsg.toString(),
                                      style: const TextStyle(
                                          color: Colors.deepPurpleAccent)));
                            } else {
                              if (widget.forQRPage) {
                                onBack(context);
                              }
                              return const SizedBox();
                            }
                          }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
