# AI Model License Documentation

This document records the license, source, and attribution requirements for the machine learning models used in Pics Tools.

---

## 1. BiRefNet General Lite (Default On-Device Model)

- **Model Name**: `BiRefNet General Lite` (`birefnet-general-lite.onnx`)
- **Architecture**: Bilateral Reference Network for High-Resolution Dichotomous Image Segmentation (BiRefNet)
- **Model Version**: `1.0.0`
- **Original Authors & Research**: ZhengPeng7 et al.
- **Original Source Repository**: [https://github.com/ZhengPeng7/BiRefNet](https://github.com/ZhengPeng7/BiRefNet)
- **ONNX Export / Distribution Source**: [https://github.com/danielgatis/rembg/releases/tag/v0.0.0](https://github.com/danielgatis/rembg/releases/tag/v0.0.0) / Hugging Face `onnx-community/BiRefNet_lite-ONNX`
- **Download URL**: `https://github.com/danielgatis/rembg/releases/download/v0.0.0/birefnet-general-lite.onnx`
- **Model License**: **MIT License**
- **Commercial Use**: **Permitted** under the MIT License terms.
- **Attribution Requirement**: Retain copyright notice and permission notice in any substantial portions of the software/distributions.

### MIT License Text
```text
MIT License

Copyright (c) 2024 ZhengPeng7 / BiRefNet Authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 2. Technical Model Specifications

- **Input Tensor**:
  - Name: `input_image` (or primary input node)
  - Dimensions: `[1, 3, 512, 512]` (NCHW)
  - Data Type: `Float32`
  - Normalization: ImageNet Mean `[0.485, 0.456, 0.406]`, Std `[0.229, 0.224, 0.225]`
- **Output Tensor**:
  - Dimensions: `[1, 1, 512, 512]`
  - Data Type: `Float32` (Logits)
  - Postprocessing: Sigmoid activation `1.0 / (1.0 + exp(-x))` to derive continuous alpha mask `[0.0, 1.0]`
- **Approximate File Size**: ~213 MB (downloaded on-demand into private application storage)
- **Local Sandbox Path**: `<AppDocuments>/ai_models/background_remover/birefnet-general-lite/1.0.0/birefnet-general-lite.onnx`

---

## 3. Compliance & Privacy

- **100% On-Device**: All model inference runs strictly locally via ONNX Runtime without uploading images or telemetry to external servers.
- **No Bundled Bloat**: The model file is NOT bundled into the APK or IPA binaries and is downloaded solely upon explicit user request.
