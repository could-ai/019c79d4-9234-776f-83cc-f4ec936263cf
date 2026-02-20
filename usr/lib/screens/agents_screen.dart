import 'package:flutter/material.dart';
import '../models/agent.dart';
import '../services/mock_api_service.dart';

class AgentsScreen extends StatefulWidget {
  const AgentsScreen({super.key});

  @override
  State<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends State<AgentsScreen> {
  final MockApiService _apiService = MockApiService();

  // State
  List<Agent> _agents = [];
  bool _isLoading = false;
  int _page = 1;
  int _pageSize = 10;
  String _search = "";
  
  // Form State
  final _formKey = GlobalKey<FormState>();
  String? _editingId;
  String _firstName = "";
  String _lastName = "";
  String _userName = "";
  String _email = "";
  String _role = "Agent";
  bool _isActive = true;
  String _password = "";

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() => _isLoading = true);
    try {
      final agents = await _apiService.getAgents(
        page: _page,
        pageSize: _pageSize,
        search: _search,
      );
      setState(() {
        _agents = agents;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveAgent() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final agent = Agent(
      id: _editingId ?? '',
      firstName: _firstName,
      lastName: _lastName,
      email: _email,
      userName: _userName,
      role: _role,
      isActive: _isActive,
      password: _editingId == null ? _password : null,
    );

    try {
      if (_editingId != null) {
        await _apiService.updateAgent(agent);
        _showToast("Agent Updated Successfully");
      } else {
        await _apiService.createAgent(agent);
        _showToast("Agent Created Successfully");
      }
      Navigator.of(context).pop(); // Close modal
      _loadAgents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving agent: $e")),
      );
    }
  }

  Future<void> _deleteAgent(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Agent?"),
        content: const Text("Are you sure you want to delete this agent?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.deleteAgent(id);
      _showToast("Agent Deleted Successfully");
      _loadAgents();
    }
  }

  void _openModal({Agent? agent}) {
    // Reset form
    if (agent != null) {
      _editingId = agent.id;
      _firstName = agent.firstName;
      _lastName = agent.lastName;
      _userName = agent.userName;
      _email = agent.email;
      _role = agent.role;
      _isActive = agent.isActive;
      _password = "";
    } else {
      _editingId = null;
      _firstName = "";
      _lastName = "";
      _userName = "";
      _email = "";
      _role = "Agent";
      _isActive = true;
      _password = "";
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          return AlertDialog(
            title: Text(_editingId != null ? "Edit Agent" : "Add Agent"),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400, // Fixed width for desktop/web feel
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: _firstName,
                        decoration: const InputDecoration(labelText: "First Name"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                        onSaved: (v) => _firstName = v!,
                      ),
                      TextFormField(
                        initialValue: _lastName,
                        decoration: const InputDecoration(labelText: "Last Name"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                        onSaved: (v) => _lastName = v!,
                      ),
                      TextFormField(
                        initialValue: _userName,
                        decoration: const InputDecoration(labelText: "Username"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                        onSaved: (v) => _userName = v!,
                      ),
                      TextFormField(
                        initialValue: _email,
                        decoration: const InputDecoration(labelText: "Email"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                        onSaved: (v) => _email = v!,
                      ),
                      DropdownButtonFormField<String>(
                        value: _role,
                        decoration: const InputDecoration(labelText: "Role"),
                        items: const [
                          DropdownMenuItem(value: "Admin", child: Text("Admin")),
                          DropdownMenuItem(value: "Agent", child: Text("Agent")),
                        ],
                        onChanged: (val) => setStateModal(() => _role = val!),
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        title: const Text("Active"),
                        value: _isActive,
                        onChanged: (val) => setStateModal(() => _isActive = val!),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_editingId == null)
                        TextFormField(
                          decoration: const InputDecoration(labelText: "Password"),
                          obscureText: true,
                          validator: (v) => v!.isEmpty ? "Required" : null,
                          onSaved: (v) => _password = v!,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _saveAgent,
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agents"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => _openModal(),
              icon: const Icon(Icons.add),
              label: const Text("Add New Agent"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Show "),
                        DropdownButton<int>(
                          value: _pageSize,
                          items: const [
                            DropdownMenuItem(value: 10, child: Text("10")),
                            DropdownMenuItem(value: 25, child: Text("25")),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _pageSize = val;
                                _page = 1; // Reset to first page
                              });
                              _loadAgents();
                            }
                          },
                        ),
                        const Text(" entries"),
                      ],
                    ),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Search",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _search = val;
                            _page = 1;
                          });
                          _loadAgents(); // Debounce could be added here
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Table
            Expanded(
              child: Card(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text("NAME")),
                                    DataColumn(label: Text("USERNAME")),
                                    DataColumn(label: Text("EMAIL")),
                                    DataColumn(label: Text("ROLE")),
                                    DataColumn(label: Text("STATUS")),
                                    DataColumn(label: Text("ACTION")),
                                  ],
                                  rows: _agents.isEmpty
                                      ? []
                                      : _agents.map((agent) {
                                          return DataRow(cells: [
                                            DataCell(Text("${agent.firstName} ${agent.lastName}")),
                                            DataCell(Text(agent.userName)),
                                            DataCell(Text(agent.email)),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  agent.role,
                                                  style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: agent.isActive ? Colors.green.shade100 : Colors.red.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  agent.isActive ? "Active" : "Inactive",
                                                  style: TextStyle(
                                                    color: agent.isActive ? Colors.green.shade900 : Colors.red.shade900,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                                    onPressed: () => _openModal(agent: agent),
                                                    tooltip: "Edit",
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () => _deleteAgent(agent.id),
                                                    tooltip: "Delete",
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ]);
                                        }).toList(),
                                ),
                              ),
                            ),
                          ),
                          if (_agents.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("No data available"),
                            ),
                          
                          // Pagination Footer
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("Page $_page"),
                                const SizedBox(width: 16),
                                OutlinedButton(
                                  onPressed: _page > 1
                                      ? () {
                                          setState(() => _page--);
                                          _loadAgents();
                                        }
                                      : null,
                                  child: const Text("Previous"),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: _agents.length == _pageSize
                                      ? () {
                                          setState(() => _page++);
                                          _loadAgents();
                                        }
                                      : null, // Disable next if fewer items than page size (simple logic)
                                  child: const Text("Next"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
