# LImagePicker
一个支持多选、选原图和视频的图片选择器，同时有预览功能。



# Example

```swift
let imagePicker = LImagePickerController(delegate: self)
imagePicker.modalPresentationStyle = .custom
self.present(imagePicker, animated: true, completion: nil)

extension ViewController: LImagePickerDelegate {
    func imagePickerController(_ picker: LImagePickerController, photos: [UIImage], asset: [PHAsset]) {
    }
}
```



# Requirements 要求

iOS10.0及以上系统可使用. ARC环境.

LImagePicker使用了相机、麦克风、相册，请参考Demo添加下列属性到info.plist文件：

`Privacy - Camera Usage Description`

`Privacy - Microphone Usage Description`

`Privacy - Photo Library Usage Description`



