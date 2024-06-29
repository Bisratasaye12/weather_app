import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forcast_item.dart';
import 'package:weather_app/secrets.dart';
import 'package:weather_app/utils.dart';

class WeatherScreen extends StatefulWidget {
  WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String CityName = "Addis Ababa";
  final kelvin_to_celsius = -272.15;

  Position? _currentPosition;
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request the user to enable it
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try requesting permissions again
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can get the position of the device
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _fetchWeather() async {
    await _getCurrentLocation();
    if (_currentPosition != null) {
      await getCurrentWeather();
    }
  }

  Future<void> getCurrentWeather() async {
    try {
      final res = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?lat=${_currentPosition!.latitude}&lon=${_currentPosition!.longitude}&APPID=$OpenWeatherAPIKEY"));

      final data = jsonDecode(res.body);

      if (int.parse(data['cod']) != 200) {
        throw "Unexpected error occurred";
      }

      setState(() {
        weatherData = data;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _fetchWeather();
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: weatherData == null
              ? CircularProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentWeatherCard(),
                    SizedBox(height: 20),
                    Text(
                      "Hourly Forecast",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: weatherData!['cnt'],
                        itemBuilder: (context, i) {
                          return HourlyForecast(
                            time: weatherData!['list'][i]['dt_txt'],
                            temperature:
                                weatherData!['list'][i]['main']['temp']
                                    .toString(),
                            icon: weatherData!['list'][i]['weather'][0]['icon'],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Additional Information",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _buildAdditionalInfo(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    final currentWeatherData = weatherData!['list'][0];
    final currentTemp = currentWeatherData['main']['temp'] + kelvin_to_celsius;
    final currentIconId = currentWeatherData['weather'][0]['icon'];
    final currentSky = currentWeatherData['weather'][0]['main'];

    return Card(
      elevation: 16,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("${currentTemp.toStringAsFixed(2)} °C",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      )),
                  SizedBox(height: 16),
                  CustomIcon(currentIconId),
                  SizedBox(height: 16),
                  Text(
                    currentSky,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    final currentWeatherData = weatherData!['list'][0];
    final currentPressure =
        currentWeatherData["main"]['pressure'].toString();
    final currentWindSpeed =
        currentWeatherData['wind']['speed'].toString();
    final currentHumidity =
        currentWeatherData['main']['humidity'].toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AdditionalInfoItem(
          icon: Icons.water_drop,
          label: "Humidity",
          value: currentHumidity,
        ),
        AdditionalInfoItem(
          icon: Icons.air,
          label: "Wind",
          value: currentWindSpeed,
        ),
        AdditionalInfoItem(
          icon: Icons.beach_access,
          label: "Pressure",
          value: currentPressure,
        ),
      ],
    );
  }
}
