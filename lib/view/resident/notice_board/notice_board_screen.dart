import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ghp_app/constants/app_images.dart';
import 'package:ghp_app/constants/app_theme.dart';
import 'package:ghp_app/controller/notices/notice_model_cubit.dart';
import 'package:ghp_app/view/session_dialogue.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:searchbar_animation/searchbar_animation.dart';

class NoticeBoardScreen extends StatefulWidget {
  bool isResidentSide;
  NoticeBoardScreen({super.key, required, this.isResidentSide = false});

  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  late NoticeModelCubit _noticeModelCubit;
  bool searchBarOpen = false;
  TextEditingController textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _noticeModelCubit = NoticeModelCubit()..fetchNotices();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent < 300) {
      _noticeModelCubit.loadMoreNotice();
    }
  }

  Future onRefresh() async {
    _noticeModelCubit = NoticeModelCubit()..fetchNotices();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoticeModelCubit, NoticeModelState>(
      listener: (context, state) {
        if (state is NoticeModelLogout) {
          sessionExpiredDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            searchBarOpen
                                ? const SizedBox()
                                : Row(children: [
                                    widget.isResidentSide
                                        ? GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Icon(Icons.arrow_back,
                                                color: Colors.white))
                                        : const SizedBox(),
                                    SizedBox(width: 10.w),
                                    Text('Notice Board',
                                        style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.w600)))
                                  ]),
                            SearchBarAnimation(
                                searchBoxColour: AppTheme.primaryLiteColor,
                                buttonColour: AppTheme.primaryLiteColor,
                                searchBoxWidth:
                                    MediaQuery.of(context).size.width / 1.1,
                                isSearchBoxOnRightSide: false,
                                textEditingController: textController,
                                isOriginalAnimation: true,
                                enableKeyboardFocus: true,
                                enteredTextStyle: GoogleFonts.nunitoSans(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onExpansionComplete: () {
                                  setState(() {
                                    searchBarOpen = true;
                                  });
                                },
                                onCollapseComplete: () {
                                  setState(() {
                                    searchBarOpen = false;
                                    textController.clear();
                                    _noticeModelCubit.searchNotice('');
                                  });
                                },
                                onPressButton: (isSearchBarOpens) {
                                  setState(() {
                                    searchBarOpen = true;
                                  });
                                },
                                onChanged: (value) {
                                  _noticeModelCubit.searchNotice(value);
                                },
                                trailingWidget: const Icon(Icons.search,
                                    size: 20, color: Colors.white),
                                secondaryButtonWidget: const Icon(Icons.close,
                                    size: 20, color: Colors.white),
                                buttonWidget: const Icon(Icons.search,
                                    size: 20, color: Colors.white))
                          ]))),
              SizedBox(height: 5.h),
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
                    child: BlocBuilder<NoticeModelCubit, NoticeModelState>(
                      bloc: _noticeModelCubit,
                      builder: (context, state) {
                        if (state is NoticeModelLoading &&
                            _noticeModelCubit.noticeList.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator.adaptive());
                        }
                        if (state is NoticeModelFailed) {
                          return Center(
                              child: Text(state.errorMsg,
                                  style: const TextStyle(
                                      color: Colors.deepPurpleAccent)));
                        }
                        if (state is NoticeModelInternetError) {
                          return Center(
                              child: Text(state.errorMsg.toString(),
                                  style: const TextStyle(color: Colors.red)));
                        }

                        var noticeList = _noticeModelCubit.noticeList;

                        if (state is NoticeModelSearchedLoaded) {
                          noticeList = state.noticeModel;
                        }

                        if (noticeList.isEmpty) {
                          return const Center(
                              child: Text('Notice Not Found!',
                                  style: TextStyle(
                                      color: Colors.deepPurpleAccent)));
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: noticeList.length + 1,
                          shrinkWrap: true,
                          itemBuilder: ((context, index) {
                            if (index == noticeList.length) {
                              return _noticeModelCubit.state
                                      is NoticeModelLoadMore
                                  ? const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                          child: CircularProgressIndicator
                                              .adaptive()))
                                  : const SizedBox.shrink();
                            }

                            String formattedDate = DateFormat('dd MMM yyyy')
                                .format(noticeList[index].date);
                            String timeString = noticeList[index].time;
                            DateTime parsedTime =
                                DateFormat("HH:mm:ss").parse(timeString);
                            String formattedTime =
                                DateFormat.jm().format(parsedTime);

                            Widget layoutChild() => Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border:
                                          Border.all(color: Colors.grey[300]!)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                ImageAssets.noticeBoardImage,
                                                height: 50.h),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text(noticeList[index].title,
                                                      style: GoogleFonts.ptSans(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                  Text(
                                                      "$formattedDate $formattedTime",
                                                      style: GoogleFonts.ptSans(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)))
                                                ])),
                                            SizedBox(width: 10.w),
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1000.r),
                                                  color: AppTheme.greyColor),
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.navigate_next,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(thickness: 0.3),
                                        Text(
                                          noticeList[index].description,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              child: GestureDetector(
                                onTap: () {
                                  showAlertDialog(
                                    context,
                                    noticeList[index].title,
                                    "$formattedDate $formattedTime",
                                    noticeList[index].description,
                                  );
                                },
                                child: getStatus(noticeList[index].createdAt) ==
                                        'newNoticed'
                                    ? Banner(
                                        message: getStatus(noticeList[index]
                                                    .createdAt) ==
                                                'newNoticed'
                                            ? "New Notice"
                                            : '',
                                        location: BannerLocation.topStart,
                                        child: layoutChild())
                                    : layoutChild(),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getStatus(apiDate) {
    String apiDateString = "$apiDate"; // API से मिली डेट
    DateTime apiDateTime = DateTime.parse(apiDateString);
    DateTime currentDate = DateTime.now();

    if (apiDateTime.year == currentDate.year &&
        apiDateTime.month == currentDate.month &&
        apiDateTime.day == currentDate.day) {
      return "newNoticed";
    } else {
      return "oldNoticed";
    }
  }

  /// dialog
  showAlertDialog(BuildContext context, title, time, description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(10.w),
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Image.asset(ImageAssets.noticeBoardImage, height: 50.h),
                      SizedBox(width: 10.w),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(title,
                                style: GoogleFonts.nunitoSans(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600))),
                            Text(time,
                                style: GoogleFonts.nunitoSans(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400)))
                          ])),
                      SizedBox(width: 10.w),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000.r),
                              color: AppTheme.greyColor),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 0.3),
                  Text(description,
                      style: GoogleFonts.nunitoSans(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
