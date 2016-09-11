$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'aws_pocketknife'
require 'webmock/rspec'
require_relative 'aws_spec_helper'

def capture_stdout(&blk)
  old = $stdout
  $stdout = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stdout = old
end

def capture(stream)
  begin
    stream = stream.to_s
    eval "$#{stream} = StringIO.new"
    yield
    result = eval("$#{stream}").string
  ensure
    eval("$#{stream} = #{stream.upcase}")
  end

  result
end

def capture_stderr(&blk)
  old = $stderr
  $stderr = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stderr = old
end

RSpec.configure do |config|

  config.mock_with :rspec
  Aws.config.update(stub_responses: true)

end