import 'package:dynamic_ui/encoded_svgs.dart';
import 'package:dynamic_ui/image_urls/banner_image_urls.dart';
import 'package:dynamic_ui/image_urls/chair_image_urls.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rfw/rfw.dart';
import '../widget_factory/widget_factory.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final String rfwLayout =
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
 ''';

  @override
  Widget build(BuildContext context) {
    final runtime = WidgetFactory.buildRuntime(rfwLayout);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: ListTile(
            dense: true,
            title: const Text('Delivery to'),
            subtitle: const Text('123456, Mumbai'),
            leading: Icon(Icons.location_pin),
          ),
        ),
        body:
            // AutoVideoBanner(),
            // AutoBannerSlider(),
            RemoteWidget(
              runtime: runtime,
              data: DynamicContent(),
              widget: const FullyQualifiedWidgetName(
                LibraryName(<String>['remote']),
                'root',
              ),
              onEvent: (name, args) {
                // print('Event received: $name, args: $args');
                _handleEvent(context, name, args);
              },
            ),
      ),
    );
  }

  void _handleEvent(BuildContext context, String name, DynamicMap args) {
    debugPrint('Event triggered: $name, args: $args');

    switch (name) {
      case 'category_tap':
        _handleCategoryTap(context, args);
        break;
      case 'product_tap':
        _handleProductTap(context, args);
        break;
      case 'type_tap':
        _handleTypeTap(context, args);
        break;
      case 'banner_tap':
        _handleBannerTap(context, args);
        break;
      case 'listtile_tap':
        _listtileTap(context, args);
        break;
      default:
        debugPrint('Unhandled event: $name');
    }
  }

  void _handleCategoryTap(BuildContext context, DynamicMap args) {
    final category = args['category'] as String?;
    final label = args['label'] as String?;

    debugPrint('Category tapped: $category ($label)');

    context.push('/category/$category');
  }

  void _handleProductTap(BuildContext context, DynamicMap args) {
    final productId = args['product_id'] as String?;
    final title = args['title'] as String?;

    debugPrint('Product tapped: $productId ($title)');

    // Navigate to product detail page
    // Navigator.pushNamed(context, '/product/$productId');
  }

  void _handleTypeTap(BuildContext context, DynamicMap args) {
    final type = args['type'] as String?;

    debugPrint('Type tapped: $type');

    // Filter products by type or navigate to filtered view
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Filtering by $type items')));
  }

  void _handleBannerTap(BuildContext context, DynamicMap args) {
    final bannerId = args['banner_id'] as String?;
    final index = args['index'] as int?;

    debugPrint('Banner tapped: $bannerId (index: $index)');

    // Handle banner tap - navigate to promotion page, etc.
  }

  void _listtileTap(BuildContext context, DynamicMap args) {
    debugPrint('ListTile tapped:');
    final destination = args['destination'] as String?;
    context.push(destination ?? '/');

    // Handle banner tap - navigate to promotion page, etc.
  }
}

// ···
