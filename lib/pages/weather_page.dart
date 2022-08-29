// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/untils/location_service.dart';
import '../provider/weather_provider.dart';

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
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _getData() {
      determinePosition().then((position) {
        provider.setNewLocation(position.latitude, position.longitude);
        provider.getWeatherData();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'images/bg1.jpg',
            height: mediaQueary.height,
            width: mediaQueary.width,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}
