import 'package:check_weather/features/getWeather/data/remote_data.dart';
import '../domain/entit.dart';
import '../domain/repo.dart';
import 'model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl( this.remoteDataSource);

  @override
  Future<Weather> getWeather(double latitude, double longitude) async {
    final weatherData = await remoteDataSource.getWeatherData(latitude, longitude);
    return WeatherModel.fromJson(weatherData);
  }

}
