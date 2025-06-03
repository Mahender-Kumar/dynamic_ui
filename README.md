# Dynamic UI

Dynamic UI is a Flutter project designed to serve as a flexible starting point for building dynamic and adaptive user interfaces in mobile applications.

## Features

- Built with Flutter for cross-platform development.
- Easily customizable to suit diverse UI requirements.
- Clean project structure to help you get started quickly.

## Packages Used

- **rfw** (`^1.0.31`):  
  Enables loading and rendering UI widgets at runtime from remote or local sources, allowing your app’s interface to be dynamically updated without requiring a new build or deployment.  
  **rfw** stands for “Remote Flutter Widgets” and is ideal for applications where the UI needs to change based on external data or configuration, or for building highly customizable apps, marketplaces, and dashboards.

- **flutter_svg** (`^2.1.0`):  
  Provides SVG rendering support, allowing you to display scalable vector graphics in your app.

- **video_player** (`^2.9.5`):  
  Lets you play videos from assets, files, or URLs within your Flutter application.

- **go_router** (`^15.1.2`):  
  A declarative, easy-to-use routing package for managing app navigation, deep linking, and more.

- **cupertino_icons** (`^1.0.8`):  
  The default set of iOS style icons for Flutter apps.

## About `rfw`

The `rfw` (Remote Flutter Widgets) package allows you to define user interfaces as data, which can be sent from a server or loaded from local configuration. Instead of hardcoding all UI in Dart, you can use the rfw syntax to describe widget trees and logic, which your app can parse and render at runtime.  
This approach is especially useful for apps that want to update their UI on the fly or provide highly dynamic/customizable experiences.

**Example rfw widget string (used in this project):**
```dart
'''
import local;

widget root = SingleChildScrollView(child: Column(
  children: [
    Padding(padding: 8.0,child:
      BannerSlider(urls:["$banner1","$banner2","$banner3","$banner4","$banner5","$banner6"]),
    ),
    Padding(padding: 8.0,child:
      Text(text:"BUY FURNITURE"),
    ),
    SizeBox(height: 8.0),
    GridViewBuilder(
      itemCount: 8,
      crossAxisCount: 4,
      children:[ 
        CategoryIcon(label: "Dining",icon: "$encodeddining",  onTap: event "category_tap" { "category": "dining", "label": "Dining" }),
        CategoryIcon(label: "Tables", icon: "$encodedTable",  onTap: event "category_tap" { "category": "table", "label": "Table" }),
        CategoryIcon(label: "Chairs", icon: "$encodedChair",  onTap: event "category_tap" { "category": "chair", "label": "Chair" }),
        CategoryIcon(label: "Cabinets", icon: "$encodedCabinet",  onTap: event "category_tap" { "category": "cabinet", "label": "Cabinets" }),
        CategoryIcon(label: "Living Room", icon: "$encodedSofa",  onTap: event "category_tap" { "category": "sofa", "label": "Sofa" }),
        CategoryIcon(label: "Bedroom", icon: "$encodedbed",  onTap: event "category_tap" { "category": "bed", "label": "Bed" }),
        CategoryIcon(label: "Storage", icon: "$encodedstorage",  onTap: event "category_tap" { "category": "storage", "label": "Storage" }),
        CategoryIcon(label: "Study", icon: "$encodedStudy",  onTap: event "category_tap" { "category": "study", "label": "Study" }),
      ],
    ),
    SizeBox(height: 8.0),
    ListTile(
      title:  'Offers & Discounts',
      onTap: event "listtile_tap" { destination: '/discount' }
    ),
    Padding(padding: 8.0,child: Row(children: [
      Expanded(child: TypeCard(icon: "$encodedBox", title: "Brand New")),
      Expanded(child: TypeCard(icon: "$encodedRecycle", title: "Refurbished")),
    ])),
    SizeBox(height: 8.0),
    SingleChildScrollView(scrollDirection:"horizontal",child: Padding(padding: 8.0,child: Row(spacing:16,children: [
      OfferCard(text: "Extra ₹100 off on SBI",subTitle:"No Action Required",icon:"$encodedSbi"),
      OfferCard(text: "Get flat ₹500 off",subTitle:"Get flat 15 % off",icon:"$encodedDsicount"),
      OfferCard(text: "Extra ₹100 off on SBI",subTitle:"No Action Required",icon:"$encodedSbi"),
      OfferCard(text: "Get flat ₹500 off",subTitle:"Get flat 15 % off",icon:"$encodedDsicount"),
      OfferCard(text: "Extra ₹100 off on SBI",subTitle:"No Action Required",icon:"$encodedSbi"),
      OfferCard(text: "Get flat ₹500 off",subTitle:"Get flat 15 % off",icon:"$encodedDsicount"),
    ]))),
    SizeBox(height: 8.0),
    ListTile(
      icon:"home",
      title:  'Deals of the Day',
      subtitle:  'To buy',
      onTap: event "listtile_tap" { destination: '/deals' }
    ),
    Padding(padding: 8.0,child: SingleChildScrollView(scrollDirection:"horizontal",child: Row(spacing:16,children: [
      ProductCard(image: "$chairImage1",title: "Flex 3 Seater Magic B...",price: "-72% ₹10,699"),
      ProductCard(image: "$chairImage2",title: "Flex Fabric 3...",price: "-74% ₹9,499"),
      ProductCard(image: "$chairImage3",title: "Flex Fabric 3...",price: "-74% ₹9,499"),
      ProductCard(image: "$chairImage5",title: "Flex Fabric 3...",price: "-74% ₹9,499"),
      ProductCard(image: "$chairImage6",title: "Flex Fabric 3...",price: "-74% ₹9,499"),
      ProductCard(image: "$chairImage7",title: "Flex Fabric 3...",price: "-74% ₹9,499"),
      ProductCard(image: "$chairImage9",title: "Flex Fabric 3...",price: "-74% ₹9,499"),
    ]))),
    Padding(padding: 8.0,child: VideoSlider(
      urls: [
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
      ]
    )),
  ],
));
'''
```

## Getting Started

To run this project:

1. Clone this repository:
   ```bash
   git clone https://github.com/Mahender-Kumar/dynamic_ui.git
   ```
2. Change into the project directory:
   ```bash
   cd dynamic_ui
   ```
3. Get the dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Resources

If you are new to Flutter, check out these helpful resources:

- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter Cookbook: Useful Samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)

## Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

---

Feel free to expand this description as your project evolves!
