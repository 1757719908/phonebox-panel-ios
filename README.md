# PhoneBoxPanel

iOS 13+ / arm64，TrollStore 用未签名 IPA。源码在 `Sources/`，工程描述 `project.yml`。

## 构建

- **Codemagic（推荐，无需 Mac）**：`codemagic.yaml` 已写好，连上仓库自动识别，产物 `out/PhoneBoxPanel.ipa`
- **本地 Mac**：

```bash
brew install xcodegen
xcodegen generate
xcodebuild -project PhoneBoxPanel.xcodeproj -scheme PhoneBoxPanel -configuration Release \
  -sdk iphoneos -derivedDataPath build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
mkdir -p out/Payload && cp -R build/Build/Products/Release-iphoneos/PhoneBoxPanel.app out/Payload/
cd out && zip -qry PhoneBoxPanel.ipa Payload
```

## 安装

未签名 IPA 直接用 TrollStore 装（它自己 ldid 伪签名，不需要证书）：文件 App 长按 IPA → 共享 → TrollStore。

## 首次配置

电脑端 PhoneBox 监听地址改 `0.0.0.0` → App 内右上齿轮填 `电脑IP:端口` → 保存。
