import 'package:ghp_app/constants/dialog.dart';
import 'package:ghp_app/constants/export.dart';
import 'package:ghp_app/view/resident/bills/my_bills.dart';
import 'package:ghp_app/view/resident/complaint/comlaint_page.dart';
import 'package:ghp_app/view/resident/event/event_screen.dart';
import 'package:ghp_app/view/resident/member/members_screen.dart';
import 'package:ghp_app/view/resident/notice_board/notice_board_screen.dart';
import 'package:ghp_app/view/resident/polls/poll_screen.dart';
import 'package:ghp_app/view/resident/refer_property/refer_property_screen.dart';
import 'package:ghp_app/view/resident/rent/property_screens.dart';
import 'package:ghp_app/view/resident/service_provider/service_provider_screen.dart';
import 'package:ghp_app/view/resident/setting/log_out_dialog.dart';
import 'package:ghp_app/view/resident/sos/sos_screen.dart';
import 'package:ghp_app/view/resident/visitors/visitor_screen.dart';
import 'package:ghp_app/view/society/select_society_screen.dart';

import '../resident/parcel_flow/parcel_listing.dart';

class HomeScreen extends StatefulWidget {
  final Function(int index) onChanged;
  const HomeScreen({super.key, required this.onChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showLess = true;

  late BuildContext dialogueContext;

  @override
  void initState() {
    super.initState();
    context.read<UserProfileCubit>().fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserProfileCubit, UserProfileState>(
            listener: (context, state) {
          if (state is UserProfileLogout) {
            sessionExpiredDialog(context);
          }
        }),
        BlocListener<LogoutCubit, LogoutState>(
          listener: (context, state) async {
            if (state is LogoutLoading) {
              showLoadingDialog(context, (ctx) {
                dialogueContext = ctx;
              });
            } else if (state is LogoutSuccessfully) {
              snackBar(context, 'User logout successfully', Icons.done,
                  AppTheme.guestColor);

              Navigator.of(dialogueContext).pop();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (builder) => const SelectSocietyScreen()),
                  (route) => false);
            } else if (state is LogoutFailed) {
              snackBar(context, 'User logout failed', Icons.warning,
                  AppTheme.redColor);

              Navigator.of(dialogueContext).pop();
            } else if (state is LogoutInternetError) {
              snackBar(context, 'Internet connection failed', Icons.wifi_off,
                  AppTheme.redColor);

              Navigator.of(dialogueContext).pop();
            } else if (state is LogoutSessionError) {
              Navigator.of(dialogueContext).pop();
              sessionExpiredDialog(context);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<UserProfileCubit, UserProfileState>(
                builder: (context, state) {
                  if (state is UserProfileLoaded) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                profileViewAlertDialog(
                                    context, state.userProfile.first);
                              },
                              child:
                                  state.userProfile.first.data!.user!.image !=
                                          null
                                      ? CircleAvatar(
                                          radius: 25.h,
                                          backgroundImage: NetworkImage(state
                                              .userProfile
                                              .first
                                              .data!
                                              .user!
                                              .image
                                              .toString()))
                                      : const CircleAvatar(
                                          radius: 25,
                                          backgroundImage: AssetImage(
                                              'assets/images/default.jpg'))),
                          Flexible(
                            child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                title: Text(
                                    state.userProfile.first.data!.user!.name
                                        .toString(),
                                    style: GoogleFonts.nunitoSans(
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                                subtitle: Text(
                                    '${state.userProfile.first.data!.user!.blockName} - FLOOR ${state.userProfile.first.data!.user!.floorNumber ?? ''}'
                                        .toUpperCase(),
                                    style: GoogleFonts.nunitoSans(
                                        textStyle: TextStyle(
                                            color: Colors.green,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500))),
                                trailing: headerWidget(
                                    context,
                                    state.userProfile.first.data!.user!.id
                                        .toString(),
                                    state.userProfile.first.data!.user!.name
                                        .toString(),
                                    state.userProfile.first.data!.user!.image ??
                                        '')),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  AssetImage('assets/images/default.jpg')),
                          Flexible(
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              title: Text('Hello user',
                                  style: GoogleFonts.nunitoSans(
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w500))),
                              subtitle: Text('Block 00 - Floor 00',
                                  style: GoogleFonts.nunitoSans(
                                      textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ))),
                              trailing: headerWidget(context, '', '', ''),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 15.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (builder) => const MemberScreen()));
                          },
                          child: Column(children: [
                            Image.asset(ImageAssets.membersImage, height: 60.h),
                            SizedBox(height: 5.h),
                            Text('Members',
                                style: GoogleFonts.nunitoSans(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500)))
                          ])),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (builder) =>
                                    const ServiceProviderScreen()));
                          },
                          child: Column(children: [
                            Image.asset(ImageAssets.serviceImage, height: 60.h),
                            SizedBox(height: 5.h),
                            Text('Service Provider',
                                style: GoogleFonts.nunitoSans(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500)))
                          ])),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (builder) => const ComplaintScreen()));
                          },
                          child: Column(children: [
                            Image.asset(ImageAssets.complaintImage,
                                height: 60.h),
                            SizedBox(height: 5.h),
                            Text('Complaints',
                                style: GoogleFonts.nunitoSans(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500)))
                          ])),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (builder) => const EventScreen()));
                          },
                          child: Column(children: [
                            Image.asset(ImageAssets.eventImage, height: 60.h),
                            SizedBox(height: 5.h),
                            Text('Event',
                                style: GoogleFonts.nunitoSans(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500)))
                          ]))
                    ]),
              ),
              SizedBox(height: 20.h),
              showLess
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (builder) => NoticeBoardScreen(
                                        isResidentSide: true)));
                              },
                              child: Column(children: [
                                Image.asset(ImageAssets.noticeImage,
                                    height: 60.h),
                                SizedBox(height: 5.h),
                                Text('Notice Board',
                                    style: GoogleFonts.nunitoSans(
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500)))
                              ])),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (builder) => const SosScreen(),
                                ));
                              },
                              child: Column(children: [
                                Image.asset(ImageAssets.sosImage, height: 60.h),
                                SizedBox(height: 5.h),
                                Text('SOS',
                                    style: GoogleFonts.nunitoSans(
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500)))
                              ])),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (builder) => const RentScreen()));
                              },
                              child: Column(children: [
                                Image.asset(ImageAssets.rentImage,
                                    height: 60.h),
                                SizedBox(height: 5.h),
                                Text('Rent/Sell',
                                    style: GoogleFonts.nunitoSans(
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500)))
                              ])),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showLess = false;
                              });
                            },
                            child: Column(
                              children: [
                                Image.asset(ImageAssets.moreImage,
                                    height: 60.h),
                                SizedBox(height: 5.h),
                                Text('More',
                                    style: GoogleFonts.nunitoSans(
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500)))
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                NoticeBoardScreen()));
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(ImageAssets.noticeImage,
                                          height: 60.h),
                                      SizedBox(height: 5.h),
                                      Text('Notice Board',
                                          style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (builder) => const SosScreen(),
                                    ));
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(ImageAssets.sosImage,
                                          height: 60.h),
                                      SizedBox(height: 5.h),
                                      Text('SOS',
                                          style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (builder) => RentScreen(),
                                    ));
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        ImageAssets.rentImage,
                                        height: 60.h,
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Text('Rent/Sell',
                                          style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                const ReferPropertyScreen()));
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        ImageAssets.referImage,
                                        height: 60.h,
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Text('Refer',
                                          style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                const VisitorScreen()));
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(ImageAssets.visitorsImage,
                                          height: 60.h),
                                      SizedBox(height: 5.h),
                                      Text('Visitors',
                                          style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (builder) =>
                                            const PollScreen(),
                                      ));
                                    },
                                    child: Column(children: [
                                      Image.asset(ImageAssets.pollsImage,
                                          height: 60.h),
                                      SizedBox(height: 5.h),
                                      Text('Polls',
                                          style: GoogleFonts.nunitoSans(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500)))
                                    ])),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (builder) =>
                                                  const ParcelListingPage()));
                                    },
                                    child: Column(children: [
                                      Image.asset(ImageAssets.parcelImage,
                                          height: 60.h),
                                      SizedBox(height: 5.h),
                                      Text('Parcel',
                                          style: GoogleFonts.nunitoSans(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500)))
                                    ])),
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showLess = true;
                                      });
                                    },
                                    child: Column(children: [
                                      Image.asset(ImageAssets.moreImage,
                                          height: 60.h),
                                      SizedBox(height: 5.h),
                                      Text('Show Less',
                                          style: GoogleFonts.nunitoSans(
                                              textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                          )))
                                    ])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              SizedBox(height: 20.h),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        const SlidersManagement(),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text('Upcoming Bills',
                                  style: GoogleFonts.nunitoSans(
                                    textStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.onChanged(1);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppTheme.primaryColor)),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 8.h),
                                    child: Center(
                                      child: Text(
                                        'View All',
                                        style: GoogleFonts.nunitoSans(
                                          textStyle: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        MyBillsPage(types: 'unpaid')
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
}
