import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonateFoodPage extends StatefulWidget {
  final String charityId;    // The selected charity's ID
  final String donorId;      // The current donor's ID
  final Map<String, dynamic> charityData; // Charity details for display

  DonateFoodPage({
    required this.charityId,
    required this.donorId,
    required this.charityData,
  });

  @override
  _DonateFoodPageState createState() => _DonateFoodPageState();
}

class _DonateFoodPageState extends State<DonateFoodPage> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool _uploading = false;

  // Uploads donation details (without image) to Firestore.
  Future<void> _uploadDonation() async {
    if (quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter the quantity of food.")),
      );
      return;
    }

    setState(() {
      _uploading = true;
    });

    try {
      // Save donation details to Firestore without an image.
      await FirebaseFirestore.instance.collection("donations").add({
        'donorId': widget.donorId,
        'charityId': widget.charityId,
        'quantity': quantityController.text,
        'description': descriptionController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Donation details uploaded successfully.")),
      );

      setState(() {
        _uploading = false;
        quantityController.clear();
        descriptionController.clear();
      });

      // Navigate back to the previous page
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _uploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading donation: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Donate Food to ${widget.charityData['email'] ?? ''}"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Donation Details Input Fields
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: "Quantity of Food",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description (optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            _uploading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _uploadDonation,
              child: Text("Upload Donation Details"),
            ),
          ],
        ),
      ),
    );
  }
}
