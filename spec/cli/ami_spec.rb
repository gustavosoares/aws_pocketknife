require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/cli/ami'

describe AwsPocketknife::Cli::Ami do

  describe '#clean' do

    let(:ami_name_pattern) {'test-*'}
    let(:days) { '15' }
    let(:dry_run) { true }

    it 'should call clean_ami with dry_run true' do


      allow(AwsPocketknife::Ec2).to receive(:clean_ami).with(ami_name_pattern: ami_name_pattern,
                                                             days: days,
                                                             dry_run: dry_run)
      expect(AwsPocketknife::Ec2).to receive(:clean_ami).with(ami_name_pattern: ami_name_pattern,
                                                             days: days,
                                                             dry_run: dry_run)

      subject.clean ami_name_pattern, days

    end

    it 'should call clean_ami with dry_run false' do

      dry_run = false

      allow(AwsPocketknife::Ec2).to receive(:clean_ami).with(ami_name_pattern: ami_name_pattern,
                                                             days: days,
                                                             dry_run: dry_run)
      expect(AwsPocketknife::Ec2).to receive(:clean_ami).with(ami_name_pattern: ami_name_pattern,
                                                              days: days,
                                                              dry_run: dry_run)

      subject.options = {:dry_run => dry_run}
      subject.clean ami_name_pattern, days

    end

  end

  describe '#share' do

    let(:image_id) {'i-1'}
    let(:account_id) {'12345678'}

    it 'should call share with right arguments' do
      allow(AwsPocketknife::Ec2).to receive(:share_ami).with(image_id: image_id, user_id: account_id)
      expect(AwsPocketknife::Ec2).to receive(:share_ami).with(image_id: image_id, user_id: account_id)

      subject.share image_id, account_id
    end
  end

end
