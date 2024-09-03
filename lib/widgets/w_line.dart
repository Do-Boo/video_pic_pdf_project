import 'package:flutter/material.dart';

class CustomLine extends StatelessWidget {
  const CustomLine({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 7,
      child: Stack(
        children: [
          Row(
            children: [
              const SizedBox(width: 3),
              Container(height: 7, width: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
              const Expanded(child: SizedBox()),
              Container(height: 7, width: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
              const SizedBox(width: 3),
            ],
          ),
          Column(
            children: [
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(height: 1, width: 7, color: Theme.of(context).hintColor.withOpacity(0.5)),
                  const SizedBox(width: 3),
                  Expanded(child: Container(height: 1, color: Theme.of(context).hintColor.withOpacity(0.2))),
                  const SizedBox(width: 3),
                  Container(height: 1, width: 7, color: Theme.of(context).hintColor.withOpacity(0.5)),
                ],
              ),
              const SizedBox(height: 3),
            ],
          ),
        ],
      ),
    );
  }
}
