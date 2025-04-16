import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ghp_society_management/constants/app_images.dart';
import 'package:ghp_society_management/constants/app_theme.dart';
import 'package:ghp_society_management/constants/local_storage.dart';
import 'package:ghp_society_management/controller/select_society/select_society_cubit.dart';
import 'package:ghp_society_management/view/resident/authentication/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:searchbar_animation/searchbar_animation.dart';

class SelectSocietyScreen extends StatefulWidget {
  const SelectSocietyScreen({super.key});

  @override
  State<SelectSocietyScreen> createState() => _SelectSocietyScreenState();
}

class _SelectSocietyScreenState extends State<SelectSocietyScreen> {
  TextEditingController textController = TextEditingController();
  bool searchBarOpen = false;
  final ScrollController _scrollController = ScrollController();
  late SelectSocietyCubit _selectSocietyCubit;

  @override
  void initState() {
    _selectSocietyCubit = SelectSocietyCubit()..fetchSocietyList();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent < 300) {
      _selectSocietyCubit.loadMoreNotice();
    }
  }

  Future onRefresh() async {
    _selectSocietyCubit = SelectSocietyCubit()..fetchSocietyList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    searchBarOpen
                        ? const SizedBox()
                        : Text('Select Society',
                            style: GoogleFonts.nunitoSans(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600))),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SearchBarAnimation(
                        searchBoxColour: AppTheme.backgroundColor,
                        buttonColour: AppTheme.backgroundColor,
                        searchBoxWidth: MediaQuery.of(context).size.width / 1.1,
                        isSearchBoxOnRightSide: false,
                        textEditingController: textController,
                        isOriginalAnimation: true,
                        enableKeyboardFocus: true,
                        hintText: "Search society name...",
                        cursorColour: AppTheme.primaryColor,
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
                            _selectSocietyCubit.fetchSocietyList();
                            textController.clear();
                          });
                        },
                        onPressButton: (isSearchBarOpens) {
                          setState(() {
                            searchBarOpen = true;
                          });
                        },
                        onChanged: (value) {
                          _selectSocietyCubit.searchSociety(value);
                        },
                        trailingWidget: const Icon(Icons.search,
                            size: 20, color: Colors.white),
                        secondaryButtonWidget: const Icon(Icons.close,
                            size: 20, color: Colors.white),
                        buttonWidget: const Icon(Icons.search,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              RefreshIndicator(
                onRefresh: onRefresh,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 100.h,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r))),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h, top: 12.h),
                    child: BlocBuilder<SelectSocietyCubit, SelectSocietyState>(
                        bloc: _selectSocietyCubit,
                        builder: (context, state) {
                          if (state is SelectSocietyLoading &&
                              _selectSocietyCubit.societyList.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator.adaptive());
                          }
                          if (state is SelectSocietyFailed) {
                            return Center(
                                child: Text(state.errorMsg,
                                    style: const TextStyle(
                                        color: Colors.deepPurpleAccent)));
                          }
                          if (state is SelectSocietyInternetError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Internet connection error!',
                                      style: GoogleFonts.nunitoSans(
                                          textStyle: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 16))),
                                  const SizedBox(height: 15),
                                  GestureDetector(
                                    onTap: () => onRefresh,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.15)),
                                      child: Text('Retry!',
                                          style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontSize: 16),
                                          )),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }

                          var societyList = _selectSocietyCubit.societyList;

                          if (state is SelectSocietySearchedLoaded) {
                            societyList = state.selectedSociety;
                          }
                          if (societyList.isEmpty) {
                            return const Center(
                                child: Text('Society Not Found!',
                                    style: TextStyle(
                                        color: Colors.deepPurpleAccent)));
                          }
                          return ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: societyList.length + 1,
                            shrinkWrap: true,
                            itemBuilder: ((context, index) {
                              if (index == societyList.length) {
                                return _selectSocietyCubit.state
                                        is SelectSocietyLoadMore
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Center(
                                            child: CircularProgressIndicator
                                                .adaptive()))
                                    : const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                child: GestureDetector(
                                  onTap: () async {
                                    LocalStorage.localStorage.setString(
                                        'societyId',
                                        '${societyList[index].id}');
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (builder) => LoginScreen(
                                                societyId: societyList[index]
                                                    .id
                                                    .toString())));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF1B1A2C),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
                                                  color:
                                                      const Color(0xFF252340)),
                                              child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Image.asset(
                                                      ImageAssets.societyImage,
                                                      height: 25.h,
                                                      width: 25.h))),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                Text(
                                                    societyList[index]
                                                        .name
                                                        .toString(),
                                                    style: GoogleFonts.ptSans(
                                                        textStyle: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))),
                                                Text(
                                                    '${societyList[index].totalTowers} Towers, ${societyList[index].location}',
                                                    style: GoogleFonts.ptSans(
                                                        textStyle: TextStyle(
                                                            color: AppTheme
                                                                .darkgreyColor,
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)))
                                              ])),
                                          Icon(
                                            Icons.navigate_next,
                                            color: AppTheme.darkgreyColor,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
