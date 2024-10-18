

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<int> getPrediction(List<int> inputData) async {
    const url = 'http://10.0.2.2:5001/predict';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'features': inputData}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['prediction'][0];
      } else {
        throw Exception('Server Error: Unable to get prediction');
      }
    } on http.ClientException {
      throw Exception('Unable to connect to server. Please check your connection.');
    }
  }
}
