import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ghp_app/constants/config.dart';
import 'package:ghp_app/constants/local_storage.dart';
import 'package:ghp_app/network/api_manager.dart';
import 'package:meta/meta.dart';

part 'create_refer_property_state.dart';

class CreateReferPropertyCubit extends Cubit<CreateReferPropertyState> {
  CreateReferPropertyCubit() : super(CreateReferPropertyInitial());

  ApiManager apiManager = ApiManager();

  /// CREATE REFER PROPERTY
  createReferProperty(referPropertyBody) async {
    emit(CreateReferPropertyLoading());
    try {
      var token = LocalStorage.localStorage.getString('token');

      var responseData = await apiManager.postRequest(
          referPropertyBody,
          Config.baseURL + Routes.createReferProperty,
          {'Authorization': 'Bearer $token', 'Accept': 'application/json'});

      if (responseData.statusCode == 201) {
        emit(CreateReferPropertysuccessfully());
      } else if (responseData.statusCode == 401) {
        emit(CreateReferPropertyLogout());
      } else {
        emit(CreateReferPropertyFailed());
      }
    } on SocketException {
      emit(CreateReferPropertyInternetError());
    } catch (e) {
      print(e);
      emit(CreateReferPropertyFailed());
    }
  }
}
