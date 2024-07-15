# Safe Sense: Intelligent Vehicle Safety Enhancement System

## Empowering Every Vehicle with Advanced Safety Features


<table>
  <tr>
    <td>
     
Safe Sense is a revolutionary aftermarket vehicle safety system designed to bring advanced driver assistance capabilities to any car, regardless of its age or model. Our mission is to make roads safer for everyone by democratizing access to cutting-edge safety technology.
    </td>
     <td>
      <img src="https://github.com/leonkoech/SafeSense-AI/assets/39020723/9ed9f175-6d43-44ac-9b08-3c5065da42ce" alt="Safe Sense MVP Design" width="2600px">
    </td>
  </tr>
</table>




## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [The Problem We're Solving](#the-problem-were-solving)
- [How It Works](#how-it-works)
- [Technology Stack](#technology-stack)
- [Installation](#installation)
- [Challenges and Solutions](#challenges-and-solutions)
- [Future Roadmap](#future-roadmap)
- [The Team](#the-team)
- [Contributing](#contributing)
- [License](#license)

## Overview

Safe Sense consists of four easy-to-install sensors that provide both audio and visual feedback for objects in proximity to your vehicle. This system enhances safety by addressing critical issues such as blind spot detection, parking assistance, and collision prevention.

## Key Features

- **Blind Spot Navigation**: Real-time alerts for objects in your vehicle's blind spots
- **Parking Assistance**: Visual and audio guidance for tight parking spaces
- **Collision Prevention**: Advanced algorithms predict potential collisions 3-5 seconds before they occur
- **Accident Analysis**: Detailed collision reports including time of impact, vehicle speeds, and suggested at-fault determinations
- **Universal Compatibility**: Designed to work with any vehicle, regardless of make or model
- **User-Friendly Installation**: Simple enough for anyone to install, including non-technical users

## The Problem We're Solving

![ADAS Statistics](https://github.com/leonkoech/SafeSense/assets/39020723/5492004d-a8f3-453e-a863-c8b13d20ba7d)

In the United States alone, there are approximately 242,000 side-swipe accidents annually, resulting in over 2,500 fatalities and 27,000 injuries. Moreover, about 62% of vehicles on the road are models from before 2015, lacking Advanced Driver Assistance Systems (ADAS). Safe Sense aims to bridge this safety gap by providing an affordable, aftermarket solution that brings modern safety features to older vehicles.

## How It Works

![Sensor Positioning](https://github.com/leonkoech/SafeSense-AI/assets/39020723/2a08620f-4817-41d6-81b8-094d2d45a57f)

1. Install four sensors at the corners of your vehicle
2. Download our cross-platform mobile application
3. The app automatically connects to the sensors via Bluetooth
4. Receive real-time alerts and safety information while driving

## Technology Stack

### Hardware
- Sensors: ESP32 modules with ultrasonic sensors (HCSR04)
- Connectivity: Bluetooth Low Energy
- Power: MT3608 step-up transformer with 3.7v LiPO battery (for wireless version)

### Software
- Mobile App: Flutter (iOS and Android compatible)
- Libraries: flutter_ble_plus, geolocator
- Backend: Custom Python 3.9 Flask API

### Machine Learning
- Custom model trained on 60 side-swipe accident simulations and 531 AI-generated data points
- Latency: <50ms

## Installation

1. Mount the four sensors at each corner of your vehicle
2. Download the Safe Sense mobile app from the App Store or Google Play
3. Follow the in-app instructions to pair the sensors with your smartphone
4. Start driving with enhanced safety features!

## Challenges and Solutions

| Challenge | Solution |
|-----------|----------|
| Sensor durability | Exploring more robust sensor options for production models |
| TensorFlow Lite Android permissions | Developed a custom in-house API as an alternative |
| Environmental sensor performance | Investigating higher-quality sensors for improved accuracy |
| Machine learning model training | Iterative refinement of training data and model architecture |

## Future Roadmap

1. Enhanced product development and iteration
2. Expansion of the training dataset for improved accuracy
3. Integration with vehicle telematics systems
4. Partnerships with insurance companies for potential premium reductions
5. Development of a professional installation network

## The Team

![Safe Sense Team](https://github.com/leonkoech/SafeSense-AI/assets/39020723/f73d329a-fb86-4f1c-ab91-57bc863ef0c1)

Our diverse team brings together expertise in embedded systems, mobile development, machine learning, and automotive safety to create a truly innovative solution.

## Contributing

We welcome contributions from the community! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines on how to get involved.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
