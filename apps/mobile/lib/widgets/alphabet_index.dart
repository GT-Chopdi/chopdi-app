// import 'package:flutter/material.dart';

// class AlphabetIndex extends StatelessWidget {
//   const AlphabetIndex({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const letters = [
//       'A','B','C','D','E','F','G','H','I','J','K','L','M',
//       'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'
//     ];

//     return Container(
//       width: 24,
//       alignment: Alignment.center,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: letters
//             .map(
//               (letter) => Expanded(
//                 child: InkWell(
//                   onTap: () {
                    
//                   },
//                   child: Center(
//                     child: Text(
//                       letter,
//                       style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xff6D7C93),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class AlphabetIndex extends StatelessWidget {
  final ValueChanged<String> onLetterSelected;

  const AlphabetIndex({
    super.key,
    required this.onLetterSelected,
  });

  static const List<String> letters = [
    '#',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters.map((letter) {
        return GestureDetector(
          onTap: () {
            onLetterSelected(letter);
          },
          child: SizedBox(
            width: 22,
            height: 20,
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff223A5E),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}