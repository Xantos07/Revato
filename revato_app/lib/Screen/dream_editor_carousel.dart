import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/carousel_editor_view_model.dart';
import '../widgets/CarouselEditor/carousel_editor_widgets.dart';

class DreamEditorCarousel extends StatefulWidget {
  const DreamEditorCarousel({super.key});

  @override
  State<DreamEditorCarousel> createState() => _DreamEditorCarouselState();
}

class _DreamEditorCarouselState extends State<DreamEditorCarousel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CarouselEditorViewModel()..loadCategories(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Personnalisation du carousel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 1.2,
            ),
          ),
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Rédactions', icon: Icon(Icons.edit_note)),
              Tab(text: 'Tags', icon: Icon(Icons.local_offer)),
            ],
          ),
        ),
        body: Consumer<CarouselEditorViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              controller: _tabController,
              children: [
                RedactionTabView(viewModel: viewModel),
                TagTabView(viewModel: viewModel),
              ],
            );
          },
        ),
      ),
    );
  }
}
