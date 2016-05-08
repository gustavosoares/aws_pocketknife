require 'spec_helper'
require 'aws_pocketknife'


describe AwsPocketknife do
  it 'has a version number' do
    expect(AwsPocketknife::VERSION).not_to be nil
  end

  it 'should use default region when env var is unset' do
    ENV['AWS_REGION'] = ""
    expect(AwsPocketknife::AWS_REGION).to eq("ap-southeast-2")
  end

end
