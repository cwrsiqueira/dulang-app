import '/features/profiles/child_profile_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class PerfisGerenciarWidget extends StatefulWidget {
  const PerfisGerenciarWidget({super.key});

  static String routeName = 'PerfisGerenciar';
  static String routePath = '/perfisGerenciar';

  @override
  State<PerfisGerenciarWidget> createState() => _PerfisGerenciarWidgetState();
}

class _PerfisGerenciarWidgetState extends State<PerfisGerenciarWidget> {
  List<ChildProfile> _list = [];
  String? _activeId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final s = ChildProfileService.instance;
    final list = await s.loadProfiles();
    final id = await s.activeProfileId();
    if (!mounted) return;
    setState(() {
      _list = list;
      _activeId = id;
      _loading = false;
    });
  }

  Future<void> _add() async {
    final name = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Novo perfil'),
          content: TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Nome da criança',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      );
      if (ok == true && mounted) {
        await ChildProfileService.instance.addProfile(name.text, 0xFF36B4FF);
        await _reload();
      }
    } finally {
      name.dispose();
    }
  }

  Future<void> _remove(ChildProfile p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remover perfil "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final didRemove =
          await ChildProfileService.instance.removeProfile(p.id);
      if (!didRemove && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Crie outro perfil antes de excluir o único.'),
          ),
        );
        return;
      }
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Perfis',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _loading ? null : _add,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _list.length,
              itemBuilder: (context, i) {
                final p = _list[i];
                final active = p.id == _activeId;
                return Card(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(p.colorValue),
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(p.name),
                    subtitle: active
                        ? const Text('Perfil ativo')
                        : const Text('Toque para ativar'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: _list.length == 1
                          ? 'É preciso outro perfil para poder excluir'
                          : 'Excluir perfil',
                      onPressed: _list.length == 1
                          ? null
                          : () => _remove(p),
                    ),
                    onTap: active
                        ? null
                        : () async {
                            await ChildProfileService.instance
                                .setActiveProfileId(p.id);
                            await _reload();
                          },
                  ),
                );
              },
            ),
    );
  }
}
