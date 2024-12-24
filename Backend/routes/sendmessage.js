// Install dependencies
// npm install express body-parser twilio

const express = require("express");
const twilio = require("twilio");
const router = express.Router();

// Twilio Credentials (replace with your own credentials)
const accountSid = "AC2e7cbc472fc84751f8bada0b6c96e08a"; // Get this from Twilio Console
const authToken = "6d48c400c56ebb63afe46cf5741b49e2"; // Get this from Twilio Console
const client = twilio(accountSid, authToken);



// API endpoint to send SMS
router.post("/send-sms", async (req, res) => {
    const { phoneNumber, message } = req.body;

    // Validate input
    if (!phoneNumber || !message) {
        return res.status(400).json({ error: "Phone number and message are required." });
    }

    try {
        // Send SMS using Twilio
        const response = await client.messages.create({
            body: message,
            from: "+13203563422", // Replace with your Twilio phone number
            to: phoneNumber,
        });

        res.status(200).json({ success: true, message: "SMS sent successfully.", sid: response.sid });
    } catch (error) {
        console.error("Error sending SMS:", error.message);
        res.status(500).json({ error: "Failed to send SMS. Please try again later." });
    }
});


module.exports = router;
