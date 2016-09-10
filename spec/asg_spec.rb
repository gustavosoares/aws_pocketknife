require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/asg'

describe AwsPocketknife::Asg do

  let(:asg_client) {instance_double(Aws::AutoScaling::Client)}

  before (:each) do
    allow(subject).to receive(:asg_client).and_return(asg_client)
  end

  describe '#describe_asg_by_name' do

    it 'should return list with the searched asg' do

      asg_name = "asg"
      asg_list = [asg_name]

      aws_response = get_aws_response({auto_scaling_groups: [
          {auto_scaling_group_name: asg_name}
      ]})

      allow(asg_client).to receive(:describe_auto_scaling_groups)
                                                      .with({
                                                                auto_scaling_group_names: asg_list,
                                                            }).and_return(aws_response)

      asgs = subject.describe_asg_by_name(name: asg_name)

      expect(asgs.length).to eq(1)
      expect(asgs[0].auto_scaling_group_name).to eq(asg_name)

    end

    it 'should return empty list with searched asg is not found' do

      asg_name = "asg"
      asg_list = [asg_name]

      aws_response = RecursiveOpenStruct.new({auto_scaling_groups: []}, recurse_over_arrays: true)

      allow(asg_client).to receive(:describe_auto_scaling_groups)
                                                              .with({
                                                                        auto_scaling_group_names: asg_list,
                                                                    }).and_return(aws_response)

      asgs = subject.describe_asg_by_name(name: asg_name)

      expect(asgs.length).to eq(0)
      expect(asgs).to eq([])

    end

  end

  describe '#list' do

    it 'should list asgs with default max records when there is no next token' do

      asg_name = "asg"

      aws_response = get_aws_response({auto_scaling_groups: [
          {auto_scaling_group_name: asg_name}
      ]})

      allow(asg_client).to receive(:describe_auto_scaling_groups)
                                                              .with({
                                                                        max_records: 100,
                                                                    }).and_return(aws_response)

      asgs = subject.list

      expect(asgs.length).to eq(1)
    end

    it 'should list asgs with default max records and use next token attribute from response' do

      asg_name = "asg"
      next_token = "abc"
      max_records = 100
      asg_list = [asg_name]

      aws_response_1 = get_aws_response({auto_scaling_groups: [
          {auto_scaling_group_name: asg_name},
      ], next_token: next_token})

      aws_response_2 = get_aws_response({auto_scaling_groups: [
          {auto_scaling_group_name: asg_name}
      ]})

      allow(asg_client).to receive(:describe_auto_scaling_groups)
                                                      .with({
                                                                max_records: max_records,
                                                            }).and_return(aws_response_1)

      expect(subject).to receive(:get_asgs)
                                         .with(next_token: next_token, max_records: max_records)
                                         .and_return(aws_response_2)

      asgs = subject.list

      expect(asgs.length).to eq(2)
    end

  end

end
