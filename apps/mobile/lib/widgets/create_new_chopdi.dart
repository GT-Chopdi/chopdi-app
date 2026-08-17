// import 'package:flutter/material.dart';
// import 'package:mychopdi/utils/app_colors.dart';

// class CreateChopdiBottomSheet extends StatefulWidget {

//   final BuildContext parentContext;

//   const CreateChopdiBottomSheet({
//     super.key,
//     required this.parentContext,
//   });

//   @override
//   State<CreateChopdiBottomSheet> createState() =>
//       _CreateChopdiBottomSheetState();
// }

// class _CreateChopdiBottomSheetState
//     extends State<CreateChopdiBottomSheet> {

//   final TextEditingController nameController =
//       TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(12),
//       padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
//       decoration: const BoxDecoration(
//         color: AppColors.card,
//         borderRadius: BorderRadius.all(
//           Radius.circular(30),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [

//           Container(
//             width: 48,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey,
//               borderRadius: BorderRadius.circular(20),
//             ),
//           ),

//           const SizedBox(height: 28),

//           TextField(
//             controller: nameController,
//             decoration: InputDecoration(
//               hintText: "Enter Shop/Business name",
//               hintStyle: const TextStyle(
//                 color: Color(0xff7B869C),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 18,
//               ),
//               filled: true,
//               fillColor: Colors.transparent,
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide: const BorderSide(
//                   color: Color(0xffB9C9E8),
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide: const BorderSide(
//                   color: Color(0xff243B67),
//                   width: 1.5,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 120),

//           SizedBox(
//             width: double.infinity,
//             height: 58,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xff243B67),
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(16),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text(
//                 "Create",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mychopdi/service/chopdi_service.dart';
import 'package:mychopdi/utils/app_colors.dart';

class CreateChopdiBottomSheet extends StatefulWidget {
  final BuildContext parentContext;

  const CreateChopdiBottomSheet({
    super.key,
    required this.parentContext,
  });

  @override
  State<CreateChopdiBottomSheet> createState() =>
      _CreateChopdiBottomSheetState();
}

class _CreateChopdiBottomSheetState
    extends State<CreateChopdiBottomSheet> {

  final TextEditingController nameController =
      TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _createChopdi() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter Chopdi name",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    // final chopdi =
    //     await ChopdiService.createChopdi(name);

    // if (!mounted) return;

    // Navigator.pop(
    //   context,
    //   chopdi,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),

      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20,
      ),

      decoration: const BoxDecoration(
        color: AppColors.card,

        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [

          Container(
            width: 48,
            height: 4,

            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius:
                  BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 28),

          TextField(
            controller: nameController,

            textCapitalization:
                TextCapitalization.words,

            decoration: InputDecoration(
              hintText:
                  "Enter Shop/Business name",

              hintStyle: const TextStyle(
                color: Color(0xff7B869C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),

                borderSide: const BorderSide(
                  color: Color(0xffB9C9E8),
                ),
              ),

              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),

                borderSide: const BorderSide(
                  color: Color(0xff243B67),
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 120),

          SizedBox(
            width: double.infinity,
            height: 58,

            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xff243B67),

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),

              onPressed:
                  isSaving
                      ? null
                      : _createChopdi,

              child: isSaving
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      "Create",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}