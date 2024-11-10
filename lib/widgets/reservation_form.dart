import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:my_app/widgets/reserved_hours_table.dart';

class ReservationForm extends StatefulWidget {
  const ReservationForm({super.key});

  @override  
  _ReservationFormState createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  DateTime? selectedDate;
  String terrain = '1';
  String selectedHour = '08:00';
  bool isLoading = false;

  final List<String> hours = List<String>.generate(
    16,
    (index) => '${(index + 8).toString().padLeft(2, '0')}:00',
  );

  List<Map<String, String>> reservedData = [];

  Future<void> fetchReservedData(String date) async {
    try {
      final response = await http.get(Uri.parse(
          'http://hamzadev.atwebpages.com/get_reserved_hours.php?date=$date'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            reservedData.clear();

            if (data['reservations'] is List) {
              for (var reservation in data['reservations']) {
                if (reservation['hour'] != null && reservation['terrain'] != null) {
                  reservedData.add({
                    'hour': reservation['hour'].toString(),
                    'terrain': reservation['terrain'].toString(),
                  });
                }
              }
            } else {
              _showDialog('No Data', 'No reservations found for the selected date.');
            }
          });
        } else {
          _showDialog('Error', data['error'] ?? 'Failed to fetch reserved data');
        }
      } else {
        _showDialog('Connection Error', 'Failed to connect to the server.');
      }
    } catch (e) {
      _showDialog('Error', 'An unexpected error occurred: $e');
    }
  }

  Future<void> submitReservation() async {
    if (selectedDate == null) {
      _showDialog('Date Required', 'Please select a date before submitting.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://hamzadev.atwebpages.com/reservation.php'),
        body: {
          'name': name,
          'phone': phone,
          'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
          'hour': selectedHour,
          'terrain': terrain,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          _showDialog('تم إرسال الطلب', 'إنتظر تأكيد على الهاتف.');
          _resetForm();
        } else {
          _showDialog('فشل الطلب', responseData['error'] ?? 'Unknown error');
        }
      } else {
        _showDialog('Connection Error', 'Failed to connect to the server.');
      }
    } catch (e) {
      _showDialog('Error', 'An unexpected error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.teal),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      name = '';
      phone = '';
      selectedDate = null;
      selectedHour = '08:00';
      terrain = '1';
      reservedData.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Container(),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Text(
                  'ALI BABA ',
                  style: TextStyle(
                    fontFamily: 'Cursive',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'الإسم',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'الهاتف',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            phone = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  primaryColor: Colors.teal,
                                  hintColor: Colors.teal,
                                  buttonTheme: ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.teal,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null && pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                            fetchReservedData(DateFormat('yyyy-MM-dd').format(selectedDate!));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          selectedDate == null
                              ? 'اختر اليوم'
                              : DateFormat('yyyy-MM-dd').format(selectedDate!),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'اختر الساعة',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      DropdownButton<String>(
                        value: selectedHour,
                        dropdownColor: Colors.black54,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedHour = newValue!;
                          });
                        },
                        items: hours.map<DropdownMenuItem<String>>((String hour) {
                          return DropdownMenuItem<String>(
                            value: hour,
                            child: Text(hour),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'اختر الملعب',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Radio<String>(
                                value: '1',
                                groupValue: terrain,
                                onChanged: (String? value) {
                                  setState(() {
                                    terrain = value!;
                                  });
                                },
                              ),
                              Icon(Icons.sports_soccer, color: Colors.white),
                              Text(
                                'ملعب 1',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Radio<String>(
                                value: '2',
                                groupValue: terrain,
                                onChanged: (String? value) {
                                  setState(() {
                                    terrain = value!;
                                  });
                                },
                              ),
                              Icon(Icons.sports_soccer, color: Colors.white),
                              Text(
                                'ملعب 2',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Radio<String>(
                                value: '3',
                                groupValue: terrain,
                                onChanged: (String? value) {
                                  setState(() {
                                    terrain = value!;
                                  });
                                },
                              ),
                              Icon(Icons.sports_soccer, color: Colors.white),
                              Text(
                                'ملعب 3',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                isLoading
                    ? CircularProgressIndicator(color: Colors.teal)
                    : ElevatedButton(
                        onPressed: submitReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'إرسال الطلب',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                const SizedBox(height: 16),
            ReservationTable(data: reservedData),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
