import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';
import 'package:unifytechxenoscaixa/presentation/providers/service_providers.dart';

class ProductDisplayCard extends ConsumerWidget {
  final dynamic item;
  final int totalItens;

  const ProductDisplayCard({
    super.key,
    required this.item,
    required this.totalItens,
  });

  String _formatImageUrl(String url, WidgetRef ref) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    
    final apiService = ref.read(apiServiceNotifierProvider);
    final baseUrl = apiService.baseUrl;
    
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanUrl = url.startsWith('/') ? url : (url.startsWith('uploads') ? '/$url' : '/uploads/$url');
    
    return '$cleanBase$cleanUrl';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = _formatImageUrl(item.produtoFotoUrl ?? '', ref);

    return Container(
      width: double.infinity,
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Área da Imagem
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          
          // Informações do Produto
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ITEM #$totalItens',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      Formatters.currency(item.precoUnitario),
                      style: const TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.produtoNome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal:',
                      style: TextStyle(
                        color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      Formatters.currency(item.total),
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_rounded,
            color: AppTheme.onSurfaceVariant.withOpacity(0.1),
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            item.produtoNome.isNotEmpty ? item.produtoNome.substring(0, 1).toUpperCase() : '?',
            style: TextStyle(
              color: AppTheme.onSurfaceVariant.withOpacity(0.1),
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
