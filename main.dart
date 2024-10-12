import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_voting/pollingresult.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simulasi Jajak Suara Pilpres 2024', 
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  } 
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PollingPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/image/kpu_logo.png'), // Path to KPU logo
      ),
    );
  }
}

class PollingPage extends StatefulWidget {
  const PollingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PollingPageState createState() => _PollingPageState();
}

class _PollingPageState extends State<PollingPage> {
  String? selectedCandidate;
  Map<String, double> pollingResults = {};

  @override
  void initState() {
    super.initState();
    fetchPollingResults();
  }

  void fetchPollingResults() async {
    // Implementasi untuk mendapatkan hasil polling dari server
    // Contoh: http.get(Uri.parse('http://your-server.com/polling_results.php'))
    // Simpan hasilnya ke pollingResults
    // Pastikan untuk memanggil setState untuk memperbarui UI setelah mendapatkan data
  }

  void _submitVote(BuildContext context) async {
    final ipAddress = await _getIPAddress();
    final response = await http.post(
      Uri.parse('http://192.168.18.22/flutter_polling/submit_vote.php'),
      body: {
        'candidate': selectedCandidate,
        'ip_address': ipAddress,
      },
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Vote Submitted'),
          content: Text('Kamu telah memilih Capres-Cawapres: $selectedCandidate'),
          actions: <Widget>[
            TextButton( 
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedCandidate = null; // Unselect candidate after submission
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Tampilkan pesan error jika terjadi kesalahan
    }
  }

  Future<String> _getIPAddress() async {
    // Implementasi untuk mendapatkan IP Address
    return '192.168.18.22'; // Contoh IP Address
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulasi Jajak Suara Pilpres 2024'),
      ),
      body: Column(
        children: <Widget>[
          CandidateTile(
            candidateName: 'Anies-Muhaimin',
            imagePath: 'assets/image/paslon1.jpg',
            isSelected: selectedCandidate == 'Anies-Muhaimin',
            onSelect: () {
              setState(() {
                selectedCandidate = 'Anies-Muhaimin';
              });
            },
          ),
          CandidateTile(
            candidateName: 'Prabowo-Gibran',
            imagePath: 'assets/image/paslon2.jpg',
            isSelected: selectedCandidate == 'Prabowo-Gibran',
            onSelect: () {
              setState(() {
                selectedCandidate = 'Prabowo-Gibran';
              });
            },
          ),
          CandidateTile(
            candidateName: 'Ganjar-Mahfud',
            imagePath: 'assets/image/paslon3.jpg',
            isSelected: selectedCandidate == 'Ganjar-Mahfud',
            onSelect: () {
              setState(() {
                selectedCandidate = 'Ganjar-Mahfud';
              });
            },
          ),
          ElevatedButton(
            onPressed: selectedCandidate != null ? () => _submitVote(context) : null,
            child: const Text('Submit Vote'),
          ),
           ElevatedButton(
            onPressed:  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PollingResultsPage(),
                      ),
                    );
                  },
            child: const Text('Lihat Hasil Voting'),
          ),
          // Widget for displaying polling results
          if (pollingResults.isNotEmpty)
            PollingResultsChart(pollingResults: pollingResults),
        ],
      ),
    );
  }
}

class PollingResultsChart extends StatelessWidget {
  final Map<String, double> pollingResults;

  const PollingResultsChart({Key? key, required this.pollingResults})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];

    pollingResults.forEach((candidate, votes) {
      final index = pollingResults.keys.toList().indexOf(candidate);
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              y: votes,
              colors: [Colors.blue],
            ),
          ],
        ),
      );
    });

    return Container(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100, // Assuming this is the max value of your polling data
          barGroups: barGroups,
         titlesData: FlTitlesData(
  show: true,
  bottomTitles: SideTitles(
    showTitles: true, // Gunakan show untuk menunjukkan atau menyembunyikan judul pada sumbu
    getTextStyles: (context, value) => const TextStyle(
      color: Colors.black,
      fontSize: 10,
    ),
    margin: 10,
    getTitles: (double value) {
      return pollingResults.keys.elementAt(value.toInt());
    },
  ),
),
        ),
      ),
    );
  }
}


class CandidateTile extends StatelessWidget {
  final String candidateName;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onSelect;

  const CandidateTile({
    Key? key,
    required this.candidateName,
    required this.imagePath,
    required this.onSelect,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(imagePath),
      title: Text(candidateName),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.radio_button_off),
      onTap: onSelect,
   );
  }
}