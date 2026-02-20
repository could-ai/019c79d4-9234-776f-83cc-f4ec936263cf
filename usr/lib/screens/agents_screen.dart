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
  String _mobile = "";
  String _role = "Agent";
  bool _isActive = true;
  String _password = "";
  bool _obscurePassword = true;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      mobile: _mobile,
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
      if (mounted) {
        Navigator.of(context).pop(); // Close modal
        _loadAgents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving agent: $e"), backgroundColor: Colors.red),
        );
      }
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
      _mobile = agent.mobile ?? "";
      _role = agent.role;
      _isActive = agent.isActive;
      _password = "";
    } else {
      _editingId = null;
      _firstName = "";
      _lastName = "";
      _userName = "";
      _email = "";
      _mobile = "";
      _role = "Agent";
      _isActive = true;
      _password = "";
    }
    _obscurePassword = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 600, // Wider for better layout
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _editingId != null ? "Edit Agent" : "Add New Agent",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: Names
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _firstName,
                                    decoration: const InputDecoration(
                                      labelText: "First Name",
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                    validator: (v) => v!.isEmpty ? "Required" : null,
                                    onSaved: (v) => _firstName = v!,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _lastName,
                                    decoration: const InputDecoration(
                                      labelText: "Last Name",
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                    validator: (v) => v!.isEmpty ? "Required" : null,
                                    onSaved: (v) => _lastName = v!,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 2: Username & Mobile
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _userName,
                                    decoration: const InputDecoration(
                                      labelText: "Username",
                                      prefixIcon: Icon(Icons.account_circle_outlined),
                                    ),
                                    validator: (v) => v!.isEmpty ? "Required" : null,
                                    onSaved: (v) => _userName = v!,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _mobile,
                                    decoration: const InputDecoration(
                                      labelText: "Mobile",
                                      prefixIcon: Icon(Icons.phone_android_outlined),
                                    ),
                                    onSaved: (v) => _mobile = v ?? "",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 3: Email
                            TextFormField(
                              initialValue: _email,
                              decoration: const InputDecoration(
                                labelText: "Email Address",
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return "Required";
                                if (!v.contains("@")) return "Invalid email";
                                return null;
                              },
                              onSaved: (v) => _email = v!,
                            ),
                            const SizedBox(height: 16),

                            // Row 4: Role & Status
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _role,
                                    decoration: const InputDecoration(
                                      labelText: "Role",
                                      prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: "Admin", child: Text("Admin")),
                                      DropdownMenuItem(value: "Agent", child: Text("Agent")),
                                    ],
                                    onChanged: (val) => setStateModal(() => _role = val!),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle_outline, color: Colors.grey),
                                        const SizedBox(width: 12),
                                        const Text("Active Status"),
                                        const Spacer(),
                                        Switch(
                                          value: _isActive,
                                          onChanged: (val) => setStateModal(() => _isActive = val),
                                          activeColor: Colors.green,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Row 5: Password (only if new)
                            if (_editingId == null) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setStateModal(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                validator: (v) => v!.isEmpty ? "Required" : null,
                                onSaved: (v) => _password = v!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveAgent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          elevation: 0,
                        ),
                        child: Text(_editingId != null ? "Save Changes" : "Create Agent"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agents Management"),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 20,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Show ", style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _pageSize,
                            items: const [
                              DropdownMenuItem(value: 10, child: Text("10")),
                              DropdownMenuItem(value: 25, child: Text("25")),
                              DropdownMenuItem(value: 50, child: Text("50")),
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(" entries", style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search agents...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _search = val;
                          _page = 1;
                        });
                        _loadAgents();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.grey.shade200,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                                    dataRowMinHeight: 60,
                                    dataRowMaxHeight: 60,
                                    columnSpacing: 30,
                                    horizontalMargin: 24,
                                    columns: const [
                                      DataColumn(label: Text("NAME", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("USERNAME", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("EMAIL", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("ROLE", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("ACTION", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: _agents.isEmpty
                                        ? []
                                        : _agents.map((agent) {
                                            return DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 16,
                                                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                                      child: Text(
                                                        agent.firstName.isNotEmpty ? agent.firstName[0].toUpperCase() : "?",
                                                        style: TextStyle(
                                                          color: Theme.of(context).primaryColor,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      "${agent.firstName} ${agent.lastName}",
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                )
                                              ),
                                              DataCell(Text(agent.userName)),
                                              DataCell(Text(agent.email)),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: agent.role == "Admin" ? Colors.purple.shade50 : Colors.blue.shade50,
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: agent.role == "Admin" ? Colors.purple.shade200 : Colors.blue.shade200,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    agent.role,
                                                    style: TextStyle(
                                                      color: agent.role == "Admin" ? Colors.purple.shade700 : Colors.blue.shade700,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: agent.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: agent.isActive ? Colors.green.shade200 : Colors.red.shade200,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        agent.isActive ? Icons.check_circle : Icons.cancel,
                                                        size: 14,
                                                        color: agent.isActive ? Colors.green.shade700 : Colors.red.shade700,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        agent.isActive ? "Active" : "Inactive",
                                                        style: TextStyle(
                                                          color: agent.isActive ? Colors.green.shade700 : Colors.red.shade700,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.edit_outlined, size: 20),
                                                      color: Colors.blue,
                                                      onPressed: () => _openModal(agent: agent),
                                                      tooltip: "Edit",
                                                      style: IconButton.styleFrom(
                                                        backgroundColor: Colors.blue.withOpacity(0.1),
                                                        padding: const EdgeInsets.all(8),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete_outline, size: 20),
                                                      color: Colors.red,
                                                      onPressed: () => _deleteAgent(agent.id),
                                                      tooltip: "Delete",
                                                      style: IconButton.styleFrom(
                                                        backgroundColor: Colors.red.withOpacity(0.1),
                                                        padding: const EdgeInsets.all(8),
                                                      ),
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
                          ),
                          if (_agents.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text("No agents found", style: TextStyle(color: Colors.grey, fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                          
                          // Pagination Footer
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Showing ${(_page - 1) * _pageSize + 1} to ${((_page - 1) * _pageSize + _agents.length)} of many entries",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                                Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: _page > 1
                                          ? () {
                                              setState(() => _page--);
                                              _loadAgents();
                                            }
                                          : null,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      child: const Text("Previous"),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "$_page",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: _agents.length == _pageSize
                                          ? () {
                                              setState(() => _page++);
                                              _loadAgents();
                                            }
                                          : null,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      child: const Text("Next"),
                                    ),
                                  ],
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
