import 'dart:io';

void main() {
  final buildDir = 'build/web';
  final indexPath = '$buildDir/index.html';
  
  final indexFile = File(indexPath);
  if (!indexFile.existsSync()) {
    print('빌드된 index.html 파일을 찾을 수 없습니다.');
    return;
  }
  
  var content = indexFile.readAsStringSync();
  
  // 기존 AdSense 코드 교체
  const oldAdSenseCode = '<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-XXXXXXXXXXXXXXXX"';
  const newAdSenseCode = '<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-2598779635969436"';
  
  if (content.contains(oldAdSenseCode)) {
    content = content.replaceAll(oldAdSenseCode, newAdSenseCode);
    indexFile.writeAsStringSync(content);
    print('AdSense 코드가 성공적으로 업데이트되었습니다.');
  } else {
    print('대체할 AdSense 코드를 찾을 수 없습니다.');
  }
}