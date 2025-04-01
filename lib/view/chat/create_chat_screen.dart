import 'package:ghp_app/constants/dialog.dart';
import 'package:ghp_app/constants/export.dart';
import 'package:ghp_app/model/user_model.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:uuid/uuid.dart';

import '../../model/staff_model.dart';

class CreateChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userImage;

  const CreateChatScreen(
      {super.key,
      required this.userId,
      required this.userName,
      required this.userImage});

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  bool searchBarOpen = false;
  final TextEditingController textController = TextEditingController();
  UserModel? userList;
  @override
  void initState() {
    context.read<GetStaffCubit>().fetchStaffList();
    super.initState();
  }

  late BuildContext dialogContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    searchBarOpen
                        ? const SizedBox()
                        : Row(children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Icon(Icons.arrow_back,
                                    color: Colors.white)),
                            SizedBox(width: 10.w),
                            Text('Society Staff',
                                style: GoogleFonts.nunitoSans(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600)))
                          ]),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SearchBarAnimation(
                        searchBoxColour: AppTheme.primaryLiteColor,
                        buttonColour: AppTheme.primaryLiteColor,
                        searchBoxWidth: MediaQuery.of(context).size.width / 1.1,
                        isSearchBoxOnRightSide: false,
                        textEditingController: textController,
                        isOriginalAnimation: true,
                        enableKeyboardFocus: true,
                        cursorColour: Colors.grey,
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
                            context.read<GetStaffCubit>().searchStaff('');
                            context.read<GetStaffCubit>().fetchStaffList();
                          });
                        },
                        onPressButton: (isSearchBarOpens) {
                          setState(() {
                            searchBarOpen = true;
                          });
                        },
                        onChanged: (value) {
                          context.read<GetStaffCubit>().searchStaff(value);
                        },
                        trailingWidget: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.white,
                        ),
                        secondaryButtonWidget: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.white,
                        ),
                        buttonWidget: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: BlocBuilder<GetStaffCubit, GetStaffState>(
                  builder: (context, state) {
                    if (state is GetStaffLoaded) {
                      List<Datum> staffList =
                          state.staffList.first.data.staffs.data;

                      if (staffList.isEmpty) {
                        return const Center(
                            child: Text("Service Provider Not Found!",
                                style:
                                    TextStyle(color: Colors.deepPurpleAccent)));
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: staffList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  showLoadingDialog(context, (ctx) {
                                    dialogContext = ctx;
                                  });

                                  var uuid = const Uuid();
                                  String groupId = uuid.v6();

                                  userList = UserModel(
                                      userImage: staffList[index].image,
                                      uid: staffList[index].userId.toString(),
                                      userName: staffList[index].name,
                                      serviceCategory: staffList[index]
                                              .staffCategory!
                                              .name
                                              .isNotEmpty
                                          ? staffList[index].staffCategory!.name
                                          : staffList[index].role.toString());

                                  print(
                                      'user--------->>>>>>${userList!.uid.toString()}');
                                  print(
                                      'user--------->>>>>>${widget.userId} ${widget.userName} ${widget.userImage} ${staffList[index].staffCategory?.name ?? ''}');
                                  //
                                  context.read<GroupCubit>().createGroup(
                                      userList!,
                                      groupId,
                                      context,
                                      widget.userId,
                                      widget.userName,
                                      widget.userImage,
                                      staffList[index]
                                              .staffCategory!
                                              .name
                                              .isNotEmpty
                                          ? staffList[index].staffCategory!.name
                                          : staffList[index].role.toString());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Card(
                                        elevation: 1,
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        child: staffList[index].image != null
                                            ? CircleAvatar(
                                                radius: 25.r,
                                                backgroundColor:
                                                    Colors.transparent,
                                                backgroundImage: NetworkImage(
                                                    staffList[index].image!))
                                            : Image.asset(ImageAssets.chatImage,
                                                height: 50.0),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                capitalizeWords(staffList[index]
                                                    .name
                                                    .toString()),
                                                style: GoogleFonts.nunitoSans(
                                                    textStyle: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600))),
                                            Text(
                                              staffList[index]
                                                      .staffCategory!
                                                      .name
                                                      .isNotEmpty
                                                  ? staffList[index]
                                                      .staffCategory!
                                                      .name
                                                      .toString()
                                                  : capitalizeWords(
                                                      staffList[index]
                                                          .role
                                                          .toString()
                                                          .replaceAll(
                                                              "_", ' ')),
                                              style: GoogleFonts.nunitoSans(
                                                  textStyle: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                color: Colors.grey[300],
                              )
                            ],
                          );
                        },
                      );
                    } else if (state is GetStaffSearchedLoaded) {
                      if (state.staffList.isEmpty) {
                        return const Center(
                            child: Text("Service Provider Not Found!",
                                style:
                                    TextStyle(color: Colors.deepPurpleAccent)));
                      }
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.staffList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  showLoadingDialog(context, (ctx) {
                                    dialogContext = ctx;
                                  });
                                  var uuid = const Uuid();
                                  String groupId = uuid.v6();
                                  userList = UserModel(
                                      userImage:
                                          state.staffList[index]!.image ?? '',
                                      uid: state.staffList[index]!.userId
                                          .toString(),
                                      userName: state.staffList[index]!.name
                                          .toString(),
                                      serviceCategory: state
                                          .staffList[index]!.staffCategory!.name
                                          .toString());
                                  context.read<GroupCubit>().createGroup(
                                      userList!,
                                      groupId,
                                      context,
                                      widget.userId,
                                      widget.userName,
                                      widget.userImage,
                                      state
                                          .staffList[index]!.staffCategory!.name
                                          .toString());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Image.asset(ImageAssets.chatImage,
                                          height: 50.0),
                                      const SizedBox(width: 10.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(state.staffList[index]!.name,
                                                style: GoogleFonts.nunitoSans(
                                                    textStyle: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600))),
                                            Text(
                                              state.staffList[index]!
                                                  .staffCategory!.name,
                                              style: GoogleFonts.nunitoSans(
                                                  textStyle: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                color: Colors.grey[300],
                              )
                            ],
                          );
                        },
                      );
                    } else if (state is GetStaffLoading) {
                      return const Center(
                          child: CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.deepPurpleAccent));
                    } else if (state is GetStaffFailed) {
                      return Center(
                          child: Text(state.errorMsg.toString(),
                              style: const TextStyle(
                                  color: Colors.deepPurpleAccent)));
                    } else if (state is GetStaffInternetError) {
                      return const Center(
                          child: Text('Internet connection error',
                              style: TextStyle(color: Colors.red)));
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
