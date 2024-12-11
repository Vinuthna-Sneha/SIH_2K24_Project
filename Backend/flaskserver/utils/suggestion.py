import google.generativeai as genai # type: ignore
import os
from google.generativeai.types import HarmCategory, HarmBlockThreshold # type: ignore

genai.configure(api_key="AIzaSyBXCoFS0SbIarbw_WMEgTi92ebJ2PGmZE4") 

class IncidentSuggestionGenerator:
    def __init__(self):
        self.generation_config = {
            "temperature": 1,  
            "top_p": 0.95,     
            "top_k": 40,      
            "max_output_tokens": 100, 
            "response_mime_type": "text/plain",
        }

        self.model_bot = genai.GenerativeModel(
            model_name="gemini-1.5-pro-002", 
            generation_config=self.generation_config,
        )
        self.chat_session = self.model_bot.start_chat()

    def get_suggestions(self, input_array):
        """Generates suggestions from Gemini using an input array."""
        reported_by, report_type, time_of_report, report_location_latitude, report_location_longitude = input_array
        message = (
            f"A {report_type} incident was reported by a {reported_by} at {time_of_report} near coordinates ({report_location_latitude}, {report_location_longitude}). "
            f"The incident occurred in Delhi, India. Generate three concise suggestions for the next bus driver to handle this situation, prioritizing safety, traffic conditions, and efficiency. Consider realistic, real-time situations in Delhi for this location."
        )

        response = self.chat_session.send_message(
            message,
            safety_settings={
                HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_NONE,
                HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_NONE,
                HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_NONE,
                HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_NONE,
            }
        )
        return response.text
