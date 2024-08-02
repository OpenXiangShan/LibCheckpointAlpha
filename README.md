# LibCheckpointAlpha

LibCheckpointAlpha is a transitional version of LibCheckpoint(https://github.com/OpenXiangShan/LibCheckpoint), currently offers two uses, one for restore checkpoint, and the other for linking the next level bootloader (riscv-pk or opensbi)

## restore checkpoint

using the following command to build gcpt.bin, which could overwrite 0x80000000 ~ sizeof(gcpt.bin) during restore checkpoint process

```bash
make clean && make
```

## link the next level bootloader

using the following command to build gcpt.bin, which could link next level bootloader, then gcpt.bin can be used boot directly

```
make clean && make GCPT_PAYLOAD_PATH=/path/to/bbl.bin
```

### ISAs support

- rv64gcbkhv
