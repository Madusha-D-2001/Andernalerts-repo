import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PieSeries<DivisionData, String>> divisionSeriesList = [];
  List<PieSeries<NotificationData, String>> riskSeriesList = [];
  double overallRisk = 0;
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> initialDivisions = [];
  List<Map<String, dynamic>> initialNotifications = [];
  String selectedDivision = 'All';
  String selectedRiskType = 'All'; //To track the selected risk type
  Map<String, dynamic>? selectedNotification;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() {
    // Dummy data for testing
    final List<Map<String, dynamic>> divisions = [
      {'name': 'Cutting', 'downtimePercentage': 20.0},
      {'name': 'Supply Chain', 'downtimePercentage': 30.0},
      {'name': 'Molding', 'downtimePercentage': 25.0},
      {'name': 'Fabric Technology', 'downtimePercentage': 15.0},
      {'name': 'Inspection', 'downtimePercentage': 10.0},
    ].map((division) {
      division['downtimePercentage'] = double.parse(
          (division['downtimePercentage'] as double).toStringAsFixed(1));
      return division;
    }).toList();

    final List<Map<String, dynamic>> notifications = [
      {
        'team': 'Team 1',
        'type': 'Line Down',
        'startDate': '2024-07-01',
        'startTime': '10:00 AM',
        'issueCategory': 'Input delay',
        'timeElapsed': '00:10:05',
        'line': 'Line 1',
        'responsibleDivision': 'Cutting'
      },
      {
        'team': 'Team 2',
        'type': 'Underperformance',
        'startDate': '2024-07-01',
        'startTime': '11:00 AM',
        'issueCategory': 'Molding quality issue',
        'timeElapsed': '00:15:30',
        'line': 'Line 1',
        'responsibleDivision': 'Supply Chain'
      },
      {
        'team': 'Team 3',
        'type': 'Line Down',
        'startDate': '2024-07-01',
        'startTime': '10:00 AM',
        'issueCategory': 'Input delay',
        'timeElapsed': '00:05:45',
        'line': 'Line 1',
        'responsibleDivision': 'Molding'
      },
      {
        'team': 'Team 4',
        'type': 'Underperformance',
        'startDate': '2024-07-01',
        'startTime': '11:00 AM',
        'issueCategory': 'Molding quality issue',
        'timeElapsed': '00:20:10',
        'line': 'Line 1',
        'responsibleDivision': 'Fabric Technology'
      },
      {
        'team': 'Team 5',
        'type': 'Line Down',
        'startDate': '2024-07-01',
        'startTime': '01:00 PM',
        'issueCategory': 'Input delay',
        'timeElapsed': '00:25:55',
        'line': 'Line 1',
        'responsibleDivision': 'Inspection'
      },
      {
        'team': 'Team 6',
        'type': 'Underperformance',
        'startDate': '2024-07-01',
        'startTime': '02:00 PM',
        'issueCategory': 'Molding quality issue',
        'timeElapsed': '00:30:40',
        'line': 'Line 1',
        'responsibleDivision': 'Cutting'
      },
      {
        'team': 'Team 7',
        'type': 'Line Down',
        'startDate': '2024-07-01',
        'startTime': '03:00 PM',
        'issueCategory': 'Input delay',
        'timeElapsed': '00:35:25',
        'line': 'Line 1',
        'responsibleDivision': 'Supply Chain'
      },
      {
        'team': 'Team 8',
        'type': 'Underperformance',
        'startDate': '2024-07-01',
        'startTime': '04:00 PM',
        'issueCategory': 'Molding quality issue',
        'timeElapsed': '00:40:50',
        'line': 'Line 1',
        'responsibleDivision': 'Molding'
      },
      {
        'team': 'Team 9',
        'type': 'Line Down',
        'startDate': '2024-07-01',
        'startTime': '05:00 PM',
        'issueCategory': 'Input delay',
        'timeElapsed': '00:45:35',
        'line': 'Line 1',
        'responsibleDivision': 'Fabric Technology'
      },
    ];

    setState(() {
      initialDivisions = divisions;
      initialNotifications = notifications;
      divisionSeriesList = _createDivisionChartData(divisions, 'All');
      riskSeriesList = _createRiskChartData(notifications);
      this.notifications = sortNotifications(notifications);
      overallRisk = calculateOverallRisk(notifications);
    });
  }

  List<Map<String, dynamic>> sortNotifications(
      List<Map<String, dynamic>> notifications) {
    notifications.sort((a, b) {
      int getTypePriority(String type) {
        switch (type) {
          case 'Line Down':
            return 1;
          case 'Underperformance':
            return 2;
          default:
            return 3;
        }
      }

      return getTypePriority(a['type']).compareTo(getTypePriority(b['type']));
    });
    return notifications;
  }

  List<PieSeries<DivisionData, String>> _createDivisionChartData(
      List<Map<String, dynamic>> divisions, String type) {
    final filteredDivisions = divisions.map((division) {
      final notificationsForDivision = initialNotifications
          .where((notification) =>
              notification['responsibleDivision'] == division['name'] &&
              (type == 'All' || notification['type'] == type))
          .toList();

      final percentage =
          (notificationsForDivision.length / initialNotifications.length) * 100;
      return {
        'name': division['name'],
        'downtimePercentage': percentage,
      };
    }).toList();

    final data = filteredDivisions
        .map((division) =>
            DivisionData(division['name'], division['downtimePercentage']))
        .toList();

    return [
      PieSeries<DivisionData, String>(
        dataSource: data,
        xValueMapper: (DivisionData data, _) => data.name,
        yValueMapper: (DivisionData data, _) => data.downtimePercentage,
        dataLabelMapper: (DivisionData data, _) =>
            '${data.downtimePercentage.toStringAsFixed(1)}%',
        dataLabelSettings: DataLabelSettings(isVisible: true),
      ),
    ];
  }

  List<PieSeries<NotificationData, String>> _createRiskChartData(
      List<Map<String, dynamic>> notifications) {
    final typeCount = notifications.fold<Map<String, int>>({}, (acc, notif) {
      acc[notif['type']] = (acc[notif['type']] ?? 0) + 1;
      return acc;
    });

    final totalCount = notifications.length;
    final data = typeCount.entries
        .map((entry) =>
            NotificationData(entry.key, (entry.value / totalCount) * 100))
        .toList();

    return [
      PieSeries<NotificationData, String>(
        dataSource: data,
        pointColorMapper: (NotificationData data, _) =>
            getNotificationColor(data.type),
        xValueMapper: (NotificationData data, _) => data.type,
        yValueMapper: (NotificationData data, _) => data.percentage,
        dataLabelMapper: (NotificationData data, _) =>
            '${data.percentage.toStringAsFixed(1)}%',
        dataLabelSettings: DataLabelSettings(isVisible: true),
        onPointTap: (ChartPointDetails details) {
          final selectedType = details.dataPoints![details.pointIndex!].x;
          setState(() {
            selectedRiskType = selectedType;
            divisionSeriesList =
                _createDivisionChartData(initialDivisions, selectedRiskType);
          });
        },
      ),
    ];
  }

  double calculateOverallRisk(List<Map<String, dynamic>> notifications) {
    final typeCount = notifications.fold<Map<String, int>>({}, (acc, notif) {
      acc[notif['type']] = (acc[notif['type']] ?? 0) + 1;
      return acc;
    });

    final lineDownCount = typeCount['Line Down'] ?? 0;
    final totalCount = notifications.length;

    return (lineDownCount / totalCount) * 100;
  }

  Color getNotificationColor(String type) {
    switch (type) {
      case 'Line Down':
        return Color.fromARGB(255, 238, 31, 16);
      case 'Underperformance':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Icon getNotificationIcon(String type) {
    switch (type) {
      case 'Line Down':
        return Icon(Icons.error, color: Colors.white);
      case 'Underperformance':
        return Icon(Icons.warning, color: Colors.white);
      default:
        return Icon(Icons.notifications, color: Colors.white);
    }
  }

  void updateCharts() {
    final filteredDivisions = initialDivisions
        .where((division) =>
            selectedDivision == 'All' || division['name'] == selectedDivision)
        .toList();
    final filteredNotifications = initialNotifications
        .where((notification) =>
            selectedDivision == 'All' ||
            notification['responsibleDivision'] == selectedDivision)
        .toList();

    setState(() {
      divisionSeriesList = _createDivisionChartData(filteredDivisions, 'All');
      riskSeriesList = _createRiskChartData(filteredNotifications);
      notifications = sortNotifications(filteredNotifications);
      overallRisk = calculateOverallRisk(filteredNotifications);
    });
  }

  void showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Team: ${notification['team']}'),
                Text('Type: ${notification['type']}'),
                Text('Start Date: ${notification['startDate']}'),
                Text('Start Time: ${notification['startTime']}'),
                Text('Issue Category: ${notification['issueCategory']}'),
                Text('Time Elapsed: ${notification['timeElapsed']}'),
                Text('Line: ${notification['line']}'),
                Text(
                    'Responsible Division: ${notification['responsibleDivision']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
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
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 245, 7, 7),
        actions: [
          ClipOval(
            child: Image.asset(
              'assets/brandix logo.png',
              width: 50, // Adjust the width as needed
              height: 50, // Adjust the height as needed
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown to filter notifications and charts
          DropdownButton<String>(
            dropdownColor: Color.fromARGB(255, 181, 196, 204),
            value: selectedDivision,
            items: [
              'All',
              'Cutting',
              'Supply Chain',
              'Molding',
              'Fabric Technology',
              'Inspection'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedDivision = newValue!;
                updateCharts();
              });
            },
          ),
          // Charts Row
          Row(
            children: [
              // Division Chart
              Expanded(
                child: SizedBox(
                  height: 250,
                  child: SfCircularChart(
                    legend: Legend(isVisible: true),
                    series: divisionSeriesList,
                  ),
                ),
              ),
              // Risk Chart
              Expanded(
                child: SizedBox(
                  height: 250,
                  child: SfCircularChart(
                    legend: Legend(isVisible: true),
                    series: riskSeriesList,
                  ),
                ),
              ),
            ],
          ),
          // Overall Risk Indicator
          Card(
            color: Color.fromARGB(255, 236, 216, 215),
            margin: EdgeInsets.symmetric(vertical: 5.0),
            child: ListTile(
              leading: Icon(Icons.warning, color: Colors.black),
              title: Text(
                'Overall Risk: ${overallRisk.toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          // Notifications
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  color: getNotificationColor(notification['type']),
                  child: ListTile(
                    leading: getNotificationIcon(notification['type']),
                    title: Text(
                      '${notification['team']}',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Issue: ${notification['issueCategory']}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Text(
                          'Elapsed Time: ${notification['timeElapsed']}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    onTap: () {
                      showNotificationDetails(notification);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DivisionData {
  DivisionData(this.name, this.downtimePercentage);
  final String name;
  final double downtimePercentage;
}

class NotificationData {
  NotificationData(this.type, this.percentage);
  final String type;
  final double percentage;
}
