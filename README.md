# Safe Sense

## What is it?

Safe Sense is a unit of four easy-to-install sensors that anyone (Even a child!) can install for their cars and get access to both audio and visual feedback for any object that comes close to your car. This helps in navigating ***blind spots*** when driving, ***parking in tight spaces***,  accessing ***collision reports*** using advanced algorithms, and even advice on ***preventive measures*** that could be taken ***3-5 seconds before*** a sideswipe accident occurs, as well as suggesting the ***at-fault driver after***  an accident occurs.

![mvp Design](https://github.com/leonkoech/SafeSense-AI/assets/39020723/9ed9f175-6d43-44ac-9b08-3c5065da42ce)


## Inspiration
As per the National Safety Commission, there are around 242,000 side-swipe accidents in the US alone. Of that number, there are more than 2,500 deaths and 27,000 injuries. Those statistics are unacceptable.

![ADAS stats](https://github.com/leonkoech/SafeSense/assets/39020723/5492004d-a8f3-453e-a863-c8b13d20ba7d)

Around 62% of vehicles on the road today are models from before the year 2015, meaning they lack the Advanced Driver Assistance Systems (ADAS) found in newer models. This significant portion of older vehicles is missing out on critical enhancements that could greatly improve their operational security and efficiency. As a result, many drivers are navigating without the support of technology that could prevent accidents and save lives. We must bridge this gap by considering upgrades or finding viable alternatives that equip these vehicles with modern advancements. Why should safety be a luxury? Your life is invaluable; making roads safer starts with us.

## What it does
Dominic Toretto places four sensors on the four corners of his 2009 Dodge Challenger and downloads a platform-agnostic application that automatically connects to the sensors. Simple as that!


Dom now has access to blind spot navigation, visual alerts when an object is getting close to his vehicle, audio alerts when an object is getting too close to his car, prediction of when a sideswipe accident is about to happen based on the behaviors of the cars next to collision reports when an accident occurs including data such as the exact time of impact, speed of the current car and any neighboring cars as well as preventive measures that could have been taken and the suggested at-fault driver.

![Untitled-1](https://github.com/leonkoech/SafeSense-AI/assets/39020723/e3bead57-e897-44d1-a908-c942ac480ce1)

## How we built it

**1. Sensors**
The Sensors use Embedded C running on ESP32 modules with Bluetooth Low Energy for data transmission and ultrasonic sensors (HCSR04) using the time of flight algorithm to determine the distance between objects. The wireless version uses a step-up transformer (MT3608) and a 3.7v LiPO battery.

**2. Mobile Application**
The mobile application is built on Flutter and runs on both IOS and Android. It makes use of flutter_ble_plus for sensor communication, geolocator for speed calculation, and HTTP for AI API access. The mobile app uses our custom algorithms for the calculation of neighboring car speeds, and proximity Sound Alerts.

**3. Machine Learning Model**
We have our custom model running on Python 3.9 (flask) on a computer in the local network which has been trained on 60 data points of side-swipe road accident simulations and 531 gen AI data points based on the sims. This model is fast with a latency of <50ms. We turned the flask application into our in-house API.

![sensors positioning](https://github.com/leonkoech/SafeSense-AI/assets/39020723/2a08620f-4817-41d6-81b8-094d2d45a57f)

## Challenges we ran into
 Some sensors died during testing,  TensorFlow lite needed specific permissions on Android so we went with our in-house API, we were using cheap sensors for the MVP which doesn't do a great job in harsh environments, training the machine learning model on the data points proved tricky at some point

## Accomplishments that we're proud of
We're proud of our incredible team dynamic. Attesting to our diverse backgrounds, we were able to foster great collaboration, enhance creativity, and promote an innovative mindset.

## Meet the team
![team mhw 2024](https://github.com/leonkoech/SafeSense-AI/assets/39020723/f73d329a-fb86-4f1c-ab91-57bc863ef0c1)


## What we learned
a lot


## What's next for Safe Sense
Product Development, Iteration then launch 🚀

