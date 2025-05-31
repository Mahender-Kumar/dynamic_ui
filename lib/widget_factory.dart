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
      'GreenBox': (context, source) => ColoredBox(
        color: const Color.fromARGB(255, 34, 22, 0),
        child: source.child(<Object>['child']),
      ),
      'Hello': (context, source) => Center(
        child: Text(
          'Hello, ${(source.v<String>(<Object>["name"]) ?? 'World')}!',
          style: const TextStyle(color: Colors.white, fontSize: 24),
          textDirection: TextDirection.ltr,
        ),
      ),
      'BannerImage': (context, source) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                16,
              ), // Set your desired radius
              image: DecorationImage(
                image: NetworkImage((source.v<String>(['url'])) ?? ''),
                fit: BoxFit.cover,
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: 200, // optional: set max height
              maxWidth: double.infinity, // optional: set max width
            ),
          ),
        );
      },

      'CategoryIcon': (context, source) {
        // print(source.v<String>(['icon']));
        return Column(
          // mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            Icon(
              iconMap[source.v<String>(['icon'])] ?? Icons.abc,
              size: 30,
            ), // can be dynamic
            Text(source.v<String>(['label']) ?? ''),
          ],
        );
      },
      'Column': (context, source) {
        return SingleChildScrollView(
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: source.childList(['children']), // ✅ This now works
          ),
        );
      },
      'Row': (context, source) {
        final spacing =
            double.tryParse(source.v<String>(['spacing']) ?? '') ?? 8;
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: source.childList(['children']), // ✅ This now works
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
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4), // Set your desired radius
            color: Colors.yellow.shade100,
          ),
          constraints: BoxConstraints(
            maxWidth: 200, // optional: set max height
          ),

          child: ListTile(
            leading: Icon(
              iconMap[source.v<String>(['icon'])] ?? Icons.announcement,
              size: 24,
            ),
            title: Text(
              source.v<String>(['text']) ?? '',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: Text(
              source.v<String>(['text']) ?? '',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
                color: Colors.black87,
              ),
            ),
          ),
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
        return SizedBox(
          width: 120,
          child: Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                (source.v<String>(['image']) ?? ''),
                height: 160,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  (source.v<String>(['title']) ?? ''),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(
                            source.v<String>(['color']) ?? '0xFF000000',
                          ),
                        ),
                      ),

                      constraints: BoxConstraints(minHeight: 32),
                      child: Text(
                        source.v<String>(['price']) ?? '',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          onTap: () {
            final action = source.v<String>(['action']);
            if (action != null) {
              debugPrint('ListTile tapped with action: $action');
            }
          },
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
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  iconMap[source.v<String>(['icon'])] ?? Icons.help,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'BUY',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    source.v<String>(['title']) ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward, size: 16),
                ),
              ],
            ),
          ),
        );
      },
      'icon': (context, source) {
        final iconName = source.v<String>(['name']);
        if (iconName != null && iconMap.containsKey(iconName)) {
          return Icon(iconMap[iconName], size: 24);
        } else {
          return const Icon(Icons.help, size: 24);
        }
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
