// ignore_for_file: unused_local_variable, avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../model/current_response_model.dart';
import '../model/forecast_response_model.dart';
import '../untils/constants.dart';

class WeatherProvider extends ChangeNotifier {
  CurrentResponseModel? currentResponseModel;
  ForecastResponseModel? forecastResponseModel;
  double latitude = 0.0, longitude = 0.0;
  String unit = 'metric';

  bool get hasDataLoaded =>
      currentResponseModel != null && forecastResponseModel != null;

  setNewLocation(double lat, double lon) {
    latitude = lat;
    longitude = lon;
  }

  getWeatherData() {
    getCurrentData();
    getForecastData();
  }

  getCurrentData() async {
    final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key');
    try {
      final response = await get(uri);
      final map = json.decode(response.body);
      if (response.statusCode == 200) {
        currentResponseModel = CurrentResponseModel.fromJson(map);
        print(currentResponseModel!.main!.temp!.round());
        notifyListeners();
      } else {
        print(map['message']);
      }
    } catch (error) {
      print('Error $error');
    }
  }

  getForecastData() async {
    final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key');
    try {
      final response = await get(uri);
      final map = json.decode(response.body);
      if (response.statusCode == 200) {
        forecastResponseModel = ForecastResponseModel.fromJson(map);
        print(forecastResponseModel!.list!.length);
        notifyListeners();
      } else {
        print(map['message']);
      }
    } catch (error) {
      print(error);
    }
  }
}
