require 'minitest/autorun'
require 'qbxml'

class XmlToHashTest < Minitest::Test

  def test_xml_to_hash
    qbxml = Qbxml.new
    h = {"qbxml"=>{"xml_attributes"=>{}, "qbxml_msgs_rq"=>{"xml_attributes"=>{}, "customer_query_rq"=>{"xml_attributes"=>{}, "list_id"=>"GUID-GOES-HERE"}}}}
    assert_equal h, qbxml.from_qbxml("<?qbxml version=\"7.0\"?>\n<QBXML>\n  <QBXMLMsgsRq>\n    <CustomerQueryRq>\n      <ListID>GUID-GOES-HERE</ListID>\n    </CustomerQueryRq>\n  </QBXMLMsgsRq>\n</QBXML>\n")
  end

end

