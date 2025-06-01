import 'package:dynamic_ui/images/chair_images.dart';
import 'package:dynamic_ui/svg_icons/cabinet.dart';
import 'package:dynamic_ui/svg_icons/bed.dart';
import 'package:dynamic_ui/svg_icons/chair.dart';
import 'package:dynamic_ui/svg_icons/dining.dart';
import 'package:dynamic_ui/svg_icons/discount.dart';
import 'package:dynamic_ui/svg_icons/sbi.dart';
import 'package:dynamic_ui/svg_icons/sofa.dart';
import 'package:dynamic_ui/svg_icons/storage.dart';
import 'package:dynamic_ui/svg_icons/study.dart';
import 'package:dynamic_ui/svg_icons/svg_icons.dart';
import 'package:dynamic_ui/svg_icons/table.dart';
import 'package:flutter/material.dart';
import 'package:rfw/rfw.dart';
import 'widget_factory.dart';

final url =
    'data:image/jpeg;base64,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';

class Home extends StatelessWidget {
  Home({super.key});

  final String rfwLayout =
      '''
    import local;

    widget root = SingleChildScrollView(child: Column(
      children: [
        BannerSlider(urls:["$banner1","$banner2","$banner3"]),

           Padding(padding: 8.0,child:

        Text(text:"BUY FURNITURE"),),

        SizeBox(height: 8.0),
 
   GridViewBuilder(
          itemCount: 8,
          crossAxisCount: 4,
           children:[ 
        CategoryIcon(label: "Dining",icon: "$encodeddining"),
          CategoryIcon(label: "Tables", icon: "$encodedTable"),
          CategoryIcon(label: "Chairs", icon: "$encodedChair"),
          CategoryIcon(label: "Cabinets", icon: "$encodedCabinet"),
                 CategoryIcon(label: "Living Room", icon: "$encodedSofa"),
          CategoryIcon(label: "Bedroom", icon: "$encodedbed"),
          CategoryIcon(label: "Storage", icon: "$encodedstorage"),
          CategoryIcon(label: "Study", icon: "$encodedStudy"),
     
           ],
        ),

        SizeBox(height: 8.0),



  ListTile(
    
            title:  'Offers & Discounts',
        
           
          ),
         Padding(padding: 8.0,child:          Row( children: [
       Expanded (child:  TypeCard(
            icon: "$encodedBox",
            title: "Brand New",
             
          ),  ),       Expanded (child:  TypeCard(
            icon: "$encodedRecycle",
            title: "Refurbished",
             
          ),),]),),
        SizeBox(height: 8.0),
       
   SingleChildScrollView(scrollDirection:"horizontal",child:    Padding(padding: 8.0,child:       Row(spacing:16,children: [
           OfferCard(text: "Extra ₹100 off on SBI",subTitle:"No Action Required",icon:"$encodedSbi"),
          OfferCard(text: "Get flat ₹500 off",subTitle:"Get flat 15 % off",icon:"$encodedDsicount"),
           OfferCard(text: "Extra ₹100 off on SBI",subTitle:"No Action Required",icon:"$encodedSbi"),
          OfferCard(text: "Get flat ₹500 off",subTitle:"Get flat 15 % off",icon:"$encodedDsicount"),
           OfferCard(text: "Extra ₹100 off on SBI",subTitle:"No Action Required",icon:"$encodedSbi"),
          OfferCard(text: "Get flat ₹500 off",subTitle:"Get flat 15 % off",icon:"$encodedDsicount"),
        ]),),),

      


        SizeBox(height: 8.0),
   ListTile(
     icon:"home",
            title:  'Deals of the Day',
            subtitle:  'To buy',
           
          ),
        
      Padding(padding: 8.0,child:   SingleChildScrollView(scrollDirection:"horizontal",child:    Row(spacing:16,children: [
          ProductCard(
            image: "$chairImage1",
            title: "Flex 3 Seater Magic B...",
            price: "-72% ₹10,699"
          ),
          ProductCard(
            image: "$chairImage2",
            title: "Flex Fabric 3...",
            price: "-74% ₹9,499"
          ),
          ProductCard(
            image: "$chairImage3",
            title: "Flex Fabric 3...",
            price: "-74% ₹9,499"
          ),
          ProductCard(
            image: "$chairImage5",
            title: "Flex Fabric 3...",
            price: "-74% ₹9,499"
          ),
          ProductCard(
            image: "$chairImage6",
            title: "Flex Fabric 3...",
            price: "-74% ₹9,499"
          ),
          ProductCard(
            image: "$chairImage7",
            title: "Flex Fabric 3...",
            price: "-74% ₹9,499"
          ),
       
          ProductCard(
            image: "$chairImage9",
            title: "Flex Fabric 3...",
            price: "-74% ₹9,499"
          ),
        ]),),),


  
      
      ],
    ),);
  ''';

  @override
  Widget build(BuildContext context) {
    final runtime = WidgetFactory.buildRuntime(rfwLayout);

    return Scaffold(
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
              debugPrint('Event triggered: $name, args: $args');
            },
          ),
    );
  }
}

// ···
final encodedRecycle = Uri.encodeComponent(recycle);
final encodedBox = Uri.encodeComponent(box);
final encodedTable = Uri.encodeComponent(table);
final encodedChair = Uri.encodeComponent(chair);
final encodedbed = Uri.encodeComponent(bed);
final encodedstorage = Uri.encodeComponent(storage);
final encodeddining = Uri.encodeComponent(dining);
final encodedStudy = Uri.encodeComponent(study);
final encodedSofa = Uri.encodeComponent(sofa);
final encodedDsicount = Uri.encodeComponent(discount);
final encodedCabinet = Uri.encodeComponent(cabinet);
final encodedSbi = Uri.encodeComponent(sbi);

final banner1 =
    'https://www.shutterstock.com/image-illustration/outdoor-concept-sale-home-decorations-260nw-2213849247.jpg';
final banner2 =
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT6oVGpf35fMz2xlXbIz9NCiGKkPVecPd2y7A&s';

final banner3 =
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSTdeRoYNdKO6kv1gG4Bn2NsNgfjzUsYyLfdQ&s';

final banner4 =
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYHZynyLKNQv2zgPNlPJzI2qWtFaSI8XjBREadSXfH1ZMwMVPMFFsq5jH9VbRFRz6q8sQ&usqp=CAU';

final banner5 =
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4KAdVkkeqM9KlNfLBZLiKl8wPHHhk-wyNZw&s';

final banner6 =
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR89Itkd1s4k006ncFd_cpAVMfUaE7UXWz0rQ&s';
