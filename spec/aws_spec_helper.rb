require 'aws_pocketknife'
require 'recursive-open-struct'

def get_aws_response(object)
  RecursiveOpenStruct.new(object, recurse_over_arrays: true)
end

# stub aws describe_image call
# .state #=> String, one of "pending", "available", "invalid", "deregistered", "transient", "failed", "error"
def get_image_response(image_id: '', date: '2040-12-16 11:57:42 +1100', state: AwsPocketknife::Ec2::STATE_PENDING)
  if image_id.empty?
    return nil
  else
    get_aws_response({image_id: image_id, state: state, creation_date: date,
                      block_device_mappings: [
                          {ebs: {snapshot_id: snapshot_id}}
                      ]
                     })
  end

end

def get_instance_response(instance_id: '')
  get_aws_response({instance_id: instance_id})
end