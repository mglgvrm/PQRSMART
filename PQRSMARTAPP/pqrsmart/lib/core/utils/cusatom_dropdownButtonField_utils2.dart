import 'package:flutter/material.dart';

class CustomDropdownField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final List<String> items;
  final String? Function(String?)? validator;
  final Function(String?) onChanged;

  const CustomDropdownField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.items,
    this.validator,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  bool isOpen = false;
  OverlayEntry? overlayEntry;
  final LayerLink layerLink = LayerLink();
  final GlobalKey fieldKey = GlobalKey();

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }

  void toggleDropdown() {
    if (isOpen) {
      closeDropdown();
    } else {
      openDropdown();
    }
  }

  void openDropdown() {
    overlayEntry = createOverlayEntry();
    Overlay.of(context).insert(overlayEntry!);
    setState(() {
      isOpen = true;
    });
  }

  void closeDropdown() {
    overlayEntry?.remove();
    overlayEntry = null;
    setState(() {
      isOpen = false;
    });
  }

  OverlayEntry createOverlayEntry() {
    RenderBox renderBox =
        fieldKey.currentContext!.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 5.0),
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 350),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final isSelected = widget.controller.text == item;

                      return InkWell(
                        onTap: () {
                          widget.controller.text = item;
                          widget.onChanged(item);
                          closeDropdown();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.blue.shade50
                                    : Colors.transparent,
                            border:
                                index < widget.items.length - 1
                                    ? Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    )
                                    : null,
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  isSelected
                                      ? Colors.blue.shade700
                                      : Colors.black,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: TextFormField(
        key: fieldKey,
        controller: widget.controller,
        readOnly: true,
        onTap: toggleDropdown,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          suffixIcon: Icon(
            isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.grey.shade600,
          ),
        ),
        style: const TextStyle(fontSize: 18, color: Colors.black),
        validator: widget.validator,
      ),
    );
  }
}
