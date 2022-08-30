// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unused_local_variable, unused_element, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers, use_build_context_synchronously, avoid_print, camel_case_types, body_might_complete_normally_nullable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/pages/settings_page.dart';
import 'package:weather_app/untils/constants.dart';
import 'package:weather_app/untils/location_service.dart';
import 'package:weather_app/untils/text_styles.dart';
import '../provider/weather_provider.dart';
import '../untils/helper_function.dart';

class WeatherPage extends StatefulWidget {
  static const routeName = '/';

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late Size mediaQueary;
  late WeatherProvider provider;
  bool inInit = true;

  @override
  void didChangeDependencies() {
    if (inInit) {
      mediaQueary = MediaQuery.of(context).size;
      provider = Provider.of<WeatherProvider>(context);
      _getData();
      inInit = false;
    }
    super.didChangeDependencies();
  }

  _getData() async {
    final locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      EasyLoading.showToast('Location is disabled');
      await Geolocator.getCurrentPosition();
      _getData();
    }
    try {
      final position = await determinePosition();
      provider.setNewLocation(position.latitude, position.longitude);
      provider.setTempUnit(await provider.getPreferanceTempUnitValue());
      provider.getWeatherData();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'images/bg1.jpg',
            height: mediaQueary.height,
            width: mediaQueary.width,
            fit: BoxFit.cover,
          ),
          provider.hasDataLoaded
              ? ListView(
                  children: [
                    _currentWeatherSection(),
                    _forecastWeatherSection(),
                  ],
                )
              : Center(
                  child: Text(
                  'Please Wait',
                  style: TextStyle(color: Colors.black),
                )),
        ],
      ),
    );
  }

  Widget _currentWeatherSection() {
    final response = provider.currentResponseModel;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () async {
                  final result = await showSearch(
                    context: context,
                    delegate: _citySearchDeligate(),
                  );
                  if (result != null && result.isNotEmpty) {
                    provider.convertAddressToLatLong(result);
                  }
                },
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                )),
            Text(
              '${response!.name}, ${response.sys!.country!}',
              style: txtAddress20,
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    _getData();
                  },
                  child: Icon(
                    Icons.my_location,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(SettingsPage.routeName);
                  },
                  child: Icon(
                    Icons.settings,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 10),
              ],
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getFormattedDateTime(response.dt!, 'MMM dd yyyy'),
              style: txtDateHeader16,
            ),
            SizedBox(width: 20,)
          ],
        ),
        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              '$iconPrefix${response.weather![0].icon}$iconSuffix',
              fit: BoxFit.cover,
            ),
            Text(
              '${response.main!.temp!.round()} $degree${provider.unitSymbool}',
              style: txtTempBig60,
            ),
            SizedBox(width: 30,)
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 50),
          padding: EdgeInsets.symmetric(horizontal: 15),
          width: mediaQueary.width,
          child: Card(
            // elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              child: Text(
                        'feels like ${response.main!.feelsLike!.round()}$degree${provider.unitSymbool}',
                        style: txtNormal16,
                      ))),
                      Expanded(
                          child: Container(
                              child: Text(
                        '${response.weather![0].main}, ${response.weather![0].description}',
                        style: txtNormal16,
                      ))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              child: Text(
                        'Humidity ${response.main!.humidity}%',
                        style: txtNormal16,
                      ))),
                      Expanded(
                          child: Container(
                              child: Text(
                        'Pressure ${response.main!.pressure} hPa',
                        style: txtNormal16,
                      ))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              child: Text(
                        'Visibility ${response.visibility} meter',
                        style: txtNormal16,
                      ))),
                      Expanded(
                          child: Container(
                              child: Text(
                        'Wind ${response.wind!.speed} m/s',
                        style: txtNormal16,
                      ))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Degree ${response.wind!.deg}$degree',
                    style: txtNormal16,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _forecastWeatherSection() {
    return Container();
  }
}

class _citySearchDeligate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      title: Text(query),
      leading: Icon(Icons.search),
      onTap: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filterList = query.isEmpty
        ? cities
        : cities
            .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: filterList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(filterList[index]),
        onTap: () {
          query = filterList[index];
          close(context, query);
        },
      ),
    );
  }
}
