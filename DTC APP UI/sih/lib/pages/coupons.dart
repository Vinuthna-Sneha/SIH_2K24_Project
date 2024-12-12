import 'package:flutter/material.dart';

class RewardsPage extends StatefulWidget {
  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final int userPoints = 750; // User's current points
  final List<Map<String, String>> userCoupons = [
    {
      "title": "20% Off on Bus Tickets",
      "code": "BUS20",
      "description": "Applicable on any bus ticket",
      "validity": "Valid till 31st Dec 2024",
    },
    {
      "title": "Flat ₹50 Off",
      "code": "SAVE50",
      "description": "On bus bookings above ₹500",
      "validity": "Valid till 15th Jan 2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Rewards"),
        centerTitle: true,
        backgroundColor: Color(0xff0095FF),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points Progress Section
            Text(
              "Your Progress",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: userPoints / 1000,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
            ),
            SizedBox(height: 8),
            Text(
              "$userPoints / 1000 Points",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),

            // Coupons Section
            Text(
              "Your Coupons",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: userCoupons.length,
                itemBuilder: (context, index) {
                  final coupon = userCoupons[index];
                  return CouponCard(
                    title: coupon['title']!,
                    code: coupon['code']!,
                    description: coupon['description']!,
                    validity: coupon['validity']!,
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Gift Section
            Text(
              "Gift Milestone",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:  Colors.blueAccent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  // Gift Image
                  Image.asset(
                    'assets/gift.png',
                    width: 60,
                    height: 60,
                  ),
                  SizedBox(width: 20),
                  // Gift Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Exclusive Gift Awaits!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          userPoints >= 1000
                              ? "Congratulations! You've earned your gift."
                              : "Earn ${1000 - userPoints} more points to unlock your gift.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Coupon Card Component
class CouponCard extends StatelessWidget {
  final String title;
  final String code;
  final String description;
  final String validity;

  const CouponCard({
    Key? key,
    required this.title,
    required this.code,
    required this.description,
    required this.validity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Copy to clipboard functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Copied $code to clipboard!"),
                      ),
                    );
                  },
                  icon: Icon(Icons.copy, color: Colors.blue),
                  label: Text(
                    "Copy",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              validity,
              style: TextStyle(
                fontSize: 12,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
