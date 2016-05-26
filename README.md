![Build Status](https://travis-ci.org/MYOB-Technology/aws_pocketknife.svg?branch=master)

# AwsPocketknife

Rake tasks to make aws administration a little bit easier and quicker from the command line than using the aws console. 
These rake tasks are also handy if you have multiple aws accounts to manage, since you can't have multiple tabs open for
different accounts.

The aws cli allows you to setup profiles for each account. (see http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles) 
After creating the profiles, you just export the environment variable AWS_PROFILE to specify the account you wish to use.

## Setup local environment

To run and/or test the gem locally you need to export the following environment variables

```
set AWS_ACCESS_KEY_ID=[YOUR AWS ACCESS KEY]
set AWS_REGION=ap-southeast-2
set AWS_SECRET_ACCESS_KEY=[YOUR AWS SECRET KEY]
set SSL_CERT_FILE=[PATH TO CRT FILE]
```

## Windows

    - Install ruby 2.2.x. in your local environment (http://rubyinstaller.org/downloads/)
    - Download Development kit for Ruby 2.0 and above (same link as above) and extract it somewhere permanent. Then cd to it, run ruby dk.rb init and ruby dk.rb install to bind it to ruby installations in your path.
    
## Linux

Install rvm, then install ruby and create a gemset.

```
rvm install ruby-2.2.3
rvm use ruby-2.2.3
rvm gemset create aws-pocketknife
rvm gemset use aws-pocketknife

gem install bundler

bundle install
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aws_pocketknife'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aws_pocketknife

## Usage

Type bundle exec rake -vT to see the list of available tasks



## Development


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/aws_pocketknife. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

