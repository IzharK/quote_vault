import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/widgets/empty_state_view.dart';
import 'package:quote_vault/core/widgets/error_state_view.dart';
import 'package:quote_vault/features/collections/domain/entities/collection.dart';
import 'package:quote_vault/features/collections/presentation/providers/collection_provider.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();
    final collections = provider.collections;
    final isLoading = provider.isLoading;
    final errorMessage = provider.errorMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('My Collections')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCollectionDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Builder(
        builder: (context) {
          if (isLoading && collections.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errorMessage != null && collections.isEmpty) {
            return ErrorStateView(
              message: errorMessage,
              onRetry: () =>
                  context.read<CollectionProvider>().loadCollections(),
            );
          }

          if (collections.isEmpty) {
            return const EmptyStateView(
              message: 'No collections yet.',
              icon: Icons.folder_open,
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<CollectionProvider>().loadCollections(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder, color: Colors.blueAccent),
                    title: Text(collection.name),
                    subtitle: Text(
                      'Created: ${_formatDate(collection.createdAt)}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'rename') {
                          _showCollectionDialog(
                            context,
                            collection: collection,
                          );
                        } else if (value == 'delete') {
                          _confirmDelete(context, collection);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'rename',
                          child: Text('Rename'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      context.pushNamed(
                        'collection_detail',
                        pathParameters: {'collectionId': collection.id},
                        queryParameters: {'name': collection.name},
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showCollectionDialog(BuildContext context, {Collection? collection}) {
    final isEditing = collection != null;
    final controller = TextEditingController(text: collection?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Rename Collection' : 'New Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Morning Motivation',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final provider = context.read<CollectionProvider>();
                if (isEditing) {
                  provider.updateCollection(collection.id, name);
                } else {
                  provider.createCollection(name);
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Collection collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection?'),
        content: Text(
          'Are you sure you want to delete "${collection.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CollectionProvider>().deleteCollection(
                collection.id,
              );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
