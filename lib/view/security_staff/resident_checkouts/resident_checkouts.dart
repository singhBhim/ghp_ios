import 'package:flutter/cupertino.dart';
import 'package:ghp_society_management/constants/export.dart';
import 'package:ghp_society_management/controller/resident_checkout_log/resident_check-in/resident_check_in_cubit.dart';
import 'package:ghp_society_management/controller/resident_checkout_log/resident_check-out/resident_checkout_cubit.dart';
import 'package:ghp_society_management/controller/resident_checkout_log/resident_checkouts/staff_side_checkouts_history_cubit.dart';
import 'package:ghp_society_management/model/resident_checkouts_history_model.dart';
import 'package:ghp_society_management/view/resident/resident_profile/resident_profile.dart';
import 'package:ghp_society_management/view/resident/residents_checkouts/resident_checkouts_history_details.dart';
import 'package:ghp_society_management/view/security_staff/scan_qr.dart';
import 'package:searchbar_animation/searchbar_animation.dart';

class ResidentsCheckoutsHistory extends StatefulWidget {
  const ResidentsCheckoutsHistory({super.key});

  @override
  State<ResidentsCheckoutsHistory> createState() =>
      _ResidentsCheckoutsHistoryState();
}

class _ResidentsCheckoutsHistoryState extends State<ResidentsCheckoutsHistory> {
  late StaffSideResidentCheckoutsHistoryCubit
      _staffSideResidentCheckoutsHistoryCubit;
  bool searchBarOpen = false;
  TextEditingController textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _staffSideResidentCheckoutsHistoryCubit =
        StaffSideResidentCheckoutsHistoryCubit();
    _staffSideResidentCheckoutsHistoryCubit.fetchResidentsCheckoutsHistoryApi();

    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent < 300) {
      _staffSideResidentCheckoutsHistoryCubit
          .loadMoreResidentsCheckoutsHistory();
    }
  }

  Future onRefresh() async {
    _staffSideResidentCheckoutsHistoryCubit.fetchResidentsCheckoutsHistoryApi();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ResidentCheckInCubit, ResidentCheckInState>(
            listener: (context, state) {
          if (state is ResidentCheckInSuccessfully) {
            onRefresh();
          }
        }),
        BlocListener<ResidentCheckOutCubit, ResidentCheckOutState>(
            listener: (context, state) {
          if (state is ResidentCheckOutSuccessfully) {
            onRefresh();
          }
        }),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: searchBarOpen
              ? const SizedBox()
              : Text(
                  'Resident Checkouts History',
                  style: GoogleFonts.nunitoSans(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          actions: [
            SearchBarAnimation(
              searchBoxColour: Colors.white,
              buttonColour: AppTheme.primaryLiteColor,
              searchBoxWidth:
                  MediaQuery.of(context).size.width * 0.95, // Fix Overflow
              isSearchBoxOnRightSide: false,
              textEditingController: textController,
              isOriginalAnimation: true,
              enableKeyboardFocus: true,
              enteredTextStyle: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600)),
              onExpansionComplete: () {
                setState(() {
                  searchBarOpen = true;
                });
              },
              onCollapseComplete: () {
                setState(() {
                  searchBarOpen = false;
                  textController.clear();
                  _staffSideResidentCheckoutsHistoryCubit.searchQueryData('');
                });
              },
              onPressButton: (isSearchBarOpens) {
                setState(() {
                  searchBarOpen = true;
                });
              },
              onChanged: (value) {
                _staffSideResidentCheckoutsHistoryCubit.searchQueryData(value);
              },
              trailingWidget:
                  const Icon(Icons.search, size: 20, color: Colors.white),
              secondaryButtonWidget:
                  const Icon(Icons.close, size: 20, color: Colors.white),
              buttonWidget:
                  const Icon(Icons.search, size: 20, color: Colors.white),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: BlocBuilder<StaffSideResidentCheckoutsHistoryCubit,
              StaffSideResidentCheckoutsHistoryState>(
            bloc: _staffSideResidentCheckoutsHistoryCubit,
            builder: (context, state) {
              if (state is StaffSideResidentCheckoutsHistoryLoading &&
                  _staffSideResidentCheckoutsHistoryCubit
                      .checkoutsHistoryLogs.isEmpty) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
              if (state is StaffSideResidentCheckoutsHistoryError) {
                return Center(
                    child: Text(state.errorMsg,
                        style:
                            const TextStyle(color: Colors.deepPurpleAccent)));
              }

              var newHistoryLogs =
                  _staffSideResidentCheckoutsHistoryCubit.checkoutsHistoryLogs;

              if (state is StaffSideResidentCheckoutsHistoryLoaded) {
                newHistoryLogs = state.residentCheckoutsHistoryList;
              }

              if (state is StaffSideResidentCheckoutsHistorySearchLoaded) {
                newHistoryLogs = state.residentCheckoutsHistoryList;
              }

              if (newHistoryLogs.isEmpty) {
                return const Center(
                    child: Text('Checkouts History Not Found!',
                        style: TextStyle(color: Colors.deepPurpleAccent)));
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: newHistoryLogs.length + 1,
                padding: const EdgeInsets.only(top: 10),
                shrinkWrap: true,
                itemBuilder: ((context, index) {
                  if (index == newHistoryLogs.length) {
                    return _staffSideResidentCheckoutsHistoryCubit.state
                            is StaffSideResidentCheckoutsHistoryLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                                child: CircularProgressIndicator.adaptive()))
                        : const SizedBox.shrink();
                  }
                  Widget layoutChild() => GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ResidentCheckoutsHistoryDetails(
                                    userId: newHistoryLogs[index]
                                        .resident!
                                        .id
                                        .toString()))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey[300]!)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: FadeInImage(
                                            height: 50.h,
                                            width: 50.w,
                                            fit: BoxFit.cover,
                                            imageErrorBuilder: (_, child,
                                                    stackTrack) =>
                                                Image.asset(
                                                    'assets/images/default.jpg',
                                                    height: 50.h,
                                                    width: 50.w,
                                                    fit: BoxFit.cover),
                                            image: NetworkImage(
                                                newHistoryLogs[index]
                                                    .resident!
                                                    .imageUrl
                                                    .toString()),
                                            placeholder: const AssetImage(
                                                'assets/images/default.jpg'))),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(
                                              newHistoryLogs[index]
                                                  .resident!
                                                  .name
                                                  .toString(),
                                              style: GoogleFonts.ptSans(
                                                  textStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w500))),
                                          Text(
                                              newHistoryLogs[index]
                                                          .resident!
                                                          .lastCheckinDetail!
                                                          .checkoutAt ==
                                                      null
                                                  ? "Last Check-In - "
                                                  : "Last Check-Out - ",
                                              style: GoogleFonts.ptSans(
                                                  textStyle: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w400))),
                                          Text(
                                              newHistoryLogs[index]
                                                          .resident!
                                                          .lastCheckinDetail!
                                                          .checkoutAt ==
                                                      null
                                                  ? formatDate(
                                                      newHistoryLogs[index]
                                                          .resident!
                                                          .lastCheckinDetail!
                                                          .checkinAt
                                                          .toString())
                                                  : formatDate(
                                                      newHistoryLogs[index]
                                                          .resident!
                                                          .lastCheckinDetail!
                                                          .checkoutAt
                                                          .toString()),
                                              style: GoogleFonts.ptSans(
                                                  textStyle: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w400)))
                                        ])),
                                    SizedBox(width: 10.w),
                                    btnTypes(newHistoryLogs[index]
                                        .resident!
                                        .lastCheckinDetail!,newHistoryLogs[index]
                                        .resident!.id),
                                  ],
                                ),
                                Divider(color: Colors.grey.withOpacity(0.2)),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5, bottom: 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                              newHistoryLogs[index]
                                                  .resident!
                                                  .member!
                                                  .blockName
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12)),
                                          const Text(
                                            "Tower Name",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                              newHistoryLogs[index]
                                                  .resident!
                                                  .member!
                                                  .floorNumber
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12)),
                                          const Text(
                                            "Floor No",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                              newHistoryLogs[index]
                                                  .resident!
                                                  .member!
                                                  .aprtNo
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12)),
                                          const Text(
                                            "Property No",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    child: GestureDetector(
                      onTap: () {
                        // showAlertDialog(
                        //   context,
                        //   noticeList[index].title,
                        //   "$formattedDate $formattedTime",
                        //   noticeList[index].description,
                        // );
                      },
                      child: layoutChild(),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget btnTypes(ResidentCheckoutsHistoryList? lastCheckinDetail, residentId) {
    return lastCheckinDetail!.checkoutAt == null
        ? MaterialButton(
            height: 32,
            onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => ResidentProfileDetails(
                        residentId: {'resident_id': residentId.toString()},
                        forQRPage: true))),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Colors.red,
            child: const Text("Check-Out",
                style: TextStyle(color: Colors.white, fontSize: 12)))
        : MaterialButton(
            height: 32,
            onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => ResidentProfileDetails(
                        residentId: {'resident_id':  residentId.toString()},
                        forQRPage: true))),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Colors.blue,
            child: const Text("Check-In",
                style: TextStyle(color: Colors.white, fontSize: 12)));
  }
}
