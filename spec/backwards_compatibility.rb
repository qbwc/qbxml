require 'spec_helper'
require 'quickbooks'

describe Qbxml do
  context 'backwards compatibility with the quickbooks_api gem' do

    let(:qb_old) { Quickbooks::API[:qb] }
    let(:qb_new) { Qbxml.new(:qb) }

    it 'should produce the same hashes when parsing qbxml requests' do
      requests.each do |req|
        qb_new.from_qbxml(req).should == {'qbxml' => qb_old.qbxml_to_hash(req, true)}
      end
    end

    it 'should produce the same hashes when parsing qbxml responses' do
      responses.each do |res|
        qb_new.from_qbxml(res).should == {'qbxml' => qb_old.qbxml_to_hash(res, true)}
      end
    end

  end
end
