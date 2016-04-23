require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/route53'

describe AwsPocketknife::Route53 do

  it 'should get hosted zone id' do
    hosted_zone = "/hostedzone/Z1DMTCYVMNIBR8"
    expect(AwsPocketknife::Route53.get_hosted_zone_id(hosted_zone: hosted_zone)).to eq("Z1DMTCYVMNIBR8")
  end

  it 'should list hosted zones' do
    expect_any_instance_of(Aws::Route53::Client).to receive(:list_hosted_zones)
    AwsPocketknife::Route53.list_hosted_zones
  end


end