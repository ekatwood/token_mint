import 'package:flutter/material.dart';
import 'phantom_ghost_button.dart'; // Make sure this exists or stub it

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Future<String> Function() connectPhantom;
  final Future<void> Function() openPhantomIfConnected;
  final void Function()? onDisconnect;

  const CustomAppBar({
    super.key,
    required this.connectPhantom,
    required this.openPhantomIfConnected,
    this.onDisconnect,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(84);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _walletConnected = false;
  String? _walletAddress;
  bool _dropdownOpen = false;

  void _handleWalletTap() async {
    if (_walletConnected) {
      setState(() {
        _dropdownOpen = !_dropdownOpen;
      });
    } else {
      final address = await widget.connectPhantom();
      if (!mounted) return;
      if (address == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please make sure Phantom Wallet browser extension is installed.'),
          ),
        );
      } else {
        setState(() {
          _walletConnected = true;
          _walletAddress = address;
          _dropdownOpen = true;
        });
      }
    }
  }

  void _disconnectWallet() {
    setState(() {
      _walletConnected = false;
      _walletAddress = null;
      _dropdownOpen = false;
    });
    if (widget.onDisconnect != null) {
      widget.onDisconnect!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBar(
          backgroundColor: Colors.tealAccent,
          elevation: 3,
          shadowColor: const Color(0x1DF7A0),
          toolbarHeight: 84,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/'); // Home navigation
                },
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    height: 72,
                    width: 72,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: GestureDetector(
                  onTap: _handleWalletTap,
                  child: _walletConnected
                      ? Image.asset(
                    'assets/dropdown-menu.png',
                    width: 55,
                    height: 55,
                  )
                      : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: PhantomGhostButton(size: 55),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_dropdownOpen)
          Positioned(
            top: 84,
            right: 14,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdownItem('Your Projects', () {
                      // TODO: Implement navigation or callback
                    }),
                    _buildDropdownItem('Liked Projects', () {
                      // TODO
                    }),
                    _buildDropdownItem('Mint Token', () {
                      // TODO
                    }),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: Text(
                        'Wallet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    _buildDropdownItem('Open', () async {
                      await widget.openPhantomIfConnected();
                      setState(() {
                        _dropdownOpen = false;
                      });
                    }),
                    _buildDropdownItem('Disconnect', () {
                      _disconnectWallet();
                    }),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
