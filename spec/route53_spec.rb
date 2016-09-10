require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/route53'

describe AwsPocketknife::Route53 do

  let(:route53_client) {instance_double(Aws::Route53::Client)}

  before (:each) do
    allow(AwsPocketknife::Route53).to receive(:route53_client).and_return(route53_client)
  end

  describe '#get_hosted_zone_id' do
    it 'should get hosted zone id' do
      hosted_zone = "/hostedzone/ABC"
      expect(subject.get_hosted_zone_id(hosted_zone: hosted_zone)).to eq("ABC")
    end
  end

  describe '#list_hosted_zones' do
    it 'should list hosted zones' do
      allow(route53_client).to receive(:list_hosted_zones)
      expect(route53_client).to receive(:list_hosted_zones)
      subject.list_hosted_zones
    end
  end

  describe '#get_record' do

    it 'should return find record and return its object' do

      hosted_zone_name = "test"
      hosted_zone_id = "ABC"
      record_name = "example2.com"
      record_type = "A"

      aws_hosted_zone_response = get_aws_response({id: hosted_zone_id})
      aws_records_response = get_aws_response({resource_record_sets: [
          {name: "example1.com", type: "A"},
          {name: "example2.com", type: "A"},
      ]})

      allow(subject).to receive(:describe_hosted_zone).and_return(aws_hosted_zone_response)

      allow(subject).to receive(:get_hosted_zone_id)
                                            .with(hosted_zone: hosted_zone_id).and_return(hosted_zone_id)

      allow(route53_client).to receive(:list_resource_record_sets)
                                                         .with({hosted_zone_id: hosted_zone_id,
                                                                start_record_name: record_name,
                                                                start_record_type: record_type,
                                                                max_items: 1,
                                                               })
                                                         .and_return(aws_records_response)

      record = subject.get_record(hosted_zone_name: hosted_zone_name, record_name: record_name, record_type: record_type)
      expect(record.length).to eq(1)
      expect(record[0].name).to eq(record_name)

    end

    it 'should return empty array when record is not found' do

      hosted_zone_name = "test"
      hosted_zone_id = "ABC"
      record_name = "example3.com"
      record_type = "A"

      aws_hosted_zone_response = get_aws_response({id: hosted_zone_id})
      aws_records_response = get_aws_response({resource_record_sets: [
          {name: "example1.com", type: "A"},
          {name: "example2.com", type: "A"},
      ]})

      allow(subject).to receive(:describe_hosted_zone).and_return(aws_hosted_zone_response)

      allow(subject).to receive(:get_hosted_zone_id)
                                            .with(hosted_zone: hosted_zone_id).and_return(hosted_zone_id)

      allow(route53_client).to receive(:list_resource_record_sets)
                                                         .with({hosted_zone_id: hosted_zone_id,
                                                                start_record_name: record_name,
                                                                start_record_type: record_type,
                                                                max_items: 1,
                                                               })
                                                         .and_return(aws_records_response)

      record = subject.get_record(hosted_zone_name: hosted_zone_name, record_name: record_name, record_type: record_type)
      expect(record.length).to eq(0)
      expect(record).to eq([])

    end

  end

  describe '#list_records_for_zone_name' do
    it 'should return an empty []' do
      allow(subject).to receive(:describe_hosted_zone).and_return(nil)
      expect(subject.list_records_for_zone_name(hosted_zone_name: "test")).to eq([])
    end

    it 'should list_records_for_zone_name for record type in ["A", "CNAME", "AAAA"]' do

      hosted_zone_name = "test"
      hosted_zone_id = "ABC"
      aws_hosted_zone_response = get_aws_response({id: hosted_zone_id})
      aws_records_response = get_aws_response({resource_record_sets: [
          {name: "example1.com", type: "A"},
          {name: "example2.com", type: "CNAME"},
          {name: "example3.com", type: "AAAA"}
      ]})

      allow(subject).to receive(:describe_hosted_zone).and_return(aws_hosted_zone_response)

      allow(subject).to receive(:get_hosted_zone_id)
                                            .with(hosted_zone: hosted_zone_id).and_return(hosted_zone_id)

      allow(route53_client).to receive(:list_resource_record_sets)
                                                         .with({hosted_zone_id: hosted_zone_id})
                                                         .and_return(aws_records_response)

      records = subject.list_records_for_zone_name(hosted_zone_name: hosted_zone_name)

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

      allow(subject).to receive(:describe_hosted_zone).and_return(aws_hosted_zone_response)

      allow(subject).to receive(:get_hosted_zone_id)
                                            .with(hosted_zone: hosted_zone_id).and_return(hosted_zone_id)

      allow(route53_client).to receive(:list_resource_record_sets)
                                                         .with({hosted_zone_id: hosted_zone_id})
                                                         .and_return(aws_records_response)

      records = subject.list_records_for_zone_name(hosted_zone_name: hosted_zone_name)

      expect(records.length).to eq(0)

    end

  end

  describe '#update_record' do

    it 'should update alias record from existing dns record' do

      origin_hosted_zone = "ABC"
      origin_dns_name = "example.com"
      record_type = "A"
      destiny_dns_name ="example2.com"
      destiny_hosted_zone = "ABCD"

      comment = ""
      hosted_zone_id = "id"
      destiny_hosted_zone_id = "id"

      change = {
          action: "UPSERT",
          resource_record_set: {
              name: origin_dns_name,
              type: record_type,
              alias_target: {
                  hosted_zone_id: destiny_hosted_zone_id, # required
                  dns_name: "dualstack." + destiny_dns_name, # required
                  evaluate_target_health: false, # required
              }
          }
      }

      payload = {
          hosted_zone_id: hosted_zone_id,
          change_batch: {
              comment: comment,
              changes: [change]
          }

      }

      aws_response_1 = get_aws_response({id: hosted_zone_id})
      aws_response_2 = get_aws_response({
                                            alias_target:
                                                {
                                                    hosted_zone_id: "id", dns_name: origin_dns_name},
                                                    resource_records: [{value: origin_dns_name}]
                                        })
      aws_response_3 = get_aws_response({alias_target: {hosted_zone_id: "id", dns_name: destiny_dns_name}})

      expect(subject).to receive(:describe_hosted_zone)
                      .with(hosted_zone: origin_hosted_zone)
                      .and_return(aws_response_1)

      expect(subject).to receive(:get_record)
                                             .with(hosted_zone_name: origin_hosted_zone,
                                                   record_name: origin_dns_name,
                                                   record_type: record_type)
                                             .and_return([aws_response_2])

      expect(subject).to receive(:get_record)
                                             .with(hosted_zone_name: destiny_hosted_zone,
                                                   record_name: destiny_dns_name,
                                                   record_type: record_type)
                                             .and_return([aws_response_3])

      allow(route53_client).to receive(:change_resource_record_sets).with(payload)

      subject.update_record(origin_hosted_zone: origin_hosted_zone,
                                            origin_dns_name: origin_dns_name,
                                            record_type: record_type,
                                            destiny_dns_name: destiny_dns_name,
                                            destiny_hosted_zone: destiny_hosted_zone
      )
    end

    it 'should not update alias record when both dns are the same' do

      origin_hosted_zone = "ABC"
      origin_dns_name = "example.com"
      record_type = "A"
      destiny_dns_name ="example.com"
      destiny_hosted_zone = "ABCD"

      comment = ""
      hosted_zone_id = "id"
      destiny_hosted_zone_id = "id"

      change = {
          action: "UPSERT",
          resource_record_set: {
              name: origin_dns_name,
              type: record_type,
              alias_target: {
                  hosted_zone_id: destiny_hosted_zone_id, # required
                  dns_name: destiny_dns_name, # required
                  evaluate_target_health: false, # required
              }
          }
      }

      payload = {
          hosted_zone_id: hosted_zone_id,
          change_batch: {
              comment: comment,
              changes: [change]
          }

      }

      aws_response_1 = get_aws_response({id: hosted_zone_id})
      aws_response_2 = get_aws_response({
                                            alias_target:
                                                {
                                                    hosted_zone_id: "id", dns_name: origin_dns_name},
                                            resource_records: [{value: origin_dns_name}]
                                        })
      aws_response_3 = get_aws_response({alias_target: {hosted_zone_id: "id", dns_name: destiny_dns_name}})

      expect(subject).to receive(:describe_hosted_zone)
                                             .with(hosted_zone: origin_hosted_zone)
                                             .and_return(aws_response_1)

      expect(subject).to receive(:get_record)
                                             .with(hosted_zone_name: origin_hosted_zone,
                                                   record_name: origin_dns_name,
                                                   record_type: record_type)
                                             .and_return([aws_response_2])

      expect(subject).to receive(:get_record)
                                             .with(hosted_zone_name: destiny_hosted_zone,
                                                   record_name: destiny_dns_name,
                                                   record_type: record_type)
                                             .and_return([aws_response_3])

      expect(route53_client).not_to receive(:change_resource_record_sets).with(payload)

      subject.update_record(origin_hosted_zone: origin_hosted_zone,
                                            origin_dns_name: origin_dns_name,
                                            record_type: record_type,
                                            destiny_dns_name: destiny_dns_name,
                                            destiny_hosted_zone: destiny_hosted_zone
      )
    end

    it 'should update CNAME record given a dns name' do

      origin_hosted_zone = "ABC"
      origin_dns_name = "example.com"
      record_type = "CNAME"
      destiny_dns_name ="example2.com"
      destiny_hosted_zone = ""

      comment = ""
      hosted_zone_id = "id"

      change = {
          action: "UPSERT",
          resource_record_set: {
              name: origin_dns_name,
              type: record_type,
              ttl: 300,
              resource_records: [{value: destiny_dns_name}]
          }
      }

      payload = {
          hosted_zone_id: hosted_zone_id,
          change_batch: {
              comment: comment,
              changes: [change]
          }

      }

      aws_response_1 = get_aws_response({id: hosted_zone_id})
      aws_response_2 = get_aws_response({alias_target:
                                                {
                                                    hosted_zone_id: "id", dns_name: origin_dns_name},
                                                    resource_records: [{value: origin_dns_name}]
                                        })

      expect(subject).to receive(:describe_hosted_zone)
                                             .with(hosted_zone: origin_hosted_zone)
                                             .and_return(aws_response_1)

      expect(subject).to receive(:get_record)
                                             .with(hosted_zone_name: origin_hosted_zone,
                                                   record_name: origin_dns_name,
                                                   record_type: record_type)
                                             .and_return([aws_response_2])

      allow(route53_client).to receive(:change_resource_record_sets).with(payload)
      expect(route53_client).to receive(:change_resource_record_sets).with(payload)

      subject.update_record(origin_hosted_zone: origin_hosted_zone,
                                            origin_dns_name: origin_dns_name,
                                            record_type: record_type,
                                            destiny_dns_name: destiny_dns_name,
                                            destiny_hosted_zone: destiny_hosted_zone
      )
    end

    it 'should not update CNAME if origin and destiny dns are the same' do

      origin_hosted_zone = "ABC"
      origin_dns_name = "example.com"
      record_type = "CNAME"
      destiny_dns_name ="example.com"
      destiny_hosted_zone = ""

      comment = ""
      hosted_zone_id = "id"

      change = {
          action: "UPSERT",
          resource_record_set: {
              name: origin_dns_name,
              type: record_type,
              ttl: 300,
              resource_records: [{value: destiny_dns_name}]
          }
      }

      payload = {
          hosted_zone_id: hosted_zone_id,
          change_batch: {
              comment: comment,
              changes: [change]
          }

      }

      aws_response_1 = get_aws_response({id: hosted_zone_id})
      aws_response_2 = get_aws_response({
                                            alias_target:
                                                {
                                                    hosted_zone_id: "id", dns_name: origin_dns_name},
                                                    resource_records: [{value: origin_dns_name}]
                                        })

      expect(subject).to receive(:describe_hosted_zone)
                                             .with(hosted_zone: origin_hosted_zone)
                                             .and_return(aws_response_1)

      expect(subject).to receive(:get_record)
                                             .with(hosted_zone_name: origin_hosted_zone,
                                                   record_name: origin_dns_name,
                                                   record_type: record_type)
                                             .and_return([aws_response_2])

      expect(route53_client).not_to receive(:change_resource_record_sets).with(payload)

      result = subject.update_record(origin_hosted_zone: origin_hosted_zone,
                                                     origin_dns_name: origin_dns_name,
                                                     record_type: record_type,
                                                     destiny_dns_name: destiny_dns_name,
                                                     destiny_hosted_zone: destiny_hosted_zone
      )

      expect(result).to eq(false)
    end

  end

end