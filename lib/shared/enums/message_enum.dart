//enhanced enums
enum MessageEnum {
  text('text'),
  audio('audio'),
  image('image'),
  video('video'),
  pdf('pdf'),
  gif('gif');

  const MessageEnum(this.type);
    final String type;
}

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'audio':
        return MessageEnum.audio;
      case 'image':
        return MessageEnum.image;
      case 'text':
        return MessageEnum.text;
      case 'gif':
        return MessageEnum.gif;
      case 'video':
        return MessageEnum.video;
        case 'pdf':
        return MessageEnum.pdf;
      default:
        return MessageEnum.text;
    }
  }
}
