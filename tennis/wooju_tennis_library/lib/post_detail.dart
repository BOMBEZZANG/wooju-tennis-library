import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'adsense.dart';


import 'home.dart';

class PostDetailPage extends StatelessWidget {
  final BlogPost post;
  
  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: post.imageUrl.isNotEmpty ? 300 : 0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: post.imageUrl.isNotEmpty
          ? FlexibleSpaceBar(
              background: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          
          // 메타 정보 (작성자, 날짜)
          Row(
            children: [
              Text(
                post.author,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '•',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatDate(post.createdAt),
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          
          // 태그
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          // 구분선
          const SizedBox(height: 24),
          Divider(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            thickness: 1,
          ),
          const SizedBox(height: 24),

          // !!!! 광고 슬롯 ID 수정 (상단 광고) !!!!
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: AdsenseAdWidget(
              adSlotId: '1372504723', // <- 실제 AdSense 슬롯 ID로 교체 완료
              width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width - 48, // 너비 제한 추가 고려
              height: 100, // 광고 크기에 맞게 조절
            ),
          ),
          // !!!! 광고 슬롯 ID 수정 끝 !!!!
          
          // 블로그 본문
          MarkdownBody(
            data: post.content,
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.7,
              ),
              h2: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.7,
              ),
              h3: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.7,
              ),
              p: TextStyle(
                fontSize: 16,
                height: 1.7,
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
              listBullet: TextStyle(
                fontSize: 16,
                height: 1.7,
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
              blockquote: TextStyle(
                fontSize: 16,
                height: 1.7,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
              blockquoteDecoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 4,
                  ),
                ),
              ),
              blockquotePadding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              code: TextStyle(
                fontSize: 14,
                backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
              ),
              codeblockDecoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              codeblockPadding: const EdgeInsets.all(16),
              horizontalRuleDecoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
            ),
            onTapLink: (text, href, title) {
              if (href != null) {
                _launchUrl(href);
              }
            },
          ),
          // !!!! 광고 슬롯 ID 수정 (하단 광고) !!!!
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: AdsenseAdWidget(
              adSlotId: 'YOUR_AD_SLOT_ID_2', // <- 다른 광고 슬롯 ID가 있다면 실제 값으로 교체
              width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width - 48, // 너비 제한 추가 고려
              height: 100, // 광고 크기에 맞게 조절
            ),
          ),
          // !!!! 광고 슬롯 ID 수정 끝 !!!!
          // 하단 구분선
          const SizedBox(height: 40),
          Divider(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            thickness: 1,
          ),
          const SizedBox(height: 24),
          
          // 출처 및 저작권 표시
          Text(
            '© ${DateTime.now().year} 우주 테니스 도서관',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('URL 실행 오류: $e');
    }
  }
}