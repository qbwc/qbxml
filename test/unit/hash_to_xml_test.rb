require 'minitest/autorun'
require 'qbxml'

class HashToXmlTest < Minitest::Test

  def test_hash_to_xml_customer_query
    qbxml = Qbxml.new
    assert_equal "<?qbxml version=\"7.0\"?>\n<QBXML>\n  <QBXMLMsgsRq>\n    <CustomerQueryRq>\n      <ListID>GUID-GOES-HERE</ListID>\n    </CustomerQueryRq>\n  </QBXMLMsgsRq>\n</QBXML>\n", qbxml.to_qbxml({:qbxml => {:qbxml_msgs_rq => {:customer_query_rq => {:list_id => 'GUID-GOES-HERE'}}}})
  end

  def test_hash_to_xml_invoice_mod
    qbxml = Qbxml.new
    xml = <<-EOF
<?qbxml version="7.0"?>
<QBXML>
  <QBXMLMsgsRq>
    <InvoiceModRq>
      <InvoiceMod>
        <TxnID>1929B9-1423150873</TxnID>
        <EditSequence/>
        <CustomerRef>
          <ListID>4A50001-1013529664</ListID>
        </CustomerRef>
        <TxnDate>2015-01-28</TxnDate>
        <RefNumber>12345678</RefNumber>
        <Memo></Memo>
        <InvoiceLineMod>
          <TxnLineID>-1</TxnLineID>
          <ItemRef>
            <FullName>Sales</FullName>
          </ItemRef>
          <Desc>Contract 123</Desc>
          <Quantity>23.44165</Quantity>
          <Rate>515.0</Rate>
          <SalesTaxCodeRef>
            <FullName>E</FullName>
          </SalesTaxCodeRef>
        </InvoiceLineMod>
      </InvoiceMod>
    </InvoiceModRq>
  </QBXMLMsgsRq>
</QBXML>
    EOF
    assert_equal xml, qbxml.to_qbxml({:invoice_mod_rq=>{:invoice_mod=>{:txn_id=>"1929B9-1423150873", :edit_sequence=>nil, :customer_ref=>{:list_id=>"4A50001-1013529664"}, :txn_date=>"2015-01-28", :ref_number=>"12345678", :memo=>"", :invoice_line_mod=>[{:txn_line_id=>-1, :item_ref=>{:full_name=>"Sales"}, :desc=>"Contract 123", :quantity=>"23.44165", :rate=> 515.0, :sales_tax_code_ref=>{:full_name=>"E"}}]}}})
  end

  def test_array_of_strings
    assert_equal "<foo>\n  <bar>baz</bar>\n  <bar>guh</bar>\n</foo>\n", Qbxml::Hash.to_xml({:foo => {:bar => ['baz', 'guh']}}, {skip_instruct: true})
  end

end
