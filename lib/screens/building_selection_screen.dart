import 'package:flutter/material.dart';
import '../models/building.dart';
import '../services/api_client.dart';
import '../dashboard/dashboard_screen.dart';

class BuildingSelectionScreen extends StatefulWidget {
  final ApiClient apiClient;

  const BuildingSelectionScreen({super.key, required this.apiClient});

  @override
  State<BuildingSelectionScreen> createState() =>
      _BuildingSelectionScreenState();
}

class _BuildingSelectionScreenState extends State<BuildingSelectionScreen> {
  List<Building> _buildings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  Future<void> _loadBuildings() async {
    try {
      final buildings = await widget.apiClient.getBuildings();
      setState(() {
        _buildings = buildings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load buildings: $e';
        _isLoading = false;
      });
    }
  }

  void _selectBuilding(Building building) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          buildingId: building.id,
          buildingName: building.name,
          apiClient: widget.apiClient,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Building'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade300,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _error = null;
                              });
                              _loadBuildings();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose your office building:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _buildings.length,
                            itemBuilder: (context, index) {
                              final building = _buildings[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: InkWell(
                                  onTap: () => _selectBuilding(building),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.business,
                                          size: 40,
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Text(
                                            building.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}