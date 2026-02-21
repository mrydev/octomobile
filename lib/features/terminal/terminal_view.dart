import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../connection/providers/connection_provider.dart';
import 'providers/terminal_provider.dart';

class TerminalView extends ConsumerStatefulWidget {
  const TerminalView({super.key});

  @override
  ConsumerState<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends ConsumerState<TerminalView> {
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void dispose() {
    _commandController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendCommand() {
    final cmd = _commandController.text.trim();
    if (cmd.isEmpty) return;

    final apiClient = ref.read(apiClientProvider);
    apiClient
        ?.sendCommand(cmd)
        .then((_) {
          _commandController.clear();
          // Optional: add a pseudo-log entry to show we sent it
          // ref.read(terminalProvider.notifier).state = [...ref.read(terminalProvider), 'Send: $cmd'];
        })
        .catchError((err) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Komut Gönderilemedi: $err')));
        });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && _autoScroll) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(terminalProvider);
    final theme = Theme.of(context);

    // Attempt to auto scroll after new logs arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              _autoScroll
                  ? Icons.vertical_align_bottom
                  : Icons.pause_circle_filled,
              color: _autoScroll
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            tooltip: _autoScroll
                ? 'Otomatik Kaydırma Açık'
                : 'Otomatik Kaydırma Kapalı',
            onPressed: () {
              setState(() {
                _autoScroll = !_autoScroll;
              });
              if (_autoScroll) _scrollToBottom();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Logları Temizle',
            onPressed: () {
              ref.read(terminalProvider.notifier).clearLogs();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.black, // Classic terminal feel
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    // Turn off auto-scroll if user scrolls up manually
                    if (notification is ScrollUpdateNotification &&
                        notification.scrollDelta != null &&
                        notification.scrollDelta! < 0) {
                      if (_autoScroll) {
                        setState(() => _autoScroll = false);
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      // Primitive coloring based on starting substrings
                      Color color = Colors.greenAccent;
                      if (log.startsWith('Send:')) color = Colors.blue;
                      if (log.contains('Error') || log.contains('error')) {
                        color = Colors.redAccent;
                      }
                      if (log.startsWith('Recv:')) color = Colors.white70;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: color,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commandController,
                      decoration: InputDecoration(
                        hintText: 'M105, G28, vs...',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _sendCommand(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: theme.colorScheme.onPrimary,
                      onPressed: _sendCommand,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
