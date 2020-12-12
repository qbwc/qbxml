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

  def test_bigdecimal
    injected_time = Time.now.strftime("%Y-%m-%dT%H:%M:%S%:z")

    qbxml = Qbxml.new
    h = {
      "qbxml" => {
        "xml_attributes" => {},
        "qbxml_msgs_rs"=> {
          "xml_attributes" => {},
          "sales_receipt_add_rs" => {
            "xml_attributes" => {
              "statusCode" => "0",
              "statusSeverity" => "Info",
              "statusMessage" => "Status OK"
            },
            "sales_receipt_ret" => {
              "xml_attributes" => {},
              "txn_id" => "1C0-1433857054",
              "time_created" => injected_time,
              "time_modified" => injected_time,
              "edit_sequence" => "1433850554",
              "txn_number" => 89,
              "customer_ref" => {
                "xml_attributes" => {},
                "list_id" => "80000013-1433852150",
                "full_name" => "custfullname"
              },
              "template_ref" => {
                "xml_attributes" => {},
                "list_id" => "80000009-1433199758",
                "full_name" => "Custom Sales Receipt"
              },
              "txn_date" => "2019-06-09",
              "ref_number" => "1040000529",
              "is_pending" => false,
              "payment_method_ref" => {
                "xml_attributes" => {},
                "list_id" => "8000000A-1433718272",
                "full_name" => "paymentmethod"
              },
              "due_date" => "2019-06-09",
              "ship_date" => "2019-06-09",
              "subtotal" => 0.2,
              "item_sales_tax_ref" => {
                "xml_attributes" => {},
                "list_id" => "80000009-1433719484",
                "full_name" => "Tax agency"
              },
              "sales_tax_percentage" => 8.25,
              "sales_tax_total" => 0.02,
              "total_amount" => 0.22,
              "is_to_be_printed" => true,
              "is_to_be_emailed" => false,
              "customer_sales_tax_code_ref" => {
                "xml_attributes" => {},
                "list_id" => "80000002-1403304324",
                "full_name" => "Non"
              },
              "deposit_to_account_ref" => {
                "xml_attributes" => {},
                "list_id" => "8000003D-1433719666",
                "full_name" => "Undeposited Funds"
              },
              "sales_receipt_line_ret" => {
                "xml_attributes" => {},
                "txn_line_id" => "1C2-1433632154",
                "item_ref" => {
                  "xml_attributes" => {},
                  "list_id" => "8000001F-1433854453",
                  "full_name" => "ABCD0000"
                },
                "desc" => "description",
                "quantity" => 0.2,
                "rate" => 1.0,
                "amount" => 0.2,
                "service_date" => "2019-06-09",
                "sales_tax_code_ref"=> {
                  "xml_attributes" => {},
                  "list_id" => "80000001-1403304324",
                  "full_name"=>"Tax"
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
          <SalesReceiptAddRs statusCode="0" statusSeverity="Info" statusMessage="Status OK">
              <SalesReceiptRet>
                <TxnID>1C0-1433857054</TxnID>
                <TimeCreated>#{injected_time}</TimeCreated>
                <TimeModified>#{injected_time}</TimeModified>
                <EditSequence>1433850554</EditSequence>
                <TxnNumber>89</TxnNumber>
                <CustomerRef>
                  <ListID>80000013-1433852150</ListID>
                  <FullName>custfullname</FullName>
                </CustomerRef>
                <TemplateRef>
                  <ListID>80000009-1433199758</ListID>
                  <FullName>Custom Sales Receipt</FullName>
                </TemplateRef>
                <TxnDate>2019-06-09</TxnDate>
                <RefNumber>1040000529</RefNumber>
                <IsPending>false</IsPending>
                <PaymentMethodRef>
                  <ListID>8000000A-1433718272</ListID>
                  <FullName>paymentmethod</FullName>
                </PaymentMethodRef>
                <DueDate>2019-06-09</DueDate>
                <ShipDate>2019-06-09</ShipDate>
                <Subtotal>0.20</Subtotal>
                <ItemSalesTaxRef>
                  <ListID>80000009-1433719484</ListID>
                  <FullName>Tax agency</FullName>
                </ItemSalesTaxRef>
                <SalesTaxPercentage>8.25</SalesTaxPercentage>
                <SalesTaxTotal>0.02</SalesTaxTotal>
                <TotalAmount>0.22</TotalAmount>
                <IsToBePrinted>true</IsToBePrinted>
                <IsToBeEmailed>false</IsToBeEmailed>
                <CustomerSalesTaxCodeRef>
                  <ListID>80000002-1403304324</ListID>
                  <FullName>Non</FullName>
                </CustomerSalesTaxCodeRef>
                <DepositToAccountRef>
                  <ListID>8000003D-1433719666</ListID>
                  <FullName>Undeposited Funds</FullName>
                </DepositToAccountRef>
                <SalesReceiptLineRet>
                  <TxnLineID>1C2-1433632154</TxnLineID>
                  <ItemRef>
                    <ListID>8000001F-1433854453</ListID>
                    <FullName>ABCD0000</FullName>
                  </ItemRef>
                  <Desc>description</Desc>
                  <Quantity>0.2</Quantity>
                  <Rate>1.00</Rate>
                  <Amount>0.20</Amount>
                  <ServiceDate>2019-06-09</ServiceDate>
                  <SalesTaxCodeRef>
                    <ListID>80000001-1403304324</ListID>
                    <FullName>Tax</FullName>
                  </SalesTaxCodeRef>
                </SalesReceiptLineRet>
              </SalesReceiptRet>
          </SalesReceiptAddRs>
        </QBXMLMsgsRs>
      </QBXML>
    XML

    assert_equal h, qbxml.from_qbxml(xml)
  end
end
