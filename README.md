# Sleep Tracker

SleepTracker aims to help with user's sleeping habits by providing personal sleeping patterns and summarizing and analysing their sleeping behaviour. It is designed for anyone including but not limited to night owls, shift workers, or someone who loves a good power nap!

## ✨ Key Features

| Demo | Description |
| :---: | --- |
| ![plan](https://github.com/user-attachments/assets/b4bfb212-0ad1-47dc-bded-9209123f5897) | **Personalized Sleep Plans** - SleepTracker caters to your unique lifestyle, offering both monophasic and polyphasic sleep plans |
| ![sleep_cycle](https://github.com/user-attachments/assets/3a9d94c2-fe17-401c-88a0-c0707e7f8f32) | **Real-time Sleep Insights** - With our real-time data collection, you can track your sleep patterns effortlessly. Get insights into your sleep stages, duration and overall quality |
| ![wakeup](https://github.com/user-attachments/assets/fbb91aeb-7414-461a-990a-fd678cc75c37) | **Sleep Satisfaction Tracking** - After you wake up, rate your sleep satisfaction and mood for easy viewing of how your rest affects your daily life and well-being |
| ![sleep_statistic](https://github.com/user-attachments/assets/4ad1b0e8-bf0c-4c1d-8fb8-a39636aa5d15) | **Visual Analytics** - Our charts and summaries provide a comprehensive look at your sleep habits over time |
| ![sleep_diary](https://github.com/user-attachments/assets/0057fab1-47b6-4e4b-8b57-03479b41b5ad) | **Sleep Diary** - Aims to help you reflect on your sleep habits and make adjustments as needed |
| ![enter_bedtime](https://github.com/user-attachments/assets/45c933f9-ab66-4fbf-9ecf-2ce216c8a8b2) | Set your bedtime and wake-up alarms with easy-to-understand symbols and a straightforward 24-hour clock |

### 🤔 Future features

- Tracking snore sounds, exhaustion rates and screen activity to provide a holistic view of sleep hygiene
- AI-powered sleep coaching with machine learning algorithms to provide personalized sleep tips
- Personalized sleep insights dashboard where users can see key metrics and trends that matter most to them at a glance
- Weekly and monthly reports highlighting improvements and areas for growth
- Incorporate a library of guided meditation and relaxation sounds
- Gamification elements where users can set sleep goals and earn rewards or badges for achieving them

## 🚀 Run locally

1. Clone this project to your local environment
```
git clone "https://github.com/Humen-debug/sleep-tracker.git"
```

2. Run the app on an emulator or a physical device
```
flutter run
```

## Development

#### 📦 File Structure

<details>
  <summary>Details</summary>

  ```
  ├── assets
  ├── lib
  │   ├── components
  │   ├── logger
  │   ├── models
  │   ├── pages
  │   ├── providers
  │   ├── routers
  │   └── utils
  └── scripts
  ```
</details>

#### 🧩 Built-with

- [auto_route](https://pub.dev/packages/auto_route) - Package to automatically generate routes
- [fl_chart](https://pub.dev/packages/fl_chart) - Chart library that supports a variety of charts
- [sensors_plus](https://pub.dev/packages/sensors_plus) - Plugin to access the accelerometer, gyroscope, magnetometer and barometer sensors
- [hooks_riverpod](https://pub.dev/packages/hooks_riverpod) - Framework for caching and data-binding
- [freezed](https://pub.dev/packages/freezed) - Code generation for immutable classes 
- [shared_preferences](https://pub.dev/packages/shared_preferences) - Plugin for local storage
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) - Plugin for secure storage
- [graphql](https://pub.dev/packages/graphql) - GraphQL client for flutter
- [logger](https://pub.dev/packages/logger) - Logger for monitoring and troubleshooting front-end errors
- [background_fetch](https://pub.dev/packages/background_fetch) - Plugin for periodic callbacks in the background
