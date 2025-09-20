// lib/core/services/data_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:talent_assessment/core/models/test_result.dart';

class DataService {
  static final DataService instance = DataService._init();
  DataService._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save test result locally and to Firebase
  Future<void> saveTestResult(TestResult result) async {
    try {
      // Save locally
      final prefs = await SharedPreferences.getInstance();
      final results = await getLocalTestResults();
      results.add(result);

      final jsonList = results.map((r) => r.toMap()).toList();
      await prefs.setString('test_results', json.encode(jsonList));

      // Save to Firebase if authenticated
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('test_results')
            .doc(result.id)
            .set(result.toMap());
      }
    } catch (e) {
      debugPrint('Error saving test result: $e');
    }
  }

  // Get test results from local storage
  Future<List<TestResult>> getLocalTestResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('test_results');

      if (jsonString == null) {
        return [];
      }

      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((json) => TestResult.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Error loading test results: $e');
      return []; // <-- ADD THIS LINE
    }
  }

  // Get user stats
  Future<Map<String, dynamic>> getUserStats() async {
    final results = await getLocalTestResults();
    if (results.isEmpty) {
      return {
        'totalTests': 0,
        'thisWeek': 0,
        'bestSitups': 0,
        'bestPushups': 0,
      };
    }

    return {
      'totalTests': results.length,
      'thisWeek': results
          .where((r) => DateTime.now().difference(r.timestamp).inDays < 7)
          .length,
      'bestSitups': _getBestScore(results, 'situps'),
      'bestPushups': _getBestScore(results, 'pushups'),
    };
  }

  int _getBestScore(List<TestResult> results, String testType) {
    final filtered = results.where((r) => r.testType == testType);
    if (filtered.isEmpty) return 0;
    return filtered.map((r) => r.repCount).reduce((a, b) => a > b ? a : b);
  }
}
