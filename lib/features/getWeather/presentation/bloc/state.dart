// lib/features/getWeather/presentation/bloc/weather_state.dart

import '../../domain/entit.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Weather weather;

  WeatherLoaded(this.weather );
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}
