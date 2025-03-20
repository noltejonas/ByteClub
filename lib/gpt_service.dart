import 'dart:convert';
import 'package:http/http.dart' as http;

class GPTService {
  final String apiKey;
  final String model;

  GPTService({required this.apiKey, this.model = "gpt-4o"});

  Future<String> sendMessage(String userMessage, List<Map<String, String>> conversation, Map<String, dynamic> dataset) async {
    // Append the new user message to the conversation history.
    conversation.add({"role": "user", "content": userMessage});

    final context = "You are an AI model tasked with analyzing the St. Gallen Model dataset. Go through the whole list and for each part of the dataset, determine whether it is impacted by the given use case. For example when the usecase says: 'Manager of a big health care company needs to decide how to implement quantum computing.', the AI should identify the impacted areas in the dataset. The dataset is a tree structure with multiple levels of nesting. The AI should be able to navigate through the tree and identify the impacted areas. So the final output would be: 'Kunden, Lieferanten, Kapitalgeber, Oeffentlichkeit, Medien, NGOs, Konkurrenz, Governance, Strategie, Strukturen, Kultur, Managementprozesse, Geschaeftsprozesse & Geschaeftsmodell, Unterstuetzungsprozesse, Optimierung, Erneuerung, Ressourcen, Normen & Werte, Anliegen & Interessen, Gesellschaft, Natur, Technologie, Wirtschaft'.";
    final goal = "Identify impacted areas and summarize them in a list. Your output shall only be this list of single words! Make sure to forget none of those possible fits, but also dont list a missfit!";
    final datasetSummary = jsonEncode(dataset).replaceAll('ä', 'ae').replaceAll('ö', 'oe').replaceAll('ü', 'ue');
    final prompt = "$context\n\n$goal\n\nUse case: $userMessage\n\nDataset: $datasetSummary";
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };

    final body = jsonEncode({
      "model": model,
      "messages": [
        {"role": "system", "content": context},
        {"role": "user", "content": prompt},
      ],
      "temperature": 0.7,
      "max_tokens": 150,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String reply = data["choices"][0]["message"]["content"];
      // Append the assistant's reply to the conversation.
      conversation.add({"role": "assistant", "content": reply});
      return reply;
    } else {
      throw Exception("Failed to fetch response: ${response.body}");
    }
  }
}
