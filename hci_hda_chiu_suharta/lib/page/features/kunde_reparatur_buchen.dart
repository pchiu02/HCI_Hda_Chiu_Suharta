import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:hci_hda_chiu_suharta/class/fahrrarzt.dart';
import 'package:hci_hda_chiu_suharta/localization/locales.dart';
import 'package:hci_hda_chiu_suharta/page/home/kunde_home.dart';
import 'package:hci_hda_chiu_suharta/theme/theme.dart';
import 'package:provider/provider.dart';

import '../../class/Booking.dart';
//import '../../localization/locales.dart';

Color primaryColor = lightColorScheme.primary;
Color bgColor = lightColorScheme.background;
Color unselectedLabelColor = Color(0xff5f6368);

class ReparaturBuchen extends StatefulWidget {
  final String userId;

  ReparaturBuchen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ReparaturBuchen> createState() => _ReparaturBuchenState();
}

class _ReparaturBuchenState extends State<ReparaturBuchen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  double _totalPrice = 0;
  late List<Tab> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [];
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newTabs = [
      Tab(text: LocaleData.komponente.getString(context)),
      Tab(text: LocaleData.zubehoer.getString(context)),
    ];
    if (_tabs != newTabs) {
      _tabs = newTabs;
      _tabController.dispose();
      _tabController = TabController(length: _tabs.length, vsync: this);
    }
  }

  List<bool> _komponenteChecked = List.generate(5, (_) => false);
  List<bool> _zubehoerChecked = List.generate(4, (_) => false);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'FAHRRARZT',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            letterSpacing: 2.0,
            color: bgColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: _tabs,
              labelColor: primaryColor,
              indicatorColor: primaryColor,
              unselectedLabelColor: unselectedLabelColor,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildKomponenteList(),
                  _buildZubehoerList(),
                ],
              ),
            ),
            _buildSubtotal(),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildKomponenteList() {
    Fahrrarzt fahrrarzt = Provider
        .of<FahrrarztProvider>(context)
        .fahrrarzt;

    return Container(
      color: lightColorScheme.background,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          final warehouse = fahrrarzt.warehouse;
          if (warehouse == null) {
            return ListTile(
              title: Text('No data available'),
            );
          }
          final sparepart = warehouse.keys.elementAt(index);
          return Column(
            children: [
              ListTile(
                title: Row(
                  children: [
                    Expanded(child: Text(sparepart.name!)),
                    Text('\€${sparepart.sellPrice!.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: _buildKomponenteTrailing(index),
              ),
              if (_komponenteChecked[index]) _buildToggleWidget(index),
              Divider(height: 1, color: Colors.grey), // Divider between items
            ],
          );
        },
      ),
    );
  }

  Widget _buildZubehoerList() {
    Fahrrarzt fahrrarzt = Provider
        .of<FahrrarztProvider>(context)
        .fahrrarzt;
    return Container(
      color: lightColorScheme.background,
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          final warehouse = fahrrarzt.warehouse;
          if (warehouse == null) {
            return ListTile(
              title: Text('No data available'),
            );
          }
          final sparepart = warehouse.keys.elementAt(index + 5);
          return Column(
            children: [
              ListTile(
                title: Row(
                  children: [
                    Expanded(child: Text(sparepart.name!)),
                    Text('\€${sparepart.sellPrice!.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: _buildZubehoerTrailing(index),
              ),
              Divider(height: 1, color: Colors.grey), // Divider between items
            ],
          );
        },
      ),
    );
  }

  Widget _buildZubehoerTrailing(index) {
    return Checkbox(
        value: _zubehoerChecked[index],
        onChanged: (bool? value) {
          setState(() {
            _zubehoerChecked[index] = value!;
          });
        });
  }

  Widget _buildKomponenteTrailing(int index) {
    return Checkbox(
      value: _komponenteChecked[index],
      onChanged: (bool? value) {
        setState(() {
          _komponenteChecked[index] = value!;

          //Reset value if main checkbox is unchecked
          switch (index) {
            case 0:
              frontBrake = false;
              rearBrake = false;
              break;
            case 3:
              frontTyre = false;
              rearTyre = false;
              break;
            case 4:
              frontSpoke = false;
              rearSpoke = false;
              break;
          }
        });
      },
    );
  }

  bool frontBrake = false;
  bool rearBrake = false;
  bool frontTyre = false;
  bool rearTyre = false;
  bool frontSpoke = false;
  bool rearSpoke = false;

  Widget _buildToggleWidget(int index) {
    switch (index) {
      case 0:
        return _brakeFrontRearToggle();
      case 3:
        return _tyreFrontRearToggle();
      case 4:
        return _spokeFrontRearToggle();
      default:
        return SizedBox.shrink(); // Placeholder if no special toggle is needed
    }
  }

  Widget _brakeFrontRearToggle() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                LocaleData.front.getString(context),
                style: TextStyle(color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
              ),
              Switch(
                  value: frontBrake,
                  activeColor: primaryColor,
                  onChanged: _komponenteChecked[0]
                      ? (bool value) {
                    setState(() {
                      frontBrake = value;
                    });
                  }
                      : null),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                LocaleData.rear.getString(context),
                style: TextStyle(color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, top: 10, bottom: 10),
              ),
              Switch(
                  value: rearBrake,
                  activeColor: primaryColor,
                  onChanged: _komponenteChecked[0]
                      ? (bool value) {
                    setState(() {
                      rearBrake = value;
                    });
                  }
                      : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tyreFrontRearToggle() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                LocaleData.front.getString(context),
                style: TextStyle(color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
              ),
              Switch(
                  value: frontTyre,
                  activeColor: primaryColor,
                  onChanged: _komponenteChecked[3]
                      ? (bool value) {
                    setState(() {
                      frontTyre = value;
                    });
                  }
                      : null),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                LocaleData.rear.getString(context),
                style: TextStyle(color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, top: 10, bottom: 10),
              ),
              Switch(
                  value: rearTyre,
                  activeColor: primaryColor,
                  onChanged: _komponenteChecked[3]
                      ? (bool value) {
                    setState(() {
                      rearTyre = value;
                    });
                  }
                      : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spokeFrontRearToggle() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                LocaleData.front.getString(context),
                style: TextStyle(color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
              ),
              Switch(
                  value: frontSpoke,
                  activeColor: primaryColor,
                  onChanged: _komponenteChecked[4]
                      ? (bool value) {
                    setState(() {
                      frontSpoke = value;
                    });
                  }
                      : null),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                LocaleData.rear.getString(context),
                style: TextStyle(color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13, top: 10, bottom: 10),
              ),
              Switch(
                  value: rearSpoke,
                  activeColor: primaryColor,
                  onChanged: _komponenteChecked[4]
                      ? (bool value) {
                    setState(() {
                      rearSpoke = value;
                    });
                  }
                      : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubtotal() {
    Fahrrarzt fahrrarzt = Provider
        .of<FahrrarztProvider>(context)
        .fahrrarzt;
    final warehouse = fahrrarzt.warehouse;
    double totalPrice = 0;

    //Calculate Komponente prices
    for (int i = 0; i < _komponenteChecked.length; i++) {
      if (warehouse == null) {
        break;
      }
      if (_komponenteChecked[i] == true) {
        if (i == 0 || i == 3 || i == 4) {
          switch (i) {
            case 0:
              if (frontBrake) {
                var sparepart = warehouse.keys.elementAt(i);
                totalPrice += sparepart.sellPrice!;
              }
              if (rearBrake) {
                var sparepart = warehouse.keys.elementAt(i);
                totalPrice += sparepart.sellPrice!;
              }
            case 3:
              if (frontTyre) {
                var sparepart = warehouse.keys.elementAt(i);
                totalPrice += sparepart.sellPrice!;
              }
              if (rearTyre) {
                var sparepart = warehouse.keys.elementAt(i);
                totalPrice += sparepart.sellPrice!;
              }
            case 4:
              if (frontSpoke) {
                var sparepart = warehouse.keys.elementAt(i);
                totalPrice += sparepart.sellPrice!;
              }
              if (rearSpoke) {
                var sparepart = warehouse.keys.elementAt(i);
                totalPrice += sparepart.sellPrice!;
              }
          }
        } else {
          var sparepart = warehouse.keys.elementAt(i);
          totalPrice += sparepart.sellPrice!;
        }
      }
    }

    //Calculate zubehoer prices
    for (int i = 0; i < _zubehoerChecked.length; i++) {
      if (warehouse == null) {
        break;
      }
      if (_zubehoerChecked[i] == true) {
        int realIndex = i + 4;
        var sparepart = warehouse.keys.elementAt(realIndex);
        totalPrice += sparepart.sellPrice!;
      }
    }

    setState(() {
      _totalPrice = totalPrice;
    });

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${LocaleData.subtotal.getString(context)}: \€ $totalPrice',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Poppins',
            ),
          ),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _komponenteChecked.any((checked) => checked) ||
            _zubehoerChecked.any((checked) => checked)
            ? primaryColor
            : Colors.grey,
      ),
      onPressed: _komponenteChecked.any((checked) => checked) ||
          _zubehoerChecked.any((checked) => checked)
          ? () async {
        bool confirm = await _showConfirmationDialog();
        if (confirm) {
          String bookingId = await _confirmBooking();
          await _showBookingId(bookingId);
        }
      }
          : null,
      child: Text(
        LocaleData.confirm.getString(context),
        style: TextStyle(
          color: bgColor,
          fontSize: 18,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleData.confirm_booking.getString(context)),
          content: Text(LocaleData.confirm_text.getString(context)),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleData.cancel.getString(context)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(LocaleData.bestatigt.getString(context)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ??
        false;
  }

  Future _showBookingId(String bookingId) async {
      showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text(LocaleData.confirm_booking.getString(context)),
        content: Text(
            '${LocaleData.your_booking_id.getString(context)}: $bookingId'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => KundeHome(userId: widget.userId),
                ),
                    (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      );
    });
  }

  Future<String> _confirmBooking() async {
    Fahrrarzt fahrrarzt =
        Provider
            .of<FahrrarztProvider>(context, listen: false)
            .fahrrarzt;
    final warehouse = fahrrarzt.warehouse;

    List<Map<String, dynamic>> komponenteList = [];
    List<Map<String, dynamic>> zubehoerList = [];

    for (int i = 0; i < _komponenteChecked.length; i++) {
      if (warehouse == null) {
        break;
      }
      if (_komponenteChecked[i] == true) {
        var sparepart = warehouse.keys.elementAt(i);
        if (i == 0 || i == 3 || i == 4) {
          if (i == 0) {
            if (frontBrake) {
              komponenteList
                  .add({"name": "front ${sparepart.name}", "done": false});
            }
            if (rearBrake) {
              komponenteList
                  .add({"name": "rear ${sparepart.name}", "done": false});
            }
          } else if (i == 3) {
            if (frontTyre) {
              komponenteList
                  .add({"name": "front ${sparepart.name}", "done": false});
            }
            if (rearTyre) {
              komponenteList
                  .add({"name": "rear ${sparepart.name}", "done": false});
            }
          } else if (i == 4) {
            if (frontSpoke) {
              komponenteList
                  .add({"name": "front ${sparepart.name}", "done": false});
            }
            if (rearSpoke) {
              komponenteList
                  .add({"name": "rear ${sparepart.name}", "done": false});
            }
          }
        } else {
          komponenteList.add({"name": sparepart.name!, "done": false});
        }
      }
    }

    for (int i = 0; i < _zubehoerChecked.length; i++) {
      if (warehouse == null) {
        break;
      }
      if (_zubehoerChecked[i] == true) {
        int realIndex = i + 5;
        var sparepart = warehouse.keys.elementAt(realIndex);
        zubehoerList.add({"name": sparepart.name!, "done": false});
      }
    }

    Booking booking = Booking(userId: widget.userId);

    String? userName = await booking.fetchUserName();

    Map<String, dynamic> userBookingMap = {
      'userId': widget.userId,
      'name': userName,
      'status': 'pending',
      'komponente': komponenteList,
      'zubehoer': zubehoerList,
      'price': _totalPrice,
    };
    String bookingId = await booking.addUserBooking(userBookingMap);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleData.confirm_text2.getString(context)),
      ),
    );
    return bookingId;
  }
}
