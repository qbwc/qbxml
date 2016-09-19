require 'minitest/autorun'
require 'qbxml'

class XmlToHashTest < Minitest::Test

  def test_xml_to_hash
    qbxml = Qbxml.new
    h = {"qbxml"=>{"xml_attributes"=>{}, "qbxml_msgs_rq"=>{"xml_attributes"=>{}, "customer_query_rq"=>{"xml_attributes"=>{}, "list_id"=>"GUID-GOES-HERE"}}}}
    assert_equal h, qbxml.from_qbxml("<?qbxml version=\"7.0\"?>\n<QBXML>\n  <QBXMLMsgsRq>\n    <CustomerQueryRq>\n      <ListID>GUID-GOES-HERE</ListID>\n    </CustomerQueryRq>\n  </QBXMLMsgsRq>\n</QBXML>\n")
  end

  def test_array_of_strings
    qbxml = Qbxml.new
    h = {
      "qbxml" => {
        "xml_attributes" => {},
        "qbxml_msgs_rq" => {
          "xml_attributes" => {},
          'invoice_query_rq' => {
            "xml_attributes" => {},
            'include_ret_element' => ['TxnID', 'RefNumber']
          }
        }
      }
    }
    assert_equal h, qbxml.from_qbxml("<?qbxml version=\"7.0\"?>\n<QBXML>\n  <QBXMLMsgsRq>\n    <InvoiceQueryRq>\n      <IncludeRetElement>TxnID</IncludeRetElement>\n    <IncludeRetElement>RefNumber</IncludeRetElement>\n    </InvoiceQueryRq>\n  </QBXMLMsgsRq>\n</QBXML>\n")
  end

  def test_array_with_one_element
    qbxml = Qbxml.new
    h = {
      "qbxml" => {
        "xml_attributes" => {},
        "qbxml_msgs_rs" => {
          "xml_attributes" => {},
          'customer_query_rs' => {
            "xml_attributes" => {},
            'customer_ret' => [{
              "xml_attributes"=> {},
              'list_id' => 'abc'
            }]
          }
        }
      }
    }
    assert_equal h, qbxml.from_qbxml("<?qbxml version=\"7.0\"?>\n<QBXML>\n  <QBXMLMsgsRs>\n    <CustomerQueryRs>\n      <CustomerRet><ListID>abc</ListID></CustomerRet>\n    </CustomerQueryRs>\n  </QBXMLMsgsRs>\n</QBXML>\n")
  end

  def test_float_percentage
    qbxml = Qbxml.new
    h = {
      "qbxml" => {
        "xml_attributes" => {},
        "qbxml_msgs_rs" => {
          "xml_attributes" => {},
          "item_query_rs" => {
            "xml_attributes" => {
              "requestID" => "Retrieve items",
              "statusCode" => "0",
              "statusSeverity" => "Info",
              "statusMessage" => "Status OK",
              "iteratorRemainingCount" => "0",
              "iteratorID" => "{10c05cbd-b25b-4a85-8aa0-8bce89e6e900}"
            },
            "item_service_ret" => {
              "xml_attributes" => {},
              "list_id" => "80000005-1468535148",
              "time_created" => "2016-07-14T15:25:48+00:00",
              "time_modified" => "2016-07-14T15:25:48+00:00",
              "edit_sequence" => "1468535148",
              "name" => "let's get intuit",
              "full_name" => "let's get intuit",
              "is_active" => true,
              "sublevel" => 0,
              "sales_or_purchase" => {
                "xml_attributes" => {},
                "price_percent" => 18.0,
                "account_ref" => {
                  "xml_attributes" => {},
                  "list_id" => "80000015-1457547358",
                  "full_name" => "Repairs and Maintenance"
                }
              }
            }
          }
        }
      }
    }

    xml = <<-XML
      <QBXML>
        <QBXMLMsgsRs>
          <ItemQueryRs requestID="Retrieve items"
                       statusCode="0"
                       statusSeverity="Info"
                       statusMessage="Status OK"
                       iteratorRemainingCount="0"
                       iteratorID="{10c05cbd-b25b-4a85-8aa0-8bce89e6e900}">
            <ItemServiceRet>
              <ListID>80000005-1468535148</ListID>
              <TimeCreated>2016-07-14T15:25:48+00:00</TimeCreated>
              <TimeModified>2016-07-14T15:25:48+00:00</TimeModified>
              <EditSequence>1468535148</EditSequence>
              <Name>let's get intuit</Name>
              <FullName>let's get intuit</FullName>
              <IsActive>true</IsActive>
              <Sublevel>0</Sublevel>
              <SalesOrPurchase>
                <PricePercent>18.0%</PricePercent>
                <AccountRef>
                  <ListID>80000015-1457547358</ListID>
                  <FullName>Repairs and Maintenance</FullName>
                </AccountRef>
              </SalesOrPurchase>
            </ItemServiceRet>
          </ItemQueryRs>
        </QBXMLMsgsRs>
      </QBXML>
    XML

    assert_equal h, qbxml.from_qbxml(xml)
  end

end
