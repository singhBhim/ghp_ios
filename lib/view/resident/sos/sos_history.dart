import 'package:ghp_society_management/constants/export.dart';
import 'package:ghp_society_management/controller/sos_management/sos_history/sos_history_cubit.dart';

import 'package:ghp_society_management/model/sos_history_model.dart';
import 'package:ghp_society_management/view/resident/sos/sos_history_details.dart';

class SosHistoryPage extends StatefulWidget {
  const SosHistoryPage({super.key});
  @override
  State<SosHistoryPage> createState() => SosHistoryPageState();
}

class SosHistoryPageState extends State<SosHistoryPage> {
  late SosHistoryCubit _sosHistoryCubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _sosHistoryCubit = SosHistoryCubit();
    fetchData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> fetchData() async {
    _sosHistoryCubit.fetchSosHistory(context: context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 300) {
      _sosHistoryCubit.loadMoreSosHistory(context);
    }
  }

  late BuildContext dialogueContext;
  @override
  Widget build(BuildContext context) {
    _sosHistoryCubit.fetchSosHistory(context: context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white)),
                  SizedBox(width: 10.w),
                  Text('SOS History',
                      style: GoogleFonts.nunitoSans(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600))),
                ])),
            SizedBox(height: 15.h),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: RefreshIndicator(
                  onRefresh: fetchData,
                  child: BlocBuilder<SosHistoryCubit, SosHistoryState>(
                      bloc: _sosHistoryCubit,
                      builder: (context, state) {
                        if (state is SosHistoryLoading &&
                            _sosHistoryCubit.sosHistory.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator.adaptive(
                                  backgroundColor: Colors.deepPurpleAccent));
                        }

                        if (state is SosHistoryFailed) {
                          return Center(
                              child: Text(state.errorMsg.toString(),
                                  style: const TextStyle(color: Colors.red)));
                        }

                        if (state is SosHistoryInternetError) {
                          return Center(
                              child: Text(state.errorMsg.toString(),
                                  style: const TextStyle(color: Colors.red)));
                        }

                        var historyList = _sosHistoryCubit.sosHistory;

                        if (historyList.isEmpty) {
                          return const Center(
                              child: Text("SOS History Not Found!",
                                  style: TextStyle(
                                      color: Colors.deepPurpleAccent)));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          controller: _scrollController,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: historyList.length + 1,
                          itemBuilder: ((context, index) {
                            if (index == historyList.length) {
                              return _sosHistoryCubit.state
                                      is SosHistoryLoadingMore
                                  ? const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                          child: CircularProgressIndicator()))
                                  : const SizedBox.shrink();
                            }

                            SosHistoryList sosHistory = historyList[index];

                            acknowledgedAt() {
                              if (sosHistory.acknowledgedAt != null) {
                                return formatDate(
                                    sosHistory.acknowledgedAt.toString());
                              }
                              return 'N/A';
                            }

                            Widget sosStatus() {
                              return Text(
                                  capitalizeWords(sosHistory.status.toString()),
                                  style: GoogleFonts.nunitoSans(
                                      textStyle: TextStyle(
                                          color: sosHistory.status == 'new'
                                              ? Colors.orange
                                              : sosHistory.status == 'cancelled'
                                                  ? Colors.red
                                                  : Colors.deepPurpleAccent,
                                          fontSize: 14.sp)));
                            }

                            return GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SosHistoryDetails(
                                          sosHistoryList: sosHistory))),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.withOpacity(0.2))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: FadeInImage(
                                                    placeholder: const AssetImage(
                                                        "assets/images/sosi.png"),
                                                    imageErrorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.asset(
                                                          "assets/images/sosi.png",
                                                          height: 80,
                                                          width: 80,
                                                          fit: BoxFit.cover);
                                                    },
                                                    image:
                                                        const NetworkImage(''),
                                                    fit: BoxFit.cover,
                                                    height: 80,
                                                    width: 80)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    capitalizeWords(sosHistory
                                                        .sosCategory!.name
                                                        .toString()
                                                        .toString()),
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                      textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),

                                                  /// Using Wrap ensures text wraps to new line if needed
                                                  Wrap(children: [
                                                    Text(
                                                        'Area : ${sosHistory.area.toString()}',
                                                        style: GoogleFonts.nunitoSans(
                                                            textStyle: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize:
                                                                    13.sp)))
                                                  ]),

                                                  Text(
                                                      'Acknowledged At : ${acknowledgedAt()}',
                                                      style: GoogleFonts.nunitoSans(
                                                          textStyle: TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 13.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400))),

                                                  Row(
                                                    children: [
                                                      Text('Status : ',
                                                          style: GoogleFonts.nunitoSans(
                                                              textStyle: TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize:
                                                                      13.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400))),
                                                      SizedBox(
                                                          child: sosStatus()),
                                                    ],
                                                  ),
                                                  // status(visitors),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        Divider(
                                            color:
                                                Colors.grey.withOpacity(0.2)),

                                        /// Wrap for Purpose of Visit
                                        Wrap(
                                          children: [
                                            Text(
                                              sosHistory.description ??
                                                  ''.toString(),
                                              style: GoogleFonts.nunitoSans(
                                                textStyle: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
    );
  }
}
