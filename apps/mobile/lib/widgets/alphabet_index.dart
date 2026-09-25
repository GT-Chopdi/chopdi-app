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
    if (!mounted) return;

    setState(() {
      _showFloatingIndicator = false;
    });
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (!mounted) return;

    setState(() {
      _showFloatingIndicator = false;
    });
  }

  String _letterFromPosition(
    double dy,
    double letterHeight,
  ) {
    if (letterHeight <= 0) {
      return AlphabetIndex.letters.first;
    }

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
    double indicatorSize,
  ) {
    if (_selectedLetter == null) {
      return 0;
    }

    final index =
        AlphabetIndex.letters.indexOf(_selectedLetter!);

    if (index < 0) {
      return 0;
    }

    final centerPosition =
        (index * letterHeight) + (letterHeight / 2);

    final top =
        centerPosition - (indicatorSize / 2);

    return top.clamp(
      0.0,
      (availableHeight - indicatorSize).clamp(
        0.0,
        double.infinity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight =
            constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 300.0;

        final availableWidth =
            constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 40.0;

        final letterCount =
          AlphabetIndex.letters.length;

        // Responsive letter height.
        final letterHeight =
            availableHeight / letterCount;

        // Responsive font size.
        final fontSize = (letterHeight * 0.55)
            .clamp(8.0, 12.0);

        // Responsive horizontal padding.
        final horizontalPadding =
            (availableWidth * 0.10)
                .clamp(2.0, 5.0);

        // Indicator should also scale with screen size.
        final indicatorSize =
            (availableWidth * 1.25)
                .clamp(44.0, 56.0);

        return SizedBox(
          width: availableWidth,
          height: availableHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
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
                      MainAxisAlignment.start,
                  children: AlphabetIndex.letters.map(
                    (letter) {
                      final isSelected =
                          _selectedLetter == letter;

                      return SizedBox(
                        width: availableWidth,
                        height: letterHeight,
                        child: Center(
                          child: AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds: 100,
                            ),
                            padding:
                                EdgeInsets.symmetric(
                              horizontal:
                                  horizontalPadding,
                              vertical: 1.5,
                            ),
                            constraints:
                                BoxConstraints(
                              minWidth:
                                  (fontSize + 8)
                                      .clamp(18.0, 28.0),
                              minHeight:
                                  (fontSize + 6)
                                      .clamp(16.0, 24.0),
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xff223A5E,
                                    )
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(
                                7,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              letter,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSize,
                                height: 1.0,
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

              // Floating letter indicator
              if (_showFloatingIndicator &&
                  _selectedLetter != null)
                Positioned(
                  right: availableWidth * 0.85,
                  top: _getIndicatorTop(
                    availableHeight,
                    letterHeight,
                    indicatorSize,
                  ),
                  child: IgnorePointer(
                    child: AnimatedScale(
                      scale:
                          _showFloatingIndicator ? 1.0 : 0.0,
                      duration:
                          const Duration(milliseconds: 100),
                      child: Container(
                        width: indicatorSize,
                        height: indicatorSize,
                        alignment: Alignment.center,
                        decoration:
                            const BoxDecoration(
                          color: Color(0xff223A5E),
                          shape: BoxShape.circle,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _selectedLetter!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  indicatorSize * 0.42,
                              fontWeight:
                                  FontWeight.bold,
                            ),
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