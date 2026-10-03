# DYXXQ 构建选项说明

## 默认全量编译

```sh
make clean && make package
```

默认会启用所有 FLEX 可选模块：

```make
FLEX_ENABLE_DOKIT = 1
FLEX_ENABLE_DISASSEMBLER = 1
FLEX_ENABLE_CLASSDUMP = 1
FLEX_ENABLE_DECRYPT = 1
FLEX_ENABLE_FILZA = 1
```

适合开发、调试、完整功能验收。

## 推荐精简版

保留 FLEX 核心和 DoKit，关闭体积较大的调试工具：

```sh
make clean && make package \
  FLEX_ENABLE_DISASSEMBLER=0 \
  FLEX_ENABLE_CLASSDUMP=0 \
  FLEX_ENABLE_DECRYPT=0 \
  FLEX_ENABLE_FILZA=0
```

效果：

- 保留：FLEX 核心、DoKit、`flex_fishhook`
- 关闭：反汇编器 + capstone、ClassDump、解密/抓包工具、Filza/AppProtection/Shared
- 适合日常安装使用，调试能力保留一部分，包体更小

## 极简版

只保留 FLEX 核心入口，不编译额外工具模块：

```sh
make clean && make package \
  FLEX_ENABLE_DOKIT=0 \
  FLEX_ENABLE_DISASSEMBLER=0 \
  FLEX_ENABLE_CLASSDUMP=0 \
  FLEX_ENABLE_DECRYPT=0 \
  FLEX_ENABLE_FILZA=0
```

适合体积最敏感的发布场景；需要这些工具时再单独出调试包。

## 单个模块开关

也可以只关闭某一个模块：

```sh
make clean && make package FLEX_ENABLE_DISASSEMBLER=0
```

其他未指定的开关保持 Makefile 默认值 `1`。

## 注意事项

- 这些开关只影响 FLEX 调试模块编译，不影响 DYYY 主功能文件列表。
- 当前 `Makefile` 中 `DODKIT_FULL_BUILD=1` 与 `DORAEMON_FULL_BUILD=1` 仍然保留；减少包体主要靠上面的文件级 `filter-out` 和 capstone 条件编译。
- 建议每次修改开关后先 `make clean`，避免旧目标文件残留。
