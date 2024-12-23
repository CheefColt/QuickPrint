import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/order_provider.dart';
import '../models/print_config.dart';
import '../services/api_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ApiService _apiService = ApiService();
  final List<String> _filePaths = [];
  final List<PrintConfig> _printConfigs = [];
  bool _isLoading = false;
  String? _error;
  bool _useBatchConfig = false;
  late final PrintConfig _batchConfig;

  @override
  void initState() {
    super.initState();
    _batchConfig = PrintConfig();
  }

  Future<void> _checkConnection() async {
    try {
      final isConnected = await _apiService.testConnection();
      if (!isConnected) {
        setState(() => _error = 'Failed to connect to server');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _filePaths.add(file.path!);
              // Apply batch config if enabled
              _printConfigs.add(_useBatchConfig 
                ? PrintConfig(
                    color: _batchConfig.color,
                    doubleSided: _batchConfig.doubleSided,
                    copies: _batchConfig.copies,
                  )
                : PrintConfig());
            }
          }
        });
      }
    } catch (e) {
      setState(() => _error = 'Error picking files: $e');
    }
  }

  Future<void> _submitFiles() async {
    if (_filePaths.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      
      for (int i = 0; i < _filePaths.length; i++) {
        final success = await orderProvider.submitOrder(_filePaths[i], _printConfigs[i]);
        if (!success) throw Exception('Failed to submit order');
      }

      setState(() {
        _filePaths.clear();
        _printConfigs.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orders submitted successfully'))
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              ),

            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.add),
              label: const Text('Add Files'),
            ),

            const SizedBox(height: 16),

            // Batch Configuration Switch
            _buildBatchConfigSwitch(),

            Expanded(
              child: ListView.builder(
                itemCount: _filePaths.length,
                itemBuilder: (context, index) {
                  return _buildFileItem(index);
                },
              ),
            ),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitFiles,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Orders'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyBatchConfig() {
    setState(() {
      for (var i = 0; i < _printConfigs.length; i++) {
        _printConfigs[i] = PrintConfig(
          color: _batchConfig.color,
          doubleSided: _batchConfig.doubleSided,
          copies: _batchConfig.copies,
        );
      }
    });
  }

  void _updateBatchConfig(PrintConfig newConfig) {
    setState(() {
      _batchConfig.color = newConfig.color;
      _batchConfig.doubleSided = newConfig.doubleSided;
      _batchConfig.copies = newConfig.copies;
      
      if (_useBatchConfig) {
        for (int i = 0; i < _printConfigs.length; i++) {
          _printConfigs[i] = PrintConfig(
            color: _batchConfig.color,
            doubleSided: _batchConfig.doubleSided,
            copies: _batchConfig.copies,
          );
        }
      }
    });
  }

  Widget _buildBatchConfigSwitch() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Use Same Configuration for All Files'),
            value: _useBatchConfig,
            onChanged: (value) {
              setState(() {
                _useBatchConfig = value;
                if (value) {
                  for (int i = 0; i < _printConfigs.length; i++) {
                    _printConfigs[i] = PrintConfig(
                      color: _batchConfig.color,
                      doubleSided: _batchConfig.doubleSided,
                      copies: _batchConfig.copies,
                    );
                  }
                }
              });
            },
          ),
          if (_useBatchConfig)
            ListTile(
              title: Text(
                'Batch Config: Copies: ${_batchConfig.copies}, ' +
                'Color: ${_batchConfig.color ? "Yes" : "No"}, ' +
                'Double Sided: ${_batchConfig.doubleSided ? "Yes" : "No"}'
              ),
              trailing: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showConfigDialog(
                  config: _batchConfig,
                  isBatch: true,
                  onConfigChanged: _updateBatchConfig,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showConfigDialog({
    required PrintConfig config,
    bool isBatch = false,
    Function(PrintConfig)? onConfigChanged,
  }) async {
    PrintConfig tempConfig = PrintConfig(
      color: config.color,
      doubleSided: config.doubleSided,
      copies: config.copies,
    );

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isBatch ? 'Batch Configuration' : 'File Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Color Print'),
                value: tempConfig.color,
                onChanged: (value) {
                  setDialogState(() => tempConfig.color = value);
                  if (onConfigChanged != null) {
                    onConfigChanged(tempConfig);
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Double Sided'),
                value: tempConfig.doubleSided,
                onChanged: (value) {
                  setDialogState(() => tempConfig.doubleSided = value);
                  if (onConfigChanged != null) {
                    onConfigChanged(tempConfig);
                  }
                },
              ),
              ListTile(
                title: const Text('Copies'),
                trailing: DropdownButton<int>(
                  value: tempConfig.copies,
                  items: List.generate(10, (i) => i + 1)
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text('$e'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => tempConfig.copies = value);
                      if (onConfigChanged != null) {
                        onConfigChanged(tempConfig);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFileConfigDialog(int index) async {
    PrintConfig config = _printConfigs[index];
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Use StatefulBuilder for dialog state
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Print Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Color Print'),
                value: config.color,
                onChanged: (value) {
                  setDialogState(() {
                    config.color = value;
                  });
                  setState(() {
                    // Create new config object to force rebuild
                    _printConfigs[index] = PrintConfig(
                      color: config.color,
                      doubleSided: config.doubleSided,
                      copies: config.copies,
                    );
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Double Sided'),
                value: config.doubleSided,
                onChanged: (value) {
                  setDialogState(() {
                    config.doubleSided = value;
                  });
                  setState(() {
                    _printConfigs[index] = PrintConfig(
                      color: config.color,
                      doubleSided: config.doubleSided,
                      copies: config.copies,
                    );
                  });
                },
              ),
              ListTile(
                title: const Text('Copies'),
                trailing: DropdownButton<int>(
                  value: config.copies,
                  items: List.generate(10, (i) => i + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        config.copies = value;
                      });
                      setState(() {
                        _printConfigs[index] = PrintConfig(
                          color: config.color,
                          doubleSided: config.doubleSided,
                          copies: config.copies,
                        );
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(int index) {
    final file = File(_filePaths[index]);
    final config = _printConfigs[index];
    
    return Card(
      child: ListTile(
        leading: const Icon(Icons.description),
        title: Text(file.path.split('/').last),
        subtitle: Text(
          'Copies: ${config.copies} | ' 
          'Color: ${config.color ? "Yes" : "No"} | '
          'Double Sided: ${config.doubleSided ? "Yes" : "No"}'
        ),
        trailing: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _showFileConfigDialog(index),
        ),
      ),
    );
  }
}
