# Qbxml

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

The parser can be initialized to either Quickbooks (:qb) or Quickbooks Point of
Sale (:qbpos)

```ruby
q = Qbxml.new(:qb)
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

    puts q.describe('CustomerModRq')

### QBXML To Ruby

Convert valid QBXML to a ruby hash

```ruby
q.from_qbxml(xml)
```

### Ruby To QBXML

Convert a ruby hash to QBXML, skipping validation

```ruby
q.to_qbxml(hash)
```

Convert a ruby hash to QBXML and validate all types

```ruby
q.to_qbxml(hash, validate: true)
```

## Caveats

Correct case conversion depends on the following ActiveSupport inflection
setting.

    ActiveSupport::Inflector.inflections do |inflect|
      inflect.acronym 'QBXML'
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
