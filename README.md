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
xml = %Q(
  <?qbxml version="2.0"?>
  <QBXML>
    <QBXMLMsgsRq onError="stopOnError">
      <CustomerAddRq requestID="15">
        <CustomerAdd>
          <Name>20706 - Eastern XYZ University</Name>
          <CompanyName>Eastern XYZ University</CompanyName>
          <FirstName>Keith</FirstName>
          <LastName>Palmer</LastName>
          <BillAddress>
            <Addr1>Eastern XYZ University</Addr1>
            <Addr2>College of Engineering</Addr2>
            <Addr3>123 XYZ Road</Addr3>
            <City>Storrs-Mansfield</City>
            <State>CT</State>
            <PostalCode>06268</PostalCode>
            <Country>United States</Country>
          </BillAddress>
          <Phone>860-634-1602</Phone>
          <AltPhone>860-429-0021</AltPhone>
          <Fax>860-429-5183</Fax>
          <Email>keith@consolibyte.com</Email>
          <Contact>Keith Palmer</Contact>
        </CustomerAdd>
      </CustomerAddRq>
    </QBXMLMsgsRq>
  </QBXML> )


q.from_qbxml(xml)

{"qbxml"=>
 {"qbxml_msgs_rq"=>
   {"customer_add_rq"=>
     {"customer_add"=>
       {"name"=>"20706 - Eastern XYZ University",
        "company_name"=>"Eastern XYZ University",
        "first_name"=>"Keith",
        "last_name"=>"Palmer",
        "bill_address"=>
         {"addr1"=>"Eastern XYZ University",
          "addr2"=>"College of Engineering",
          "addr3"=>"123 XYZ Road",
          "city"=>"Storrs-Mansfield",
          "state"=>"CT",
          "postal_code"=>"06268",
          "country"=>"United States"},
        "phone"=>"860-634-1602",
        "alt_phone"=>"860-429-0021",
        "fax"=>"860-429-5183",
        "email"=>"keith@consolibyte.com",
        "contact"=>"Keith Palmer"},
      :xml_attributes=>{"requestID"=>"15"}},
    :xml_attributes=>{"onError"=>"stopOnError"}}}}
```
### Ruby To QBXML

Convert a ruby hash to QBXML, skipping validation

    q.to_qbxml(hash)

Convert a ruby hash to QBXML and validate all types

    q.to_qbxml(hash, validate: true)

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
