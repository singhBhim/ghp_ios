import 'package:ghp_app/constants/export.dart';
import 'package:ghp_app/model/service_request_history_model.dart';
import 'package:ghp_app/view/staff/mark_done_screen.dart';
import 'package:ghp_app/view/staff/service/service_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  bool showLess = true;

  List<String> filterList = ["All", "Completed", "Pending"];
  List<String> types = ["all", "completed", "pending"];
  final ScrollController _scrollController = ScrollController();

  late ServiceRequestHistoryCubit _serviceRequestHistoryCubit;
  int selectedFilter = 0;
  String? startDate;
  String? endDate;

  Future<void> startingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2015, 8),
      initialDate: DateTime.now(),
      lastDate: DateTime(2101),
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
          )),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        startDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      if (endDate != null) {
        _serviceRequestHistoryCubit.serviceRequestHistory(
            filter: types[selectedFilter].toString(),
            startDate: startDate,
            endDate: endDate);
      }
    }
  }

  Future<void> endingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2015, 8),
      initialDate: DateTime.now(),
      lastDate: DateTime(2101),
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
            )),
            child: child ?? const SizedBox());
      },
    );
    if (picked != null) {
      setState(() {
        endDate = DateFormat('yyyy-MM-dd').format(picked);
        if (startDate != null) {
          _serviceRequestHistoryCubit.serviceRequestHistory(
              filter: types[selectedFilter].toString(),
              startDate: startDate,
              endDate: endDate);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _serviceRequestHistoryCubit = ServiceRequestHistoryCubit();
    _serviceRequestHistoryCubit.serviceRequestHistory();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _serviceRequestHistoryCubit.serviceRequestHistory(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceRequestHistoryCubit, ServiceRequestHistoryState>(
      bloc: _serviceRequestHistoryCubit,
      listener: (context, state) {
        if (state is ServiceRequestHistoryLogout) {
          sessionExpiredDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text('Service History',
                      style: GoogleFonts.nunitoSans(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600)))),
              SizedBox(height: 20.h),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    selectedFilter = 0;
                    endDate = null;
                    startDate = null;
                    setState(() {});
                    _serviceRequestHistoryCubit.serviceRequestHistory(
                        startDate: null,
                        filter: types[selectedFilter].toString(),
                        endDate: null);
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          child: Row(
                            children: List.generate(
                                filterList.length,
                                (index) => Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedFilter = index;

                                            _serviceRequestHistoryCubit
                                                .serviceRequestHistory(
                                                    filter:
                                                        types[selectedFilter]
                                                            .toString(),
                                                    startDate: startDate,
                                                    endDate: endDate);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 12),
                                          margin: EdgeInsets.all(5.w),
                                          decoration: BoxDecoration(
                                              color: selectedFilter == index
                                                  ? AppTheme.primaryColor
                                                  : Colors.transparent,
                                              border: Border.all(
                                                  color: selectedFilter == index
                                                      ? AppTheme.primaryColor
                                                      : const Color(
                                                          0xFFD9D9D9)),
                                              borderRadius:
                                                  BorderRadius.circular(6.r)),
                                          child: Center(
                                              child: Text(
                                            filterList[index],
                                            style: GoogleFonts.poppins(
                                              color: selectedFilter == index
                                                  ? Colors.white
                                                  : const Color.fromARGB(
                                                      255, 102, 101, 101),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          )),
                                        ),
                                      ),
                                    )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    startingDate(context);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            color: const Color(0xFFD9D9D9)),
                                        borderRadius:
                                            BorderRadius.circular(6.r)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0.w, vertical: 11),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                              'assets/images/calendar2.png',
                                              height: 22.h),
                                          SizedBox(width: 10.w),
                                          Center(
                                              child: Text(
                                            startDate == null
                                                ? 'yy-mm-dd'
                                                : startDate.toString(),
                                            style: GoogleFonts.poppins(
                                              color: const Color.fromARGB(
                                                  255, 102, 101, 101),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (startDate != null) {
                                      endingDate(context);
                                    } else {
                                      snackBar(
                                          context,
                                          'Please select starting date first',
                                          Icons.info_outline,
                                          AppTheme.redColor);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            color: const Color(0xFFD9D9D9)),
                                        borderRadius:
                                            BorderRadius.circular(6.r)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0.w, vertical: 11),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                              'assets/images/calendar2.png',
                                              height: 22.h),
                                          SizedBox(width: 10.w),
                                          Center(
                                              child: Text(
                                            endDate == null
                                                ? 'yy-mm-dd'
                                                : endDate.toString(),
                                            style: GoogleFonts.poppins(
                                              color: const Color.fromARGB(
                                                  255, 102, 101, 101),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5.h),
                        BlocBuilder<ServiceRequestHistoryCubit,
                            ServiceRequestHistoryState>(
                          bloc: _serviceRequestHistoryCubit,
                          builder: (context, state) {
                            if (state is ServiceRequestHistoryLoaded) {
                              return Expanded(
                                child: ListView.builder(
                                  controller: _scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: state.serviceHistory.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == state.serviceHistory.length) {
                                      return state
                                              is ServiceRequestHistoryLoadingMore
                                          ? const Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()))
                                          : const SizedBox.shrink();
                                    }
                                    List<ServiceHistoryModel> requestList =
                                        state.serviceHistory;

                                    String status =
                                        requestList[index].status!.toString();

                                    dateTypes() {
                                      if (status == 'assigned') {
                                        DateTime assignedDate =
                                            requestList[index].createdAt!;
                                        String day =
                                            assignedDate.day.toString();
                                        return Text(
                                            "Assigned At: $day ${monthYear(assignedDate)}",
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14));
                                      } else if (status == 'in_progress') {
                                        DateTime startDate =
                                            requestList[index].startAt!;
                                        String day = startDate.day.toString();
                                        return Text(
                                            "Start At: $day ${monthYear(startDate)}",
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14));
                                      } else {
                                        DateTime completeDate =
                                            requestList[index]
                                                .resolvedOrCancelledAt!;
                                        String day =
                                            completeDate.day.toString();
                                        return Text(
                                            "Complete At: $day ${monthYear(completeDate)}",
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14));
                                      }
                                    }

                                    getStatus() {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: status == 'assigned'
                                                ? Colors.blue.withOpacity(0.2)
                                                : status == 'in_progress'
                                                    ? Colors.deepPurpleAccent
                                                        .withOpacity(0.2)
                                                    : Colors.green
                                                        .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Text(
                                            capitalizeWords(status.toString())
                                                .replaceFirst("_", " "),
                                            style: TextStyle(
                                                color: status == 'assigned'
                                                    ? Colors.blue
                                                    : status == 'in_progress'
                                                        ? Colors
                                                            .deepPurpleAccent
                                                        : Colors.green,
                                                fontSize: 14)),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            border: Border.all(
                                                color:
                                                    const Color(0xFFE5E5E5))),
                                        child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10),
                                            dense: true,
                                            leading: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
                                                  color:
                                                      const Color(0xFFF2F1FE)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Image.asset(
                                                  ImageAssets
                                                      .serviceRequestImage,
                                                  height: 32.h,
                                                  width: 25,
                                                ),
                                              ),
                                            ),
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                          requestList[index]
                                                              .area
                                                              .toString(),
                                                          style: GoogleFonts
                                                              .nunitoSans(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                      Text(
                                                        "Complaint By : ${requestList[index].member!.name.toString()}",
                                                        style: GoogleFonts
                                                            .nunitoSans(
                                                                color:
                                                                    Colors.pink,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (builder) =>
                                                                ServiceDetailScreen(
                                                                    data: state
                                                                            .serviceHistory[
                                                                        index])));
                                                  },
                                                  child: CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor: Colors
                                                          .grey
                                                          .withOpacity(0.1),
                                                      child: const Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          size: 16,
                                                          color:
                                                              Colors.black45)),
                                                )
                                                /*Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CircleAvatar(
                                                        radius: 16,
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(1),
                                                            child: CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                child: Text(
                                                                    day
                                                                        .toString(),
                                                                    style: GoogleFonts.nunitoSans(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold))))),
                                                    Text(
                                                        monthYear(
                                                            assignedDate),
                                                        style: GoogleFonts
                                                            .nunitoSans(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12))
                                                  ],
                                                )*/
                                              ],
                                            ),
                                            subtitle: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                dateTypes(),
                                                getStatus(),
                                              ],
                                            )),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else if (state is ServiceRequestHistoryLoading) {
                              return SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              5,
                                    ),
                                    const CircularProgressIndicator(),
                                  ],
                                ),
                              );
                            }
                            if (state is ServiceRequestHistoryFailed) {
                              return SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                5),
                                    Center(
                                        child: Text(state.errorMsg.toString(),
                                            style: const TextStyle(
                                                color:
                                                    Colors.deepPurpleAccent)))
                                  ],
                                ),
                              );
                            } else {
                              return SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                5),
                                    const Center(
                                        child: Text(
                                      'Internet connection error',
                                      style: TextStyle(color: Colors.red),
                                    )),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  serviceDetailAlertDialogue(
      description, serviceId, serviceName, area, date, time, block) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          contentPadding: EdgeInsets.zero,
          // Set contentPadding to zero
          content: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.w, left: 10.w, right: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Service Detail",
                        style: GoogleFonts.nunitoSans(
                          color: Colors.black,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(Icons.close)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.w, left: 10.w, right: 10.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            color: const Color(0xFFF2F1FE),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              ImageAssets.serviceRequestImage,
                              height: 27.h,
                              width: 25.h,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceName,
                              style: GoogleFonts.nunitoSans(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Resident Unit: $block",
                              style: GoogleFonts.nunitoSans(
                                color: Colors.grey,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.h, left: 15.w, right: 15.w, bottom: 10.h),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0XffE6E6E6))),
                    child: Padding(
                      padding: EdgeInsets.all(15.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(
                                'Date',
                                style: GoogleFonts.nunitoSans(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                              Expanded(
                                  child: Text(
                                'Time',
                                style: GoogleFonts.nunitoSans(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(
                                date,
                                style: GoogleFonts.nunitoSans(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                              Expanded(
                                  child: Text(time,
                                      style: GoogleFonts.nunitoSans(
                                        color: Colors.black,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ))),
                            ],
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(
                                'Area',
                                style: GoogleFonts.nunitoSans(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(area,
                                      style: GoogleFonts.nunitoSans(
                                        color: Colors.black,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ))),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          description == null || description == ''
                              ? const SizedBox()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text(
                                      'Description',
                                      style: GoogleFonts.nunitoSans(
                                        color: Colors.grey,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )),
                                    const Expanded(child: SizedBox()),
                                  ],
                                ),
                          description == null || description == ''
                              ? const SizedBox()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text(description,
                                            style: GoogleFonts.nunitoSans(
                                              color: Colors.black,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ))),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Padding(
                  padding: EdgeInsets.all(15.w),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      enterOtpAlertDialogue('12');
                    },
                    child: Container(
                      height: 40.h,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppTheme.staffPrimaryColor),
                      child: Center(
                        child: Text(
                          'Start Service',
                          style: GoogleFonts.nunitoSans(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  enterOtpAlertDialogue(complaintId) {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);

        final defaultPinTheme = PinTheme(
          width: 56.w,
          height: 56.h,
          textStyle: const TextStyle(
              fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.staffPrimaryColor),
          ),
        );
        return AlertDialog(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          contentPadding: EdgeInsets.zero,
          // Set contentPadding to zero
          content: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.w, left: 10.w, right: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Enter OTP",
                        style: GoogleFonts.nunitoSans(
                          color: Colors.black,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(Icons.close)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.w, left: 10.w, right: 10.w, bottom: 10.h),
                  child: Text(
                    'Please Enter the OTP shared to you',
                    style: GoogleFonts.nunitoSans(
                      color: Colors.black,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Center(
                  child: Pinput(
                    controller: controller,
                    defaultPinTheme: defaultPinTheme,
                    separatorBuilder: (index) => const SizedBox(width: 8),
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (pin) {},
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 22,
                          height: 1,
                          color: focusedBorderColor,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: EdgeInsets.all(15.w),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (builder) => MarkDoneScreen()));
                    },
                    child: Container(
                      height: 40.h,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppTheme.staffPrimaryColor),
                      child: Center(
                        child: Text(
                          'Mark as Done',
                          style: GoogleFonts.nunitoSans(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/*
Widget headerWidget(BuildContext context, userId, userName, userImage) =>
    SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                  backgroundColor:
                      AppTheme.resolvedButtonColor.withOpacity(0.3),
                  child: Image.asset(ImageAssets.bellImage, height: 20.h))),
          GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (builder) => StaffChatScreen(
                        userImage: userImage,
                        userId: userId,
                        userName: userName,
                      ))),
              child: CircleAvatar(
                  backgroundColor:
                      AppTheme.resolvedButtonColor.withOpacity(0.3),
                  child: Image.asset(ImageAssets.messageImage, height: 20.h))),
          GestureDetector(
              onTap: () {
                context.read<LogoutCubit>().logout();
              },
              child: CircleAvatar(
                  backgroundColor:
                      AppTheme.resolvedButtonColor.withOpacity(0.3),
                  child:
                      Image.asset(ImageAssets.staffLogoutImage, height: 20.h))),
        ],
      ),
    );
*/
