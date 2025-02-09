# minimap

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('อัพโหลดรูปภาพ'),
                ),
                if (_image != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      File(_image!.path),
                      height: 100, // กำหนดความสูงของภาพตัวอย่าง
                    ),
                  ),
              ],
            ),