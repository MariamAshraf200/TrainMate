import 'package:check_weather/features/getWeather/domain/repo.dart';

import '../entit.dart';

class GetWeatherUseCase {
  final WeatherRepository repository;

  GetWeatherUseCase(this.repository);

  Future<Weather> call(double latitude, double longitude) {
    return repository.getWeather(latitude, longitude);
  }
}
