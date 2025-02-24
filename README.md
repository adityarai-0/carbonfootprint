# carbonfootprint
The Carbon Footprint Tracker app helps users monitor and reduce their daily carbon emissions by logging transportation, energy, and waste usage, providing offline tracking and insightful trends to promote sustainable living.
Carbon Footprint Tracker App
Documentation
Table of Contents
1. Introduction
2. Key Features
3. System Requirements and Setup
4. Architecture and Code Structure
○
Custom Color and Date Extensions
○
Data Model – CarbonRecord
○
Offline Data Manager – CarbonDataManager
○
Main Application Entry Point
○
Tab-Based Navigation (MainView)
○
Dashboard Screen
○
Log Entry Screen
○
Trends Screen
○
History Screen and Data Export
○
Record Row and Detail Views
○
Custom Button Style and Activity Sharing
5. Offline Data Persistence
6. Enhancements for UI and User Experience
7. Converting Documentation to PDF
8. Conclusion
Introduction
The Carbon Footprint Tracker app is a SwiftUI-based application designed to help users
monitor and reduce their daily carbon emissions. With a focus on environmental sustainability
and SDG 13 (Climate Action), the app allows users to log data for transportation, energy usage,
and waste production. The app is fully functional offline, storing user data locally in JSON
format.
Key Features
●
Dashboard: Provides an overview of today’s carbon emissions with a clear breakdown
of transportation, energy, and waste contributions.
●
Log Entry: Allows users to input daily metrics along with additional notes, with built-in
validations and haptic feedback.
●
Trends: Uses SwiftUI’s Charts framework (iOS 16+) to display a dynamic line and point
chart of recent records over the past seven days.
●
History and Export: Lists all historical records with the ability to view detailed
information for each record and export the stored data via a share sheet.
System Requirements and Setup
●
Development Environment: Xcode with SwiftUI support.
●
iOS Version: iOS 16 or later is recommended (required for the Charts framework).
●
Setup Instructions:
1. Create a new SwiftUI project in Xcode.
2. Replace the default code with the updated Carbon Footprint Tracker code.
3. Build and run the app on a compatible simulator or device.
Architecture and Code Structure
Custom Color and Date Extensions
●
Custom Color Extension:
Defines two custom colors—primaryOrange and primaryYellow—to ensure a
consistent design language across the app.
●
Date Extensions:
Provides helper methods (formatted() and timeFormatted()) to convert dates into
user-friendly string representations.
Data Model – CarbonRecord
●
Purpose:
Represents a single record of daily carbon emissions.
●
Key Properties:
○
date: The date of the record.
○
transportationKm, energyKWh, wasteKg: Numeric values representing daily
inputs.
○
notes: A string field for additional user comments.
●
Computed Properties:
Calculates emissions for each category and provides a total emission value.
Offline Data Manager – CarbonDataManager
●
Functionality:
Manages the offline storage and retrieval of carbon records using JSON persistence via
the device’s document directory.
●
Key Methods:
○
loadRecords() and saveRecords(): Handle JSON file reading and writing.
○
addRecord(_:) and deleteRecord(at:): Modify the list of records.
○
recordForToday() and sortedRecords(): Facilitate record queries.
Main Application Entry Point
●
@main Struct:
The main entry point creates an environment object for CarbonDataManager and sets
up the main view.
Tab-Based Navigation (MainView)
●
Overview:
A TabView provides four tabs corresponding to the Dashboard, Log Entry, Trends, and
History screens.
●
Navigation:
Each tab is labeled with a system image and a title, ensuring intuitive navigation.
Dashboard Screen
●
Purpose:
Displays today’s carbon footprint with a clear breakdown of emissions.
●
Design:
Utilizes a ScrollView, styled text, and colored backgrounds to highlight key information.
Log Entry Screen
●
Functionality:
A form-based interface that lets users input daily data.
●
Enhancements:
Includes input validations, focus management for dismissing the keyboard, and haptic
feedback upon successful entry submission.
Trends Screen
●
Purpose:
Visualizes emission trends over the past 7 days using a line chart and point markers.
●
Implementation:
Uses SwiftUI’s Charts framework to create a dynamic chart. The X-axis is formatted to
display dates, while the Y-axis displays emission values.
History Screen and Data Export
●
Functionality:
Lists all logged records in a sortable list.
●
Additional Feature:
Provides a share/export button to open a share sheet that allows users to export their
JSON data.
Record Row and Detail Views
●
RecordRowView:
Displays a summary of each record in the History list.
●
RecordDetailView:
Offers an in-depth view of a selected record, including all metrics and notes.
Custom Button Style and Activity Sharing
●
PrimaryButtonStyle:
A custom button style that applies the primary orange color, rounded corners, and subtle
animations.
●
ActivityView:
A UIViewControllerRepresentable that facilitates sharing of exported data using a share
sheet.
Offline Data Persistence
The app uses local JSON file storage to maintain records offline. The CarbonDataManager
class handles the encoding/decoding of records with Swift’s Codable protocol, ensuring user
data remains available without an internet connection.
Enhancements for UI and User Experience
●
Aesthetic Consistency:
A vibrant color scheme (orange and yellow) combined with clear typography creates a
visually appealing interface.
●
Interactive Feedback:
Haptic feedback is provided when saving log entries, and animations enhance button
interactions.
●
Comprehensive Navigation:
The addition of the Trends screen and data export functionality enrich the overall user
experience, allowing users to visualize and share their carbon footprint data seamlessly.
Converting Documentation to PDF
To convert this documentation into a PDF:
1. Markdown Editor Export:
Use an editor like Typora or Visual Studio Code with Markdown PDF extension to export
the document.
Pandoc Command:
Run the following command if you have Pandoc installed:
nginx
CopyEdit
pandoc Documentation.md -o Documentation.pdf
2.
3. Online Converter:
Use any online Markdown-to-PDF converter.
Conclusion
The updated Carbon Footprint Tracker app offers a robust, offline solution to monitor daily
carbon emissions with an enhanced, aesthetically pleasing user interface. By combining
SwiftUI’s powerful declarative UI capabilities with offline JSON persistence and additional
features such as trends visualization and data export, the app not only meets the needs of
eco-conscious users but also provides a superior user experience. This documentation outlines
the architecture and design decisions, serving as a guide for further development and
customization
