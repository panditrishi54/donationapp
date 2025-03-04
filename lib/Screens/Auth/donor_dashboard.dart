import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'donate_food_page.dart'; // Page for adding new donation details
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class DonorDashboard extends StatefulWidget {
  final String donorId;
  DonorDashboard({required this.donorId});

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }

  // ===================== Charity List (Donate Tab) =====================
  Widget buildCharityList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('charities').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        var charities = snapshot.data!.docs;
        if (charities.isEmpty) return Center(child: Text("No charities found."));
        return ListView.builder(
          itemCount: charities.length,
          itemBuilder: (context, index) {
            var charity = charities[index].data() as Map<String, dynamic>;
            charity['id'] = charities[index].id;
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(charity['email'] ?? "No Email"),
                trailing: ElevatedButton(
                  child: Text("Donate Food"),
                  onPressed: () {
                    // Navigate to DonateFoodPage with charity details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonateFoodPage(
                          charityId: charity['id'],
                          donorId: widget.donorId,
                          charityData: charity,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===================== Accepted Donations Tab =====================
  Widget buildAcceptedDonations() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .where('donorId', isEqualTo: widget.donorId)
          .where('status', isEqualTo: 'accepted')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        var donations = snapshot.data!.docs;
        if (donations.isEmpty) return Center(child: Text("No accepted donations yet."));

        // Show notification once if accepted donation is present.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Your donation has been accepted.")),
          );
        });

        return ListView.builder(
          itemCount: donations.length,
          itemBuilder: (context, index) {
            var donation = donations[index].data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text("Donation accepted: Quantity ${donation['quantity']}"),
                subtitle: Text("Description: ${donation['description'] ?? ''}"),
                trailing: ElevatedButton(
                  onPressed: () {
                    generateCertificate(donation);
                  },
                  child: Text("Generate Certificate"),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===================== Certificate Generation =====================
  Future<void> generateCertificate(Map<String, dynamic> donationData) async {
    final pdf = pw.Document();
    // Retrieve the donor's email from Firebase Auth (or default)
    final donorEmail = FirebaseAuth.instance.currentUser?.email ?? "Donor";
    final quantity = donationData['quantity'];
    final description = donationData['description'] ?? "";
    String donationTime = "N/A";
    if (donationData['timestamp'] != null) {
      donationTime = (donationData['timestamp'] as Timestamp).toDate().toString();
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text("Certificate of Donation",
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text("This certifies that",
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text("$donorEmail",
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text("has donated food with the following details:",
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 10),
                pw.Text("Quantity: $quantity", style: pw.TextStyle(fontSize: 18)),
                pw.Text("Description: $description", style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 10),
                pw.Text("Donation Time: $donationTime", style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 20),
                pw.Text("Thank you for your generosity!", style: pw.TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );

    // Preview/Print the generated PDF certificate
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Donor Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Donate"),
            Tab(text: "Accepted Donations"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildCharityList(),
          buildAcceptedDonations(),
        ],
      ),
    );
  }
}
