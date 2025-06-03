import 'package:dynamic_ui/pages/deals_of_the_day.dart';
import 'package:dynamic_ui/pages/discount.dart';
import 'package:dynamic_ui/pages/home.dart';
import 'package:dynamic_ui/pages/category_page.dart';
import 'package:dynamic_ui/pages/product_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', name: 'home', builder: (context, state) => Home()),
      GoRoute(
        path: '/category/:category',
        name: 'category',
        builder: (context, state) {
          // final category = state.pathParameters['category']!;
          return CategoryPage(category: state.pathParameters['category'] ?? '');
        },
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product',
        builder: (context, state) {
          // final productId = state.pathParameters['id']!;
          return ProductPage(id: state.pathParameters['id'] ?? '');
        },
      ),
      GoRoute(
        path: '/deals',
        name: 'deals',
        builder: (context, state) {
          // final productId = state.pathParameters['id']!;
          return DealsOfTheDay();
        },
      ),
      GoRoute(
        path: '/discount',
        name: 'discount',
        builder: (context, state) {
          // final productId = state.pathParameters['id']!;
          return DiscountPage();
        },
      ),
    ],
  );
}
