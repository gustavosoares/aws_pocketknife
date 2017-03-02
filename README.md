![Build Status](https://travis-ci.org/MYOB-Technology/aws_pocketknife.svg?branch=master)
[![Gem Version](https://badge.fury.io/rb/aws_pocketknife.svg)](https://badge.fury.io/rb/aws_pocketknife)

# Aws Pocketknife

## Why?

Have you ever find yourself going through the aws cli documentation page over and over again just to remember the right syntax or argument(s) for that command that you wanna run? Do you feel that you are more productive from the command line? Are you tired of having to open private browser windows or even a different browser to work with multiple aws accounts?

## What?

Command line tools to make aws administration a little bit easier and faster than using the aws console. It also helps to script some AWS tasks such as cleaning up
old AMIs along its snapshots or cleaning up manual RDS snapshots or even creating a manual snapshot for a particular RDS.

These commands are also handy if you have multiple aws accounts to manage, since you can't have multiple tabs open for
different accounts in a web browser. The only way would be to use diffente browsers or open incognito windows.

The aws cli allows you to setup profiles for each account. (see http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles) 
After creating the profiles, you just export the environment variable AWS_PROFILE to specify the account you wish to use.

## Installation

Add this line to your application's Gemfile:

```
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

### AMI

```
$ pocketknife ami
Commands:
  pocketknife ami clean AMI_NAME_PATTERN DAYS --dry_run  # Given a name or filter (i.e, test-*), this command will delete all matched AMIs (and associated snapshots) with creation time lower than DAYS.
  pocketknife ami help [COMMAND]                         # Describe subcommands or one specific subcommand
  pocketknife ami share IMAGE_ID ACCOUNT_ID              # share the IMAGE_ID with the specified ACCOUNT_ID                 # stop ec2 instance

```

### RDS

```
$ pocketknife rds
Commands:
  pocketknife rds help [COMMAND]               # Describe subcommands or one specific subcommand
  pocketknife rds snapshot SUBCOMMAND ...ARGS  # snapshot command lines

```

### Elastic beanstalk

```
$ pocketknife eb
Commands:
  pocketknife eb desc ENVIRONMENT_NAME  # describe environment name
  pocketknife eb help [COMMAND]         # Describe subcommands or one specific subcommand
  pocketknife eb list                   # list environments
  pocketknife eb vars NAME              # list environment variables for the specified elastic beanstalk environment name
```

### Route53

```
$ pocketknife route53
Commands:
  pocketknife route53 describe_hosted_zone HOSTED_ZONE                                                                              # describe hosted zone
  pocketknife route53 get_record HOSTED_ZONE RECORD_NAME --record_type                                                              # Get record for hosted zone.
  pocketknife route53 help [COMMAND]                                                                                                # Describe subcommands or one specific subcommand
  pocketknife route53 list                                                                                                          # list hosted zones
  pocketknife route53 list_records HOSTED_ZONE                                                                                      # list records for hosted zone
  pocketknife route53 update_record HOSTED_ZONE ORIGIN_DNS_NAME DESTINY_RECORD_NAME DESTINY_HOSTED_ZONE RECORD_TYPE (default to A)  # Update a dns record from an existing dns entry.
```

### ECS

```
Commands:
  pocketknife ecs help [COMMAND]              # Describe subcommands or one specific subcommand
  pocketknife ecs list_clusters               # list clustes
  pocketknife ecs list_services CLUSTER_NAME  # list services for a given cluster
```

## Development


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MYOB-Technology/aws_pocketknife. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

   * Fork it
   * Make you changes
   * Submit a pull request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

