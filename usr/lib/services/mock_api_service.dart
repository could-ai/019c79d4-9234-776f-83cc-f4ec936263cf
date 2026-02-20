import 'dart:async';
import '../models/agent.dart';

class MockApiService {
  // Simulate a database
  final List<Agent> _mockDb = List.generate(
    15,
    (index) => Agent(
      id: 'agent-$index',
      firstName: 'User',
      lastName: '$index',
      email: 'user$index@example.com',
      userName: 'user_$index',
      role: index % 3 == 0 ? 'Admin' : 'Agent',
      isActive: index % 4 != 0,
    ),
  );

  Future<List<Agent>> getAgents({
    int page = 1,
    int pageSize = 10,
    String search = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    var filtered = _mockDb.where((agent) {
      if (search.isEmpty) return true;
      final s = search.toLowerCase();
      return agent.firstName.toLowerCase().contains(s) ||
          agent.lastName.toLowerCase().contains(s) ||
          agent.email.toLowerCase().contains(s) ||
          agent.userName.toLowerCase().contains(s);
    }).toList();

    final startIndex = (page - 1) * pageSize;
    if (startIndex >= filtered.length) return [];

    final endIndex = (startIndex + pageSize) < filtered.length
        ? (startIndex + pageSize)
        : filtered.length;

    return filtered.sublist(startIndex, endIndex);
  }

  Future<void> createAgent(Agent agent) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newAgent = agent.copyWith(id: 'agent-${DateTime.now().millisecondsSinceEpoch}');
    _mockDb.insert(0, newAgent);
  }

  Future<void> updateAgent(Agent agent) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockDb.indexWhere((a) => a.id == agent.id);
    if (index != -1) {
      _mockDb[index] = agent;
    }
  }

  Future<void> deleteAgent(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockDb.removeWhere((a) => a.id == id);
  }
}
