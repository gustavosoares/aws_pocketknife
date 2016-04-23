require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/route53'

describe '#get_hosted_zone_id' do

  it 'shoudl get hosted zone id' do

    hosted_zone = "/hostedzone/Z1DMTCYVMNIBR8"

    expect(AwsPocketknife::Route53.get_hosted_zone_id(hosted_zone: hosted_zone)).to eq("Z1DMTCYVMNIBR8")
  end



end