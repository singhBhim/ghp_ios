import 'package:ghp_society_management/constants/dialog.dart';
import 'package:ghp_society_management/constants/export.dart';
import 'package:ghp_society_management/model/user_profile_model.dart';
import 'package:ghp_society_management/view/resident/bills/my_bills.dart';
import 'package:ghp_society_management/view/resident/complaint/comlaint_page.dart';
import 'package:ghp_society_management/view/resident/event/event_screen.dart';
import 'package:ghp_society_management/view/resident/member/members_screen.dart';
import 'package:ghp_society_management/view/resident/notice_board/notice_board_screen.dart';
import 'package:ghp_society_management/view/resident/polls/poll_screen.dart';
import 'package:ghp_society_management/view/resident/refer_property/refer_property_screen.dart';
import 'package:ghp_society_management/view/resident/rent/property_screens.dart';
import 'package:ghp_society_management/view/resident/service_provider/service_provider_screen.dart';
import 'package:ghp_society_management/view/resident/setting/log_out_dialog.dart';
import 'package:ghp_society_management/view/resident/sos/sos_screen.dart';
import 'package:ghp_society_management/view/resident/visitors/visitor_screen.dart';
import 'package:ghp_society_management/view/society/select_society_screen.dart';
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
    // context.read<UserProfileCubit>().fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // BlocListener<UserProfileCubit, UserProfileState>(
        //     listener: (context, state) {
        //   if (state is UserProfileLoaded) {
        //     String status = checkBillStatus(
        //         context, state.userProfile.first.data!.unpaidBills!.first);
        //   }
        // }),
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
        appBar: AppBar(
            leadingWidth: double.infinity,
            leading: BlocBuilder<UserProfileCubit, UserProfileState>(
              builder: (context, state) {
                if (state is UserProfileLoaded) {
                  Future.delayed(const Duration(milliseconds: 5), () {
                    List<UnpaidBill> billData =
                        state.userProfile.first.data!.unpaidBills!;
                    if (billData.isNotEmpty) {
                      checkPaymentReminder(
                          context: context,
                          myUnpaidBill:
                              state.userProfile.first.data!.unpaidBills!.first);
                    }
                  });

                  // Future.delayed(const Duration(milliseconds: 5),(){
                  //   checkPaymentReminder(
                  //       context: context,
                  //       myUnpaidBill:
                  //       state.userProfile.first.data!.unpaidBills!.first);
                  // });
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () => profileViewAlertDialog(
                                      context, state.userProfile.first),
                                  child: state.userProfile.first.data!.user!
                                              .image !=
                                          null
                                      ? CircleAvatar(
                                          radius: 22.h,
                                          backgroundImage: NetworkImage(state
                                              .userProfile
                                              .first
                                              .data!
                                              .user!
                                              .image
                                              .toString()))
                                      : const CircleAvatar(
                                          radius: 22,
                                          backgroundImage: AssetImage(
                                              'assets/images/default.jpg'))),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        state.userProfile.first.data!.user!.name
                                            .toString(),
                                        style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w600,
                                                overflow:
                                                    TextOverflow.ellipsis))),
                                    const SizedBox(height: 3),
                                    Text(
                                        '${state.userProfile.first.data!.user!.blockName} - FLOOR ${state.userProfile.first.data!.user!.floorNumber ?? ''}'
                                            .toUpperCase(),
                                        style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w500)))
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                        headerWidget(
                            context,
                            state.userProfile.first.data!.user!.id.toString(),
                            state.userProfile.first.data!.user!.name.toString(),
                            state.userProfile.first.data!.user!.image ?? '')
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                  radius: 22,
                                  backgroundImage:
                                      AssetImage('assets/images/default.jpg')),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Loading...",
                                        style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w600,
                                                overflow:
                                                    TextOverflow.ellipsis))),
                                    const SizedBox(height: 3),
                                    Text('TOWER LOADING...',
                                        style: GoogleFonts.nunitoSans(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w500)))
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10)
                            ],
                          ),
                        ),
                        headerWidget(context, '', '', '', isDemo: true)
                      ],
                    ),
                  );
                }
              },
            )),
        body: SafeArea(
          child: Column(
            children: [
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
                                        color: Colors.black,
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
                                        color: Colors.black,
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
                                        color: Colors.black,
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
                                        color: Colors.black,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500)))
                          ]))
                    ]),
              ),
              SizedBox(height: 10.h),
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
                                            color: Colors.black,
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
                                            color: Colors.black,
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
                                            color: Colors.black,
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
                                            color: Colors.black,
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
                                              color: Colors.black,
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
                                              color: Colors.black,
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
                                              color: Colors.black,
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
                                              color: Colors.black,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 15.h),
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
                                              color: Colors.black,
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
                                                  color: Colors.black,
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
                                                  color: Colors.black,
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
                                            color: Colors.black,
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
              const SizedBox(height: 10),
              Expanded(
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
                                    border:
                                        Border.all(color: AppTheme.blueColor)),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 8.h),
                                  child: Center(
                                    child: Text(
                                      'View All',
                                      style: GoogleFonts.nunitoSans(
                                        textStyle: TextStyle(
                                          color: AppTheme.blueColor,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
