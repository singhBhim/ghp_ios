import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:ghp_app/constants/config.dart';
import 'package:ghp_app/constants/local_storage.dart';
import 'package:ghp_app/network/api_manager.dart';
import 'package:meta/meta.dart';
part 'resend_request_state.dart';

class ResendRequestCubit extends Cubit<ResendRequestState> {
  ResendRequestCubit() : super(ResendRequestInitial());
  ApiManager apiManager = ApiManager();
  resendRequestAPI({var statusBody}) async {
    emit(ResendRequestLoading());

    try {
      var token = LocalStorage.localStorage.getString('token');
      var responseData = await apiManager.postRequest(
          statusBody,
          Config.baseURL + Routes.resendVisitorsRequest,
          {'Authorization': 'Bearer $token', 'Accept': 'application/json'});

      var data = json.decode((responseData.body.toString()));
      print(responseData.statusCode);
      if (responseData.statusCode == 201) {
        if (data['status']) {
          emit(ResendRequestSuccessfully(
              successMsg: data['message'],
              visitorsId: data['data']['visitor_id'].toString()));
        } else {
          emit(ResendRequestFailed(errorMsg: data['message']));
        }
      } else if (responseData.statusCode == 401) {
        emit(ResendRequestLogout());
      } else {
        emit(ResendRequestFailed(errorMsg: data['message']));
      }
    } on SocketException {
      emit(ResendRequestInternetError(errorMsg: "Internet Connection Failed"));
    } catch (e) {
      emit(ResendRequestFailed(errorMsg: e.toString()));
    }
  }
}
