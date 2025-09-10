import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/models/custom_category.dart';
import 'package:soundboard/core/providers/custom_category_providers.dart';

/// Dialog for creating and editing custom categories
class CustomCategoryManagementDialog extends ConsumerStatefulWidget {
  final CustomCategory? category; // null for creating new, non-null for editing

  const CustomCategoryManagementDialog({super.key, this.category});

  @override
  ConsumerState<CustomCategoryManagementDialog> createState() =>
      _CustomCategoryManagementDialogState();
}

class _CustomCategoryManagementDialogState
    extends ConsumerState<CustomCategoryManagementDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedIcon;
  late String _selectedColor;

  bool _isLoading = false;

  // Available icons for categories
  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'music_note', 'icon': Icons.music_note, 'label': 'Music Note'},
    {'name': 'star', 'icon': Icons.star, 'label': 'Star'},
    {'name': 'sports_soccer', 'icon': Icons.sports_soccer, 'label': 'Soccer'},
    {'name': 'campaign', 'icon': Icons.campaign, 'label': 'Horn'},
    {'name': 'warning', 'icon': Icons.warning, 'label': 'Warning'},
    {'name': 'pan_tool', 'icon': Icons.pan_tool, 'label': 'Hand'},
    {
      'name': 'folder_special',
      'icon': Icons.folder_special,
      'label': 'Special Folder',
    },
    {'name': 'celebration', 'icon': Icons.celebration, 'label': 'Celebration'},
    {'name': 'volume_up', 'icon': Icons.volume_up, 'label': 'Volume'},
    {'name': 'audiotrack', 'icon': Icons.audiotrack, 'label': 'Audio Track'},
    {'name': 'queue_music', 'icon': Icons.queue_music, 'label': 'Queue Music'},
    {'name': 'headphones', 'icon': Icons.headphones, 'label': 'Headphones'},
  ];

  // Available colors for categories
  final List<Map<String, dynamic>> _availableColors = [
    {'name': 'Purple', 'hex': '#9C27B0', 'color': const Color(0xFF9C27B0)},
    {'name': 'Blue', 'hex': '#2196F3', 'color': const Color(0xFF2196F3)},
    {'name': 'Green', 'hex': '#4CAF50', 'color': const Color(0xFF4CAF50)},
    {'name': 'Orange', 'hex': '#FF9800', 'color': const Color(0xFFFF9800)},
    {'name': 'Red', 'hex': '#F44336', 'color': const Color(0xFFF44336)},
    {'name': 'Teal', 'hex': '#009688', 'color': const Color(0xFF009688)},
    {'name': 'Indigo', 'hex': '#3F51B5', 'color': const Color(0xFF3F51B5)},
    {'name': 'Pink', 'hex': '#E91E63', 'color': const Color(0xFFE91E63)},
    {'name': 'Amber', 'hex': '#FFC107', 'color': const Color(0xFFFFC107)},
    {'name': 'Deep Purple', 'hex': '#673AB7', 'color': const Color(0xFF673AB7)},
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.category != null) {
      // Editing existing category
      _nameController = TextEditingController(text: widget.category!.name);
      _descriptionController = TextEditingController(
        text: widget.category!.description,
      );
      _selectedIcon = widget.category!.iconName;
      _selectedColor = widget.category!.colorHex;
    } else {
      // Creating new category
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedIcon = 'music_note';
      _selectedColor = '#9C27B0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.category != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Category' : 'Create New Category'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'Enter category name',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Description field
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter category description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Icon selection
              Text(
                'Icon',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildIconSelection(),
              const SizedBox(height: 20),

              // Color selection
              Text(
                'Color',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildColorSelection(),
              const SizedBox(height: 16),

              // Preview
              _buildPreview(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Widget _buildIconSelection() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableIcons.length,
        itemBuilder: (context, index) {
          final iconData = _availableIcons[index];
          final isSelected = iconData['name'] == _selectedIcon;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedIcon = iconData['name'];
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Icon(
                  iconData['icon'],
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelection() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableColors.length,
        itemBuilder: (context, index) {
          final colorData = _availableColors[index];
          final isSelected = colorData['hex'] == _selectedColor;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedColor = colorData['hex'];
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorData['color'],
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 3,
                        )
                      : Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreview() {
    final theme = Theme.of(context);
    final selectedIconData = _availableIcons.firstWhere(
      (icon) => icon['name'] == _selectedIcon,
      orElse: () => _availableIcons.first,
    );
    final selectedColorData = _availableColors.firstWhere(
      (color) => color['hex'] == _selectedColor,
      orElse: () => _availableColors.first,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedColorData['color'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  selectedIconData['icon'],
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty
                          ? 'Category Name'
                          : _nameController.text,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _descriptionController.text.isEmpty
                          ? 'Category description'
                          : _descriptionController.text,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    // Validate input
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(customCategoriesProvider.notifier);

      if (widget.category != null) {
        // Update existing category
        await notifier.updateCategory(
          widget.category!.id,
          name: name,
          description: description,
          iconName: _selectedIcon,
          colorHex: _selectedColor,
        );
      } else {
        // Create new category
        await notifier.createCategory(
          name: name,
          description: description,
          iconName: _selectedIcon,
          colorHex: _selectedColor,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.category != null
                  ? 'Category updated successfully'
                  : 'Category created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
