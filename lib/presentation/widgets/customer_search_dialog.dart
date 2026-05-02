import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';
import 'package:unifytechxenoscaixa/presentation/providers/customer_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/sale_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_input.dart';

class CustomerSearchDialog extends ConsumerStatefulWidget {
  const CustomerSearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => const CustomerSearchDialog(),
    );
  }

  @override
  ConsumerState<CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends ConsumerState<CustomerSearchDialog> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerNotifierProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 750,
        height: 600,
        decoration: AppTheme.glassCard(),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_search_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vincular Cliente', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                        Text('Pesquise por nome, CPF ou CNPJ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: GlassInput(
                controller: _searchController,
                focusNode: _focusNode,
                hint: 'Digite o nome ou documento do cliente...',
                prefixIcon: Icons.search_rounded,
                onChanged: (val) => ref.read(customerNotifierProvider.notifier).search(val),
              ),
            ),

            // Results List
            Expanded(
              child: customerState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : customerState.error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.accentRed),
                                const SizedBox(height: 16),
                                Text(
                                  'Erro ao buscar clientes:',
                                  style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  customerState.error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => ref.read(customerNotifierProvider.notifier).search(_searchController.text),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Tentar Novamente'),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        )
                      : customerState.searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_off_outlined, size: 48, color: AppTheme.onSurfaceVariant.withOpacity(0.2)),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isEmpty 
                                      ? 'Digite para começar a pesquisar'
                                      : 'Nenhum cliente encontrado para "${_searchController.text}"', 
                                    style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.5)),
                                  ),
                                ],
                              ),
                            )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: customerState.searchResults.length,
                          separatorBuilder: (_, __) => const Divider(color: AppTheme.divider, height: 1),
                          itemBuilder: (_, i) {
                            final c = customerState.searchResults[i];
                            final disponivel = c.creditoDisponivel;
                            final hasNoCredit = disponivel <= 0;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                child: Text(c.nome[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(c.nome, style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.cpfCnpj ?? 'S/ Documento', style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text('Limite: ${Formatters.currency(c.limiteCredito)}', style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant)),
                                      const SizedBox(width: 8),
                                      Text('Débito: ${Formatters.currency(c.saldoDevedor)}', style: const TextStyle(fontSize: 11, color: AppTheme.accentRed)),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Formatters.currency(disponivel),
                                    style: TextStyle(
                                      color: hasNoCredit ? AppTheme.accentRed : AppTheme.accentGreen,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Text('Crédito Disponível', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 10)),
                                ],
                              ),
                              onTap: () {
                                ref.read(saleNotifierProvider.notifier).selectCustomer(c);
                                Navigator.pop(context);
                                ref.read(customerNotifierProvider.notifier).clearSearch();
                              },
                            );
                          },
                        ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.keyboard_return_rounded, size: 16, color: AppTheme.onSurfaceVariant),
                  SizedBox(width: 8),
                  Text('Pressione ENTER para vincular', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                  Spacer(),
                  Text('ESC para sair', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
