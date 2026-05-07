# 🎯 QUICK REFERENCE GUIDE

## 🆕 New Utilities

### ResponsiveHelper
```dart
import 'package:billing_software/utils/responsive_helper.dart';

// Check device type
bool isMobile = ResponsiveHelper.isMobile(context);
bool isTablet = ResponsiveHelper.isTablet(context);
bool isDesktop = ResponsiveHelper.isDesktop(context);

// Get adaptive values
int columns = ResponsiveHelper.getGridCrossAxisCount(context);
double cartWidth = ResponsiveHelper.getCartWidth(context);
EdgeInsets padding = ResponsiveHelper.getScreenPadding(context);
```

### ShimmerLoading
```dart
import 'package:billing_software/widgets/shimmer_loading.dart';

// Basic shimmer
ShimmerLoading(
  width: 100,
  height: 20,
  borderRadius: BorderRadius.circular(10),
)

// Item card shimmer
ItemCardShimmer()
```

### EmptyStateWidget
```dart
import 'package:billing_software/widgets/empty_state_widget.dart';

EmptyStateWidget(
  icon: Icons.restaurant_menu,
  title: 'No items found',
  subtitle: 'Try adjusting your filters',
  actionLabel: 'Add Item',
  onAction: () => addNewItem(),
)
```

### ErrorStateWidget
```dart
import 'package:billing_software/widgets/error_state_widget.dart';

ErrorStateWidget(
  message: 'Failed to load data',
  onRetry: () => retryLoad(),
)
```

---

## 🔄 Updated Services

### CategoryService
```dart
import 'package:billing_software/services/category_service.dart';

final service = CategoryService();

// Listen to real-time updates
service.stream.listen((categories) {
  // Handle categories
});

// Add category
await service.add(CategoryModel(
  id: '',
  name: 'New Category',
  displayOrder: 1,
  isActive: true,
));

// Update category
await service.update(category);

// Delete category
await service.delete(categoryId);

// Auto-seed if empty
await service.seedIfEmpty();
```

---

## 🎨 Responsive Patterns

### Adaptive Grid
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
    crossAxisSpacing: isMobile ? 16 : 30,
    mainAxisSpacing: isMobile ? 16 : 30,
  ),
  itemBuilder: (context, index) => YourWidget(),
)
```

### Adaptive Padding
```dart
Padding(
  padding: EdgeInsets.all(
    ResponsiveHelper.isMobile(context) ? 12 : 16,
  ),
  child: YourWidget(),
)
```

### Conditional Sidebar
```dart
Row(
  children: [
    if (!ResponsiveHelper.isMobile(context))
      SidebarWidget(...),
    Expanded(child: MainContent()),
  ],
)
```

---

## 📱 Mobile-Specific Features

### Floating Cart Button
```dart
floatingActionButton: isMobile
    ? Obx(() {
        if (cartController.totalItems == 0) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          onPressed: () => showCart(),
          icon: const Icon(Icons.shopping_cart),
          label: Text('Cart (${cartController.totalItems})'),
        );
      })
    : null,
```

### Bottom Sheet Cart
```dart
void showMobileCart(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      builder: (context, scrollController) => CartWidget(...),
    ),
  );
}
```

---

## 🎭 Loading States

### Shimmer Grid
```dart
if (isLoading) {
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
    ),
    itemCount: 8,
    itemBuilder: (context, index) => const ItemCardShimmer(),
  );
}
```

### Image Loading
```dart
Image.network(
  imageUrl,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return CircularProgressIndicator(
      value: progress.expectedTotalBytes != null
          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
          : null,
    );
  },
  errorBuilder: (_, __, ___) => Icon(Icons.broken_image),
)
```

---

## 🎯 State Management Patterns

### Reactive Loading
```dart
final RxBool isLoading = true.obs;

Obx(() {
  if (controller.isLoading.value) {
    return ShimmerLoading(...);
  }
  return ActualContent();
})
```

### Empty State Check
```dart
Obx(() {
  if (controller.items.isEmpty) {
    return EmptyStateWidget(...);
  }
  return ListView.builder(...);
})
```

### Error Handling
```dart
Obx(() {
  if (controller.hasError.value) {
    return ErrorStateWidget(
      message: controller.errorMessage.value,
      onRetry: controller.retry,
    );
  }
  return Content();
})
```

---

## 🎨 UI Enhancements

### Quantity Badge
```dart
if (quantity > 0)
  Positioned(
    top: 8,
    right: 8,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7ED957),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text('x$quantity'),
    ),
  ),
```

### Better Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(message),
    backgroundColor: isError ? Colors.red : Color(0xFF16A34A),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);
```

---

## 🔥 Performance Tips

### Const Constructors
```dart
// Always use const when possible
const SizedBox(height: 16)
const Icon(Icons.add)
const EdgeInsets.all(16)
```

### Minimize Rebuilds
```dart
// Bad: Rebuilds entire widget
Obx(() => Column(
  children: [
    Text(controller.value.value),
    ExpensiveWidget(),
  ],
))

// Good: Only rebuilds Text
Column(
  children: [
    Obx(() => Text(controller.value.value)),
    const ExpensiveWidget(),
  ],
)
```

### ListView.builder
```dart
// Always use builder for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

---

## 🧪 Testing Checklist

- [ ] Test on mobile (< 600px width)
- [ ] Test on tablet (600-1024px width)
- [ ] Test on desktop (> 1024px width)
- [ ] Test loading states
- [ ] Test empty states
- [ ] Test error states
- [ ] Test with slow network
- [ ] Test with no network
- [ ] Test Firebase real-time updates
- [ ] Test cart on mobile (FAB + bottom sheet)
- [ ] Test image loading
- [ ] Test quantity badges
- [ ] Test print functionality

---

## 🐛 Common Issues & Solutions

### Issue: Shimmer not animating
**Solution:** Ensure parent widget has `SingleTickerProviderStateMixin`

### Issue: Cart not showing on mobile
**Solution:** Add items to cart first, FAB only shows when cart has items

### Issue: Categories not loading
**Solution:** Check Firebase configuration and Firestore rules

### Issue: Images not loading
**Solution:** Verify image URLs and network connectivity

### Issue: Layout overflow on small screens
**Solution:** Use `ResponsiveHelper` for adaptive sizing

---

## 📚 Additional Resources

- [Flutter Responsive Design](https://docs.flutter.dev/ui/layout/responsive)
- [GetX State Management](https://pub.dev/packages/get)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Material Design 3](https://m3.material.io/)

---

**Happy Coding! 🚀**
