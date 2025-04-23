import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'post_detail.dart';
import 'adsense.dart';

class BlogPost {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String author;
  final List<String> tags;
  final String imageUrl;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.author,
    this.tags = const [],
    this.imageUrl = '',
  });

  factory BlogPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BlogPost(
      id: doc.id,
      title: data['title'] ?? '제목 없음',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      author: data['author'] ?? '익명',
      tags: List<String>.from(data['tags'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<BlogPost> _posts = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _posts = snapshot.docs
            .map((doc) => BlogPost.fromFirestore(doc))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '게시물을 불러오는 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '우주 테니스 도서관',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPosts,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPosts,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Text(
          '아직 게시물이 없습니다.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _posts.length + (_posts.length ~/ 3), // 3개 게시물마다 광고 삽입
    itemBuilder: (context, index) {
      // 광고 삽입 위치 계산
      if (index > 0 && index % 4 == 0) { // index 4, 8, 12 ... 에 광고
        // !!!! 광고 슬롯 ID 수정 !!!!
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: AdsenseAdWidget(
            adSlotId: '1372504723', // <- 실제 AdSense 슬롯 ID로 교체 완료 (상세 페이지와 다른 슬롯 ID 사용 가능)
            width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width - 32, // 너비 제한 추가 고려 (패딩 16*2=32 고려)
            height: 100, // 광고 크기에 맞게 조절
          ),
        );
        // !!!! 광고 슬롯 ID 수정 끝 !!!!
    }
    
    // 실제 게시물 인덱스 계산 (광고로 인한 오프셋 조정)
      final postIndex = index - (index ~/ 4);
      // Bounds check 추가
      if (postIndex >= _posts.length) {
        return const SizedBox.shrink(); // 혹시 모를 인덱스 오류 방지
      }
      final post = _posts[postIndex];
      return _buildPostCard(post);
    },
  );
  }

  Widget _buildPostCard(BlogPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // 게시물 상세 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(post: post),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  post.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _truncateContent(post.content),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        post.author,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: post.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

String _truncateContent(String content) {
  // 마크다운 형식 제거 시도
  String plainText = content
      .replaceAll(RegExp(r'#+\s'), '') // 헤더 제거
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // 볼드 제거 - r 접두사 추가
      .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // 이탤릭 제거 - r 접두사 추가
      .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1') // 링크 텍스트만 유지 - r 접두사 추가
      .replaceAll(RegExp(r'```.*?```', dotAll: true), '') // 코드 블록 제거
      .replaceAll(RegExp(r'`(.*?)`'), r'$1') // 인라인 코드 제거 - r 접두사 추가
      .replaceAll(RegExp(r'>\s.*?(\n|$)'), '') // 인용 제거
      .replaceAll(RegExp(r'!\[(.*?)\]\(.*?\)'), ''); // 이미지 제거
  
  if (plainText.length <= 200) return plainText;
  return '${plainText.substring(0, 200)}...';
}

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }
}