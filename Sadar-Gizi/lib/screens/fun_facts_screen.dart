import 'package:flutter/material.dart';

import 'package:project_capstone_1/widgets/navbar_widget.dart';

class FunFactsScreen extends StatefulWidget {
  const FunFactsScreen({super.key});

  @override
  _FunFactsScreenState createState() => _FunFactsScreenState();
}

class _FunFactsScreenState extends State<FunFactsScreen> {
  int _currentPage = 0;
  final PageController _controller = PageController();

  final List<_SliderPage> _pages = const [
    _SliderPage(
      description:
          "WHO memberikan gambaran takaran gula yang dapat dipertimbangkan yaitu di bawah 5 persen atau sekitar 25 gram (6 sendok teh) per harinya.",
      image: "assets/images/fun_facts/Being-Healthy-Streamline-Tokyo.png",
    ),
    _SliderPage(
      description:
          "Makanan tinggi gula dapat meningkatkan kadar glukosa darah dengan cepat, lalu turun drastis sehingga kamu lebih cepat lapar dan mudah lelah.",
      image: "assets/images/fun_facts/Order-Groceries-Online-Streamline-Tokyo.png",
    ),
    _SliderPage(
      description:
          "Satu bungkus mi instan bisa mengandung lebih dari 1.200 mg natrium, setara dengan 60% batas konsumsi garam harian.",
      image: "assets/images/fun_facts/Fast-Food-2-Streamline-Tokyo.png",
    ),
    _SliderPage(
      description:
          "Dalam daftar komposisi, bahan yang disebut paling awal berarti jumlahnya paling banyak. Jadi kalau “gula” muncul di urutan pertama, tandanya produk itu sangat manis.",
      image: "assets/images/fun_facts/Order-Groceries-Online-2-Streamline-Tokyo.png",
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _controller.jumpToPage(0);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuint,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color (0xFFFBE19D),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 0),
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _controller,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) => _pages[index],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 5,
                    width: (_currentPage == index) ? 30 : 10,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: (_currentPage == index)
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
                    ),
                  );
                }),
              ),
              
              InkWell(
                onTap: _nextPage,
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 45,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: const Icon(
                    Icons.navigate_next,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}

/// WIDGET TAMPILAN PER SLIDE
class _SliderPage extends StatelessWidget {
  final String description;
  final String image;

  const _SliderPage({
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Container(
      color: Color(0xFFFBE19D),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Fun Facts',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Image.asset(
            image,
            width: width * 0.6,
          ),
          const SizedBox(height: 30),
          Text(
            description,
            style: const TextStyle(
              height: 1.5,
              fontWeight: FontWeight.normal,
              fontSize: 15,
              letterSpacing: 0.7,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
