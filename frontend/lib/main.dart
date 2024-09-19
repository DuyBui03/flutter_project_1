import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Hàm main là điểm bắt đầu của ứng dụng
void main() {
  runApp(const MainApp()); // Chạy ứng dụng với widget MainApp
}

/// Widget MainApp là widget gốc của ứng dụng, sử dụng một StatelessWidget
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt biểu tượng debug ở góc phải trên
      title: 'Ứng dụng full-stack flutter đơn giản',
      home: MyHomePage(),
    );
  }
}

/// Widget MyHomePage là trang chính của ứng dụng, sử dụng StatefulWidget
/// để quản lý trạng thái do có nội dung cần thay đổi trên trang này
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Lớp state cho MyHomePage
class _MyHomePageState extends State<MyHomePage> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _controller = TextEditingController();
  String _responseMessage = '';

  /// Hàm để chọn thời gian
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// Hàm để gửi dữ liệu tới server
  Future<void> _sendData() async {
    final name = _controller.text.trim();
    final time = _selectedTime.format(context);
    _controller.clear();

    final Uri url = Uri.parse('http://localhost:8080/api/v1/submit');
    try {
      final http.Response response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'name': name, 'time': time}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _responseMessage = data['message'] ?? 'Không có thông điệp từ server';
        });
      } else {
        setState(() {
          _responseMessage = 'Server trả về mã lỗi ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Đã xảy ra lỗi: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text('Nơi đặt lịch hẹn!'),
        ),
        // Hoặc sử dụng flexibleSpace để căn giữa tiêu đề
        // flexibleSpace: Center(
        //   child: const Text('Chọn thời gian bạn tới!'),
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            SizedBox(height: 20.0),
            Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              height: 150,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 202, 92, 86),
                  borderRadius: BorderRadius.circular(20.0)),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Text('Chọn thời gian',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25.0,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _selectTime(context);
                        },
                        child: Icon(
                          Icons.alarm,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Text(_selectedTime.format(context),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Tên'),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: _sendData,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                decoration: BoxDecoration(
                    color: Color(0xFFdf711a),
                    borderRadius: BorderRadius.circular(30)),
                child: Center(
                  child: Text(
                    "ĐẶT NGAY",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              _responseMessage,
              style: Theme.of(context).textTheme.titleLarge,
            )
          ],
        ),
      ),
    );
  }
}
