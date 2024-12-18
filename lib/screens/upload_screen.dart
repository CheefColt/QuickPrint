import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/order_provider.dart';
import '../models/print_config.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final List<String> _filePaths = [];
  List<PrintConfig> _printConfigs = [];
  bool _useSameConfigForAll = true;
  late PrintConfig _defaultConfig;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _defaultConfig = const PrintConfig();
  }

  void _updateConfig(int? index, {
    String? paperSize,
    bool? isColor,
    bool? isDuplex,
    int? copies,
  }) {
    setState(() {
      if (index != null) {
        _printConfigs[index] = _printConfigs[index].copyWith(
          paperSize: paperSize,
          isColor: isColor,
          isDuplex: isDuplex,
          copies: copies,
        );
      } else {
        _defaultConfig = _defaultConfig.copyWith(
          paperSize: paperSize,
          isColor: isColor,
          isDuplex: isDuplex,
          copies: copies,
        );
        if (_useSameConfigForAll) {
          _printConfigs = List.generate(
            _printConfigs.length,
            (_) => _defaultConfig,
          );
        }
      }
    });
  }

  Future<void> _pickFiles() async {
    try {
      setState(() => _isLoading = true);
      
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _filePaths.addAll(result.paths.whereType<String>());
          _printConfigs.addAll(
            List.generate(
              result.paths.length,
              (_) => _defaultConfig,
            ),
          );
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    final orderProvider = context.read<OrderProvider>();
    
    try {
      setState(() => _isLoading = true);
      
      for (var i = 0; i < _filePaths.length; i++) {
        await orderProvider.addOrder(_filePaths[i], _printConfigs[i]);
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFileList(),
                _buildConfigSection(),
                _buildSubmitButton(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _pickFiles,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFileList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _filePaths.length,
        itemBuilder: (context, index) {
          final path = _filePaths[index];
          final fileName = path.split('\\').last;
          
          return ListTile(
            title: Text(fileName),
            subtitle: _buildConfigTile(index),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => setState(() {
                _filePaths.removeAt(index);
                _printConfigs.removeAt(index);
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfigTile(int index) {
    final config = _printConfigs[index];
    return Text(
      '${config.paperSize} - ${config.isColor ? "Color" : "B&W"} - ${config.copies} copies',
    );
  }

  Widget _buildConfigSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Use same settings for all'),
              value: _useSameConfigForAll,
              onChanged: (value) => setState(() => _useSameConfigForAll = value),
            ),
            const Divider(),
            _buildConfigForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigForm() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _defaultConfig.paperSize,
          items: PrintConfig.VALID_PAPER_SIZES
              .map((size) => DropdownMenuItem(
                    value: size,
                    child: Text(size),
                  ))
              .toList(),
          onChanged: (value) => _updateConfig(
            null,
            paperSize: value,
          ),
          decoration: const InputDecoration(
            labelText: 'Paper Size',
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Color Print'),
          value: _defaultConfig.isColor,
          onChanged: (value) => _updateConfig(
            null,
            isColor: value,
          ),
        ),
        SwitchListTile(
          title: const Text('Double Sided'),
          value: _defaultConfig.isDuplex,
          onChanged: (value) => _updateConfig(
            null,
            isDuplex: value,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final bool canSubmit = _filePaths.isNotEmpty && !_isLoading;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: canSubmit ? _submit : null,
        child: const Text('Submit Order'),
      ),
    );
  }
}