import 'package:dynamic_ui/widgets/auto_banner_slider.dart';
import 'package:dynamic_ui/widgets/auto_video_player.dart';
import 'package:dynamic_ui/widgets/product_card.dart';
import 'package:dynamic_ui/widgets/category_icon.dart';
import 'package:dynamic_ui/svgs/svg_icons.dart';
import 'package:dynamic_ui/widgets/offer_card.dart';
import 'package:dynamic_ui/widgets/svg_image.dart';
import 'package:dynamic_ui/widgets/banner_image.dart';
import 'package:dynamic_ui/widgets/type_card.dart';
import 'package:flutter/material.dart';
import 'package:rfw/formats.dart';
import 'package:rfw/rfw.dart';

class WidgetFactory {
  static Runtime buildRuntime(String widgetDsl) {
    final runtime = Runtime();

    runtime.update(const LibraryName(<String>['local']), _createLocalWidgets());

    try {
      runtime.update(
        const LibraryName(<String>['remote']),
        parseLibraryFile(widgetDsl),
      );
    } catch (e) {
      debugPrint('RFW parse error: $e');
      debugPrint('DSL:\n$widgetDsl');
    }

    return runtime;
  }

  static WidgetLibrary _createLocalWidgets() {
    return LocalWidgetLibrary(<String, LocalWidgetBuilder>{
      'BannerImage': (context, source) {
        final url = source.v<String>(['url']);
        return BannerImage(url: url);
      },

      'CategoryIcon': (context, source) {
        final iconName = source.v<String>(['icon']) ?? recycle;
        final label = source.v<String>(['label']) ?? '';
        final onTap =
            source.voidHandler(['onTap']) ??
            () {
              print('clicking on $label');
            };
        print('this${source.voidHandler(['onTap'])}');

        return CategoryIcon(icon: iconName, label: label, onTap: onTap);
      },
      'Column': (context, source) {
        return Column(children: source.childList(['children']));
      },
      'Row': (context, source) {
        final spacing =
            double.tryParse(source.v<String>(['spacing']) ?? '') ?? 8;
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: source.childList(['children']),
        );
      },
      'Padding': (context, source) {
        final paddingValue = source.v<double>(['padding']) ?? 8.0;
        return Padding(
          padding: EdgeInsets.all(paddingValue),
          child: source.optionalChild(<Object>['child']),
        );
      },
      'OfferCard': (context, source) {
        final svgString = source.v<String>(['icon']);
        final title = source.v<String>(['text']) ?? '';
        final subTitle = source.v<String>(['subTitle']) ?? '';
        // print('svgString $svgString');
        return OfferCard(
          svgString: svgString,
          title: title,
          subTtitle: subTitle,
        );
      },
      'SingleChildScrollView': (context, source) {
        return SingleChildScrollView(
          scrollDirection: source.v<String>(['scrollDirection']) == 'horizontal'
              ? Axis.horizontal
              : Axis.vertical,
          child: source.optionalChild(<Object>['child']),
        );
      },
      'ProductCard': (context, source) {
        final image = source.v<String>(['image']);
        final title = source.v<String>(['title']) ?? '';
        final price = source.v<String>(['price']) ?? '';
        final color = source.v<String>(['color']);

        return ProductCard(
          image: image,
          title: title,
          price: price,
          color: color,
        );
      },
      'Text': (context, source) {
        return Text(
          source.v<String>(['text']) ?? '',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: source.v<String>(['color']) != null
                ? Color(int.parse(source.v<String>(['color'])!))
                : Colors.black,
          ),
        );
      },
      'Center': (context, source) {
        return Center(child: source.optionalChild(<Object>['child']));
      },
      'SizeBox': (context, source) {
        final width = source.v<double>(['width']) ?? 0.0;
        final height = source.v<double>(['height']) ?? 0.0;

        return SizedBox(
          width: width,
          height: height,
          child: source.optionalChild(['child']),
        );
      },
      'ListTile': (context, source) {
        final onTap =
            source.voidHandler(['onTap']) ??
            () {
              debugPrint('ListTile tapped');
            };
        return ListTile(
          dense: true,
          leading: source.v<String>(['icon']) != null
              ? Icon(iconMap[source.v<String>(['icon'])] ?? Icons.help)
              : null,
          title: Text(
            source.v<String>(['title']) ?? '',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          subtitle: source.v<String>(['subtitle']) != null
              ? Text(source.v<String>(['subtitle']) ?? '')
              : null,
          trailing: Icon(
            iconMap[source.v<String>(['trailingIcon'])] ?? Icons.arrow_forward,
          ),
          onTap: onTap,
        );
      },
      'TextFormField': (context, source) {
        final label = source.v<String>(['label']) ?? '';
        final hint = source.v<String>(['hint']) ?? '';
        final initialValue = source.v<String>(['initialValue']) ?? '';
        return TextFormField(
          decoration: InputDecoration(labelText: label, hintText: hint),
          initialValue: initialValue,
          onChanged: (value) {
            debugPrint('TextFormField changed: $value');
          },
        );
      },
      'Expanded': (context, source) {
        return Expanded(child: source.child(<Object>['child']));
      },

      'TypeCard': (context, source) {
        final iconName = source.v<String>(['icon']) ?? recycle;
        final title = source.v<String>(['title']) ?? '';

        return TypeCard(iconName: iconName, title: title);
      },
      'Icon': (context, source) {
        final iconName = source.v<String>(['name']);
        if (iconName != null && iconMap.containsKey(iconName)) {
          return Icon(iconMap[iconName], size: 24);
        } else {
          return const Icon(Icons.help, size: 24);
        }
      },
      'Svg': (context, source) {
        final iconName = source.v<String>(['icon']) ?? recycle;
        return SvgImage(icon: iconName);
      },
      'GridViewBuilder': (context, source) {
        final crossAxisCount = source.v<int>(['crossAxisCount']) ?? 2;
        final spacing = source.v<double>(['spacing']) ?? 8.0;
        final itemCount = source.v<int>(['itemCount']) ?? 0;
        final children = source.childList(['children']);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),

          itemCount: itemCount.clamp(0, children.length),
          itemBuilder: (context, index) {
            return children[index];
          },
        );
      },
      'BannerSlider': (context, source) {
        if (source.isList(['urls'])) {
          final length = source.length(['urls']);
          final banners = List.generate(length, (index) {
            return source.v<String>(['urls', index]);
          }).whereType<String>().toList();
          return AutoBannerSlider(urls: banners);
        }
        return SizedBox.shrink();
      },
      'VideoSlider': (context, source) {
        if (source.isList(['urls'])) {
          final length = source.length(['urls']);
          final videos = List.generate(length, (index) {
            return source.v<String>(['urls', index]);
          }).whereType<String>().toList();
          return AutoVideoBanner(videoUrls: videos);
        }
        return SizedBox.shrink();
      },
    });
  }

  static Map<String, IconData> iconMap = {
    'home': Icons.home,
    'settings': Icons.settings,
    'search': Icons.search,
    'person': Icons.person,
    'account_circle': Icons.account_circle,
    'email': Icons.email,
    'lock': Icons.lock,
    'visibility': Icons.visibility,
    'visibility_off': Icons.visibility_off,
    'camera': Icons.camera,
    'photo': Icons.photo,
    'phone': Icons.phone,
    'map': Icons.map,
    'location_on': Icons.location_on,
    'favorite': Icons.favorite,
    'favorite_border': Icons.favorite_border,
    'star': Icons.star,
    'star_border': Icons.star_border,
    'shopping_cart': Icons.shopping_cart,
    'check': Icons.check,
    'close': Icons.close,
    'arrow_back': Icons.arrow_back,
    'arrow_forward': Icons.arrow_forward,
    'menu': Icons.menu,
    'notifications': Icons.notifications,
    'calendar_today': Icons.calendar_today,
    'edit': Icons.edit,
    'delete': Icons.delete,
    'add': Icons.add,
    'remove': Icons.remove,
    'play_arrow': Icons.play_arrow,
    'pause': Icons.pause,
    'info': Icons.info,
    'help': Icons.help,
    'warning': Icons.warning,
    'cloud': Icons.cloud,
    'download': Icons.download,
    'upload': Icons.upload,
    'weekend': Icons.weekend,
    'bed': Icons.bed,
    'kitchen': Icons.kitchen,
    'chair': Icons.chair,
  };
}
