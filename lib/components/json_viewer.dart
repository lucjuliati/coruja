import 'package:flutter/material.dart';

class JsonViewer extends StatelessWidget {
  final dynamic jsonData;

  const JsonViewer({super.key, required this.jsonData});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: _buildJsonWidget(jsonData),
      ),
    );
  }

  Widget _buildJsonWidget(dynamic data, {bool isRoot = true}) {
    if (data is Map<String, dynamic>) {
      return _buildMapWidget(data);
    } else if (data is List) {
      return _buildListWidget(data);
    } else {
      return _buildValueWidget(data);
    }
  }

  Widget _buildMapWidget(Map<String, dynamic> mapData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: mapData.entries.map((entry) {
        return ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(vertical: 0),
          minTileHeight: 10,
          title: Text(
            entry.key,
            style: TextStyle(color: Colors.blue),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _buildJsonWidget(entry.value, isRoot: false),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildListWidget(List listData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listData.asMap().entries.map((entry) {
        return ExpansionTile(
          title: Text('[${entry.key}]:', style: TextStyle(color: Colors.green)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _buildJsonWidget(entry.value, isRoot: false),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildValueWidget(dynamic value) {
    Color valueColor;
    if (value is String) {
      valueColor = const Color.fromARGB(255, 74, 230, 126);
    } else if (value is num) {
      valueColor = const Color.fromARGB(255, 54, 177, 74);
    } else if (value is bool) {
      valueColor = Colors.purple;
    } else {
      valueColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Text(
        value.toString(),
        style: TextStyle(color: valueColor),
      ),
    );
  }
}
