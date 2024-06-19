import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Nutrition App',
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(
        scheme: FlexScheme.dellGenoa,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 20,
        appBarOpacity: 0.95,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          blendOnColors: false,
          defaultRadius: 45.0,
          elevatedButtonRadius: 3.0,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      themeMode: ThemeMode.light,
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.dellGenoa,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 15,
        appBarStyle: FlexAppBarStyle.background,
        appBarOpacity: 0.90,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 30,
          defaultRadius: 45.0,
          elevatedButtonRadius: 3.0,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  Map<String, dynamic>? _nutritionData;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage(BuildContext context) async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dio = Dio();
      dio.interceptors.add(
        TalkerDioLogger(
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: true,
            printResponseHeaders: true,
            printResponseMessage: true,
          ),
        ),
      );
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_image!.path),
      });

      final response = await dio.post(
        'http://192.168.52.8:8000/identify_and_get_nutrition',
        data: formData,
      );

      if (response.statusCode == 200) {
        setState(() {
          _nutritionData = response.data[0];
        });
      } else {
        setState(() {
          _nutritionData = null;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${response.statusCode}'),
          ));
        });
      }
    } on DioException catch (e) {
      setState(() {
        _nutritionData = null;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.response?.data["message"]}'),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildNutritionTable(Map<String, dynamic> data) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          children: [
            _buildTableHeader('Nutrient'),
            _buildTableHeader('Value'),
          ],
        ),
        _buildTableRow('Food Name', data['name']),
        _buildTableRow('Calories', data['calories']),
        _buildTableRow('Serving Size (g)', data['serving_size_g']),
        _buildTableRow('Total Fat (g)', data['fat_total_g']),
        _buildTableRow('Saturated Fat (g)', data['fat_saturated_g']),
        _buildTableRow('Protein (g)', data['protein_g']),
        _buildTableRow('Sodium (mg)', data['sodium_mg']),
        _buildTableRow('Potassium (mg)', data['potassium_mg']),
        _buildTableRow('Cholesterol (mg)', data['cholesterol_mg']),
        _buildTableRow(
            'Total Carbohydrates (g)', data['carbohydrates_total_g']),
        _buildTableRow('Fiber (g)', data['fiber_g']),
        _buildTableRow('Sugar (g)', data['sugar_g']),
      ],
    );
  }

  TableRow _buildTableRow(String nutrient, dynamic value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(nutrient,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value.toString()),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Nutrition App'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image != null)
                Image.file(
                  _image!,
                  height: 200,
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => _uploadImage(context),
                child: const Text('Upload Image'),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
              if (!_isLoading && _nutritionData != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildNutritionTable(_nutritionData!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
