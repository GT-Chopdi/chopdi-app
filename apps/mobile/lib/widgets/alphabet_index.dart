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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Available height for the complete alphabet.
        final availableHeight = constraints.maxHeight;

        // Number of letters.
        final letterCount = letters.length;

        /*
          Calculate the maximum height available for
          each letter.

          Small screens -> smaller letter height.
          Large screens -> slightly larger letter height.
        */
        final calculatedHeight =
            availableHeight / letterCount;

        // Keep the letter height within a sensible range.
        final letterHeight = calculatedHeight
            .clamp(14.0, 22.0);

        return SizedBox(
          width: 22,
          height: availableHeight,
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: letters.map((letter) {
              return SizedBox(
                width: 22,
                height: letterHeight,
                child: GestureDetector(
                  behavior:
                      HitTestBehavior.opaque,
                  onTap: () {
                    onLetterSelected(letter);
                  },
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize:
                            letterHeight < 17
                                ? 9
                                : 10,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            const Color(0xff223A5E),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}