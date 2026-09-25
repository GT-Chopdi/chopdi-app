import 'package:flutter/material.dart';

class AlphabetIndex extends StatefulWidget {
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
  State<AlphabetIndex> createState() => _AlphabetIndexState();
}

class _AlphabetIndexState extends State<AlphabetIndex> {
  String? _selectedLetter;

  // Used only while the finger is touching/dragging.
  bool _showFloatingIndicator = false;

  void _selectLetter(String letter) {
    if (_selectedLetter == letter) {
      return;
    }

    setState(() {
      _selectedLetter = letter;
      _showFloatingIndicator = true;
    });

    widget.onLetterSelected(letter);
  }

  void _handlePointerDown(
    PointerDownEvent event,
    double letterHeight,
  ) {
    final letter = _letterFromPosition(
      event.localPosition.dy,
      letterHeight,
    );

    setState(() {
      _selectedLetter = letter;
      _showFloatingIndicator = true;
    });

    widget.onLetterSelected(letter);
  }

  void _handlePointerMove(
    PointerMoveEvent event,
    double letterHeight,
  ) {
    final letter = _letterFromPosition(
      event.localPosition.dy,
      letterHeight,
    );

    if (letter != _selectedLetter) {
      _selectLetter(letter);
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    setState(() {
      // Keep selected letter highlighted,
      // but hide the floating bubble.
      _showFloatingIndicator = false;
    });
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    setState(() {
      _showFloatingIndicator = false;
    });
  }

  String _letterFromPosition(
    double dy,
    double letterHeight,
  ) {
    int index = (dy / letterHeight).floor();

    index = index.clamp(
      0,
      AlphabetIndex.letters.length - 1,
    );

    return AlphabetIndex.letters[index];
  }

  double _getIndicatorTop(
    double availableHeight,
    double letterHeight,
  ) {
    if (_selectedLetter == null) {
      return 0;
    }

    final index =
        AlphabetIndex.letters.indexOf(_selectedLetter!);

    if (index < 0) {
      return 0;
    }

    final position =
        (index * letterHeight) +
        (letterHeight / 2) -
        26;

    return position.clamp(
      0.0,
      availableHeight - 52,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        final letterCount =
            AlphabetIndex.letters.length;

        final calculatedHeight =
            availableHeight / letterCount;

        final letterHeight =
            calculatedHeight.clamp(14.0, 22.0);

        return SizedBox(
          width: 42,
          height: availableHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // --------------------------------------------------
              // ALPHABET INDEX
              // --------------------------------------------------

              Listener(
                behavior: HitTestBehavior.opaque,

                onPointerDown: (event) {
                  _handlePointerDown(
                    event,
                    letterHeight,
                  );
                },

                onPointerMove: (event) {
                  _handlePointerMove(
                    event,
                    letterHeight,
                  );
                },

                onPointerUp: _handlePointerUp,

                onPointerCancel: _handlePointerCancel,

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children:
                      AlphabetIndex.letters.map(
                    (letter) {
                      final isSelected =
                          _selectedLetter == letter;

                      return SizedBox(
                        width: 42,
                        height: letterHeight,
                        child: Center(
                          child: AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds: 100,
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xff223A5E,
                                    )
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                            ),
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontSize:
                                    letterHeight < 17
                                        ? 9
                                        : 10,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(
                                        0xff223A5E,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),

              // --------------------------------------------------
              // FLOATING LETTER INDICATOR
              // --------------------------------------------------

              if (_showFloatingIndicator &&
                  _selectedLetter != null)
                Positioned(
                  right: 35,
                  top: _getIndicatorTop(
                    availableHeight,
                    letterHeight,
                  ),
                  child: IgnorePointer(
                    child: AnimatedScale(
                      scale: _showFloatingIndicator
                          ? 1.0
                          : 0.0,
                      duration:
                          const Duration(milliseconds: 100),
                      child: Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration:
                            const BoxDecoration(
                          color: Color(0xff223A5E),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _selectedLetter!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}