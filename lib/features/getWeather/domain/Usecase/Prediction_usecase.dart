
import '../../../../core/helper/model_helper_api.dart';
import '../weather_mapper.dart';
import '../entit.dart';

class GetTennisPredictionUseCase {
  final ApiService apiService;

  GetTennisPredictionUseCase(this.apiService);

  Future<int> execute(Weather weather) async {
    final modelInput = mapDailyWeatherToModelInput(weather as DailyWeather);
    final prediction = await apiService.getPrediction(modelInput.cast<int>());
    return prediction;
  }
}
