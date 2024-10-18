import 'package:check_weather/core/helper/model_helper_api.dart';
import 'package:check_weather/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:check_weather/features/auth/presentation/bloc/auth_event.dart';
import 'package:check_weather/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entit.dart';
import '../../domain/weather_mapper.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';
import '../../../../core/helper/gelocator_helpr.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  _WeatherForecastScreenState createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  late WeatherBloc _weatherBloc;
  late AuthBloc _authBloc;
  int _selectedIndex = 0;
  ApiService apiService = ApiService();
  late SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    _weatherBloc = BlocProvider.of<WeatherBloc>(context);
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _fetchLocationAndWeather();
  }

  Future<void> _fetchLocationAndWeather() async {
    try {
      Position position = await GelocatorHelpr().determinePosition();
      _weatherBloc.add(GetWeatherEvent(
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _showPredictionDialog(String prediction) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Prediction'),
          content: Text('Prediction: $prediction'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff253340),
      appBar: AppBar(
        backgroundColor: const Color(0xff253340),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchLocationAndWeather,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            // Navigate to login screen after logout
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        child: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            if (state is WeatherLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WeatherLoaded) {
              final weather = state.weather;
              final selectedDay = weather.forecast[_selectedIndex];

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildBasicSection(weather),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Days of the Week',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildForecastSection(weather),
                      _buildSelectedDaySection(selectedDay),
                      Center(
                          child: _buildNavigateToPredictionButton(selectedDay)),
                    ],
                  ),
                ),
              );
            } else if (state is WeatherError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavigateToPredictionButton(DailyWeather selectedDay) {
    return TextButton(
      onPressed: () async {
        try {
          List<int> modelInput = mapDailyWeatherToModelInput(selectedDay);

          final prediction = await apiService.getPrediction(modelInput);

          await _showPredictionDialog(prediction == 1
              ? 'You can train'
              : 'No, you shouldn\'t train for your safety');
        } catch (e) {
          if (e.toString().contains('Unable to connect to server')) {
            await _showErrorDialog('Please Connect To Server');
          } else {
            await _showErrorDialog('Failed to get prediction');
          }
          print('Error: $e');
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        backgroundColor: Colors.white30,
      ),
      child: const Text('Get Prediction', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildForecastSection(weather) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.17,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weather.forecast.length,
        itemBuilder: (context, index) {
          final day = weather.forecast[index];
          final dayName = DateFormat('EEEE').format(DateTime.parse(day.date));

          return SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: Card(
                color: _selectedIndex == index
                    ? Colors.blueAccent
                    : const Color(0xff2b5c6b),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(dayName, style: const TextStyle(color: Colors.white)),
                      Image.network(day.iconUrl, height: 50),
                      const SizedBox(height: 5),
                      Text('${day.maxTempC}° / ${day.minTempC}°',
                          style: const TextStyle(color: Colors.white)),
                      Text(day.condition,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDaySection(DailyWeather selectedDay) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: const Color(0xff2b5c6b),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selected Day: ${DateFormat('EEEE').format(DateTime.parse(selectedDay.date))}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Image.network(selectedDay.iconUrl, height: 80),
              const SizedBox(height: 10),
              Text(
                'Max Temp: ${selectedDay.maxTempC}°C',
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 5),
              Text(
                'Min Temp: ${selectedDay.minTempC}°C',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                selectedDay.condition,
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicSection(Weather weather) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: const Color(0xff2b5c6b),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Location: ${weather.locationName}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Image.network(weather.currentIconUrl, height: 80),
              const SizedBox(height: 10),
              Text(
                'Temperature: ${weather.currentTemperatureC}°C',
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 10),
              Text(
                weather.currentCondition,
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() {
    _authBloc.add(LogoutEvent());
    sharedPreferences.clear();
  }
}
