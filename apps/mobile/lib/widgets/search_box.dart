// import 'package:flutter/material.dart';

// class SearchBox extends StatelessWidget {
//   final TextEditingController controller;
//   final Function(String) onChanged;

//   const SearchBox({
//     super.key,
//     required this.controller,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 48,
//       child: TextField(
//         controller: controller,
//         onChanged: onChanged,
//         style: const TextStyle(
//           fontSize: 15,
//           color: Color(0xff223A5E),
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           hintText: "Search contacts",
//           hintStyle: TextStyle(
//             color: Colors.grey.shade500,
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//           prefixIcon: const Padding(
//             padding: EdgeInsets.only(left: 12, right: 8),
//             child: Icon(
//               Icons.search,
//               color: Color(0xff223A5E),
//               size: 22,
//             ),
//           ),
//           prefixIconConstraints: const BoxConstraints(
//             minWidth: 40,
//             minHeight: 40,
//           ),
//           filled: true,
//           fillColor: const Color(0xffF8EEDC),
//           contentPadding: const EdgeInsets.symmetric(vertical: 12),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(
//               color: Color(0xffB7C2D5),
//               width: 1,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(
//               color: Color(0xff223A5E),
//               width: 1.2,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchBox({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: "Search contact",
        hintStyle: const TextStyle(
          color: Color(0xff8A93A6),
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xff6D7B94),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color(0xff6D7B94),
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xffC9D2E3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xff29406B),
            width: 1.3,
          ),
        ),
      ),
    );
  }
}