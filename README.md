# Translator for virtual address to physical address

## Building

```ruby
bundle
```

## Usage

There are various test cases in `test_files/`. 

```shell
ruby app.rb < test_files/input > test_files/actual_output
diff test_files/actual_output test_files/expected_output
```
