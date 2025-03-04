import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CharityPage extends StatefulWidget {
  final String charityId;
  final String charityEmail;
  CharityPage({required this.charityId, required this.charityEmail});

  @override
  _CharityPageState createState() => _CharityPageState();
}

class _CharityPageState extends State<CharityPage> {
  late final Stream<QuerySnapshot> donationStream;

  @override
  void initState() {
    super.initState();
    donationStream = FirebaseFirestore.instance
        .collection("donations")
        .where("charityId", isEqualTo: widget.charityId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charity Dashboard'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: donationStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final donations = snapshot.data!.docs;
          if (donations.isEmpty) return Center(child: Text("No donations received yet."));
          return ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, index) {
              var donationDoc = donations[index];
              var data = donationDoc.data() as Map<String, dynamic>;
              var status = data['status'] ?? 'pending';
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text("Donation from ${data['donorId']}"),
                  subtitle: Text("Quantity: ${data['quantity']}"),
                  trailing: status == 'accepted'
                      ? Text("Accepted", style: TextStyle(color: Colors.green))
                      : ElevatedButton(
                    onPressed: () async {
                      // Update the donation status to accepted
                      await donationDoc.reference.update({
                        'status': 'accepted',
                        'acceptedAt': FieldValue.serverTimestamp(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Donation accepted.")),
                      );
                    },
                    child: Text("Accept Donation"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
