$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'aws_pocketknife'
require 'webmock/rspec'
require 'recursive-open-struct'

def capture_stdout(&blk)
  old = $stdout
  $stdout = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stdout = old
end

def get_aws_response(object)
  RecursiveOpenStruct.new(object, recurse_over_arrays: true)
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