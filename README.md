# Qbxml

[![Build Status](https://travis-ci.org/qbwc/qbxml.svg?branch=master)](https://travis-ci.org/qbwc/qbxml)

Qbxml is a QBXML parser and validation tool.

## Installation

Add this line to your application's Gemfile:

    gem 'qbxml'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install qbxml

## Usage

### Initialization

The QBXML supported depends on whether you use QuickBooks (`:qb`) or
QuickBooks Point of Sale (`:qbpos`) and on the version of QuickBooks used.

```ruby
q = Qbxml.new(:qb, '7.0')
```

### API Introspection

Return all types defined in the schema

```ruby
q.types
```

Return all types matching a certain pattern

```ruby
q.types('Customer')

q.types(/Customer/)
```

Print the xml template for a specific type

```ruby
puts q.describe('CustomerModRq')
```

### QBXML To Ruby

Convert valid QBXML to a ruby hash

```ruby
q.from_qbxml(xml)
```

### Ruby To QBXML

Convert a ruby hash to QBXML, skipping validation

```ruby
q.to_qbxml(hsh)
```

Convert a ruby hash to QBXML and validate all types

```ruby
q.to_qbxml(hsh, validate: true)
```

## Caveats

QuickBooks only supports [ISO-8859-1](http://en.wikipedia.org/wiki/ISO/IEC_8859-1) characters. Any characters outside of ISO-8859-1 will become question marks in QuickBooks.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
