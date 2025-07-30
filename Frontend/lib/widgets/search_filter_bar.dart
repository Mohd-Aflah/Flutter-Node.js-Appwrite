import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/intern_controller.dart';

/// Widget for search and filter functionality
class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final InternController controller = Get.find<InternController>();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search interns by name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.searchInterns(''),
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => controller.searchInterns(value),
          ),
          
          const SizedBox(height: 12),
          
          // Filter Row
          Obx(() => Row(
            children: [
              // Batch Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Filter by Batch',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  value: controller.selectedBatch.value.isEmpty 
                      ? null 
                      : controller.selectedBatch.value,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Batches'),
                    ),
                    ...controller.availableBatches.map((batch) =>
                        DropdownMenuItem<String>(
                          value: batch,
                          child: Text(batch),
                        )),
                  ],
                  onChanged: (value) => controller.filterByBatch(value ?? ''),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Clear Filters Button
              if (controller.searchQuery.value.isNotEmpty ||
                  controller.selectedBatch.value.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => controller.clearFilters(),
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                    elevation: 0,
                  ),
                ),
            ],
          )),
          
          // Results Count
          Obx(() => controller.interns.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Text(
                        'Showing ${controller.interns.length} intern(s)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      if (controller.totalCount.value > 0)
                        Text(
                          ' of ${controller.totalCount.value} total',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
