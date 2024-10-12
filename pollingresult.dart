import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Polling Results',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PollingResultsPage(),
    );
  }
}

class PollingResultsPage extends StatelessWidget {
  const PollingResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polling Results'),
      ),
      body: const Center(
        child: VoteChart(),
      ),
    );
  }
}

class VoteChart extends StatefulWidget {
  const VoteChart({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VoteChartState createState() => _VoteChartState();
}

class _VoteChartState extends State<VoteChart> {
  late Future<List<VoteData>> futureVoteData;

  @override
  void initState() {
    super.initState();
    futureVoteData = fetchVoteData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VoteData>>(
      future: futureVoteData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            // Membuat grup data untuk grafik
            final barGroups = snapshot.data!
                .asMap()
                .map((index, voteData) => MapEntry(
                      index,
                      BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(y: voteData.votes.toDouble(), colors: [Colors.blue]),
                        ],
                      ),
                    ))
                .values
                .toList();

            // Membuat label untuk sumbu X
            final titles = snapshot.data!
                .asMap()
                .map((index, voteData) => MapEntry(index, SideTitles(showTitles: true, getTitles: (double value) => voteData.candidate)))
                .values
                .toList();

            return BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTitles: (double value) => titles[value.toInt()].getTitles(value),
                  ),
                ),
              ),
            );
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

Future<List<VoteData>> fetchVoteData() async {
  final response = await http.get(Uri.parse('http://192.168.18.22/flutter_polling/polling_result.php'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((data) => VoteData.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load vote data');
  }
}

class VoteData {
  final String candidate;
  final int votes;

  VoteData({required this.candidate, required this.votes});

  factory VoteData.fromJson(Map<String, dynamic> json) {
    return VoteData(
      candidate: json['candidate'],
      votes: json['votes'],
   );
 }
}