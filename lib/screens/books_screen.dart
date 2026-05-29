import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'القرآن الكريم', 'icon': Icons.menu_book, 'count': 114},
    {'name': 'الحديث الشريف', 'icon': Icons.format_quote, 'count': 50},
    {'name': 'الفقه', 'icon': Icons.balance, 'count': 30},
    {'name': 'العقيدة', 'icon': Icons.lightbulb, 'count': 20},
    {'name': 'السيرة النبوية', 'icon': Icons.person, 'count': 15},
    {'name': 'التفسير', 'icon': Icons.auto_stories, 'count': 25},
  ];

  final List<Map<String, dynamic>> _featuredBooks = [
    {
      'title': 'فاتحون صلاة',
      'author': 'إسلام جمال',
      'image': 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400',
      'rating': 4.8,
      'pages': 320,
    },
    {
      'title': 'علمتني سورة البقرة',
      'author': 'أحمد الشقيري',
      'image': 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
      'rating': 4.9,
      'pages': 280,
    },
    {
      'title': 'الأذكار',
      'author': 'الإمام النووي',
      'image': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
      'rating': 4.7,
      'pages': 450,
    },
    {
      'title': 'رياض الصالحين',
      'author': 'الإمام النووي',
      'image': 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400',
      'rating': 4.9,
      'pages': 680,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'المكتبة الإسلامية',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryGreen.withOpacity(0.1),
                                AppTheme.gold.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryGreen.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category['icon'] as IconData,
                                color: AppTheme.primaryGreen,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category['name'] as String,
                                style: TextStyle(
                                  color: AppTheme.charcoal,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Featured Books
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.gold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'كتب مميزة',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _featuredBooks.length,
                    itemBuilder: (context, index) {
                      final book = _featuredBooks[index];
                      return _buildBookCard(book);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return InkWell(
      onTap: () => Get.toNamed('/book-detail', arguments: book),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Image.network(
                    book['image'] as String,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${book['rating']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'] as String,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book['author'] as String,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 14,
                        color: AppTheme.primaryGreen.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${book['pages']} صفحة',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryGreen.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
