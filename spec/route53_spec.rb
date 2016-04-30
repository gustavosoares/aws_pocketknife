require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/route53'

describe AwsPocketknife::Route53 do

  describe '#get_hosted_zone_id' do
    it 'should get hosted zone id' do
      hosted_zone = "/hostedzone/ABC"
      expect(AwsPocketknife::Route53.get_hosted_zone_id(hosted_zone: hosted_zone)).to eq("ABC")
    end
  end

  describe '#list_hosted_zones' do
    it 'should list hosted zones' do
      expect_any_instance_of(Aws::Route53::Client).to receive(:list_hosted_zones)
      AwsPocketknife::Route53.list_hosted_zones
    end
  end

  describe '#list_records_for_zone_name' do
    it 'should return an empty []' do
      allow(AwsPocketknife::Route53).to receive(:describe_hosted_zone).and_return(nil)
      expect(AwsPocketknife::Route53.list_records_for_zone_name(hosted_zone_name: "test")).to eq([])
    end

    it 'should list_records_for_zone_name for record type in ["A", "CNAME", "AAAA"]' do

      hosted_zone_name = "test"
      hosted_zone_id = "ABC"
      aws_hosted_zone_response = RecursiveOpenStruct.new({id: hosted_zone_id}, recurse_over_arrays: true)
      aws_records_response = RecursiveOpenStruct.new({resource_record_sets: [
          {name: "example1.com", type: "A"},
          {name: "example2.com", type: "CNAME"},
          {name: "example3.com", type: "AAAA"}
      ]}, recurse_over_arrays: true)

      allow(AwsPocketknife::Route53).to receive(:describe_hosted_zone).and_return(aws_hosted_zone_response)

      allow(AwsPocketknife::Route53).to receive(:get_hosted_zone_id)
                                            .with(hosted_zone: hosted_zone_id).and_return(hosted_zone_id)

      allow_any_instance_of(Aws::Route53::Client).to receive(:list_resource_record_sets)
                                                         .with({hosted_zone_id: hosted_zone_id})
                                                         .and_return(aws_records_response)

      records = AwsPocketknife::Route53.list_records_for_zone_name(hosted_zone_name: hosted_zone_name)

      expect(records.length).to eq(3)
      i = 0
      records.each do |record|
        expect(record.name).to eq(aws_records_response.resource_record_sets[i].name)
        i = i + 1
      end

    end

    it 'should return empty array for record type not in ["A", "CNAME", "AAAA"]' do

      hosted_zone_name = "test"
      hosted_zone_id = "ABC"
      aws_hosted_zone_response = RecursiveOpenStruct.new({id: hosted_zone_id}, recurse_over_arrays: true)
      aws_records_response = RecursiveOpenStruct.new({resource_record_sets: [
          {name: "example1.com", type: "SOA"},
          {name: "example2.com", type: "NS"},
          {name: "example3.com", type: "TXT"}
      ]}, recurse_over_arrays: true)

      allow(AwsPocketknife::Route53).to receive(:describe_hosted_zone).and_return(aws_hosted_zone_response)

      allow(AwsPocketknife::Route53).to receive(:get_hosted_zone_id)
                                            .with(hosted_zone: hosted_zone_id).and_return(hosted_zone_id)

      allow_any_instance_of(Aws::Route53::Client).to receive(:list_resource_record_sets)
                                                         .with({hosted_zone_id: hosted_zone_id})
                                                         .and_return(aws_records_response)

      records = AwsPocketknife::Route53.list_records_for_zone_name(hosted_zone_name: hosted_zone_name)

      expect(records.length).to eq(0)

    end

  end


end