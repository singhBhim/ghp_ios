import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ghp_app/constants/app_images.dart';
import 'package:ghp_app/constants/app_theme.dart';
import 'package:ghp_app/controller/my_bills/my_bills_cubit.dart';
import 'package:ghp_app/view/resident/bills/bill_detail_screen.dart';

class MyBillsPage extends StatefulWidget {
  final String types;

  MyBillsPage({required this.types});

  @override
  MyBillsPageState createState() => MyBillsPageState();
}

class MyBillsPageState extends State<MyBillsPage> {
  final ScrollController _scrollController = ScrollController();
  late MyBillsCubit _myBillsCubit;

  @override
  void initState() {
    super.initState();
    // Initialize cubit and fetch bills based on the types passed
    _myBillsCubit = MyBillsCubit()
      ..fetchMyBills(context: context, billTypes: widget.types);
    _scrollController
        .addListener(_onScroll); // Add scroll listener for pagination
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // If scrolled to the bottom, attempt to load more bills
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _myBillsCubit.loadMoreBills(
          context, widget.types); // Load more bills based on current type
    }
  }

  void _fetchData() {
    // Re-fetch the data when types are changed (when navigating between sections)
    _myBillsCubit.fetchMyBills(context: context, billTypes: widget.types);
  }

  @override
  void didUpdateWidget(covariant MyBillsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the bill type has changed, then re-fetch data
    if (oldWidget.types != widget.types) {
      _fetchData(); // Re-fetch data based on the new type
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBillsCubit, MyBillsState>(
      bloc: _myBillsCubit, // Attach cubit
      builder: (context, state) {
        if (state is MyBillsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MyBillsLoaded) {
          return ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount:
                state.hasMore ? state.bills.length + 1 : state.bills.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == state.bills.length) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
              final bill = state.bills[index];
              int delay = bill.dueDateRemainDays!;
              delayData() {
                if (delay > 0) {
                  return "Due in ${bill.dueDateRemainDays.toString()} Days";
                } else {
                  return "${bill.dueDateDelayDays.toString()} Days Delay";
                }
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(5)),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.r),
                        color: const Color(0xFFF2F1FE)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(ImageAssets.receiptImage,
                          height: 30.h,
                          width: 30.h,
                          color: bill.status == 'unpaid'
                              ? Colors.red.withOpacity(0.5)
                              : Colors.cyanAccent.withOpacity(0.5)),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(bill.service!.name.toString(),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16)),
                      Text(bill.invoiceNumber.toString(),
                          style: const TextStyle(
                              color: Colors.deepPurpleAccent, fontSize: 12)),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("₹${bill.amount.toString().replaceAll('.00', '')}",
                          style: const TextStyle(
                              color: Colors.blue, fontSize: 14)),
                      const SizedBox(width: 18),
                      Text(delayData().toString(),
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                  trailing: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                BillDetailScreen(billId: bill.id.toString()))),
                    child: CircleAvatar(
                      backgroundColor: AppTheme.greyColor,
                      child: Icon(
                        Icons.navigate_next,
                        color: AppTheme.darkgreyColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else if (state is MyBillsFailed) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
                child: Text(
              state.errorMsg.toString(),
              style: const TextStyle(color: Colors.deepPurpleAccent),
            )),
          );
        } else if (state is MyBillsInternetError) {
          return const Center(
              child: Text(
            'Internet connection error',
            style: TextStyle(color: Colors.red),
          )); // Handle internet error
        }
        return Container(); // Return empty container if no state matches
      },
    );
  }
}
