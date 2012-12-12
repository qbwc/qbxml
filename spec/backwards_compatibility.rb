require 'spec_helper'
require 'quickbooks'

describe Qbxml do
  context 'backwards compatibility with the quickbooks_api gem' do

    let(:qb_old) { Quickbooks::API[:qb] }
    let(:qb_new) { Qbxml.new(:qb) }

    it 'should produce the same results when parsing qbxml/hash data' do
      (requests + responses).each do |data|
        old_parse = qb_old.qbxml_to_hash(data, true) 

        new_parse1 = qb_new.from_qbxml(data)
        new_parse1.should == { 'qbxml' => old_parse }

        # XML is a pain to compare so we can compare the parsed hash resulting
        # from the generated XML instead.
        #
        new_parse2 =  qb_new.from_qbxml(qb_new.to_qbxml(new_parse1))
        new_parse2.should == { 'qbxml' => old_parse }
      end
    end

  end
end
