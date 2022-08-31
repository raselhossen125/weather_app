// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unused_local_variable, unused_element, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers, use_build_context_synchronously, avoid_print, camel_case_types, body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/pages/settings_page.dart';
import 'package:weather_app/untils/constants.dart';
import 'package:weather_app/untils/location_service.dart';
import 'package:weather_app/untils/text_styles.dart';
import '../provider/weather_provider.dart';
import '../untils/color.dart';
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
            'images/bg2.jpg',
            height: mediaQueary.height,
            width: mediaQueary.width,
            fit: BoxFit.cover,
          ),
          provider.hasDataLoaded
              ? SingleChildScrollView(
                child: Column(
                    children: [
                      _currentWeatherSection(),
                      _forecastWeatherSection(),
                      _sunRiseSunSetSection(),
                    ],
                  ),
              )
              : Center(
                  child: Text(
                  'Please Wait',
                  style: TextStyle(color: Colors.white),
                )),
        ],
      ),
      floatingActionButton: provider.currentResponseModel == null ? null : SpeedDial(
        icon: Icons.add,
        foregroundColor: iconColor,
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: btnColor,
        overlayColor: Colors.black,
        overlayOpacity: 0.2,
        animationDuration: Duration(milliseconds: 250),
        spacing: 10,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            onTap: () {
              _getData();
            },
            backgroundColor: cardColor,
            labelBackgroundColor: cardColor,
            child: Icon(
              Icons.my_location,
              color: iconColor,
            ),
            label: 'My Location',
            labelStyle: TextStyle(color: txtColor),
          ),
          SpeedDialChild(
            onTap: () async {
              final result = await showSearch(
                context: context,
                delegate: _citySearchDeligate(),
              );
              if (result != null && result.isNotEmpty) {
                provider.convertAddressToLatLong(result);
              }
            },
            backgroundColor: cardColor,
            labelBackgroundColor: cardColor,
            child: Icon(
              Icons.search,
              color: iconColor,
            ),
            label: 'Search',
            labelStyle: TextStyle(color: txtColor),
          ),
          SpeedDialChild(
            onTap: () {
              Navigator.of(context).pushNamed(SettingsPage.routeName);
            },
            backgroundColor: cardColor,
            labelBackgroundColor: cardColor,
            child: Icon(
              Icons.settings,
              color: iconColor,
            ),
            label: 'Settings',
            labelStyle: TextStyle(color: txtColor),
          ),
        ],
      ),
    );
  }

  Widget _currentWeatherSection() {
    final response = provider.currentResponseModel;
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 55),
          padding: EdgeInsets.symmetric(horizontal: 15),
          width: mediaQueary.width,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FittedBox(
                        child: Text(
                          '${response!.name}, ${response.sys!.country!}',
                          style: txtAddress20,
                        ),
                      ),
                      Text(
                        getFormattedDateTime(response.dt!, 'MMM dd yyyy'),
                        style: txtDateHeader16,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        '$iconPrefix${response.weather![0].icon}$iconSuffix',
                        fit: BoxFit.cover,
                        color: Colors.white,
                      ),
                      Text(
                        '${response.main!.temp!.round()} $degree${provider.unitSymbool}',
                        style: txtTempBig60,
                      ),
                      SizedBox(
                        width: 30,
                      )
                    ],
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: Chip(
                        backgroundColor: cardColor.withOpacity(0.9),
                        label: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            response.weather![0].description!,
                            style: txtNormal14B,
                          ),
                        ),
                      ),
                  ),
                  SizedBox(height: 20),
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
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _forecastWeatherSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.forecastResponseModel!.list!.length,
        itemBuilder: (context, index) {
          final forecastM = provider.forecastResponseModel!.list![index];
          return Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getFormattedDateTime(forecastM.dt!, 'MMM dd yyyy'),
                      style: txtNormal14,
                    ),
                    SizedBox(height: 5),
                    Text(
                      getFormattedDateTime(forecastM.dt!, 'hh mm a'),
                      style: txtNormal14,
                    ),
                    Image.network(
                      '$iconPrefix${forecastM.weather![0].icon}$iconSuffix',
                      fit: BoxFit.cover,
                      height: 50,
                      width: 50,
                      color: Colors.white,
                    ),
                    Text(
                      '${forecastM.main!.temp!.round()} $degree${provider.unitSymbool}',
                      style: txtNormal16W,
                    ),
                    Chip(
                      backgroundColor: cardColor,
                      label: Text(
                        forecastM.weather![0].description!,
                        style: txtNormal14B,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sunRiseSunSetSection() {
    final response = provider.currentResponseModel;
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Container(
              height: 60,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.13)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sun Rise  :  ', style: txtNormal15,),
                    Text(getFormattedDateTime(response!.sys!.sunrise!, 'hh mm a'), style: txtNormal15,),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 60,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.13)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sun Set  :  ', style: txtNormal15),
                    Text(getFormattedDateTime(response.sys!.sunset!, 'hh mm a'), style: txtNormal15,),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
