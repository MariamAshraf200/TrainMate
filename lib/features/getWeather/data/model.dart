import '../domain/entit.dart';

class WeatherModel extends Weather {
  WeatherModel({
    required String locationName,
    required double currentTemperatureC,
    required String currentCondition,
    required String currentIconUrl,
    required List<DailyWeatherModel> forecast,
  }) : super(
    locationName: locationName,
    currentTemperatureC: currentTemperatureC,
    currentCondition: currentCondition,
    currentIconUrl: currentIconUrl,
    forecast: forecast.map((day) => day.toEntity()).toList(),
  );

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    List<DailyWeatherModel> forecast = (json['forecast']['forecastday'] as List)
        .map((day) => DailyWeatherModel.fromJson(day))
        .toList();

    return WeatherModel(
      locationName: json['location']['name'],
      currentTemperatureC: json['current']['temp_c'],
      currentCondition: json['current']['condition']['text'],
      currentIconUrl: 'http:${json['current']['condition']['icon']}',
      forecast: forecast,
    );
  }
}

class DailyWeatherModel {
  final String date;
  final double maxTempC;
  final double minTempC;
  final String condition;
  final String iconUrl;

  DailyWeatherModel({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.condition,
    required this.iconUrl,
  });

  factory DailyWeatherModel.fromJson(Map<String, dynamic> json) {
    return DailyWeatherModel(
      date: json['date'],
      maxTempC: json['day']['maxtemp_c'],
      minTempC: json['day']['mintemp_c'],
      condition: json['day']['condition']['text'],
      iconUrl: 'http:${json['day']['condition']['icon']}',
    );
  }

  // Convert the data model to domain entity
  DailyWeather toEntity() {
    return DailyWeather(
      date: date,
      maxTempC: maxTempC,
      minTempC: minTempC,
      condition: condition,
      iconUrl: iconUrl,
    );
  }
}
