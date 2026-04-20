import 'package:flutter/material.dart';

class CusatomDropdownbuttonfieldUtils<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final double widthFactor; // Permite modificar el ancho
  final Function(T?) onChanged; // Callback para detectar cambios en el texto
  final String Function(T)? itemLabel;
  final List<T> items;
  final T? value;

  const CusatomDropdownbuttonfieldUtils({
    Key? key,
    required this.label,
    required this.hintText,
    this.widthFactor = 0.9, // Valor por defecto
    required this.onChanged,
    this.itemLabel,
    required this.items,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.transparent, // Hace el borde invisible
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.transparent, // Hace el borde invisible
                ),
              ),
              filled: true, // Permite que el fondo tenga color
              fillColor: Colors.white,
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).size.width *
                    widthFactor, // Usa el 90% del ancho
                minWidth: 250, // No permite que sea más pequeño de 250px
                minHeight: 50,
              ),
            ),
            hint: Text(hintText),
            value: value,
            onChanged: onChanged,
            items:
                items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Row(
                      children: [
                        Text(
                          itemLabel != null
                              ? itemLabel!(item)
                              : item.toString(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
