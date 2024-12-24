const express = require('express');
const nodemailer = require('nodemailer');
const router = express.Router();
const trans = require('../setup/email')

// Email sending route
router.post('/send-emailer', async (req, res) => {
    const { subject, message, recipients } = req.body;

    // Validate input
    if (!subject || !message || !Array.isArray(recipients) || recipients.length < 2) {
        return res.status(400).json({
            success: false,
            message: "Please provide a subject, message, and at least two recipients."
        });
    }

    try {
        // Configure the Nodemailer transporter
        const transporter = trans ; 
        console.log("messages")
        // Email options
        const mailOptions = {
            from: 'dattanidumukkala.98@gmail.com', // Sender's email address
            to: recipients.join(','), // Join recipients into a comma-separated string
            subject: subject,
            text: message,
        };

        // Send the email
        await transporter.sendMail(mailOptions);

        res.status(200).json({
            success: true,
            message: 'Email sent successfully to all recipients!'
        });
    } catch (error) {
        console.error('Error sending email:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to send email. Please try again later.'
        });
    }
});

module.exports = router;
