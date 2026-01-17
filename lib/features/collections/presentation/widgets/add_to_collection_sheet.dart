import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/features/collections/presentation/providers/collection_provider.dart';

class AddToCollectionSheet extends StatelessWidget {
  final String quoteId;

  const AddToCollectionSheet({super.key, required this.quoteId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();
    final collections = provider.collections;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add to Collection',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Create New Collection',
                  onPressed: () => _createNewCollection(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (collections.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No collections found. Create one!',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.folder_open,
                      color: Colors.blueAccent,
                    ),
                    title: Text(collection.name),
                    onTap: () => _addToCollection(context, collection.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _createNewCollection(BuildContext context) {
    // We can't easily reuse the dialog from CollectionsScreen without extracting it.
    // For simplicity, let's just close this and prompt user to go to Collections?
    // Or ask user for name here. Let's do a simple dialog on top of sheet.
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Collection Name'),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<CollectionProvider>().createCollection(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCollection(
    BuildContext context,
    String collectionId,
  ) async {
    // Show loading?
    try {
      await context.read<CollectionProvider>().addQuoteToCollection(
        collectionId,
        quoteId,
      );
      if (context.mounted) {
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to collection successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
