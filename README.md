# Translator for virtual address to physical address

This is the second project of CS2106 (Operating Systems).

## Building

```ruby
bundle
```

## Usage

There are various test cases in `test_files/`. 
Two input files are required; one to initialize the physical memory, and the
other is a series of read/write operations of virtual addresses.

Optional modifiers:

* `--enable-tlb`: Enable the translation look-aside buffer
* `--verbose`: Verbose output that shows the breakdown of the virtual address
  components and operations.

```shell
ruby app.rb --config configuration.txt --input virtual_addresses.rb [--enable-tlb] [--verbose] > output.txt
```

## Explanation

Each virtual address is a 32-bit integer. It is broken down, from the LSB,
accordingly:

Bits [0-9]: offset
Bits [10-19]: page
Bits [19-28]: segment

The physical memory is represented by 1024 frames of 512 words each. The
segment table lives in the first frame, i.e. frame 0 ~ physical address 0 to
511

Page tables take up 2 consecutive frames and pages take up 1 frame.

Free frames are seeked in a left-to-right basis, starting from frame 1.

`app.rb` is the main IO driver of the program, while `physical_memory_manager.rb` 
manages the read/write operations.
