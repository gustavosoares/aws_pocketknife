require 'rspec'
require 'spec_helper'

describe AwsPocketknife::Cli::Route53 do

  let(:hosted_zone) {'example.com.'}
  let(:record_name) {'abc.example.com'}
  let(:record_type) {'AAAA'}


  describe '#describe_hosted_zone' do

    it 'should call describe_hosted_zone with right arguments' do

      allow(AwsPocketknife::Route53).to receive(:describe_hosted_zone).with(hosted_zone: hosted_zone)
      expect(AwsPocketknife::Route53).to receive(:describe_hosted_zone).with(hosted_zone: hosted_zone)

      subject.describe_hosted_zone hosted_zone

    end

  end

  describe '#list' do

    it 'should call list with right arguments' do

      allow(AwsPocketknife::Route53).to receive(:list_hosted_zones).and_return([])
      expect(AwsPocketknife::Route53).to receive(:list_hosted_zones)

      subject.list

    end

  end

  describe '#list_records' do

    it 'should call list_records with right arguments and get back an empty list of records' do

      allow(AwsPocketknife::Route53).to receive(:list_records_for_zone_name).with(hosted_zone_name: hosted_zone).and_return([])
      expect(AwsPocketknife::Route53).to receive(:list_records_for_zone_name).with(hosted_zone_name: hosted_zone)

      subject.list_records hosted_zone

    end

  end

  describe '#get_record' do

    it 'should call get_record without record_type argument and get back an empty list' do

      allow(AwsPocketknife::Route53).to receive(:get_record).with(hosted_zone_name: hosted_zone,
                                                                  record_name:record_name,
                                                                  record_type: 'A').and_return([])
      expect(AwsPocketknife::Route53).to receive(:get_record).with(hosted_zone_name: hosted_zone,
                                                                  record_name:record_name,
                                                                  record_type: 'A')

      subject.get_record hosted_zone, record_name

    end

    it 'should call get_record with record_type argument and get back an empty list' do

      allow(AwsPocketknife::Route53).to receive(:get_record).with(hosted_zone_name: hosted_zone,
                                                                  record_name:record_name,
                                                                  record_type: record_type).and_return([])
      expect(AwsPocketknife::Route53).to receive(:get_record).with(hosted_zone_name: hosted_zone,
                                                                   record_name:record_name,
                                                                   record_type: record_type)

      subject.get_record hosted_zone, record_name, record_type

    end

  end

  describe '#update_record' do

    let (:origin_dns_name) {'origin.example.com'}
    let (:destiny_dns_name) {'destiny.example.com'}
    let (:destiny_hosted_zone) {'example2.com'}

    it 'should call update_record with right arguments' do

      allow(AwsPocketknife::Route53).to receive(:update_record).with(origin_hosted_zone: hosted_zone,
                                                                     origin_dns_name: origin_dns_name,
                                                                     record_type: 'A',
                                                                     destiny_dns_name: destiny_dns_name,
                                                                     destiny_hosted_zone: destiny_hosted_zone)
      expect(AwsPocketknife::Route53).to receive(:update_record).with(origin_hosted_zone: hosted_zone,
                                                                     origin_dns_name: origin_dns_name,
                                                                     record_type: 'A',
                                                                     destiny_dns_name: destiny_dns_name,
                                                                     destiny_hosted_zone: destiny_hosted_zone)

      subject.update_record hosted_zone, origin_dns_name, destiny_dns_name, destiny_hosted_zone

    end

  end

end
