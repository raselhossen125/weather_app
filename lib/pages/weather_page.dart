// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unused_local_variable, unused_element, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
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

  _getData() {
    determinePosition().then((position) {
      provider.setNewLocation(position.latitude, position.longitude);
      provider.getWeatherData();
    });
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.add,
                  color: Colors.black,
                )),
            Text(
              '${response!.name} ${response.sys!.country!}',
              style: txtAddress20,
            ),
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.settings,
                  color: Colors.black,
                )),
          ],
        ),
        Text(
          getFormattedDateTime(response.dt!, 'MMM dd yyyy'),
          style: txtDateHeader16,
        ),
        SizedBox(height: 40),
        Text(
          '${response.main!.temp!.round()} $degree$celsius',
          style: txtTempBig60,
        ),
        Container(
          margin: EdgeInsets.only(top: 50),
          padding: EdgeInsets.symmetric(horizontal: 20),
          width: mediaQueary.width,
          child: Card(
            // elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: cardColor.withOpacity(0.4),
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
                        'feels like ${response.main!.feelsLike!.round()}$degree$celsius',
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
