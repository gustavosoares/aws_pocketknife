require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/asg'

describe AwsPocketknife::Asg do

  describe '#describe_asg_by_name' do

    it 'should return list with the searched asg' do

      asg_name = "asg"
      asg_list = [asg_name]

      aws_response = RecursiveOpenStruct.new({auto_scaling_groups: [
          {auto_scaling_group_name: asg_name}
      ]}, recurse_over_arrays: true)

      expect_any_instance_of(Aws::AutoScaling::Client).to receive(:describe_auto_scaling_groups)
                                                      .with({
                                                                auto_scaling_group_names: asg_list,
                                                            }).and_return(aws_response)

      asgs = AwsPocketknife::Asg.describe_asg_by_name(name: asg_name)

      expect(asgs.length).to eq(1)
      expect(asgs[0].auto_scaling_group_name).to eq(asg_name)

    end

    it 'should return empty list with searched asg is not found' do

      asg_name = "asg"
      asg_list = [asg_name]

      aws_response = RecursiveOpenStruct.new({auto_scaling_groups: []}, recurse_over_arrays: true)

      expect_any_instance_of(Aws::AutoScaling::Client).to receive(:describe_auto_scaling_groups)
                                                              .with({
                                                                        auto_scaling_group_names: asg_list,
                                                                    }).and_return(aws_response)

      asgs = AwsPocketknife::Asg.describe_asg_by_name(name: asg_name)

      expect(asgs.length).to eq(0)
      expect(asgs).to eq([])

    end

  end

  describe '#list' do

    it 'should list asgs with default max records when there is no next token' do

      asg_name = "asg"

      aws_response = RecursiveOpenStruct.new({auto_scaling_groups: [
          {auto_scaling_group_name: asg_name}
      ]}, recurse_over_arrays: true)

      expect_any_instance_of(Aws::AutoScaling::Client).to receive(:describe_auto_scaling_groups)
                                                              .with({
                                                                        max_records: 100,
                                                                    }).and_return(aws_response)

      asgs = AwsPocketknife::Asg.list

      expect(asgs.length).to eq(1)
    end

    it 'should list asgs with default max records and use next token in th response' do

      asg_name = "asg"
      next_token = "abc"
      max_records = 100
      asg_list = [asg_name]

      aws_response_1 = RecursiveOpenStruct.new({auto_scaling_groups: [
          {auto_scaling_group_name: asg_name}
      ], next_token: next_token}, recurse_over_arrays: true)

      aws_response_2 = RecursiveOpenStruct.new({auto_scaling_groups: [
          {auto_scaling_group_name: asg_name}
      ]}, recurse_over_arrays: true)

      expect_any_instance_of(Aws::AutoScaling::Client).to receive(:describe_auto_scaling_groups)
                                                      .with({
                                                                max_records: max_records,
                                                            }).and_return(aws_response_1)

      expect(AwsPocketknife::Asg).to receive(:get_asgs)
                                         .with(next_token: next_token, max_records: max_records)
                                         .and_return(aws_response_2)

      asgs = AwsPocketknife::Asg.list

      expect(asgs.length).to eq(2)
    end

  end

end
