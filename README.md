![Build Status](https://travis-ci.org/MYOB-Technology/aws_pocketknife.svg?branch=master)

# Aws Pocketknife

Command line tools to make aws administration a little bit easier and quicker than using the aws console. 
These commands are also handy if you have multiple aws accounts to manage, since you can't have multiple tabs open for
different accounts in a web browser. The only way would be to use diffente browsers or open incognito windows.

The aws cli allows you to setup profiles for each account. (see http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles) 
After creating the profiles, you just export the environment variable AWS_PROFILE to specify the account you wish to use.

## Setup local environment

To run and/or test the gem locally you need to export the following environment variables

### Windows

    - Install ruby 2.2.x. in your local environment (http://rubyinstaller.org/downloads/)
    - Download Development kit for Ruby 2.0 and above (same link as above) and extract it somewhere permanent. Then cd to it, run ruby dk.rb init and ruby dk.rb install to bind it to ruby installations in your path.
    
```
set AWS_ACCESS_KEY_ID=[YOUR AWS ACCESS KEY]
set AWS_REGION=ap-southeast-2
set AWS_SECRET_ACCESS_KEY=[YOUR AWS SECRET KEY]
set SSL_CERT_FILE=[PATH TO CRT FILE]
```

    
### Linux

Install rvm, then install ruby and create a gemset.

```
rvm install ruby-2.2.3
rvm use ruby-2.2.3
rvm gemset create aws-pocketknife
rvm gemset use aws-pocketknife

gem install bundler

bundle install

export AWS_REGION=ap-southeast-2
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export SSL_CERT_FILE=certs/ca-bundle.crt
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aws_pocketknife'
```

And then execute:

    $ bundle

Or install it yourself as:

```
git clone https://github.com/MYOB-Technology/aws_pocketknife.git
bundle install
rake install
```

## Usage

Use the pocketknife that get installed

```
$ pocketknife 
Commands:
  pocketknife ami SUBCOMMAND ...ARGS      # ami command lines
  pocketknife eb SUBCOMMAND ...ARGS       # elastic beanstalk command lines
  pocketknife ec2 SUBCOMMAND ...ARGS      # ec2 command lines
  pocketknife help [COMMAND]              # Describe available commands or one specific command
  pocketknife route53 SUBCOMMAND ...ARGS  # route53 command lines

```

### EC2

```
$ pocketknife ec2 help
Commands:
  pocketknife ec2 describe_instance_by_id INSTANCE_ID  # find instances by id.
  pocketknife ec2 find_instances_by_name NAME          # find instances by name. (You can filter by adding *) 
  pocketknife ec2 get_windows_password INSTANCE_ID     # get windows password.
  pocketknife ec2 help [COMMAND]                       # Describe subcommands or one specific subcommand
  pocketknife ec2 start INSTANCE_ID                    # start ec2 instance
  pocketknife ec2 stop INSTANCE_ID                     # stop ec2 instance

```

## Development


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MYOB-Technology/aws_pocketknife. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

